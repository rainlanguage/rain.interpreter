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
/// @param actualBytecodeHash The bytecode hash that was found at the interpreter
/// address upon construction.
error UnexpectedInterpreterBytecodeHash(bytes32 actualBytecodeHash);

/// Thrown when the `Rainterpreter` is constructed with unknown store bytecode.
/// @param actualBytecodeHash The bytecode hash that was found at the store
/// address upon construction.
error UnexpectedStoreBytecodeHash(bytes32 actualBytecodeHash);

/// Thrown when the `Rainterpreter` is constructed with unknown meta.
error UnexpectedConstructionMetaHash(bytes32 actualOpMeta);

/// @dev The function pointers for the integrity check fns.
bytes constant INTEGRITY_FUNCTION_POINTERS =
    hex"17f7187118d81954195e195419541954195419541968198a19b419d6196819d619d619e019ea19d619d619f319f319d619ea19ea19f319f319f319f319f319f319f319f319f319f319f319f319ea1a0a1a141a14";

/// @dev Hash of the known store bytecode.
bytes32 constant STORE_BYTECODE_HASH = bytes32(0xd6130168250d3957ae34f8026c2bdbd7e21d35bb202e8540a9b3abcbc232ddb6);

/// @dev Hash of the known authoring meta.
bytes32 constant AUTHORING_META_HASH = bytes32(0xa2c386cc7ced237aa034c135d204e1fe6690e8c7d7be07bde19dac02b1e607d2);

/// @dev Hash of the known construction meta.
bytes32 constant CONSTRUCTION_META_HASH = bytes32(0xc5f88c7b71759d7844f415eaca8194d7a98491f996e81d80672dd73ee1460159);

bytes constant PARSE_META =
    hex"010f00c20804b001180500014114144080040101008082020092020040a100148024173082aae700108f616d2300e3c6181c0025fdfc2200a1cef21d00e7762b2600229a7e0c103e260a0700ce656d0320f12be70d0035f0270a00da2bcc15001874cb0800319e1e2400c17cd61200d0684c06007c4b9520000859681f00ce62340e0021f48513009046c21a008710c504002c340816002eaa701840b3357a1b00e6d342022018b0960900f0dfe2050080a95b0f004e5b480b107012321940438b4b25008a3266291043e2f6011056328a1e00ec53cd10006e69fa1100ac8cde2700f2c1681400b8577628103fa0c82100c6ff51";

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
            revert UnexpectedInterpreterBytecodeHash(interpreterHash);
        }

        // Guard against an store with unknown bytecode.
        bytes32 storeHash;
        assembly ("memory-safe") {
            storeHash := extcodehash(store)
        }
        if (storeHash != STORE_BYTECODE_HASH) {
            /// THIS IS NOT A SECURITY CHECK. IT IS AN INTEGRITY CHECK TO PREVENT
            /// HONEST MISTAKES.
            revert UnexpectedStoreBytecodeHash(storeHash);
        }

        /// This IS a security check. This prevents someone making an exact
        /// bytecode copy of the interpreter and shipping different meta for
        /// the copy to lie about what each op does in the interpreter.
        bytes32 constructionMetaHash = keccak256(config.meta);
        if (constructionMetaHash != CONSTRUCTION_META_HASH) {
            revert UnexpectedConstructionMetaHash(constructionMetaHash);
        }

        emit DISpair(msg.sender, address(this), address(interpreter), address(store), config.meta);

        IERC1820_REGISTRY.setInterfaceImplementer(
            address(this), IERC1820_REGISTRY.interfaceHash(IERC1820_NAME_IEXPRESSION_DEPLOYER_V2), address(this)
        );
    }

    // @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId_) public view virtual override returns (bool) {
        return interfaceId_ == type(IExpressionDeployerV2).interfaceId || interfaceId_ == type(IERC165).interfaceId;
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
