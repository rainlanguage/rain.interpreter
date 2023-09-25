// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytecode, SourceIndexOutOfBounds} from "src/lib/bytecode/LibBytecode.sol";

contract LibBytecodeTest is Test {
    /// Test some examples of source relative offsets.
    function testSourceRelativeOffsetHappy() external {
        // 1 source 0 offset 0 header
        assertEq(LibBytecode.sourceRelativeOffset(hex"01000000000000", 0), 0);
        // 1 source 0 offset some header
        assertEq(LibBytecode.sourceRelativeOffset(hex"01000001020304", 0), 0);
        // 1 source 2 offset some header
        assertEq(LibBytecode.sourceRelativeOffset(hex"010002ffff01020304", 0), 2);
        // 2 source 8 offset some header index 1
        assertEq(LibBytecode.sourceRelativeOffset(hex"0200000008ffffffff01020304ffffffff", 1), 8);
    }

    function checkSourceRelativeOffsetIndexOutOfBoundsExternal(bytes memory bytecode, uint256 sourceIndex)
        external
        pure
        returns (uint256 offset)
    {
        return LibBytecode.sourceRelativeOffset(bytecode, sourceIndex);
    }

    function checkSourceRelativeOffsetIndexOutOfBounds(bytes memory bytecode, uint256 sourceIndex) internal {
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, bytecode, sourceIndex));
        this.checkSourceRelativeOffsetIndexOutOfBoundsExternal(bytecode, sourceIndex);
    }

    /// Test some examples of source relative offset errors.
    function testSourceRelativeOffsetIndexError() external {
        // 0 source 0 offset 0 header
        // index 0
        checkSourceRelativeOffsetIndexOutOfBounds("", 0);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"00", 0);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"0000", 0);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"000000", 0);
        // index 1
        checkSourceRelativeOffsetIndexOutOfBounds(hex"", 1);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"00", 1);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"0000", 1);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"000000", 1);
        // index 2
        checkSourceRelativeOffsetIndexOutOfBounds(hex"", 2);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"00", 2);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"0000", 2);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"000000", 2);

        // 1 source 0 offset 0 header
        // index 1
        checkSourceRelativeOffsetIndexOutOfBounds(hex"01", 1);
        checkSourceRelativeOffsetIndexOutOfBounds(hex"0100", 1);
        // has offset but not header
        checkSourceRelativeOffsetIndexOutOfBounds(hex"010000", 1);
        // with header
        checkSourceRelativeOffsetIndexOutOfBounds(hex"01000000000000", 1);
    }
}
