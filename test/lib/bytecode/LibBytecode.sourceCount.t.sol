// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";

contract LibBytecodeSourceCountTest is Test {
    /// Test that a zero length bytecode returns zero sources.
    function testSourceCount0() external {
        assertEq(LibBytecode.sourceCount(""), 0);
    }

    /// Test that a non-zero length bytecode returns the first byte as the
    /// source count.
    function testSourceCount1(bytes memory bytecode) external {
        vm.assume(bytecode.length > 0);
        assertEq(LibBytecode.sourceCount(bytecode), uint256(uint8(bytecode[0])));
    }
}
