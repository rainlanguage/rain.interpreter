// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "../../lib/rain.lib.typecast/src/LibCast.sol";
import {Pointer as DataContractPointer, LibDataContract} from "../../lib/rain.datacontract/src/lib/LibDataContract.sol";

import "../interface/unstable/IDebugInterpreterV1.sol";

import "../lib/eval/LibEval.sol";
import "../lib/ns/LibNamespace.sol";
import "../lib/state/LibInterpreterStateDataContract.sol";
import "../lib/caller/LibEncodedDispatch.sol";

import "../lib/op/LibAllStandardOpsNP.sol";

/// Thrown when the stack length is negative during eval.
error NegativeStackLength(int256 length);

/// @title RainterpreterNP
/// @notice !!EXPERIMENTAL!! implementation of a Rainlang interpreter that is
/// compatible with native onchain Rainlang parsing. Initially copied verbatim
/// from the JS compatible Rainterpreter. This interpreter is deliberately
/// separate from the JS Rainterpreter to allow for experimentation with the
/// onchain interpreter without affecting the JS interpreter, up to and including
/// a complely different execution model and opcodes.
contract RainterpreterNP is IInterpreterV1, IDebugInterpreterV1, ERC165 {
    using LibStackPointer for Pointer;
    using LibStackPointer for uint256[];
    using LibUint256Array for uint256[];
    using LibEval for InterpreterState;
    using LibNamespace for StateNamespace;
    using LibInterpreterStateDataContract for bytes;
    using LibCast for function(InterpreterState memory, Operand, Pointer) view returns (Pointer)[];
    using LibMemoryKV for MemoryKV;

    // @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV1).interfaceId || interfaceId == type(IDebugInterpreterV1).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IDebugInterpreterV1
    function offchainDebugEval(
        IInterpreterStoreV1 store,
        FullyQualifiedNamespace namespace,
        bytes[] memory compiledSources,
        uint256[] memory constants,
        uint256[][] memory context,
        uint256[] memory stack,
        SourceIndex sourceIndex
    ) external view returns (uint256[] memory, uint256[] memory) {
        InterpreterState memory state = InterpreterState(
            stack.dataPointer(), constants.dataPointer(), MemoryKV.wrap(0), namespace, store, context, compiledSources
        );
        Pointer stackTop = state.eval(sourceIndex, state.stackBottom);
        int256 stackLengthFinal = state.stackBottom.toIndexSigned(stackTop);
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
        InterpreterState memory state = LibDataContract.read(expression).unsafeDeserialize();
        state.stateKV = MemoryKV.wrap(0);
        state.namespace = namespace.qualifyNamespace(msg.sender);
        state.store = store;
        state.context = context;

        // Eval the expression and return up to maxOutputs from the final stack.
        Pointer stackTop = state.eval(sourceIndex, state.stackBottom);
        int256 stackLengthFinal = state.stackBottom.toIndexSigned(stackTop);
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
