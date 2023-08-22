// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "../../interface/IInterpreterV1.sol";
import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibBytes.sol";
import "rain.solmem/lib/LibMemCpy.sol";

/// Thrown when a bytecode source offset is out of bounds.
error SourceOffsetOutOfBounds(bytes bytecode, uint256 sourceIndex);

library LibBytecode {
    using LibPointer for Pointer;
    using LibBytes for bytes;
    using LibMemCpy for Pointer;

    function sourceCount(bytes memory bytecode) internal pure returns (uint256 count) {
        if (bytecode.length == 0) {
            return 0;
        }
        assembly {
            // The first byte of rain bytecode is the count of how many sources
            // there are.
            count := byte(0, mload(add(bytecode, 0x20)))
        }
    }

    function sourceRelativeOffset(bytes memory bytecode, uint256 sourceIndex) internal pure returns (uint256 offset) {
        assembly {
            // After the first byte, all the relative offset pointers are
            // stored sequentially as 16 bit values.
            offset := and(mload(add(add(bytecode, 3), mul(sourceIndex, 2))), 0xFFFF)
        }
        // This doesn't replace a full integrity check but gives a sanity check
        // that the offset is within the bytecode. This also covers the functions
        // that use this function, to generate absolute pointers and read from
        // the source header after the offset, so they don't need to check
        // bounds redundantly.
        unchecked {
            uint256 count = sourceCount(bytecode);
            // Source count byte + 2 bytes per source offset + offset + 4 byte source header.
            uint256 expectedMinBytes = 1 + count * 2 + offset + 4;
            if (bytecode.length < expectedMinBytes || sourceIndex >= count) {
                revert SourceOffsetOutOfBounds(bytecode, sourceIndex);
            }
        }
    }

    function sourcePointer(bytes memory bytecode, uint256 sourceIndex) internal pure returns (Pointer pointer) {
        unchecked {
            uint256 sourcesStartOffset = 1 + sourceCount(bytecode) * 2;
            uint256 offset = sourceRelativeOffset(bytecode, sourceIndex);
            assembly {
                pointer := add(add(add(bytecode, 0x20), sourcesStartOffset), offset)
            }
        }
    }

    function sourceOpsLength(bytes memory bytecode, uint256 sourceIndex) internal pure returns (uint256 length) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                length := byte(0, mload(pointer))
            }
        }
    }

    function sourceStackAllocation(bytes memory bytecode, uint256 sourceIndex)
        internal
        pure
        returns (uint256 allocation)
    {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                allocation := byte(1, mload(pointer))
            }
        }
    }

    function sourceInputsLength(bytes memory bytecode, uint256 sourceIndex) internal pure returns (uint256 length) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                length := byte(2, mload(pointer))
            }
        }
    }

    function sourceOutputsLength(bytes memory bytecode, uint256 sourceIndex) internal pure returns (uint256 length) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                length := byte(3, mload(pointer))
            }
        }
    }

    /// Backwards compatibility with the old way of representing sources.
    /// Requires allocation and copying so it isn't particularly efficient, but
    /// allows us to use the new bytecode format with old interpreter code. Not
    /// recommended for production code but useful for testing.
    function bytecodeToSources(bytes memory bytecode) internal pure returns (bytes[] memory) {
        unchecked {
            uint256 count = sourceCount(bytecode);
            bytes[] memory sources = new bytes[](count);
            for (uint256 i = 0; i < count; i++) {
                // Skip over the prefix 4 bytes.
                Pointer pointer = sourcePointer(bytecode, i).unsafeAddBytes(4);
                uint256 length = sourceOpsLength(bytecode, i) * 4;
                bytes memory source = new bytes(length);
                pointer.unsafeCopyBytesTo(source.dataPointer(), length);
                // Move the opcode index one byte for each opcode, into the input
                // position, as legacly sources did not have input bytes.
                assembly ("memory-safe") {
                    for {
                        let cursor := add(source, 0x20)
                        let end := add(cursor, length)
                    } lt(cursor, end) { cursor := add(cursor, 4) } {
                        mstore8(add(cursor, 1), byte(0, mload(cursor)))
                        mstore8(cursor, 0)
                    }
                }
                sources[i] = source;
            }
            return sources;
        }
    }
}
