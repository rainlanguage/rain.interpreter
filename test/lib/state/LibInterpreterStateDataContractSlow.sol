// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.solmem/lib/LibBytes.sol";
import "rain.solmem/lib/LibUint256Array.sol";

import "src/lib/compile/LibCompile.sol";
import "src/lib/state/LibInterpreterState.sol";

library LibInterpreterStateDataContractSlow {
    using LibStackPointer for Pointer;
    using LibPointer for Pointer;
    using LibBytes for bytes;
    using LibUint256Array for uint256[];

    function size(uint256) internal pure returns (uint256) {
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

    function serializeSlow(
        Pointer pointer,
        bytes[] memory sources,
        uint256[] memory constants,
        uint256 stackLength,
        bytes memory opcodeFunctionPointers
    ) internal pure {
        unchecked {
            // Copy stack length.
            pointer = pointer.unsafePush(stackLength);

            // Then the constants.
            pointer = pointer.unsafePush(constants.length);
            for (uint256 i = 0; i < constants.length; i++) {
                pointer = pointer.unsafePush(constants[i]);
            }

            // Last the sources.
            bytes memory source;
            for (uint256 i = 0; i < sources.length; i++) {
                source = sources[i];
                LibCompile.unsafeCompile(source, opcodeFunctionPointers);
                pointer = pointer.unsafePush(source.length);
                LibMemCpy.unsafeCopyBytesTo(source.dataPointer(), pointer, source.length);
                pointer = pointer.unsafeAddBytes(source.length);
            }
        }
    }

    function deserializeSlow(bytes memory serialized) internal pure returns (InterpreterState memory) {
        unchecked {
            InterpreterState memory state;

            // Context will probably be overridden by the caller according to the
            // context scratch that we deserialize so best to just set it empty
            // here.
            state.context = new uint256[][](0);

            Pointer cursor = serialized.dataPointer();
            // The end of processing is the end of the state bytes.
            Pointer end = cursor.unsafeAddBytes(cursor.unsafePeek());

            // Read the stack length and build a stack.
            cursor = cursor.unsafeAddWord();
            uint256 stackLength = cursor.unsafePeek();

            // The stack is never stored in stack bytes so we allocate a new
            // array for it with length as per the indexes and point the state
            // at it.
            uint256[] memory stack = new uint256[](stackLength);
            state.stackBottom = stack.dataPointer();

            // Reference the constants array and move cursor past it.
            cursor = cursor.unsafeAddWord();
            state.constantsBottom = cursor;
            cursor = cursor.unsafeAddWords(cursor.unsafePeek());

            // Rebuild the sources array.
            uint256 i = 0;
            Pointer lengthCursor = cursor;
            uint256 sourcesLength_ = 0;
            while (Pointer.unwrap(lengthCursor) < Pointer.unwrap(end)) {
                lengthCursor = lengthCursor.unsafeAddBytes(lengthCursor.unsafeReadWord()).unsafeAddWord();
                sourcesLength_++;
            }
            state.compiledSources = new bytes[](sourcesLength_);
            while (Pointer.unwrap(cursor) < Pointer.unwrap(end)) {
                state.compiledSources[i] = cursor.unsafeAsBytes();
                cursor = cursor.unsafeAddBytes(cursor.unsafeReadWord()).unsafeAddWord();
                i++;
            }
            return state;
        }
    }
}
