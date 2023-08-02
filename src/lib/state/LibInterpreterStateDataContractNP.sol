// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibBytes.sol";

import "../ns/LibNamespace.sol";
import "./LibInterpreterStateNP.sol";

library LibInterpreterStateDataContractNP {
    using LibBytes for bytes;

    function serializeSizeNP(bytes memory bytecode, uint256[] memory constants) internal pure returns (uint256 size) {
        unchecked {
            size = bytecode.length + constants.length * 0x20 + 0x40;
        }
    }

    function unsafeSerializeNP(Pointer cursor, bytes memory bytecode, uint256[] memory constants) internal pure {
        unchecked {
            // Copy constants into place with length.
            assembly ("memory-safe") {
                for {
                    let constantsCursor := constants
                    let constantsEnd := add(constantsCursor, mul(0x20, add(mload(constants), 1)))
                } lt(constantsCursor, constantsEnd) {
                    constantsCursor := add(constantsCursor, 0x20)
                    cursor := add(cursor, 0x20)
                } { mstore(cursor, mload(constantsCursor)) }
            }
            // Copy the bytecode into place with length.
            LibMemCpy.unsafeCopyBytesTo(bytecode.startPointer(), cursor, bytecode.length + 0x20);
        }
    }

    function unsafeDeserializeNP(
        bytes memory serialized,
        FullyQualifiedNamespace namespace,
        IInterpreterStoreV1 store,
        uint256[][] memory context,
        bytes memory fs
    ) internal pure returns (InterpreterStateNP memory) {
        unchecked {
            Pointer cursor;
            assembly ("memory-safe") {
                cursor := add(serialized, 0x20)
            }

            // Reference the constants array as-is and move cursor past it.
            Pointer firstConstant;
            assembly ("memory-safe") {
                let constantsLength := mload(cursor)
                firstConstant := add(cursor, 0x20)
                cursor := add(firstConstant, mul(constantsLength, 0x20))
            }

            // Reference the bytecode array as-is.
            bytes memory bytecode;
            assembly ("memory-safe") {
                bytecode := cursor
            }

            // Build all the stacks.
            uint256[][] memory stacks;
            assembly ("memory-safe") {
                cursor := add(cursor, 0x20)
                let stacksLength := byte(0, mload(cursor))
                cursor := add(cursor, 1)
                let sourcesStart := add(cursor, mul(stacksLength, 2))

                // Allocate the memory for stacks.
                // We don't need to zero this because we're about to write to it.
                stacks := mload(0x40)
                mstore(stacks, stacksLength)
                mstore(0x40, add(stacks, mul(add(stacksLength, 1), 0x20)))

                // Allocate each stack and point to it.
                let stacksCursor := add(stacks, 0x20)
                for { let i := 0 } lt(i, stacksLength) {
                    i := add(i, 1)
                    // Move over the 2 byte source pointer.
                    cursor := add(cursor, 2)
                    // Move the stacks cursor forward.
                    stacksCursor := add(stacksCursor, 0x20)
                } {
                    // The stack size is in the prefix of the source data, which
                    // is behind a relative pointer in the bytecode prefix.
                    let sourcePointer := add(sourcesStart, shr(0xf0, mload(cursor)))
                    // Stack size is the second byte of the source prefix.
                    let stackSize := byte(1, mload(sourcePointer))

                    // Allocate the stack.
                    // We don't need to zero the stack because the interpreter
                    // assumes values above the stack top are dirty anyway.
                    let stack := mload(0x40)
                    mstore(stack, stackSize)
                    mstore(0x40, add(stack, mul(add(stackSize, 1), 0x20)))

                    // Point to the stack.
                    mstore(stacksCursor, stack)
                }
            }

            return InterpreterStateNP(stacks, firstConstant, MemoryKV.wrap(0), namespace, store, context, bytecode, fs);
        }
    }
}
