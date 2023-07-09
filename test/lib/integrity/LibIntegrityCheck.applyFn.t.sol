// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "sol.lib.memory/LibPointer.sol";
import "src/lib/integrity/LibIntegrityCheck.sol";

/// @title LibIntegrityCheckApplyFnTest
/// Tests all the variations of applyFn in the integrity check.
contract LibIntegrityCheckApplyFnTest is Test {
    using LibPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;

    function i2o1(uint256, uint256) internal view returns (uint256) {}

    /// Calling applyFnN over i2o1 should be equivalent to calling applyFn n
    /// times over i2o1.
    function testIntegrityCheckApplyFnNi2o1(Pointer stackTop, uint8 n) external {
        vm.assume(Pointer.unwrap(stackTop) >= Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(n)));
        function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[] memory pointers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](0);
        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);

        Pointer stackTopAfter = state.applyFnN(stackTop, i2o1, uint256(n));

        IntegrityCheckState memory referenceState = LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), pointers);
        Pointer referenceStackTopAfter = stackTop;
        for (uint8 i = 0; i < n; i++) {
            referenceStackTopAfter = referenceState.applyFn(referenceStackTopAfter, i2o1);
        }

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(referenceStackTopAfter));
        // assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(referenceState.stackBottom));
        // assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(referenceState.stackMaxTop));
        // assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(referenceState.stackHighwater));
    }
}
