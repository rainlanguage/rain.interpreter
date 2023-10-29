// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPDeploymentTest.sol";

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {IMetaV1} from "rain.metadata/IMetaV1.sol";

import {LibInterpreterState, InterpreterState} from "src/lib/state/deprecated/LibInterpreterState.sol";
import {
    LibIntegrityCheck,
    IntegrityCheckState,
    INITIAL_STACK_HIGHWATER
} from "src/lib/integrity/deprecated/LibIntegrityCheck.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {Operand} from "src/interface/IInterpreterV1.sol";

import {LibOpTimestamp} from "src/lib/op/evm/deprecated/LibOpTimestamp.sol";

/// @title LibOpTimestampTest
/// @notice Test the runtime and integrity time logic of LibOpTimestamp.
contract LibOpTimestampTest is RainterpreterExpressionDeployerNPDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpTimestamp.
    function testOpTimestampIntegrity(Operand operand) external {
        function(IntegrityCheckState memory, Operand, Pointer)
        view
        returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpTimestamp.integrity;

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpTimestamp.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the runtime logic of LibOpTimestamp. This tests that the
    /// opcode correctly pushes the timestamp onto the stack.
    function testOpTimestampRun(Operand operand, uint256 pre, uint256 post, uint256 blockTimestamp) external {
        InterpreterState memory state;
        vm.warp(blockTimestamp);
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }

        // Timestamp doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpTimestamp.run(state, operand, stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // Check that the opcode pushed the correct value onto the stack without
        // modifying the stack beyond the first element.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), blockTimestamp);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }
}
