// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "../../interface/IInterpreterV1.sol";
import "rain.solmem/lib/LibPointer.sol";

library LibBytecode {
    function sourceCount(bytes memory bytecode) internal pure returns (uint256 count) {
        assembly {
            // The first byte of rain bytecode is the count of how many sources
            // there are.
            count := byte(0, mload(add(bytecode, 0x20)))
        }
    }

    function sourceRelativeOffset(bytes memory bytecode, SourceIndex sourceIndex) internal pure returns (uint256 offset) {
        assembly {
            // After the first byte, all the relative offset pointers are
            // stored sequentially as 16 bit values.
            offset := and(mload(add(add(bytecode, 3), mul(sourceIndex, 2))), 0xFFFF)
        }
    }

    function sourcePointer(bytes memory bytecode, SourceIndex sourceIndex) internal pure returns (Pointer pointer) {
        unchecked {
            uint256 sourceCount = sourceCount(bytecode);
            uint256 sourcesStartOffset = 1 + sourceCount * 2;
            uint256 offset = sourceRelativeOffset(bytecode, sourceIndex);
            assembly {
                pointer := add(add(add(bytecode, 0x20), sourcesStartOffset), offset)
            }
        }
    }

    function sourceOpsLength(bytes memory bytecode, SourceIndex sourceIndex) internal pure returns (uint256 length) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                length := byte(0, mload(pointer))
            }
        }
    }

    function sourceStackAllocation(bytes memory bytecode, SourceIndex sourceIndex) internal pure returns (uint256 allocation) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                allocation := byte(1, mload(pointer))
            }
        }
    }

    function sourceInputsLength(bytes memory bytecode, SourceIndex sourceIndex) internal pure returns (uint256 length) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                length := byte(2, mload(pointer))
            }
        }
    }

    function sourceOutputsLength(bytes memory bytecode, SourceIndex sourceIndex) internal pure returns (uint256 length) {
        unchecked {
            Pointer pointer = sourcePointer(bytecode, sourceIndex);
            assembly ("memory-safe") {
                length := byte(3, mload(pointer))
            }
        }
    }
}