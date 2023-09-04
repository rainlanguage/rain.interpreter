// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/concrete/RainterpreterNP.sol";

/// @title RainterpreterNPTest
/// Test suite for RainterpreterNP.
contract RainterpreterNPTest is Test {
    /// The function pointers of the interpreter must be even non-zero length.
    function testRainterpreterNPOddFunctionPointersLength() external {
        assertTrue(OPCODE_FUNCTION_POINTERS.length % 2 == 0);
        assertTrue(OPCODE_FUNCTION_POINTERS.length > 0);
    }
}
