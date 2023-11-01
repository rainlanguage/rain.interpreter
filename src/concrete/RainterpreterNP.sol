// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "rain.lib.typecast/LibCast.sol";
import {LibDataContract} from "rain.datacontract/lib/LibDataContract.sol";

import {IDebugInterpreterV2} from "../interface/IDebugInterpreterV2.sol";

import {LibEvalNP} from "../lib/eval/LibEvalNP.sol";
import "../lib/ns/LibNamespace.sol";
import {LibInterpreterStateDataContractNP} from "../lib/state/LibInterpreterStateDataContractNP.sol";
import "../lib/caller/LibEncodedDispatch.sol";

import {InterpreterStateNP} from "../lib/state/LibInterpreterStateNP.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibMemoryKV, MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";

/// Thrown when the stack length is negative during eval.
error NegativeStackLength(int256 length);

/// Thrown when the source index is invalid during eval. This is a runtime check
/// for the exposed external eval entrypoint. Internally recursive evals are
/// expected to preflight check the source index.
error InvalidSourceIndex(SourceIndex sourceIndex);

/// @dev Hash of the known interpreter bytecode.
bytes32 constant INTERPRETER_BYTECODE_HASH = bytes32(0x7c92b6f8af0156483f49175f220b7f9f8349ccfdb0e9f5a46c8b54872b14c1b3);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS =
    hex"0d1b0d670da20dbb0dfd0e4f0eed0fd1100b10bb115d118c11bb11bb120a1239129b132313ca13de14341448145d14771482149614ab15281573159915b015c715c71612165d16a816a816f316f3173e178917d417d4181f190619391990";

/// @dev compile time computed hash of the function pointers.
bytes32 constant OPCODE_FUNCTION_POINTERS_HASH = keccak256(OPCODE_FUNCTION_POINTERS);

/// @title RainterpreterNP
/// @notice !!EXPERIMENTAL!! implementation of a Rainlang interpreter that is
/// compatible with native onchain Rainlang parsing. Initially copied verbatim
/// from the JS compatible Rainterpreter. This interpreter is deliberately
/// separate from the JS Rainterpreter to allow for experimentation with the
/// onchain interpreter without affecting the JS interpreter, up to and including
/// a complely different execution model and opcodes.
contract RainterpreterNP is IInterpreterV1, IDebugInterpreterV2, ERC165 {
    using LibEvalNP for InterpreterStateNP;
    using LibNamespace for StateNamespace;
    using LibInterpreterStateDataContractNP for bytes;

    /// There are MANY ways that eval can be forced into undefined/corrupt
    /// behaviour by passing in invalid data. This is a deliberate design
    /// decision to allow for the interpreter to be as gas efficient as
    /// possible. The interpreter is provably read only, it contains no state
    /// changing evm opcodes reachable on any logic path. This means that
    /// the caller can only harm themselves by passing in invalid data and
    /// either reverting, exhausting gas or getting back some garbage data.
    /// The caller can trivially protect themselves from these OOB issues by
    /// ensuring the integrity check has successfully run over the bytecode
    /// before calling eval. Any smart contract caller can do this by using a
    /// trusted and appropriate deployer contract to deploy the bytecode, which
    /// will automatically run the integrity check during deployment, then
    /// keeping a registry of trusted expression addresses for itself in storage.
    ///
    /// This appears first in the contract in the hope that the compiler will
    /// put it in the most efficient internal dispatch location to save a few
    /// gas per eval call.
    ///
    /// @inheritdoc IInterpreterV1
    function eval(
        IInterpreterStoreV1 store,
        StateNamespace namespace,
        EncodedDispatch dispatch,
        uint256[][] memory context
    ) external view virtual returns (uint256[] memory, uint256[] memory) {
        // Decode the dispatch.
        (address expression, SourceIndex sourceIndex16, uint256 maxOutputs) = LibEncodedDispatch.decode(dispatch);
        bytes memory expressionData = LibDataContract.read(expression);

        // Need to clean source index as it is a uint16.
        uint256 sourceIndex;
        assembly ("memory-safe") {
            sourceIndex := and(sourceIndex16, 0xFFFF)
        }

        InterpreterStateNP memory state = expressionData.unsafeDeserializeNP(
            sourceIndex, namespace.qualifyNamespace(msg.sender), store, context, OPCODE_FUNCTION_POINTERS
        );
        // We use the return by returning it. Slither false positive.
        //slither-disable-next-line unused-return
        return state.evalNP(new uint256[](0), maxOutputs);
    }

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV1).interfaceId || interfaceId == type(IDebugInterpreterV2).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IDebugInterpreterV2
    function offchainDebugEval(
        IInterpreterStoreV1 store,
        FullyQualifiedNamespace namespace,
        bytes memory expressionData,
        SourceIndex sourceIndex16,
        uint256 maxOutputs,
        uint256[][] memory context,
        uint256[] memory inputs
    ) external view virtual returns (uint256[] memory, uint256[] memory) {
        // Need to clean source index as it is a uint16.
        uint256 sourceIndex;
        assembly ("memory-safe") {
            sourceIndex := and(sourceIndex16, 0xFFFF)
        }
        InterpreterStateNP memory state =
            expressionData.unsafeDeserializeNP(sourceIndex, namespace, store, context, OPCODE_FUNCTION_POINTERS);
        // We use the return by returning it. Slither false positive.
        //slither-disable-next-line unused-return
        return state.evalNP(inputs, maxOutputs);
    }

    /// @inheritdoc IInterpreterV1
    function functionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
