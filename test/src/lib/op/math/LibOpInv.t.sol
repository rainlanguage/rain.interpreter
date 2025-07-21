// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, OperandV2, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {LibOpInv} from "src/lib/op/math/LibOpInv.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract LibOpInvTest is OpTest {
    /// Directly test the integrity logic of LibOpInv.
    /// Inputs are always 1, outputs are always 1.
    function testOpInvIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpInv.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpInv.
    function testOpInvRun(Float a, uint16 operandData) public view {
        // 0 is division by 0.
        vm.assume(!LibDecimalFloat.isZero(a));
        InterpreterState memory state = opTestDefaultInterpreterState();

        OperandV2 operand = LibOperand.build(1, 1, operandData);
        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] = StackItem.wrap(Float.unwrap(a));

        opReferenceCheck(state, operand, LibOpInv.referenceFn, LibOpInv.integrity, LibOpInv.run, inputs);
    }

    /// Test the eval of `inv`.
    function testOpInvEval() external view {
        checkHappy("_: inv(1);", Float.unwrap(LibDecimalFloat.packLossless(1e38, -38)), "1");
        checkHappy("_: inv(0.5);", Float.unwrap(LibDecimalFloat.packLossless(2e37, -37)), "0.5");
        checkHappy("_: inv(2);", Float.unwrap(LibDecimalFloat.packLossless(0.5e38, -38)), "2");
        checkHappy(
            "_: inv(3);",
            Float.unwrap(LibDecimalFloat.packLossless(0.33333333333333333333333333333333333333e38, -38)),
            "3"
        );
    }

    /// Test the eval of `inv` for bad inputs.
    function testOpInvZeroInputs() external {
        checkBadInputs("_: inv();", 0, 1, 0);
    }

    function testOpInvTwoInputs() external {
        checkBadInputs("_: inv(1 1);", 2, 1, 2);
    }

    function testOpInvZeroOutputs() external {
        checkBadOutputs(": inv(1);", 1, 1, 0);
    }

    function testOpInvTwoOutputs() external {
        checkBadOutputs("_ _: inv(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpExpEvalOperandDisallowed() external {
        checkUnhappyParse("_: inv<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
