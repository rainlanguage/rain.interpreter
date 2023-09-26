// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

abstract contract BytecodeTest is Test {
    function conformBytecode(bytes memory bytecode, uint256 sourceCount, bytes32 seed) internal view {
        unchecked {
            if (bytecode.length > 0) {
                // Max source count would be treating all the bytecode as empty sources.
                // ignore source count byte.
                // each source needs a 2 byte offset pointer and 4 byte header.
                uint256 maxSourceCount = (bytecode.length - 1) / 6;
                // Max source count can't exceed 256.
                maxSourceCount = bound(maxSourceCount, 0, 0xFF);

                // Source count is bounded by the max source count.
                sourceCount = bound(sourceCount, 0, maxSourceCount);

                // If source count is zero then return early with zero bytecode.
                if (sourceCount == 0) {
                    assembly ("memory-safe") {
                        mstore(bytecode, 1)
                        mstore8(add(bytecode, 0x20), 0)
                    }
                    return;
                }

                bytecode[0] = bytes1(uint8(sourceCount));

                uint256 sourcesRelativeStart = 1 + sourceCount * 2;

                // Truncate the bytecode to be a multiple of 4 bytes after the
                // relative start.
                {
                    uint256 sourcesLengthMod4 = (bytecode.length - sourcesRelativeStart) % 4;
                    if (sourcesLengthMod4 != 0) {
                        assembly ("memory-safe") {
                            mstore(bytecode, sub(mload(bytecode), sourcesLengthMod4))
                        }
                    }
                    // Sanity check.
                    require((bytecode.length - sourcesRelativeStart) % 4 == 0, "bytecode length not multiple of 4");
                }

                // Randomly allocate ops to sources.
                uint256 sourceHeadersSize = sourceCount * 4;
                uint256 totalOpsCount = (bytecode.length - sourcesRelativeStart - sourceHeadersSize) / 4;
                uint256[] memory opsPerSource = new uint256[](sourceCount);
                seed = keccak256(abi.encodePacked(seed));
                for (uint256 i = 0; i < totalOpsCount; i++) {
                    uint256 sourceIndex = uint256(seed) % sourceCount;
                    opsPerSource[sourceIndex]++;
                    seed = keccak256(abi.encodePacked(seed));
                }

                // Set all the offset pointers.
                uint256 offset = 0;
                uint256 cursor = 1;
                for (uint256 i = 0; i < sourceCount; i++) {
                    bytecode[cursor] = bytes1(uint8(offset >> 8));
                    bytecode[cursor + 1] = bytes1(uint8(offset));
                    cursor += 2;

                    // Set the ops count for the source in the header.
                    bytecode[sourcesRelativeStart + offset] = bytes1(uint8(opsPerSource[i]));

                    offset += opsPerSource[i] * 4 + 4;
                }
                // Sanity check.
                require(offset == bytecode.length - sourcesRelativeStart, "offsets don't match bytecode length");
            }
        }
    }
}
