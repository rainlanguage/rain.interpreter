// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "rain.lib.typecast/LibCast.sol";
import "rain.datacontract/lib/LibDataContract.sol";

import "../interface/unstable/IDebugInterpreterV2.sol";

import "../lib/eval/LibEvalNP.sol";
import "../lib/ns/LibNamespace.sol";
import "../lib/state/LibInterpreterStateDataContractNP.sol";
import "../lib/caller/LibEncodedDispatch.sol";

import "../lib/op/LibAllStandardOpsNP.sol";

/// Thrown when the stack length is negative during eval.
error NegativeStackLength(int256 length);

/// Thrown when the source index is invalid during eval. This is a runtime check
/// for the exposed external eval entrypoint. Internally recursive evals are
/// expected to preflight check the source index.
error InvalidSourceIndex(SourceIndex sourceIndex);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS = hex"0c150c240c370c490c570c85";

/// @title RainterpreterNP
/// @notice !!EXPERIMENTAL!! implementation of a Rainlang interpreter that is
/// compatible with native onchain Rainlang parsing. Initially copied verbatim
/// from the JS compatible Rainterpreter. This interpreter is deliberately
/// separate from the JS Rainterpreter to allow for experimentation with the
/// onchain interpreter without affecting the JS interpreter, up to and including
/// a complely different execution model and opcodes.
contract RainterpreterNP is IInterpreterV1, IDebugInterpreterV2, ERC165 {
    using LibStackPointer for Pointer;
    using LibStackPointer for uint256[];
    using LibUint256Array for uint256[];
    using LibEvalNP for InterpreterStateNP;
    using LibNamespace for StateNamespace;
    using LibInterpreterStateDataContractNP for bytes;
    using LibCast for function(InterpreterState memory, Operand, Pointer) view returns (Pointer)[];
    using LibMemoryKV for MemoryKV;
    using LibNamespace for StateNamespace;

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV1).interfaceId || interfaceId == type(IDebugInterpreterV2).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IDebugInterpreterV2
    function offchainDebugEval(
        IInterpreterStoreV1 store,
        bytes memory expressionData,
        FullyQualifiedNamespace namespace,
        uint256[][] memory context,
        uint256[] memory stack,
        SourceIndex sourceIndex
    ) external view returns (uint256[] memory, uint256[] memory) {
        InterpreterStateNP memory state = expressionData.unsafeDeserializeNP(
            namespace, store, context, OPCODE_FUNCTION_POINTERS
        );

        if (SourceIndex.unwrap(sourceIndex) >= state.bytecode.length) {
            revert InvalidSourceIndex(sourceIndex);
        }

        Pointer stackBottom = stack.endPointer();
        Pointer stackTop = state.evalNP(sourceIndex, stackBottom);
        int256 stackLengthFinal = stackTop.toIndexSigned(stackBottom);
        if (stackLengthFinal < 0) {
            revert NegativeStackLength(stackLengthFinal);
        }
        uint256 stackLengthFinalPositive = uint256(stackLengthFinal);
        (uint256 head, uint256[] memory tail) = stackTop.unsafeList(stackLengthFinalPositive);
        // The head is irrelevant here because it's whatever was overridden by
        // the length of the array in building the final substack to return.
        (head);
        return (tail, state.stateKV.toUint256Array());
    }

    /// @inheritdoc IInterpreterV1
    function eval(
        IInterpreterStoreV1 store,
        StateNamespace namespace,
        EncodedDispatch dispatch,
        uint256[][] memory context
    ) external view returns (uint256[] memory, uint256[] memory) {
        // Decode the dispatch.
        (address expression, SourceIndex sourceIndex, uint256 maxOutputs) = LibEncodedDispatch.decode(dispatch);

        // Build the interpreter state from the onchain expression.
        InterpreterStateNP memory state = LibDataContract.read(expression).unsafeDeserializeNP(
            namespace.qualifyNamespace(msg.sender), store, context, OPCODE_FUNCTION_POINTERS
        );

        if (SourceIndex.unwrap(sourceIndex) >= state.bytecode.length) {
            revert InvalidSourceIndex(sourceIndex);
        }

        // Eval the expression and return up to maxOutputs from the final stack.
        Pointer stackBottom = state.stacks[SourceIndex.unwrap(sourceIndex)].endPointer();
        Pointer stackTop = state.evalNP(sourceIndex, stackBottom);
        int256 stackLengthFinal = stackTop.toIndexSigned(stackBottom);
        if (stackLengthFinal < 0) {
            revert NegativeStackLength(stackLengthFinal);
        }
        uint256 stackLengthFinalPositive = uint256(stackLengthFinal);
        (uint256 head, uint256[] memory tail) =
            stackTop.unsafeList(maxOutputs < stackLengthFinalPositive ? maxOutputs : stackLengthFinalPositive);
        // The head is irrelevant here because it's whatever was overridden by
        // the length of the array in building the final substack to return.
        (head);
        return (tail, state.stateKV.toUint256Array());
    }

    /// @inheritdoc IInterpreterV1
    function functionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
