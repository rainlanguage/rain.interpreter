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
import {
    IExpressionDeployerV4,
    IERC1820_NAME_IEXPRESSION_DEPLOYER_V4
} from "rain.interpreter.interface/interface/unstable/IExpressionDeployerV4.sol";
import {IParserV1} from "rain.interpreter.interface/interface/IParserV1.sol";
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

/// @dev The function pointers for the integrity check fns.
bytes constant INTEGRITY_FUNCTION_POINTERS =
    hex"0d940e120e770ff10ffb0ffb1005100e102910cf10cf112b11a511b20ffb10050ffb0ffb10050ff10ff10ff10ff111bc11e111fb0ffb11bc0ffb0ffb11b210050ffb0ffb11b211b212051205120512050ffb1005120510051005100510050ffb1005100510051005100512051205120512050ffb100510050ffb100510050ffb0ffb100512051205100511fb";

/// @dev Hash of the metadata that describes the deployer (parsing).
bytes32 constant DESCRIBED_BY_META_HASH = bytes32(0x500c32bf4cbd462f40ff5c3319187b1a8e393bc9ac49248e2fda1648dbb6c6aa);

/// All config required to construct a `RainterpreterNPE2`.
/// @param interpreter The `IInterpreterV2` to use for evaluation. MUST match
/// known bytecode.
/// @param store The `IInterpreterStoreV2`. MUST match known bytecode.
/// @param parser The `IParserV1`. MUST match known bytecode.
struct RainterpreterExpressionDeployerNPE2ConstructionConfigV2 {
    address interpreter;
    address store;
    address parser;
}

/// @title RainterpreterExpressionDeployerNPE2
contract RainterpreterExpressionDeployerNPE2 is
    IDescribedByMetaV1,
    IExpressionDeployerV4,
    IParserV2,
    IParserPragmaV1,
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
    IParserV1 public immutable iParser;

    constructor(RainterpreterExpressionDeployerNPE2ConstructionConfigV2 memory config) {
        // Set the immutables.
        IInterpreterV2 interpreter = IInterpreterV2(config.interpreter);
        IInterpreterStoreV2 store = IInterpreterStoreV2(config.store);
        IParserV1 parser = IParserV1(config.parser);

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

        // Emit the DISPairV2.
        // The parser is this contract as it implements both
        // `IExpressionDeployerV4` and `IParserV1`.
        emit DISPairV2(msg.sender, address(interpreter), address(store), address(parser));

        // Register the interface for the deployer.
        // We have to check that the 1820 registry has bytecode at the address
        // before we can register the interface. We can't assume that the chain
        // we are deploying to has 1820 deployed.
        if (address(IERC1820_REGISTRY).code.length > 0) {
            IERC1820_REGISTRY.setInterfaceImplementer(
                address(this), IERC1820_REGISTRY.interfaceHash(IERC1820_NAME_IEXPRESSION_DEPLOYER_V4), address(this)
            );
        }
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IExpressionDeployerV4).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    /// @inheritdoc IExpressionDeployerV4
    function deployExpression2(bytes memory bytecode, uint256[] memory constants)
        external
        virtual
        returns (IInterpreterV2, IInterpreterStoreV2, address, bytes memory)
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
    function integrityFunctionPointers() external view virtual returns (bytes memory) {
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
