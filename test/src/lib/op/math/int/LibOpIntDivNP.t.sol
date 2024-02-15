// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, stdError} from "test/abstract/OpTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOpIntDivNP} from "src/lib/op/math/int/LibOpIntDivNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpIntDivNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIntDivNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntDivNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 operandData)
        external
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntDivNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntDivNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntDivNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntDivNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntDivNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntDivNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntDivNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntDivNP.
    function testOpIntDivNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);

        uint256 divZeros = 0;
        for (uint256 i = 1; i < inputs.length; i++) {
            if (inputs[i] == 0) {
                divZeros++;
            }
        }
        if (divZeros > 0) {
            vm.expectRevert(stdError.divisionError);
        }
        opReferenceCheck(state, operand, LibOpIntDivNP.referenceFn, LibOpIntDivNP.integrity, LibOpIntDivNP.run, inputs);
    }

    /// Test the eval of `int-div` opcode parsed from a string. Tests zero inputs.
    function testOpIntDivNPEvalZeroInputs() external {
        checkBadInputs("_: int-div();", 0, 2, 0);
    }

    /// Test the eval of `int-div` opcode parsed from a string. Tests one input.
    function testOpIntDivNPEvalOneInput() external {
        checkBadInputs("_: int-div(5);", 1, 2, 1);
        checkBadInputs("_: int-div(0);", 1, 2, 1);
        checkBadInputs("_: int-div(1);", 1, 2, 1);
        checkBadInputs("_: int-div(max-int-value());", 1, 2, 1);
    }

    function testOpIntDivNPEvalZeroOutputs() external {
        checkBadOutputs(": int-div(0 0);", 2, 1, 0);
    }

    function testOpIntDivNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: int-div(0 0);", 2, 1, 2);
    }

    /// Test the eval of `int-div` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where we do not divide by zero.
    /// Note that the division truncates (rounds down).
    function testOpIntDivNPEval2InputsHappy() external {
        // Show that the division truncates (rounds down).
        checkHappy("_: int-div(6 1);", 6, "6 / 1");
        checkHappy("_: int-div(6 2);", 3, "6 / 2");
        checkHappy("_: int-div(6 3);", 2, "6 / 3");
        checkHappy("_: int-div(6 4);", 1, "6 / 4");
        checkHappy("_: int-div(6 5);", 1, "6 / 5");
        checkHappy("_: int-div(6 6);", 1, "6 / 6");
        checkHappy("_: int-div(6 7);", 0, "6 / 7");
        checkHappy("_: int-div(6 max-int-value());", 0, "6 / max-int-value()");

        // Anything divided by 1 is itself.
        checkHappy("_: int-div(0 1);", 0, "0 / 1");
        checkHappy("_: int-div(1 1);", 1, "1 / 1");
        checkHappy("_: int-div(2 1);", 2, "2 / 1");
        checkHappy("_: int-div(3 1);", 3, "3 / 1");
        checkHappy("_: int-div(max-int-value() 1);", type(uint256).max, "max-int-value() / 1");

        // Anything divided by itself is 1 (except 0).
        checkHappy("_: int-div(1 1);", 1, "1 / 1");
        checkHappy("_: int-div(2 2);", 1, "2 / 2");
        checkHappy("_: int-div(3 3);", 1, "3 / 3");
        checkHappy("_: int-div(max-int-value() max-int-value());", 1, "max-int-value() / max-int-value()");
    }

    /// Test the eval of `int-div` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where we divide by zero.
    function testOpIntDivNPEval2InputsUnhappy() external {
        checkUnhappy("_: int-div(0 0);", stdError.divisionError);
        checkUnhappy("_: int-div(1 0);", stdError.divisionError);
        checkUnhappy("_: int-div(max-int-value() 0);", stdError.divisionError);
    }

    /// Test the eval of `int-div` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where we do not divide by zero.
    function testOpIntDivNPEval3InputsHappy() external {
        // Show that the division truncates (rounds down).
        checkHappy("_: int-div(6 1 1);", 6, "6 / 1 / 1");
        checkHappy("_: int-div(6 2 1);", 3, "6 / 2 / 1");
        checkHappy("_: int-div(6 3 1);", 2, "6 / 3 / 1");
        checkHappy("_: int-div(6 4 1);", 1, "6 / 4 / 1");
        checkHappy("_: int-div(6 5 1);", 1, "6 / 5 / 1");
        checkHappy("_: int-div(6 6 1);", 1, "6 / 6 / 1");
        checkHappy("_: int-div(6 7 1);", 0, "6 / 7 / 1");
        checkHappy("_: int-div(6 max-int-value() 1);", 0, "6 / max-int-value() / 1");
        checkHappy("_: int-div(6 1 2);", 3, "6 / 1 / 2");
        checkHappy("_: int-div(6 2 2);", 1, "6 / 2 / 2");
        checkHappy("_: int-div(6 3 2);", 1, "6 / 3 / 2");
        checkHappy("_: int-div(6 4 2);", 0, "6 / 4 / 2");
        checkHappy("_: int-div(6 5 2);", 0, "6 / 5 / 2");
        checkHappy("_: int-div(6 6 2);", 0, "6 / 6 / 2");
        checkHappy("_: int-div(6 7 2);", 0, "6 / 7 / 2");
        checkHappy("_: int-div(6 max-int-value() 2);", 0, "6 / max-int-value() / 2");

        // Anything divided by 1 is itself.
        checkHappy("_: int-div(0 1 1);", 0, "0 / 1 / 1");
        checkHappy("_: int-div(1 1 1);", 1, "1 / 1 / 1");
        checkHappy("_: int-div(2 1 1);", 2, "2 / 1 / 1");
        checkHappy("_: int-div(3 1 1);", 3, "3 / 1 / 1");
        checkHappy("_: int-div(max-int-value() 1 1);", type(uint256).max, "max-int-value() / 1 / 1");

        // Anything divided by itself is 1 (except 0).
        checkHappy("_: int-div(1 1 1);", 1, "1 / 1 / 1");
        checkHappy("_: int-div(2 2 1);", 1, "2 / 2 / 1");
        checkHappy("_: int-div(2 1 2);", 1, "2 / 1 / 2");
        checkHappy("_: int-div(3 3 1);", 1, "3 / 3 / 1");
        checkHappy("_: int-div(3 1 3);", 1, "3 / 1 / 3");
        checkHappy("_: int-div(max-int-value() max-int-value() 1);", 1, "max-int-value() / max-int-value() / 1");
        checkHappy("_: int-div(max-int-value() 1 max-int-value());", 1, "max-int-value() / 1 / max-int-value()");
    }

    /// Test the eval of `int-div` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where we divide by zero.
    function testOpIntDivNPEval3InputsUnhappy() external {
        checkUnhappy("_: int-div(0 0 0);", stdError.divisionError);
        checkUnhappy("_: int-div(1 0 0);", stdError.divisionError);
        checkUnhappy("_: int-div(max-int-value() 0 0);", stdError.divisionError);
        checkUnhappy("_: int-div(0 1 0);", stdError.divisionError);
        checkUnhappy("_: int-div(1 1 0);", stdError.divisionError);
        checkUnhappy("_: int-div(max-int-value() max-int-value() 0);", stdError.divisionError);
        checkUnhappy("_: int-div(0 0 1);", stdError.divisionError);
        checkUnhappy("_: int-div(1 0 1);", stdError.divisionError);
        checkUnhappy("_: int-div(max-int-value() 0 1);", stdError.divisionError);
    }

    /// Test the eval of `int-div` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntDivNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-div<0>(0 0 0);");
        checkDisallowedOperand("_: int-div<1>(0 0 0);");
        checkDisallowedOperand("_: int-div<2>(0 0 0);");
        checkDisallowedOperand("_: int-div<3 1>(0 0 0);");
    }
}
