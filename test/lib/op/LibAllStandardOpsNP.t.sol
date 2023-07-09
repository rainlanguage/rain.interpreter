// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/integrity/LibIntegrityCheck.sol";
import "src/lib/state/LibInterpreterState.sol";
import "src/lib/op/LibAllStandardOpsNP.sol";

/// @title LibAllStandardOpsNPTest
/// Some basic guard rails around the `LibAllStandardOpsNP` library. Most of the
/// logic can only be tested by deploying an interpreter and running it.
contract LibAllStandardOpsNPTest is Test {
    /// Test that the dynamic length of the function pointers is correct.
    function testIntegrityFunctionPointersLength() external {
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                LibAllStandardOpsNP.integrityFunctionPointers();
        assertEq(integrityCheckers.length, ALL_STANDARD_OPS_LENGTH);
    }

    /// Test that the dynamic length of the function pointers is correct.
    function testOpcodeFunctionPointersLength() external {
        bytes memory functionPointers = LibAllStandardOpsNP.opcodeFunctionPointers();
        // Each function pointer is 2 bytes.
        assertEq(functionPointers.length, ALL_STANDARD_OPS_LENGTH * 2);
    }

    /// Test that the integrity function pointers length and opcode function
    /// pointers length are the same.
    function testIntegrityAndOpcodeFunctionPointersLength() external {
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                LibAllStandardOpsNP.integrityFunctionPointers();
        bytes memory functionPointers = LibAllStandardOpsNP.opcodeFunctionPointers();
        assertEq(integrityCheckers.length * 2, functionPointers.length);
    }
}