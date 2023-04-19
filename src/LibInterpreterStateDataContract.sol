// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibInterpreterStateDataContract {
    function serializeSize(
        bytes[] memory sources_,
        uint256[] memory constants_,
        uint256 stackLength_
    ) internal pure returns (uint256) {
        uint256 size_ = 0;
        size_ += stackLength_.size();
        size_ += constants_.size();
        for (uint256 i_ = 0; i_ < sources_.length; i_++) {
            size_ += sources_[i_].size();
        }
        return size_;
    }

    /// Efficiently serializes some `IInterpreterV1` state config into bytes that
    /// can be deserialized to an `InterpreterState` without memory allocation or
    /// copying of data on the return trip. This is achieved by mutating data in
    /// place for both serialization and deserialization so it is much more gas
    /// efficient than abi encode/decode but is NOT SAFE to use the
    /// `ExpressionConfig` after it has been serialized. Notably the index based
    /// opcodes in the sources in `ExpressionConfig` will be replaced by function
    /// pointer based opcodes in place, so are no longer usable in a portable
    /// format.
    /// @param sources_ As per `IExpressionDeployerV1`.
    /// @param constants_ As per `IExpressionDeployerV1`.
    /// @param stackLength_ Stack length calculated by `IExpressionDeployerV1`
    /// that will be used to allocate memory for the stack upon deserialization.
    /// @param opcodeFunctionPointers_ As per `IInterpreterV1.functionPointers`,
    /// bytes to be compiled into the final `InterpreterState.compiledSources`.
    function serialize(
        Pointer memPointer_,
        bytes[] memory sources_,
        uint256[] memory constants_,
        uint256 stackLength_,
        bytes memory opcodeFunctionPointers_
    ) internal pure {
        unchecked {
            StackPointer pointer_ = StackPointer.wrap(
                Pointer.unwrap(memPointer_)
            );
            // Copy stack length.
            pointer_ = pointer_.push(stackLength_);

            // Then the constants.
            pointer_ = pointer_.pushWithLength(constants_);

            // Last the sources.
            bytes memory source_;
            for (uint256 i_ = 0; i_ < sources_.length; i_++) {
                source_ = sources_[i_];
                compile(source_, opcodeFunctionPointers_);
                pointer_ = pointer_.unalignedPushWithLength(source_);
            }
        }
    }

    /// Return trip from `serialize` but targets an `InterpreterState` NOT a
    /// `ExpressionConfig`. Allows serialized bytes to be written directly into
    /// contract code on the other side of an expression address, then loaded
    /// directly into an eval-able memory layout. The only allocation required
    /// is to initialise the stack for eval, there is no copying in memory from
    /// the serialized data as the deserialization merely calculates Solidity
    /// compatible pointers to positions in the raw serialized data. This is much
    /// more gas efficient than an equivalent abi.decode call which would involve
    /// more processing, copying and allocating.
    ///
    /// Note that per-eval data such as namespace and context is NOT initialised
    /// by the deserialization process and so will need to be handled by the
    /// interpreter as part of `eval`.
    ///
    /// @param serialized_ Bytes previously serialized by
    /// `LibInterpreterState.serialize`.
    /// @return An eval-able interpreter state with initialized stack.
    function deserialize(
        bytes memory serialized_
    ) internal pure returns (InterpreterState memory) {
        unchecked {
            InterpreterState memory state_;

            // Context will probably be overridden by the caller according to the
            // context scratch that we deserialize so best to just set it empty
            // here.
            state_.context = new uint256[][](0);

            StackPointer cursor_ = serialized_.asStackPointer().up();
            // The end of processing is the end of the state bytes.
            StackPointer end_ = cursor_.upBytes(cursor_.peek());

            // Read the stack length and build a stack.
            cursor_ = cursor_.up();
            uint256 stackLength_ = cursor_.peek();

            // The stack is never stored in stack bytes so we allocate a new
            // array for it with length as per the indexes and point the state
            // at it.
            uint256[] memory stack_ = new uint256[](stackLength_);
            state_.stackBottom = stack_.asStackPointerUp();

            // Reference the constants array and move cursor past it.
            cursor_ = cursor_.up();
            state_.constantsBottom = cursor_;
            cursor_ = cursor_.up(cursor_.peek());

            // Rebuild the sources array.
            uint256 i_ = 0;
            StackPointer lengthCursor_ = cursor_;
            uint256 sourcesLength_ = 0;
            while (
                StackPointer.unwrap(lengthCursor_) < StackPointer.unwrap(end_)
            ) {
                lengthCursor_ = lengthCursor_
                    .upBytes(lengthCursor_.peekUp())
                    .up();
                sourcesLength_++;
            }
            state_.compiledSources = new bytes[](sourcesLength_);
            while (StackPointer.unwrap(cursor_) < StackPointer.unwrap(end_)) {
                state_.compiledSources[i_] = cursor_.asBytes();
                cursor_ = cursor_.upBytes(cursor_.peekUp()).up();
                i_++;
            }
            return state_;
        }
    }
}