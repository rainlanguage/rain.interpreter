// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibInterpreterState, InterpreterState} from "../state/LibInterpreterState.sol";

import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibMemoryKV, MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {LibBytecode} from "rain.interpreter.interface/lib/bytecode/LibBytecode.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// Thrown when the inputs length does not match the expected inputs length.
/// @param expected The expected number of inputs.
/// @param actual The actual number of inputs.
error InputsLengthMismatch(uint256 expected, uint256 actual);

library LibEval {
    using LibMemoryKV for MemoryKV;

    function evalLoop(InterpreterState memory state, uint256 parentSourceIndex, Pointer stackTop, Pointer stackBottom)
        internal
        view
        returns (Pointer)
    {
        uint256 sourceIndex = state.sourceIndex;
        uint256 cursor;
        uint256 end;
        uint256 m;
        uint256 fPointersStart;
        // We mod the indexes with the fsCount for each lookup to ensure that
        // the indexes are in bounds. A mod is cheaper than a bounds check.
        uint256 fsCount = state.fs.length / 2;
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

        function(InterpreterState memory, OperandV2, Pointer)
                    internal
                    view
                    returns (Pointer) f;
        OperandV2 operand;
        uint256 word;
        while (cursor < end) {
            assembly ("memory-safe") {
                word := mload(cursor)
            }

            // Process high bytes [28, 31]
            // f needs to be looked up from the fn pointers table.
            // operand is 3 bytes.
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(0, word), fsCount), 2))))
                operand := and(shr(0xe0, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [24, 27].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(4, word), fsCount), 2))))
                operand := and(shr(0xc0, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [20, 23].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(8, word), fsCount), 2))))
                operand := and(shr(0xa0, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [16, 19].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(12, word), fsCount), 2))))
                operand := and(shr(0x80, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [12, 15].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(16, word), fsCount), 2))))
                operand := and(shr(0x60, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [8, 11].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(20, word), fsCount), 2))))
                operand := and(shr(0x40, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [4, 7].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(24, word), fsCount), 2))))
                operand := and(shr(0x20, word), 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            // Bytes [0, 3].
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(28, word), fsCount), 2))))
                operand := and(word, 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);

            cursor += 0x20;
        }

        // Loop over the remainder.
        // Need to shift the cursor back 28 bytes so that we're reading from
        // its 4 low bits rather than high bits, to make the loop logic more
        // efficient.
        cursor -= 0x1c;
        end = cursor + m * 4;
        while (cursor < end) {
            assembly ("memory-safe") {
                word := mload(cursor)
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(byte(28, word), fsCount), 2))))
                // 3 bytes mask.
                operand := and(word, 0xFFFFFF)
            }
            stackTop = f(state, operand, stackTop);
            cursor += 4;
        }

        LibInterpreterState.stackTrace(parentSourceIndex, sourceIndex, stackTop, stackBottom);

        return stackTop;
    }

    function eval2(InterpreterState memory state, StackItem[] memory inputs, uint256 maxOutputs)
        internal
        view
        returns (StackItem[] memory, bytes32[] memory)
    {
        unchecked {
            // Use the bytecode's own definition of its IO. Clear example of
            // how the bytecode could accidentally or maliciously force OOB reads
            // if the integrity check is not run.
            (uint256 sourceInputs, uint256 sourceOutputs) =
                LibBytecode.sourceInputsOutputsLength(state.bytecode, state.sourceIndex);

            Pointer stackBottom;
            Pointer stackTop;
            {
                stackBottom = state.stackBottoms[state.sourceIndex];
                stackTop = stackBottom;
                // Copy inputs into place if needed.
                if (inputs.length > 0) {
                    // Inline some logic to avoid jumping due to function calls
                    // on hot path.
                    Pointer inputsDataPointer;
                    assembly ("memory-safe") {
                        // Move stack top by the number of inputs.
                        stackTop := sub(stackTop, mul(mload(inputs), 0x20))
                        inputsDataPointer := add(inputs, 0x20)
                    }
                    LibMemCpy.unsafeCopyWordsTo(inputsDataPointer, stackTop, inputs.length);
                } else if (inputs.length != sourceInputs) {
                    revert InputsLengthMismatch(sourceInputs, inputs.length);
                }
            }

            // Run the loop.
            // Parent source index and child are the same at the root eval.
            stackTop = evalLoop(state, state.sourceIndex, stackTop, stackBottom);

            // Convert the stack top pointer to an array with the correct length.
            // If the stack top is pointing to the base of Solidity's understanding
            // of the stack array, then this will simply write the same length over
            // the length the stack was initialized with, otherwise a shorter array
            // will be built within the bounds of the stack. After this point `tail`
            // and the original stack MUST be immutable as they're both pointing to
            // the same memory region.
            uint256 outputs = maxOutputs < sourceOutputs ? maxOutputs : sourceOutputs;
            StackItem[] memory stack;
            assembly ("memory-safe") {
                stack := sub(stackTop, 0x20)
                mstore(stack, outputs)
            }

            return (stack, state.stateKV.toBytes32Array());
        }
    }
}
