// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {RainterpreterNPE2, OPCODE_FUNCTION_POINTERS} from "src/concrete/RainterpreterNPE2.sol";

/// @title RainterpreterNPE2Test
/// Test suite for RainterpreterNP.
contract RainterpreterNPE2Test is Test {
    /// The function pointers of the interpreter must be even non-zero length.
    function testRainterpreterNPE2OddFunctionPointersLength() external {
        assertTrue(OPCODE_FUNCTION_POINTERS.length % 2 == 0);
        assertTrue(OPCODE_FUNCTION_POINTERS.length > 0);
    }
}
