// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "rain.lib.typecast/LibCast.sol";
import "rain.datacontract/LibDataContract.sol";

import "../interface/unstable/IDebugInterpreterV1.sol";

import "../lib/eval/LibEval.sol";
import "../lib/ns/LibNamespace.sol";
import "../lib/state/LibInterpreterStateDataContract.sol";
import "../lib/caller/LibEncodedDispatch.sol";

import "../lib/op/LibAllStandardOpsNP.sol";

/// @title Rainterpreter
/// @notice Minimal binding of the `IIinterpreterV1` interface to the
/// `LibInterpreterState` library, including every opcode in `AllStandardOps`.
/// This is the default implementation of "an interpreter" but is designed such
/// that other interpreters can easily be developed alongside. Alterpreters can
/// either be built by inheriting and overriding the functions on this contract,
/// or using the relevant libraries to construct an alternative binding to the
/// same interface.
contract RainterpreterNP is IInterpreterV1, IDebugInterpreterV1, ERC165 {
    using LibStackPointer for Pointer;
    using LibStackPointer for uint256[];
    using LibUint256Array for uint256[];
    using LibEval for InterpreterState;
    using LibNamespace for StateNamespace;
    using LibInterpreterStateDataContract for bytes;
    using LibCast for function(InterpreterState memory, Operand, Pointer)
        view
        returns (Pointer)[];
    using Math for uint256;
    using LibMemoryKV for MemoryKV;

    // @inheritdoc ERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IInterpreterV1).interfaceId || interfaceId == type(IDebugInterpreterV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IDebugInterpreterV1
    function offchainDebugEval(
        IInterpreterStoreV1 store_,
        FullyQualifiedNamespace namespace_,
        bytes[] memory compiledSources_,
        uint256[] memory constants_,
        uint256[][] memory context_,
        uint256[] memory stack_,
        SourceIndex sourceIndex_
    ) external view returns (uint256[] memory, uint256[] memory) {
        InterpreterState memory state_ = InterpreterState(
            stack_.dataPointer(),
            constants_.dataPointer(),
            MemoryKV.wrap(0),
            namespace_,
            store_,
            context_,
            compiledSources_
        );
        Pointer stackTop_ = state_.eval(sourceIndex_, state_.stackBottom);
        uint256 stackLengthFinal_ = state_.stackBottom.unsafeToIndex(stackTop_);
        (, uint256[] memory tail_) = stackTop_.unsafeList(stackLengthFinal_);
        return (tail_, state_.stateKV.toUint256Array());
    }

    /// @inheritdoc IInterpreterV1
    function eval(
        IInterpreterStoreV1 store_,
        StateNamespace namespace_,
        EncodedDispatch dispatch_,
        uint256[][] memory context_
    ) external view returns (uint256[] memory, uint256[] memory) {
        // Decode the dispatch.
        (
            address expression_,
            SourceIndex sourceIndex_,
            uint256 maxOutputs_
        ) = LibEncodedDispatch.decode(dispatch_);

        // Build the interpreter state from the onchain expression.
        InterpreterState memory state_ = LibDataContract
            .read(expression_)
            .unsafeDeserialize();
        state_.stateKV = MemoryKV.wrap(0);
        state_.namespace = namespace_.qualifyNamespace(msg.sender);
        state_.store = store_;
        state_.context = context_;

        // Eval the expression and return up to maxOutputs_ from the final stack.
        Pointer stackTop_ = state_.eval(sourceIndex_, state_.stackBottom);
        uint256 stackLength_ = state_.stackBottom.unsafeToIndex(stackTop_);
        (, uint256[] memory tail_) = stackTop_.unsafeList(
            stackLength_.min(maxOutputs_)
        );
        return (tail_, state_.stateKV.toUint256Array());
    }

    /// @inheritdoc IInterpreterV1
    function functionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
