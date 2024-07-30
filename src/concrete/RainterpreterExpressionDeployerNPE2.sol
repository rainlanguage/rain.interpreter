// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {ERC165, IERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibDataContract, DataContractMemoryContainer} from "rain.datacontract/lib/LibDataContract.sol";
import {IERC1820_REGISTRY} from "rain.erc1820/lib/LibIERC1820.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {IParserV2} from "rain.interpreter.interface/interface/unstable/IParserV2.sol";
import {IParserPragmaV1, PragmaV1} from "rain.interpreter.interface/interface/unstable/IParserPragmaV1.sol";

import {
    UnexpectedConstructionMetaHash,
    UnexpectedInterpreterBytecodeHash,
    UnexpectedStoreBytecodeHash,
    UnexpectedParserBytecodeHash,
    UnexpectedPointers
} from "../error/ErrDeploy.sol";
import {IParserV1View} from "rain.interpreter.interface/interface/unstable/IParserV1View.sol";
import {IInterpreterV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/unstable/IDescribedByMetaV1.sol";

import {LibIntegrityCheckNP} from "../lib/integrity/LibIntegrityCheckNP.sol";
import {LibInterpreterStateDataContractNP} from "../lib/state/LibInterpreterStateDataContractNP.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {LibParse, LibParseMeta} from "../lib/parse/LibParse.sol";
import {RainterpreterNPE2, INTERPRETER_BYTECODE_HASH} from "./RainterpreterNPE2.sol";
import {PARSER_BYTECODE_HASH} from "./RainterpreterParserNPE2.sol";
import {STORE_BYTECODE_HASH} from "./RainterpreterStoreNPE2.sol";
import {
    INTEGRITY_FUNCTION_POINTERS,
    DESCRIBED_BY_META_HASH
} from "../generated/RainterpreterExpressionDeployerNPE2.pointers.sol";
import {IIntegrityToolingV1} from "rain.sol.codegen/interface/IIntegrityToolingV1.sol";

/// All config required to construct a `RainterpreterNPE2`.
/// @param interpreter The `IInterpreterV2` to use for evaluation. MUST match
/// known bytecode.
/// @param store The `IInterpreterStoreV2`. MUST match known bytecode.
/// @param parser The `IParserV1View`. MUST match known bytecode.
struct RainterpreterExpressionDeployerNPE2ConstructionConfigV2 {
    address interpreter;
    address store;
    address parser;
}

/// @title RainterpreterExpressionDeployerNPE2
contract RainterpreterExpressionDeployerNPE2 is
    IDescribedByMetaV1,
    IParserV2,
    IParserPragmaV1,
    IIntegrityToolingV1,
    ERC165
{
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256[];

    /// The interpreter with known bytecode that this deployer is constructed
    /// for.
    IInterpreterV2 public immutable iInterpreter;
    /// The store with known bytecode that this deployer is constructed for.
    IInterpreterStoreV2 public immutable iStore;
    IParserV1View public immutable iParser;

    constructor(RainterpreterExpressionDeployerNPE2ConstructionConfigV2 memory config) {
        // Set the immutables.
        IInterpreterV2 interpreter = IInterpreterV2(config.interpreter);
        IInterpreterStoreV2 store = IInterpreterStoreV2(config.store);
        IParserV1View parser = IParserV1View(config.parser);

        iInterpreter = interpreter;
        iStore = store;
        iParser = parser;

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
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IDescribedByMetaV1).interfaceId || interfaceId == type(IParserV2).interfaceId
            || interfaceId == type(IParserPragmaV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IParserV2
    function parse2(bytes memory data) external view virtual override returns (bytes memory) {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(data);

        uint256 size = LibInterpreterStateDataContractNP.serializeSizeNP(bytecode, constants);
        bytes memory serialized;
        Pointer cursor;
        assembly ("memory-safe") {
            serialized := mload(0x40)
            mstore(0x40, add(serialized, add(0x20, size)))
            mstore(serialized, size)
            cursor := add(serialized, 0x20)
        }
        LibInterpreterStateDataContractNP.unsafeSerializeNP(cursor, bytecode, constants);

        bytes memory io = LibIntegrityCheckNP.integrityCheck2(INTEGRITY_FUNCTION_POINTERS, bytecode, constants);
        // Nothing is done with IO in IParserV2.
        (io);

        return serialized;
    }

    /// This is just here for convenience for `IParserV2` consumers, it would be
    /// more gas efficient to call the parser directly.
    /// @inheritdoc IParserPragmaV1
    function parsePragma1(bytes calldata data) external view virtual override returns (PragmaV1 memory) {
        // We know the iParser is also an IParserPragmaV1 because we enforced
        // the bytecode hash in the constructor.
        return IParserPragmaV1(address(iParser)).parsePragma1(data);
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
    /// @inheritdoc IIntegrityToolingV1
    function buildIntegrityFunctionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.integrityFunctionPointers();
    }

    ///@inheritdoc IDescribedByMetaV1
    function describedByMetaV1() external pure returns (bytes32) {
        return DESCRIBED_BY_META_HASH;
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
