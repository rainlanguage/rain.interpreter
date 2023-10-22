// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibDataContract, DataContractMemoryContainer} from "rain.datacontract/lib/LibDataContract.sol";
import "rain.erc1820/lib/LibIERC1820.sol";

import "../interface/unstable/IExpressionDeployerV2.sol";
import "../interface/unstable/IDebugExpressionDeployerV2.sol";
import "../interface/unstable/IDebugInterpreterV2.sol";
import "../interface/unstable/IParserV1.sol";

import {LibIntegrityCheckNP} from "../lib/integrity/LibIntegrityCheckNP.sol";
import "../lib/state/LibInterpreterStateDataContractNP.sol";
import "../lib/op/LibAllStandardOpsNP.sol";
import {LibParse, LibParseMeta, AuthoringMeta} from "../lib/parse/LibParse.sol";

import {RainterpreterNP, OPCODE_FUNCTION_POINTERS, INTERPRETER_BYTECODE_HASH} from "./RainterpreterNP.sol";

/// @dev Thrown when the pointers known to the expression deployer DO NOT match
/// the interpreter it is constructed for. This WILL cause undefined expression
/// behaviour so MUST REVERT.
/// @param actualPointers The actual function pointers found at the interpreter
/// address upon construction.
error UnexpectedPointers(bytes actualPointers);

/// Thrown when the `RainterpreterExpressionDeployer` is constructed with unknown
/// interpreter bytecode.
/// @param expectedBytecodeHash The bytecode hash that was expected at the
/// interpreter address upon construction.
/// @param actualBytecodeHash The bytecode hash that was found at the interpreter
/// address upon construction.
error UnexpectedInterpreterBytecodeHash(bytes32 expectedBytecodeHash, bytes32 actualBytecodeHash);

/// Thrown when the `Rainterpreter` is constructed with unknown store bytecode.
/// @param expectedBytecodeHash The bytecode hash that was expected at the store
/// address upon construction.
/// @param actualBytecodeHash The bytecode hash that was found at the store
/// address upon construction.
error UnexpectedStoreBytecodeHash(bytes32 expectedBytecodeHash, bytes32 actualBytecodeHash);

/// Thrown when the `Rainterpreter` is constructed with unknown meta.
/// @param expectedConstructionMetaHash The meta hash that was expected upon
/// construction.
/// @param actualConstructionMetaHash The meta hash that was found upon
/// construction.
error UnexpectedConstructionMetaHash(bytes32 expectedConstructionMetaHash, bytes32 actualConstructionMetaHash);

/// @dev The function pointers for the integrity check fns.
bytes constant INTEGRITY_FUNCTION_POINTERS =
    hex"1811188b18f218fb19771981198b198b19771977197719771977199519b719e1198b1995198b198b1a0318f2198b198b1a0d1a0d198b18f218f21a0d1a0d1a0d1a0d1a0d1a0d1a0d1a0d1a0d1a0d1a0d1a0d18f21a241a2e1a2e";

/// @dev Hash of the known store bytecode.
bytes32 constant STORE_BYTECODE_HASH = bytes32(0xd6130168250d3957ae34f8026c2bdbd7e21d35bb202e8540a9b3abcbc232ddb6);

/// @dev Hash of the known authoring meta.
bytes32 constant AUTHORING_META_HASH = bytes32(0xb16774f25e8070712c15ff6f551827d0c112a45d880c2aa8b63b1c2f89a13f7b);

/// @dev Hash of the known construction meta.
bytes32 constant CONSTRUCTION_META_HASH = bytes32(0xe3035aa2e0beed9803be8737be4058602335fcc2ebdb5fb2c3142af41964a72b);

