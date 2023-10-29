// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/RainterpreterExpressionDeployerNPDeploymentTest.sol";

import {LibInterpreterState, InterpreterState} from "src/lib/state/deprecated/LibInterpreterState.sol";
import {IntegrityCheckState} from "src/lib/integrity/deprecated/LibIntegrityCheck.sol";
// import "src/lib/caller/LibContext.sol";

import {LibOpBlockNumber} from "src/lib/op/evm/deprecated/LibOpBlockNumber.sol";

/// @title LibOpBlockNumberTest
/// @notice Test the runtime and integrity time logic of LibOpBlockNumber.
contract LibOpBlockNumberTest is RainterpreterExpressionDeployerNPDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpBlockNumber.
    function testOpBlockNumberIntegrity(Operand operand) external {
        function(IntegrityCheckState memory, Operand, Pointer)
        view
        returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpBlockNumber.integrity;

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpBlockNumber.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the runtime logic of LibOpBlockNumber. This tests that the
    /// opcode correctly pushes the block number onto the stack.
    function testOpBlockNumberRun(Operand operand, uint256 pre, uint256 post, uint256 blockNumber) external {
        InterpreterState memory state;
        vm.roll(blockNumber);
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }

        // Block number doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpBlockNumber.run(state, operand, stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // The block number should be on the stack without modifying any other
        // data.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), blockNumber);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }
}
