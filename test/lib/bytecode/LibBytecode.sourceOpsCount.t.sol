// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";

contract LibBytecodeSourceOpsCountTest is Test {
    function testSourceOpsCount() external {
        // 1 source 0 offset 0 header
        assertEq(LibBytecode.sourceOpsCount(hex"01000000000000", 0), 0);
        // 1 source 0 offset some header (should be 1)
        assertEq(LibBytecode.sourceOpsCount(hex"01000001020304", 0), 1);
        // 1 source 2 offset some header
        assertEq(LibBytecode.sourceOpsCount(hex"010002ffff01020304", 0), 1);
        // 2 source 8 offset some header index 1
        assertEq(LibBytecode.sourceOpsCount(hex"020000000801000000ffffffff01020304ffffffff", 1), 1);
    }
}
