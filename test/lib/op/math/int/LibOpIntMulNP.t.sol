// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import {LibOpIntMulNP} from "src/lib/op/math/int/LibOpIntMulNP.sol";

contract LibOpIntMulNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIntMulNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntMulNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntMulNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

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
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
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
        checkBadInputs("_: int-mul(5);", 1, 2, 1);
        checkBadInputs("_: int-mul(0);", 1, 2, 1);
        checkBadInputs("_: int-mul(1);", 1, 2, 1);
        checkBadInputs("_: int-mul(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where multiplication does not overflow.
    function testOpIntMulNPEvalTwoInputsHappy() external {
        checkHappy("_: int-mul(0 0);", 0, "0 0");
        checkHappy("_: int-mul(0 1);", 0, "0 1");
        checkHappy("_: int-mul(1 0);", 0, "1 0");
        checkHappy("_: int-mul(1 1);", 1, "1 1");
        checkHappy("_: int-mul(1 2);", 2, "1 2");
        checkHappy("_: int-mul(2 1);", 2, "2 1");
        checkHappy("_: int-mul(2 2);", 4, "2 2");
        checkHappy("_: int-mul(max-int-value() 0);", 0, "max-int-value() 0");
        checkHappy("_: int-mul(max-int-value() 1);", type(uint256).max, "max-int-value() 1");
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where multiplication overflows.
    function testOpIntMulNPEvalTwoInputsUnhappy() external {
        checkUnhappyOverflow("_: int-mul(max-int-value() 2);");
        checkUnhappyOverflow("_: int-mul(2 max-int-value());");
        checkUnhappyOverflow("_: int-mul(max-int-value() max-int-value());");
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where multiplication does not overflow.
    function testOpIntMulNPEvalThreeInputsHappy() external {
        checkHappy("_: int-mul(0 0 0);", 0, "0 0 0");
        checkHappy("_: int-mul(0 0 1);", 0, "0 0 1");
        checkHappy("_: int-mul(0 1 0);", 0, "0 1 0");
        checkHappy("_: int-mul(0 1 1);", 0, "0 1 1");
        checkHappy("_: int-mul(1 0 0);", 0, "1 0 0");
        checkHappy("_: int-mul(1 0 1);", 0, "1 0 1");
        checkHappy("_: int-mul(1 1 0);", 0, "1 1 0");
        checkHappy("_: int-mul(1 1 1);", 1, "1 1 1");
        checkHappy("_: int-mul(1 1 2);", 2, "1 1 2");
        checkHappy("_: int-mul(1 2 1);", 2, "1 2 1");
        checkHappy("_: int-mul(1 2 2);", 4, "1 2 2");
        checkHappy("_: int-mul(2 1 1);", 2, "2 1 1");
        checkHappy("_: int-mul(2 1 2);", 4, "2 1 2");
        checkHappy("_: int-mul(2 2 1);", 4, "2 2 1");
        checkHappy("_: int-mul(2 2 2);", 8, "2 2 2");
        checkHappy("_: int-mul(max-int-value() 0 0);", 0, "max-int-value() 0 0");
        checkHappy("_: int-mul(max-int-value() 0 1);", 0, "max-int-value() 0 1");
        checkHappy("_: int-mul(max-int-value() 0 2);", 0, "max-int-value() 0 2");
        checkHappy("_: int-mul(max-int-value() 1 0);", 0, "max-int-value() 1 0");
        checkHappy("_: int-mul(max-int-value() 1 1);", type(uint256).max, "max-int-value() 1 1");
    }

    /// Test the eval of `int-mul` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where multiplication overflows.
    function testOpIntMulNPEvalThreeInputsUnhappy() external {
        checkUnhappyOverflow("_: int-mul(max-int-value() 2 2);");
        checkUnhappyOverflow("_: int-mul(2 max-int-value() 2);");
        checkUnhappyOverflow("_: int-mul(2 2 max-int-value());");
        checkUnhappyOverflow("_: int-mul(max-int-value() max-int-value() 2);");
        checkUnhappyOverflow("_: int-mul(max-int-value() 2 max-int-value());");
        checkUnhappyOverflow("_: int-mul(2 max-int-value() max-int-value());");
        checkUnhappyOverflow("_: int-mul(max-int-value() max-int-value() max-int-value());");

        // Show that overflow can happen in the middle of the calculation.
        checkUnhappyOverflow("_: int-mul(2 max-int-value() 2 2);");
        checkUnhappyOverflow("_: int-mul(2 2 max-int-value() 2);");
        checkUnhappyOverflow("_: int-mul(2 2 2 max-int-value());");
        checkUnhappyOverflow("_: int-mul(max-int-value() 2 2 2);");
        checkUnhappyOverflow("_: int-mul(2 max-int-value() 0);");
    }

    /// Test the eval of `int-mul` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntMulNPEvalOperandsDisallowed() external {
        checkDisallowedOperand("_: int-mul<>(0 0);", 10);
        checkDisallowedOperand("_: int-mul<0>(0 0 0);", 10);
        checkDisallowedOperand("_: int-mul<1>(0 0 0);", 10);
        checkDisallowedOperand("_: int-mul<2>(0 0 0);", 10);
        checkDisallowedOperand("_: int-mul<0 0>(0 0 0);", 10);
        checkDisallowedOperand("_: int-mul<0 1>(0 0 0);", 10);
        checkDisallowedOperand("_: int-mul<1 0>(0 0 0);", 10);
    }
}
