// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ERC165, IERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibDataContract, DataContractMemoryContainer} from "rain.datacontract/lib/LibDataContract.sol";
import {IERC1820_REGISTRY} from "rain.erc1820/lib/LibIERC1820.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {
    UnexpectedConstructionMetaHash,
    UnexpectedInterpreterBytecodeHash,
    UnexpectedStoreBytecodeHash,
    UnexpectedParserBytecodeHash,
    UnexpectedPointers
} from "../error/ErrDeploy.sol";
import {
    IExpressionDeployerV3,
    IERC1820_NAME_IEXPRESSION_DEPLOYER_V3
} from "../interface/unstable/IExpressionDeployerV3.sol";
import {IParserV1} from "../interface/IParserV1.sol";
import {IInterpreterV2} from "../interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "../interface/IInterpreterStoreV1.sol";

import {LibIntegrityCheckNP} from "../lib/integrity/LibIntegrityCheckNP.sol";
import {LibInterpreterStateDataContractNP} from "../lib/state/LibInterpreterStateDataContractNP.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {LibParse, LibParseMeta} from "../lib/parse/LibParse.sol";
import {RainterpreterNPE2, INTERPRETER_BYTECODE_HASH} from "./RainterpreterNPE2.sol";
import {PARSER_BYTECODE_HASH} from "./RainterpreterParserNPE2.sol";
import {STORE_BYTECODE_HASH} from "./RainterpreterStoreNPE2.sol";

/// @dev The function pointers for the integrity check fns.
bytes constant INTEGRITY_FUNCTION_POINTERS =
    hex"0b210b9f0c0c0d860d900d900d9a0da30dbe0e640e640ec00f3a0f470d900d9a0d900d900d9a0d860d860d860d860d860f510f760f900d900f510d900d900f470d9a0d900d900d900d9a0f9a0d9a0d9a0d9a0d9a0d900d9a0d9a0d9a0d9a0f9a0d900d900d900d9a0d9a0d9a0d900d9a0f9a0f9a0f9a0f9a0f9a0f9a0f9a0f9a0f9a0f9a0f9a0f9a0d9a0f90";

/// @dev Hash of the known construction meta.
bytes32 constant CONSTRUCTION_META_HASH = bytes32(0x53a35a974cd1943fb47046f985bf919b2a9594a5af3bb46277319d4f68acdc8e);

/// All config required to construct a `RainterpreterNPE2`.
/// @param interpreter The `IInterpreterV2` to use for evaluation. MUST match
/// known bytecode.
/// @param store The `IInterpreterStoreV2`. MUST match known bytecode.
/// @param meta Contract meta for tooling.
struct RainterpreterExpressionDeployerNPE2ConstructionConfig {
    address interpreter;
    address store;
    address parser;
    bytes meta;
}