bytes constant PARSE_META =
    hex"013e002a2208b2001080a0102400000302920481840880062e1240044004200204001100c332a00a00d8ac552500df95d8070038ef251e008683ce050031dbd003208596c41f00048a5a16008b6c060d00f39c0626006806f922002870ea21002cb51d1d007ed6ee1c40ce75301000ab79f01400862cf02300f82ccc2b102116660f10a5c7372c10d76cb417003e0bda1b40dce01d2700ec21ff1200121cd20010f7a0481500d0147329002655b3042036bc2d01100b23821a3074ca4013006c16580b00afd55a0e1097af9a02006ab30728009ea40f090008512f2a00a2f61c24002b93430c00e043780800cb7812060096888b190069940c20000c6d8d18002584c4";

/// All config required to construct a `Rainterpreter`.
/// @param interpreter The `IInterpreterV1` to use for evaluation. MUST match
/// known bytecode.
/// @param store The `IInterpreterStoreV1`. MUST match known bytecode.
/// @param meta Contract meta for tooling.
struct RainterpreterExpressionDeployerConstructionConfig {
    address interpreter;
    address store;
    bytes meta;
}

/// @title RainterpreterExpressionDeployer
/// @notice !!!EXPERIMENTAL!!! This is the deployer for the RainterpreterNP
/// interpreter. Notably includes onchain parsing/compiling of expressions from
/// Rainlang strings.
contract RainterpreterExpressionDeployerNP is IExpressionDeployerV2, IDebugExpressionDeployerV2, IParserV1, ERC165 {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256[];

    /// The config of the deployed expression including uncompiled sources. Will
    /// only be emitted after the config passes the integrity check.
    /// @param sender The caller of `deployExpression`.
    /// @param bytecode As per `IExpressionDeployerV2`.
    /// @param constants As per `IExpressionDeployerV2`.
    /// @param minOutputs As per `IExpressionDeployerV2`.
    event NewExpression(address sender, bytes bytecode, uint256[] constants, uint256[] minOutputs);

    /// The address of the deployed expression. Will only be emitted once the
    /// expression can be loaded and deserialized into an evaluable interpreter
    /// state.
    /// @param sender The caller of `deployExpression`.
    /// @param expression The address of the deployed expression.
    event ExpressionAddress(address sender, address expression);

    /// The interpreter with known bytecode that this deployer is constructed
    /// for.
    IInterpreterV1 public immutable iInterpreter;
    /// The store with known bytecode that this deployer is constructed for.
    IInterpreterStoreV1 public immutable iStore;

    constructor(RainterpreterExpressionDeployerConstructionConfig memory config) {
        // Set the immutables.
        IInterpreterV1 interpreter = IInterpreterV1(config.interpreter);
        IInterpreterStoreV1 store = IInterpreterStoreV1(config.store);
        iInterpreter = interpreter;
        iStore = store;

        /// This IS a security check. This prevents someone making an exact
        /// bytecode copy of the interpreter and shipping different meta for
        /// the copy to lie about what each op does in the interpreter.
        bytes32 constructionMetaHash = keccak256(config.meta);
        if (constructionMetaHash != CONSTRUCTION_META_HASH) {
            revert UnexpectedConstructionMetaHash(CONSTRUCTION_META_HASH, constructionMetaHash);
        }

        // Guard against serializing incorrect function pointers, which would
        // cause undefined runtime behaviour for corrupted opcodes.
        bytes memory functionPointers = interpreter.functionPointers();
        if (keccak256(functionPointers) != keccak256(OPCODE_FUNCTION_POINTERS)) {
            revert UnexpectedPointers(functionPointers);
        }
        // Guard against an interpreter with unknown bytecode.
        bytes32 interpreterHash;
        assembly ("memory-safe") {
            interpreterHash := extcodehash(interpreter)
        }
        if (interpreterHash != INTERPRETER_BYTECODE_HASH) {
            /// THIS IS NOT A SECURITY CHECK. IT IS AN INTEGRITY CHECK TO PREVENT
            /// HONEST MISTAKES.
            revert UnexpectedInterpreterBytecodeHash(INTERPRETER_BYTECODE_HASH, interpreterHash);
        }

        // Guard against an store with unknown bytecode.
        bytes32 storeHash;
        assembly ("memory-safe") {
            storeHash := extcodehash(store)
        }
        if (storeHash != STORE_BYTECODE_HASH) {
            /// THIS IS NOT A SECURITY CHECK. IT IS AN INTEGRITY CHECK TO PREVENT
            /// HONEST MISTAKES.
            revert UnexpectedStoreBytecodeHash(STORE_BYTECODE_HASH, storeHash);
        }

        emit DISpair(msg.sender, address(this), address(interpreter), address(store), config.meta);

        // Register the interface for the deployer.
        // We have to check that the 1820 registry has bytecode at the address
        // before we can register the interface. We can't assume that the chain
        // we are deploying to has 1820 deployed.
        if (address(IERC1820_REGISTRY).code.length > 0) {
            IERC1820_REGISTRY.setInterfaceImplementer(
                address(this), IERC1820_REGISTRY.interfaceHash(IERC1820_NAME_IEXPRESSION_DEPLOYER_V2), address(this)
            );
        }
    }

    // @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IExpressionDeployerV2).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IParserV1
    function authoringMetaHash() external pure virtual override returns (bytes32) {
        return AUTHORING_META_HASH;
    }

    /// @inheritdoc IParserV1
    function buildParseMeta(bytes memory authoringMeta) external pure virtual override returns (bytes memory) {
        bytes32 inputAuthoringMetaHash = keccak256(authoringMeta);
        if (inputAuthoringMetaHash != AUTHORING_META_HASH) {
            revert AuthoringMetaHashMismatch(AUTHORING_META_HASH, inputAuthoringMetaHash);
        }
        AuthoringMeta[] memory words = abi.decode(authoringMeta, (AuthoringMeta[]));
        return LibParseMeta.buildParseMeta(words, 2);
    }

    /// @inheritdoc IParserV1
    function parseMeta() public pure virtual override returns (bytes memory) {
        return PARSE_META;
    }

    /// @inheritdoc IParserV1
    function parse(bytes memory data) external pure virtual override returns (bytes memory, uint256[] memory) {
        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return LibParse.parse(data, parseMeta());
    }

    /// @inheritdoc IExpressionDeployerV2
    function deployExpression(bytes memory bytecode, uint256[] memory constants, uint256[] memory minOutputs)
        external
        returns (IInterpreterV1, IInterpreterStoreV1, address)
    {
        integrityCheck(bytecode, constants, minOutputs);

        emit NewExpression(msg.sender, bytecode, constants, minOutputs);

        (DataContractMemoryContainer container, Pointer pointer) =
            LibDataContract.newContainer(LibInterpreterStateDataContractNP.serializeSizeNP(bytecode, constants));

        // Serialize the state config into bytes that can be deserialized later
        // by the interpreter.
        LibInterpreterStateDataContractNP.unsafeSerializeNP(pointer, bytecode, constants);

        // Deploy the serialized expression onchain.
        address expression = LibDataContract.write(container);

        // Emit and return the address of the deployed expression.
        emit ExpressionAddress(msg.sender, expression);

        return (iInterpreter, iStore, expression);
    }

    /// @inheritdoc IDebugExpressionDeployerV2
    function integrityCheck(bytes memory bytecode, uint256[] memory constants, uint256[] memory minOutputs)
        public
        view
    {
        LibIntegrityCheckNP.integrityCheck(INTEGRITY_FUNCTION_POINTERS, bytecode, constants, minOutputs);
    }

    /// Defines all the function pointers to integrity checks. This is the
    /// expression deployer's equivalent of the opcode function pointers and
    /// follows a near identical dispatch process. These are never compiled into
    /// source and are instead indexed into directly by the integrity check. The
    /// indexing into integrity pointers (which has an out of bounds check) is a
    /// proxy for enforcing that all opcode pointers exist at runtime, so the
    /// length of the integrity pointers MUST match the length of opcode function
    /// pointers. This function is `virtual` so that it can be overridden
    /// pairwise with overrides to `functionPointers` on `Rainterpreter`.
    /// @return The list of integrity function pointers.
    function integrityFunctionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.integrityFunctionPointers();
    }
}
