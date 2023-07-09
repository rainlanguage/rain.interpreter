// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/state/LibInterpreterState.sol";

/// @title LibInterpreterStateTest
/// @notice Exercises the interpreter state utility library.
contract LibInterpreterStateTest is Test {
    using LibInterpreterState for InterpreterState;

    /// Ensures the fingerprint is not the same for two different states.
    function testInterpreterStateFingerprint(InterpreterState memory a, InterpreterState memory b) external {
        // Currently this assumption makes the test completely redundant as it
        // is the same as the implementation. However, it is a good idea to
        // have this test in place in case the implementation changes.
        vm.assume(keccak256(abi.encode(a)) != keccak256(abi.encode(b)));
        assertTrue(a.fingerprint() != b.fingerprint());
    }
}
