// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, OperandV2, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpSqrt} from "src/lib/op/math/LibOpSqrt.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract LibOpSqrtTest is OpTest {
    using LibDecimalFloat for Float;

    function beforeOpTestConstructor() internal virtual override {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
    }

    /// Directly test the integrity logic of LibOpSqrt.
    /// Inputs are always 1, outputs are always 1.
    function testOpSqrtIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpSqrt.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpSqrt.
    function testOpSqrtRun(Float a) public view {
        a = a.abs();
        InterpreterState memory state = opTestDefaultInterpreterState();

        OperandV2 operand = LibOperand.build(1, 1, 0);
        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] = StackItem.wrap(Float.unwrap(a));

        opReferenceCheck(state, operand, LibOpSqrt.referenceFn, LibOpSqrt.integrity, LibOpSqrt.run, inputs);
    }

    /// Test the eval of `sqrt`.
    function testOpSqrtEval() external view {
        checkHappy("_: sqrt(0);", 0, "0");
        checkHappy("_: sqrt(1);", Float.unwrap(LibDecimalFloat.packLossless(1e3, -3)), "1");
        checkHappy(
            "_: sqrt(0.5);",
            Float.unwrap(LibDecimalFloat.packLossless(70671378091872791519434628975265017667, -38)),
            "0.5"
        );
        checkHappy("_: sqrt(2);", Float.unwrap(LibDecimalFloat.packLossless(1415, -3)), "2");
        checkHappy("_: sqrt(2.5);", Float.unwrap(LibDecimalFloat.packLossless(1581, -3)), "2.5");
    }

    /// Test the eval of `sqrt` for bad inputs.
    function testOpSqrtEvalBad() external {
        checkBadInputs("_: sqrt();", 0, 1, 0);
        checkBadInputs("_: sqrt(1 1);", 2, 1, 2);
    }

    function testOpSqrtEvalZeroOutputs() external {
        checkBadOutputs(": sqrt(1);", 1, 1, 0);
    }

    function testOpSqrtEvalTwoOutputs() external {
        checkBadOutputs("_ _: sqrt(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpSqrtEvalOperandDisallowed() external {
        checkUnhappyParse("_: sqrt<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