/// @title RainterpreterExpressionDeployerNPE2
contract RainterpreterExpressionDeployerNPE2 is IExpressionDeployerV3, ERC165 {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256[];

    /// The interpreter with known bytecode that this deployer is constructed
    /// for.
    IInterpreterV2 public immutable iInterpreter;
    /// The store with known bytecode that this deployer is constructed for.
    IInterpreterStoreV1 public immutable iStore;
    IParserV1 public immutable iParser;

    constructor(RainterpreterExpressionDeployerNPE2ConstructionConfig memory config) {
        // Set the immutables.
        IInterpreterV2 interpreter = IInterpreterV2(config.interpreter);
        IInterpreterStoreV1 store = IInterpreterStoreV1(config.store);
        IParserV1 parser = IParserV1(config.parser);

        iInterpreter = interpreter;
        iStore = store;
        iParser = parser;

        /// This IS a security check. This prevents someone making an exact
        /// bytecode copy of the interpreter and shipping different meta for
        /// the copy to lie about what each op does in the interpreter.
        bytes32 constructionMetaHash = keccak256(config.meta);
        if (constructionMetaHash != expectedConstructionMetaHash()) {
            revert UnexpectedConstructionMetaHash(expectedConstructionMetaHash(), constructionMetaHash);
        }

        // Guard against an interpreter with unknown bytecode.
        bytes32 interpreterHash;
        assembly ("memory-safe") {
            interpreterHash := extcodehash(interpreter)
        }
        if (interpreterHash != expectedInterpreterBytecodeHash()) {
            revert UnexpectedInterpreterBytecodeHash(expectedInterpreterBytecodeHash(), interpreterHash);
        }

        // Guard against an store with unknown bytecode.
        bytes32 storeHash;
        assembly ("memory-safe") {
            storeHash := extcodehash(store)
        }
        if (storeHash != expectedStoreBytecodeHash()) {
            revert UnexpectedStoreBytecodeHash(expectedStoreBytecodeHash(), storeHash);
        }

        // Guard against a parser with unknown bytecode.
        bytes32 parserHash;
        assembly ("memory-safe") {
            parserHash := extcodehash(parser)
        }
        if (parserHash != expectedParserBytecodeHash()) {
            revert UnexpectedParserBytecodeHash(expectedParserBytecodeHash(), parserHash);
        }

        // Emit the DISPair.
        // The parser is this contract as it implements both
        // `IExpressionDeployerV3` and `IParserV1`.
        emit DISPair(msg.sender, address(interpreter), address(store), address(parser), config.meta);

        // Register the interface for the deployer.
        // We have to check that the 1820 registry has bytecode at the address
        // before we can register the interface. We can't assume that the chain
        // we are deploying to has 1820 deployed.
        if (address(IERC1820_REGISTRY).code.length > 0) {
            IERC1820_REGISTRY.setInterfaceImplementer(
                address(this), IERC1820_REGISTRY.interfaceHash(IERC1820_NAME_IEXPRESSION_DEPLOYER_V3), address(this)
            );
        }
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IExpressionDeployerV3).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IExpressionDeployerV3
    function deployExpression2(bytes memory bytecode, uint256[] memory constants)
        external
        virtual
        returns (IInterpreterV2, IInterpreterStoreV1, address, bytes memory)
    {
        bytes memory io = LibIntegrityCheckNP.integrityCheck2(INTEGRITY_FUNCTION_POINTERS, bytecode, constants);

        emit NewExpression(msg.sender, bytecode, constants);

        (DataContractMemoryContainer container, Pointer pointer) =
            LibDataContract.newContainer(LibInterpreterStateDataContractNP.serializeSizeNP(bytecode, constants));

        // Serialize the state config into bytes that can be deserialized later
        // by the interpreter.
        LibInterpreterStateDataContractNP.unsafeSerializeNP(pointer, bytecode, constants);

        // Deploy the serialized expression onchain.
        address expression = LibDataContract.write(container);

        // Emit and return the address of the deployed expression.
        emit DeployedExpression(msg.sender, iInterpreter, iStore, expression, io);

        return (iInterpreter, iStore, expression, io);
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

    /// Virtual function to return the expected construction meta hash.
    /// Public so that external tooling can read it, although this should be
    /// considered deprecated. The intended workflow is that tooling uses a real
    /// evm to deploy the full dispair and reads the hashes from errors using a
    /// trail/error approach until a full dispair is deployed.
    function expectedConstructionMetaHash() public pure virtual returns (bytes32) {
        return CONSTRUCTION_META_HASH;
    }

    /// Virtual function to return the expected interpreter bytecode hash.
    function expectedInterpreterBytecodeHash() internal pure virtual returns (bytes32) {
        return INTERPRETER_BYTECODE_HASH;
    }

    /// Virtual function to return the expected store bytecode hash.
    function expectedStoreBytecodeHash() internal pure virtual returns (bytes32) {
        return STORE_BYTECODE_HASH;
    }

    /// Virtual function to return the expected parser bytecode hash.
    function expectedParserBytecodeHash() internal pure virtual returns (bytes32) {
        return PARSER_BYTECODE_HASH;
    }
}
