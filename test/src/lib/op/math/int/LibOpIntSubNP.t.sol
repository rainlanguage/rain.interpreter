// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, InterpreterStateNP, Operand, stdError} from "test/abstract/OpTest.sol";
import {LibOpIntSubNP} from "src/lib/op/math/int/LibOpIntSubNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpIntSubNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIntSubNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntSubNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 operandData)
        external
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntSubNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntSubNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntSubNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntSubNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntSubNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntSubNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntSubNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntSubNP.
    function testOpIntSubNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        uint256 underflows = 0;
        unchecked {
            uint256 a = inputs[0];
            for (uint256 i = 1; i < inputs.length; i++) {
                uint256 b = inputs[i];
                uint256 c = a - b;
                if (c > a) {
                    underflows++;
                }
                a = c;
            }
        }
        if (underflows > 0) {
            vm.expectRevert(stdError.arithmeticError);
        }
        opReferenceCheck(state, operand, LibOpIntSubNP.referenceFn, LibOpIntSubNP.integrity, LibOpIntSubNP.run, inputs);
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests zero inputs.
    function testOpIntSubNPEvalZeroInputs() external {
        checkBadInputs("_: int-sub();", 0, 2, 0);
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests zero inputs.
    /// Test that saturating does not change the result.
    function testOpIntSubNPEvalZeroInputsSaturating() external {
        checkBadInputs("_: int-sub<1>();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests zero inputs.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-sub();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests zero inputs.
    /// Test that saturating does not change the result.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEvalZeroInputsSaturating() external {
        checkBadInputs("_: decimal18-sub<1>();", 0, 2, 0);
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests one input.
    function testOpIntSubNPEvalOneInput() external {
        checkBadInputs("_: int-sub(5);", 1, 2, 1);
        checkBadInputs("_: int-sub(0);", 1, 2, 1);
        checkBadInputs("_: int-sub(1);", 1, 2, 1);
        checkBadInputs("_: int-sub(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests one input.
    /// Test that saturating does not change the result.
    function testOpIntSubNPEvalOneInputSaturating() external {
        checkBadInputs("_: int-sub<1>(5);", 1, 2, 1);
        checkBadInputs("_: int-sub<1>(0);", 1, 2, 1);
        checkBadInputs("_: int-sub<1>(1);", 1, 2, 1);
        checkBadInputs("_: int-sub<1>(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests one input.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEvalOneInput() external {
        checkBadInputs("_: decimal18-sub(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-sub(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-sub(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-sub(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests one input.
    /// Test that saturating does not change the result.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEvalOneInputSaturating() external {
        checkBadInputs("_: decimal18-sub<1>(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-sub<1>(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-sub<1>(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-sub<1>(max-int-value());", 1, 2, 1);
    }

    function testOpDecimal18SubNPEvalZeroOutputs() external {
        checkBadOutputs(": decimal18-sub(0 0);", 2, 1, 0);
    }

    function testOpDecimal18SubNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-sub(0 0);", 2, 1, 2);
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests two inputs.
    function testOpIntSubNPEvalTwoInputs() external {
        checkHappy("_: int-sub(1 0);", 1, "1 0");
        checkHappy("_: int-sub(1 1);", 0, "1 1");
        checkHappy("_: int-sub(2 1);", 1, "2 1");
        checkHappy("_: int-sub(2 2);", 0, "2 2");
        checkHappy("_: int-sub(max-int-value() 0);", type(uint256).max, "max-int-value() 0");
        checkHappy("_: int-sub(max-int-value() 1);", type(uint256).max - 1, "max-int-value() 1");
        checkHappy("_: int-sub(max-int-value() max-int-value());", 0, "max-int-value() max-int-value()");
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests two inputs.
    /// Test that saturating does not change the result.
    function testOpIntSubNPEvalTwoInputsSaturating() external {
        checkHappy("_: int-sub<1>(1 0);", 1, "1 0");
        checkHappy("_: int-sub<1>(1 1);", 0, "1 1");
        checkHappy("_: int-sub<1>(2 1);", 1, "2 1");
        checkHappy("_: int-sub<1>(2 2);", 0, "2 2");
        checkHappy("_: int-sub<1>(max-int-value() 0);", type(uint256).max, "max-int-value() 0");
        checkHappy("_: int-sub<1>(max-int-value() 1);", type(uint256).max - 1, "max-int-value() 1");
        checkHappy("_: int-sub<1>(max-int-value() max-int-value());", 0, "max-int-value() max-int-value()");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests two inputs.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEvalTwoInputs() external {
        checkHappy("_: decimal18-sub(1 0);", 1, "1 0");
        checkHappy("_: decimal18-sub(1 1);", 0, "1 1");
        checkHappy("_: decimal18-sub(2 1);", 1, "2 1");
        checkHappy("_: decimal18-sub(2 2);", 0, "2 2");
        checkHappy("_: decimal18-sub(max-int-value() 0);", type(uint256).max, "max-int-value() 0");
        checkHappy("_: decimal18-sub(max-int-value() 1);", type(uint256).max - 1, "max-int-value() 1");
        checkHappy("_: decimal18-sub(max-int-value() max-int-value());", 0, "max-int-value() max-int-value()");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests two inputs.
    /// Test that saturating does not change the result.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEval2InputsSaturating() external {
        checkHappy("_: decimal18-sub<1>(1 0);", 1, "1 0");
        checkHappy("_: decimal18-sub<1>(1 1);", 0, "1 1");
        checkHappy("_: decimal18-sub<1>(2 1);", 1, "2 1");
        checkHappy("_: decimal18-sub<1>(2 2);", 0, "2 2");
        checkHappy("_: decimal18-sub<1>(max-int-value() 0);", type(uint256).max, "max-int-value() 0");
        checkHappy("_: decimal18-sub<1>(max-int-value() 1);", type(uint256).max - 1, "max-int-value() 1");
        checkHappy("_: decimal18-sub<1>(max-int-value() max-int-value());", 0, "max-int-value() max-int-value()");
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where we underflow.
    function testOpIntSubNPEval2InputsUnhappyUnderflow() external {
        checkUnhappyOverflow("_: int-sub(0 1);");
        checkUnhappyOverflow("_: int-sub(1 2);");
        checkUnhappyOverflow("_: int-sub(2 3);");
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests two inputs.
    /// Tests saturating on an underflow.
    function testOpIntSubNPEval2InputsSaturatingUnderflow() external {
        checkHappy("_: int-sub<1>(0 1);", 0, "0 1");
        checkHappy("_: int-sub<1>(1 2);", 0, "1 2");
        checkHappy("_: int-sub<1>(2 3);", 0, "2 3");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests the unhappy path where we underflow.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEval2InputsUnhappyUnderflow() external {
        checkUnhappyOverflow("_: decimal18-sub(0 1);");
        checkUnhappyOverflow("_: decimal18-sub(1 2);");
        checkUnhappyOverflow("_: decimal18-sub(2 3);");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests saturating on an underflow.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEval2InputsSaturatingUnderflow() external {
        checkHappy("_: decimal18-sub<1>(0 1);", 0, "0 1");
        checkHappy("_: decimal18-sub<1>(1 2);", 0, "1 2");
        checkHappy("_: decimal18-sub<1>(2 3);", 0, "2 3");
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests three inputs.
    function testOpIntSubNPEvalThreeInputs() external {
        checkHappy("_: int-sub(1 0 0);", 1, "1 0 0");
        checkHappy("_: int-sub(1 1 0);", 0, "1 1 0");
        checkHappy("_: int-sub(2 1 1);", 0, "2 1 1");
        checkHappy("_: int-sub(2 2 0);", 0, "2 2 0");
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests three inputs.
    /// Test that saturating does not change the result.
    function testOpIntSubNPEvalThreeInputsSaturating() external {
        checkHappy("_: int-sub<1>(1 0 0);", 1, "1 0 0");
        checkHappy("_: int-sub<1>(1 1 0);", 0, "1 1 0");
        checkHappy("_: int-sub<1>(2 1 1);", 0, "2 1 1");
        checkHappy("_: int-sub<1>(2 2 0);", 0, "2 2 0");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests three inputs.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEvalThreeInputs() external {
        checkHappy("_: decimal18-sub(1 0 0);", 1, "1 0 0");
        checkHappy("_: decimal18-sub(1 1 0);", 0, "1 1 0");
        checkHappy("_: decimal18-sub(2 1 1);", 0, "2 1 1");
        checkHappy("_: decimal18-sub(2 2 0);", 0, "2 2 0");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests three inputs.
    /// Test that saturating does not change the result.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEval3InputsSaturating() external {
        checkHappy("_: decimal18-sub<1>(1 0 0);", 1, "1 0 0");
        checkHappy("_: decimal18-sub<1>(1 1 0);", 0, "1 1 0");
        checkHappy("_: decimal18-sub<1>(2 1 1);", 0, "2 1 1");
        checkHappy("_: decimal18-sub<1>(2 2 0);", 0, "2 2 0");
    }

    /// Test the eval of `int-sub` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where we underflow.
    function testOpIntSubNPEval3InputsUnhappyUnderflow() external {
        checkUnhappyOverflow("_: int-sub(0 0 1);");
        checkUnhappyOverflow("_: int-sub(0 1 2);");
        checkUnhappyOverflow("_: int-sub(1 1 1);");
        checkUnhappyOverflow("_: int-sub(1 2 3);");
        checkUnhappyOverflow("_: int-sub(2 3 4);");
        checkUnhappyOverflow("_: int-sub(3 4 5);");
        checkUnhappyOverflow("_: int-sub(2 2 1);");
    }

    /// Test the eval of `int-sub` opcocde parsed from a string. Tests three inputs.
    /// Tests saturating on an underflow.
    function testOpIntSubNPEval3InputsSaturatingUnderflow() external {
        checkHappy("_: int-sub<1>(0 0 1);", 0, "0 0 1");
        checkHappy("_: int-sub<1>(0 1 2);", 0, "0 1 2");
        checkHappy("_: int-sub<1>(1 1 1);", 0, "1 1 1");
        checkHappy("_: int-sub<1>(1 2 3);", 0, "1 2 3");
        checkHappy("_: int-sub<1>(2 3 4);", 0, "2 3 4");
        checkHappy("_: int-sub<1>(3 4 5);", 0, "3 4 5");
        checkHappy("_: int-sub<1>(2 2 1);", 0, "2 2 1");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests the unhappy path where we underflow.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEval3InputsUnhappyUnderflow() external {
        checkUnhappyOverflow("_: decimal18-sub(0 0 1);");
        checkUnhappyOverflow("_: decimal18-sub(0 1 2);");
        checkUnhappyOverflow("_: decimal18-sub(1 1 1);");
        checkUnhappyOverflow("_: decimal18-sub(1 2 3);");
        checkUnhappyOverflow("_: decimal18-sub(2 3 4);");
        checkUnhappyOverflow("_: decimal18-sub(3 4 5);");
        checkUnhappyOverflow("_: decimal18-sub(2 2 1);");
    }

    /// Test the eval of `decimal18-sub` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests saturating on an underflow.
    /// MUST behave the same as `int-sub`.
    function testOpDecimal18SubNPEval3InputsSaturatingUnderflow() external {
        checkHappy("_: decimal18-sub<1>(0 0 1);", 0, "0 0 1");
        checkHappy("_: decimal18-sub<1>(0 1 2);", 0, "0 1 2");
        checkHappy("_: decimal18-sub<1>(1 1 1);", 0, "1 1 1");
        checkHappy("_: decimal18-sub<1>(1 2 3);", 0, "1 2 3");
        checkHappy("_: decimal18-sub<1>(2 3 4);", 0, "2 3 4");
        checkHappy("_: decimal18-sub<1>(3 4 5);", 0, "3 4 5");
        checkHappy("_: decimal18-sub<1>(2 2 1);", 0, "2 2 1");
    }
}
