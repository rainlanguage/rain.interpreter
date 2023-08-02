// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../state/LibInterpreterStateNP.sol";

library LibEvalNP {
    /// @param sourceIndex The index of the source to run out of the provided
    /// bytecode. This can point out of bounds. `evalNP` is designed to be called
    /// recursively by opcodes and the preflight checks MUST ensure that the
    /// sourceIndex is valid. The interpreter is responsible for ensuring that
    /// the sourceIndex is valid for the externally exposed `eval` entrypoint on
    /// the interface.
    function evalNP(InterpreterStateNP memory state, SourceIndex sourceIndex, Pointer stackTop)
        internal
        view
        returns (Pointer)
    {
        unchecked {
            uint256 cursor;
            uint256 end;
            uint256 m;
            uint256 fPointersStart;
            {
                bytes memory bytecode = state.bytecode;
                bytes memory fPointers = state.fs;
                assembly ("memory-safe") {
                    // SourceIndex is a uint16 so needs cleaning.
                    sourceIndex := and(sourceIndex, 0xFFFF)
                    // Cursor starts at the beginning of the source.
                    cursor := add(bytecode, 0x20)
                    let sourcesLength := byte(0, mload(cursor))
                    cursor := add(cursor, 1)
                    // Find start of sources.
                    let sourcesStart := add(cursor, mul(sourcesLength, 2))
                    // Find relative pointer to source.
                    let sourcesPointer := shr(0xf0, mload(add(cursor, mul(sourceIndex, 2))))
                    // Move cursor to start of source.
                    cursor := add(sourcesStart, sourcesPointer)
                    // Calculate the end.
                    let opsLength := byte(0, mload(cursor))
                    // Move cursor past 4 byte source prefix.
                    cursor := add(cursor, 4)

                    // Calculate the mod `m` which is the portion of the source
                    // that can't be copied in 32 byte chunks.
                    m := mod(opsLength, 8)

                    // Each op is 4 bytes, and there's a 4 byte prefix for the
                    // source. The initial end is only what can be processed in
                    // 32 byte chunks.
                    end := add(cursor, mul(sub(opsLength, m), 4))

                    fPointersStart := add(fPointers, 0x20)
                }
            }

            function(InterpreterStateNP memory, Operand, Pointer)
                    internal
                    view
                    returns (Pointer) f;
            Operand operand;
            uint256 word;
            while (cursor < end) {
                assembly ("memory-safe") {
                    word := mload(cursor)
                }

                // Process high bytes [28, 31]
                // f needs to be looked up from the fn pointers table.
                // operand is 3 bytes.
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(0, word), 2))))
                    operand := and(shr(0xe0, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [24, 27].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(4, word), 2))))
                    operand := and(shr(0xc0, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [20, 23].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(8, word), 2))))
                    operand := and(shr(0xa0, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [16, 19].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(12, word), 2))))
                    operand := and(shr(0x80, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [12, 15].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(16, word), 2))))
                    operand := and(shr(0x60, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [8, 11].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(20, word), 2))))
                    operand := and(shr(0x40, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [4, 7].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(24, word), 2))))
                    operand := and(shr(0x20, word), 0xFFFFFF)
                }
                stackTop = f(state, operand, stackTop);

                // Bytes [0, 3].
                assembly ("memory-safe") {
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(28, word), 2))))
                    operand := and(word, 0xFFFFFF)
                }

                cursor += 0x20;
            }

            // Loop over the remainder.
            // Need to shift the cursor back so that we're reading from its low
            // bits rather than high bits, to make the loop logic more efficient.
            cursor -= 0xe0;
            end = cursor + m * 4;
            while (cursor < end) {
                assembly ("memory-safe") {
                    word := mload(cursor)
                    f := shr(0xf0, mload(add(fPointersStart, mul(byte(28, word), 2))))
                    operand := and(word, 0xFFFFFF)
                }
                cursor += 4;
            }
            return stackTop;
        }
    }
}
