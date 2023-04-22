// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";

import "../src/LibCompile.sol";
import "../src/LibInterpreterState.sol";

library LibInterpreterStateDataContractSlow {
    using LibStackPointer for Pointer;

    function size(uint256 a) internal pure returns (uint256) {
        return 0x20;
    }

    function size(uint256[] memory a) internal pure returns (uint256) {
        return a.length * 0x20 + 0x20;
    }

    function size(bytes memory a) internal pure returns (uint256) {
        return a.length + 0x20;
    }

    function serializeSizeSlow(bytes[] memory sources, uint256[] memory constants, uint256 stackLength)
        internal
        pure
        returns (uint256)
    {
        uint256 totalSize = 0;
        totalSize += size(stackLength);
        totalSize += size(constants);
        for (uint256 i_ = 0; i_ < sources.length; i_++) {
            totalSize += size(sources[i_]);
        }
        return totalSize;
    }

    function serialize(
        Pointer pointer,
        bytes[] memory sources_,
        uint256[] memory constants_,
        uint256 stackLength_,
        bytes memory opcodeFunctionPointers_
    ) internal pure {
        unchecked {
            // Copy stack length.
            pointer = pointer.push(stackLength_);

            // Then the constants.
            pointer = pointer.pushWithLength(constants_);

            // Last the sources.
            bytes memory source_;
            for (uint256 i_ = 0; i_ < sources_.length; i_++) {
                source_ = sources_[i_];
                LibCompile.compile(source_, opcodeFunctionPointers_);
                pointer = pointer.unalignedPushWithLength(source_);
            }
        }
    }

    function deserialize(bytes memory serialized) internal pure returns (InterpreterState memory) {
        unchecked {
            InterpreterState memory state;

            // Context will probably be overridden by the caller according to the
            // context scratch that we deserialize so best to just set it empty
            // here.
            state.context = new uint256[][](0);

            Pointer cursor = serialized.dataPointer();
            // The end of processing is the end of the state bytes.
            Pointer end = cursor.upBytes(cursor.peek());

            // Read the stack length and build a stack.
            cursor = cursor.up();
            uint256 stackLength_ = cursor.peek();

            // The stack is never stored in stack bytes so we allocate a new
            // array for it with length as per the indexes and point the state
            // at it.
            uint256[] memory stack_ = new uint256[](stackLength_);
            state.stackBottom = stack_.asStackPointerUp();

            // Reference the constants array and move cursor past it.
            cursor = cursor.up();
            state.constantsBottom = cursor;
            cursor = cursor.up(cursor.peek());

            // Rebuild the sources array.
            uint256 i = 0;
            Pointer lengthCursor = cursor;
            uint256 sourcesLength_ = 0;
            while (Pointer.unwrap(lengthCursor) < Pointer.unwrap(end)) {
                lengthCursor = lengthCursor.upBytes(lengthCursor.peekUp()).up();
                sourcesLength_++;
            }
            state.compiledSources = new bytes[](sourcesLength_);
            while (Pointer.unwrap(cursor) < Pointer.unwrap(end)) {
                state.compiledSources[i] = cursor.asBytes();
                cursor = cursor.upBytes(cursor.peekUp()).up();
                i++;
            }
            return state;
        }
    }
}
