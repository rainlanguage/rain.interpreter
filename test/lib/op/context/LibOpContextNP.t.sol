// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

/// @title LibOpContextNPTest
/// @notice Test the LibOpContextNP library that includes the "context" word.
contract LibOpContextNPTest is OpTest {

    /// Directly test the integrity logic of LibOpContextNP. All operands are
    /// valid, so the integrity check should always pass. The inputs and
    /// outputs are always 0 and 1 respectively.
    function testOpContextNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpContextNP.integrity(state, operand);

        assertEq(calcInputs, 0, "inputs");
        assertEq(calcOutputs, 1, "outputs");
    }

    /// Directly test the runtime logic of LibOpContextNP. This tests that the
    /// values in the context matrix can be pushed to the stack via. the operand.
    function testOpContextNPRun(InterpreterStateNP memory state, uint256 i, uint256 j) external {
        vm.assume(state.context.length > 0);
        vm.assume(state.context.length < type(uint8).max);
        i = bound(i, 0, state.context.length - 1);
        vm.assume(state.context[i].length > 0);
        vm.assume(state.context[i].length < type(uint8).max);
        j = bound(j, 0, state.context[i].length - 1);
        Operand operand = Operand.wrap(uint256(i) | uint256(j) << 8);
        uint256[] memory inputs = new uint256[](0);
        opReferenceCheck(state, operand, LibOpContextNP.referenceFn, LibOpContextNP.integrity, LibOpContextNP.run, inputs);
    }
}