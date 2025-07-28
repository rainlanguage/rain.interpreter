// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, OperandV2, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpFloor} from "src/lib/op/math/LibOpFloor.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract LibOpFloorTest is OpTest {
    /// Directly test the integrity logic of LibOpFloor.
    /// Inputs are always 1, outputs are always 1.
    function testOpFloorIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpFloor.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpFloor.
    function testOpFloorRun(Float a, uint16 operandData) public view {
        InterpreterState memory state = opTestDefaultInterpreterState();

        OperandV2 operand = LibOperand.build(1, 1, operandData);
        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] = StackItem.wrap(Float.unwrap(a));

        opReferenceCheck(state, operand, LibOpFloor.referenceFn, LibOpFloor.integrity, LibOpFloor.run, inputs);
    }

    /// Test the eval of `floor`.
    function testOpFloorEval() external view {
        checkHappy("_: floor(0);", 0, "0");
        checkHappy("_: floor(1);", Float.unwrap(LibDecimalFloat.packLossless(1, 0)), "1");
        checkHappy("_: floor(0.5);", Float.unwrap(LibDecimalFloat.packLossless(0, -1)), "0.5");
        checkHappy("_: floor(2);", Float.unwrap(LibDecimalFloat.packLossless(2, 0)), "2");
        checkHappy("_: floor(3);", Float.unwrap(LibDecimalFloat.packLossless(3, 0)), "3");
        checkHappy("_: floor(3.8);", Float.unwrap(LibDecimalFloat.packLossless(30, -1)), "3.8");
    }

    /// Test the eval of `floor` for bad inputs.
    function testOpFloorZeroInputs() external {
        checkBadInputs("_: floor();", 0, 1, 0);
    }

    function testOpFloorTwoInputs() external {
        checkBadInputs("_: floor(1 1);", 2, 1, 2);
    }

    function testOpFloorZeroOutputs() external {
        checkBadOutputs(": floor(1);", 1, 1, 0);
    }

    function testOpFloorTwoOutputs() external {
        checkBadOutputs("_ _: floor(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpFloorEvalOperandDisallowed() external {
        checkUnhappyParse("_: floor<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
