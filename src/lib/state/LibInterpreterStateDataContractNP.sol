// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibBytes} from "rain.solmem/lib/LibBytes.sol";
import {FullyQualifiedNamespace} from "../../interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "../../interface/IInterpreterStoreV1.sol";

import {InterpreterStateNP} from "./LibInterpreterStateNP.sol";

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
        uint256 sourceIndex,
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
            uint256[] memory constants;
            assembly ("memory-safe") {
                constants := cursor
                cursor := add(cursor, mul(0x20, add(mload(cursor), 1)))
            }

            // Reference the bytecode array as-is.
            bytes memory bytecode;
            assembly ("memory-safe") {
                bytecode := cursor
            }

            // Build all the stacks.
            Pointer[] memory stackBottoms;
            assembly ("memory-safe") {
                cursor := add(cursor, 0x20)
                let stacksLength := byte(0, mload(cursor))
                cursor := add(cursor, 1)
                let sourcesStart := add(cursor, mul(stacksLength, 2))

                // Allocate the memory for stackBottoms.
                // We don't need to zero this because we're about to write to it.
                stackBottoms := mload(0x40)
                mstore(stackBottoms, stacksLength)
                mstore(0x40, add(stackBottoms, mul(add(stacksLength, 1), 0x20)))

                // Allocate each stack and point to it.
                let stacksCursor := add(stackBottoms, 0x20)
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
                    let stackBottom := add(stack, mul(add(stackSize, 1), 0x20))
                    mstore(0x40, stackBottom)

                    // Point to the stack bottom
                    mstore(stacksCursor, stackBottom)
                }
            }

            return InterpreterStateNP(
                stackBottoms, constants, sourceIndex, MemoryKV.wrap(0), namespace, store, context, bytecode, fs
            );
        }
    }
}
