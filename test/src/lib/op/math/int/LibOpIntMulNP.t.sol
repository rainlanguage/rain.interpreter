// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, stdError} from "test/abstract/OpTest.sol";
import {LibOpIntMulNP} from "src/lib/op/math/int/LibOpIntMulNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpIntMulNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIntMulNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntMulNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 operandData)
        external
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntMulNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntMulNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntMulNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntMulNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntMulNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntMulNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntMulNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntMulNP.
    function testOpIntMulNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        uint256 overflows = 0;
        unchecked {
            uint256 a = inputs[0];
            for (uint256 i = 1; i < inputs.length; i++) {
                uint256 b = inputs[i];
                if (a == 0 || b == 0) {
                    break;
                }
                uint256 c = a * b;
                if (c / a != b) {
                    overflows++;
                }
                a = c;
            }
        }
        if (overflows > 0) {
            vm.expectRevert(stdError.arithmeticError);
        }
        opReferenceCheck(state, operand, LibOpIntMulNP.referenceFn, LibOpIntMulNP.integrity, LibOpIntMulNP.run, inputs);
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests zero inputs.
    function testOpIntMulNPEvalZeroInputs() external {
        checkBadInputs("_: int-mul();", 0, 2, 0);
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests one input.
    function testOpIntMulNPEvalOneInput() external {
        checkBadInputs("_: int-mul(5e-18);", 1, 2, 1);
        checkBadInputs("_: int-mul(0);", 1, 2, 1);
        checkBadInputs("_: int-mul(1e-18);", 1, 2, 1);
        checkBadInputs("_: int-mul(max-value());", 1, 2, 1);
    }

    function testOpIntMulNPEvalZeroOutputs() external {
        checkBadOutputs(": int-mul(0 0);", 2, 1, 0);
    }

    function testOpIntMulNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: int-mul(0 0);", 2, 1, 2);
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where multiplication does not overflow.
    function testOpIntMulNPEvalTwoInputsHappy() external {
        checkHappy("_: int-mul(0 0);", 0, "0 0");
        checkHappy("_: int-mul(0 1e-18);", 0, "0 1");
        checkHappy("_: int-mul(1e-18 0);", 0, "1 0");
        checkHappy("_: int-mul(1e-18 1e-18);", 1, "1 1");
        checkHappy("_: int-mul(1e-18 2e-18);", 2, "1 2");
        checkHappy("_: int-mul(2e-18 1e-18);", 2, "2 1");
        checkHappy("_: int-mul(2e-18 2e-18);", 4, "2 2");
        checkHappy("_: int-mul(max-value() 0);", 0, "max-value() 0");
        checkHappy("_: int-mul(max-value() 1e-18);", type(uint256).max, "max-value() 1");
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where multiplication overflows.
    function testOpIntMulNPEvalTwoInputsUnhappy() external {
        checkUnhappyOverflow("_: int-mul(max-value() 2e-18);");
        checkUnhappyOverflow("_: int-mul(2e-18 max-value());");
        checkUnhappyOverflow("_: int-mul(max-value() max-value());");
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where multiplication does not overflow.
    function testOpIntMulNPEvalThreeInputsHappy() external {
        checkHappy("_: int-mul(0 0 0);", 0, "0 0 0");
        checkHappy("_: int-mul(0 0 1e-18);", 0, "0 0 1");
        checkHappy("_: int-mul(0 1e-18 0);", 0, "0 1 0");
        checkHappy("_: int-mul(0 1e-18 1e-18);", 0, "0 1 1");
        checkHappy("_: int-mul(1e-18 0 0);", 0, "1 0 0");
        checkHappy("_: int-mul(1e-18 0 1e-18);", 0, "1 0 1");
        checkHappy("_: int-mul(1e-18 1e-18 0);", 0, "1 1 0");
        checkHappy("_: int-mul(1e-18 1e-18 1e-18);", 1, "1 1 1");
        checkHappy("_: int-mul(1e-18 1e-18 2e-18);", 2, "1 1 2");
        checkHappy("_: int-mul(1e-18 2e-18 1e-18);", 2, "1 2 1");
        checkHappy("_: int-mul(1e-18 2e-18 2e-18);", 4, "1 2 2");
        checkHappy("_: int-mul(2e-18 1e-18 1e-18);", 2, "2 1 1");
        checkHappy("_: int-mul(2e-18 1e-18 2e-18);", 4, "2 1 2");
        checkHappy("_: int-mul(2e-18 2e-18 1e-18);", 4, "2 2 1");
        checkHappy("_: int-mul(2e-18 2e-18 2e-18);", 8, "2 2 2");
        checkHappy("_: int-mul(max-value() 0 0);", 0, "max-value() 0 0");
        checkHappy("_: int-mul(max-value() 0 1e-18);", 0, "max-value() 0 1");
        checkHappy("_: int-mul(max-value() 0 2e-18);", 0, "max-value() 0 2");
        checkHappy("_: int-mul(max-value() 1e-18 0);", 0, "max-value() 1 0");
        checkHappy("_: int-mul(max-value() 1e-18 1e-18);", type(uint256).max, "max-value() 1 1");
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where multiplication overflows.
    function testOpIntMulNPEvalThreeInputsUnhappy() external {
        checkUnhappyOverflow("_: int-mul(max-value() 2e-18 2e-18);");
        checkUnhappyOverflow("_: int-mul(2e-18 max-value() 2e-18);");
        checkUnhappyOverflow("_: int-mul(2e-18 2e-18 max-value());");
        checkUnhappyOverflow("_: int-mul(max-value() max-value() 2e-18);");
        checkUnhappyOverflow("_: int-mul(max-value() 2e-18 max-value());");
        checkUnhappyOverflow("_: int-mul(2e-18 max-value() max-value());");
        checkUnhappyOverflow("_: int-mul(max-value() max-value() max-value());");

        // Show that overflow can happen in the middle of the calculation.
        checkUnhappyOverflow("_: int-mul(2e-18 max-value() 2e-18 2e-18);");
        checkUnhappyOverflow("_: int-mul(2e-18 2e-18 max-value() 2e-18);");
        checkUnhappyOverflow("_: int-mul(2e-18 2e-18 2e-18 max-value());");
        checkUnhappyOverflow("_: int-mul(max-value() 2e-18 2e-18 2e-18);");
        checkUnhappyOverflow("_: int-mul(2e-18 max-value() 0);");
    }

    /// Test the eval of `int-mul` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntMulNPEvalOperandsDisallowed() external {
        checkDisallowedOperand("_: int-mul<0>(0 0 0);");
        checkDisallowedOperand("_: int-mul<1>(0 0 0);");
        checkDisallowedOperand("_: int-mul<2>(0 0 0);");
        checkDisallowedOperand("_: int-mul<0 0>(0 0 0);");
        checkDisallowedOperand("_: int-mul<0 1>(0 0 0);");
        checkDisallowedOperand("_: int-mul<1 0>(0 0 0);");
    }
}
