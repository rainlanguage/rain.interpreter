// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {
    LibBytecode,
    UnexpectedSources,
    TruncatedHeaderOffsets,
    TruncatedHeader,
    UnexpectedTrailingOffsetBytes,
    TruncatedSource
} from "src/lib/bytecode/LibBytecode.sol";

import {console2} from "forge-std/console2.sol";

contract LibBytecodeCheckNoOOBPointersTest is Test {
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

    /// Test that all conforming bytecodes pass.
    function testCheckNoOOBPointersConforming(bytes memory bytecode, uint256 sourceCount, bytes32 seed) external view {
        conformBytecode(bytecode, sourceCount, seed);
        LibBytecode.checkNoOOBPointers(bytecode);
    }

    /// Expose the library function externally so we can expect reverts against
    /// it.
    function checkNoOOBPointersExternal(bytes memory bytecode) external pure {
        LibBytecode.checkNoOOBPointers(bytecode);
    }

    /// Test that a zero length bytecode passes.
    function testCheckNoOOBPointers0() external pure {
        LibBytecode.checkNoOOBPointers("");
    }

    /// Test that a zero count bytecode length 1 passes.
    function testCheckNoOOBPointers1() external pure {
        LibBytecode.checkNoOOBPointers(hex"00");
    }

    /// Test that a zero count bytecode length > 1 fails as `UnexpectedSources`.
    function testCheckNoOOBPointers1Fail(bytes memory bytecode) external {
        vm.assume(bytecode.length > 1);
        bytecode[0] = 0;

        vm.expectRevert(abi.encodeWithSelector(UnexpectedSources.selector, bytecode));
        this.checkNoOOBPointersExternal(bytecode);
    }

    /// If the relative offsets are truncated the bytecode fails as
    /// `TruncatedHeaderOffsets`.
    function testCheckNoOOBPointersOffsetsTruncated(bytes memory bytecode, uint8 sourceCount, uint256 length)
        external
    {
        vm.assume(sourceCount > 0);
        vm.assume(bytecode.length > 0);
        bytecode[0] = bytes1(sourceCount);

        // Length anywhere from 1 to preserve the count up to 1 less than the
        // offsets allocation should throw.
        length = bound(length, 1, uint256(sourceCount) * 2);

        // Truncate the bytecode to the length if needed.
        if (bytecode.length > length) {
            assembly ("memory-safe") {
                mstore(bytecode, length)
            }
        }

        vm.expectRevert(abi.encodeWithSelector(TruncatedHeaderOffsets.selector, bytecode));
        this.checkNoOOBPointersExternal(bytecode);
    }

    /// If any of the relative offsets point to a space that doesn't fit a header
    /// the bytecode fails as `TruncatedHeader`.
    function testCheckNoOOBPointersHeaderTruncated(
        bytes memory bytecode,
        uint8 sourceCount,
        bytes32 seed,
        uint256 corruptOffset
    ) external {
        conformBytecode(bytecode, sourceCount, seed);
        // The case of empty sources is not relevant.
        vm.assume(bytecode.length > 1);
        sourceCount = uint8(bytecode[0]);

        // Randomly corrupt an offset pointer.
        uint256 sourceRelativeStart = 1 + sourceCount * 2;
        seed = keccak256(abi.encodePacked(seed, uint256(0)));
        uint256 offsetIndex = uint256(seed) % sourceCount;
        uint256 nextOffset;
        if (offsetIndex == sourceCount - 1) {
            nextOffset = bytecode.length - sourceRelativeStart;
        } else {
            uint256 nextOffsetPosition = (offsetIndex + 1) * 2 + 1;
            nextOffset =
                (uint256(uint8(bytecode[nextOffsetPosition])) << 8) | uint256(uint8(bytecode[nextOffsetPosition + 1]));
        }
        corruptOffset = bound(corruptOffset, nextOffset - 3, type(uint16).max);
        uint256 offsetPosition = offsetIndex * 2 + 1;
        bytecode[offsetPosition] = bytes1(uint8(corruptOffset >> 8));
        bytecode[offsetPosition + 1] = bytes1(uint8(corruptOffset));

        vm.expectRevert(abi.encodeWithSelector(TruncatedHeader.selector, bytecode));
        this.checkNoOOBPointersExternal(bytecode);
    }

    /// Any corruption of the ops count for a given source header fails as
    /// `TruncatedSource`.
    function testCheckNoOOBPointersSourceTruncated(
        bytes memory bytecode,
        uint8 sourceCount,
        bytes32 seed,
        bytes1 corruptOpCount
    ) external {
        conformBytecode(bytecode, sourceCount, seed);
        // The case of empty sources is not relevant.
        vm.assume(bytecode.length > 1);
        sourceCount = uint8(bytecode[0]);

        // Randomly corrupt an ops count.
        uint256 sourceRelativeStart = 1 + uint256(sourceCount) * 2;
        seed = keccak256(abi.encodePacked(seed, uint256(0)));
        uint256 offsetIndex = uint256(seed) % sourceCount;
        uint256 offsetPosition = offsetIndex * 2 + 1;
        uint256 offset = (uint256(uint8(bytecode[offsetPosition])) << 8) | uint256(uint8(bytecode[offsetPosition + 1]));
        uint256 opsCount = uint256(uint8(bytecode[sourceRelativeStart + offset]));
        vm.assume(opsCount != uint8(corruptOpCount));
        bytecode[sourceRelativeStart + offset] = corruptOpCount;

        vm.expectRevert(abi.encodeWithSelector(TruncatedSource.selector, bytecode));
        this.checkNoOOBPointersExternal(bytecode);
    }

    /// If the initial offset is anything other than 0 the bytecode fails as
    /// `UnexpectedTrailingOffsetBytes`.
    function testCheckNoOOBPointersTrailingOffsetBytes(
        bytes memory bytecode,
        bytes memory garbage,
        uint8 sourceCount,
        bytes32 seed
    ) external {
        vm.assume(garbage.length > 0);
        conformBytecode(bytecode, sourceCount, seed);
        // The case of empty sources is not relevant.
        vm.assume(bytecode.length > 1);
        sourceCount = uint8(bytecode[0]);

        // Split the bytecode into two parts at the end of the offset pointers.
        uint256 sourceRelativeStart = 1 + sourceCount * 2;
        uint256 sourceAbsoluteStart;
        assembly ("memory-safe") {
            sourceAbsoluteStart := add(bytecode, add(0x20, sourceRelativeStart))
        }

        uint256 originalLength = bytecode.length;

        // Truncate the bytecode down to the source relative start.
        assembly ("memory-safe") {
            mstore(bytecode, sourceRelativeStart)
        }

        bytes memory bytecodeCorrupted = abi.encodePacked(bytecode, garbage);

        // Need to add the garbage length to every offset.
        for (uint256 i = 0; i < sourceCount; i++) {
            uint256 offsetPosition = i * 2 + 1;
            uint256 offset = (uint256(uint8(bytecodeCorrupted[offsetPosition])) << 8)
                | uint256(uint8(bytecodeCorrupted[offsetPosition + 1]));
            offset += garbage.length;
            bytecodeCorrupted[offsetPosition] = bytes1(uint8(offset >> 8));
            bytecodeCorrupted[offsetPosition + 1] = bytes1(uint8(offset));
        }

        // Restore the suffix of the bytecode.
        uint256 suffixLength = originalLength - sourceRelativeStart;
        assembly ("memory-safe") {
            bytecode := add(bytecode, sourceRelativeStart)
            mstore(bytecode, suffixLength)
        }
        bytecodeCorrupted = abi.encodePacked(bytecodeCorrupted, bytecode);

        vm.expectRevert(abi.encodeWithSelector(UnexpectedTrailingOffsetBytes.selector, bytecodeCorrupted));
        this.checkNoOOBPointersExternal(bytecodeCorrupted);
    }
}
