// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {stdError} from "forge-std/Test.sol";
import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP} from "test/abstract/OpTest.sol";
import {LibOpIntAddNP} from "src/lib/op/math/int/LibOpIntAddNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpIntAddNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIntAddNP. This tests the happy
    /// path where the inputs and calc match.
    function testOpIntAddNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 operandData)
        external
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntAddNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntAddNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntAddNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntAddNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntAddNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntAddNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntAddNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntAddNP.
    function testOpIntAddNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        uint256 overflows = 0;
        unchecked {
            uint256 a = inputs[0];
            for (uint256 i = 1; i < inputs.length; i++) {
                uint256 c = a + inputs[i];
                if (c < a) {
                    overflows++;
                }
                a = c;
            }
        }
        if (overflows > 0) {
            vm.expectRevert(stdError.arithmeticError);
        }
        opReferenceCheck(state, operand, LibOpIntAddNP.referenceFn, LibOpIntAddNP.integrity, LibOpIntAddNP.run, inputs);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests zero inputs.
    function testOpIntAddNPEvalZeroInputs() external {
        checkBadInputs("_: int-add();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests zero inputs.
    function testOpDecimal18AddNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-add();", 0, 2, 0);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests one input.
    function testOpIntAddNPEvalOneInput() external {
        checkBadInputs("_: int-add(5e-18);", 1, 2, 1);
    }

    function testOpIntAddNPEvalZeroOutputs() external {
        checkBadOutputs(": int-add(5e-18 6e-18);", 2, 1, 0);
    }

    function testOpIntAddNPEvalTwoOutput() external {
        checkBadOutputs("_ _: int-add(5e-18 6e-18);", 2, 1, 2);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests one input.
    function testOpDecimal18AddNPEvalOneInput() external {
        checkBadInputs("_: decimal18-add(5e-18);", 1, 2, 1);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpIntAddNPEval2InputsHappy() external {
        checkHappy("_: int-add(5e-18 6e-18);", 11, "5 + 6");
        checkHappy("_: int-add(6e-18 5e-18);", 11, "6 + 5");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpDecimal18AddNPEval2InputsHappy() external {
        checkHappy("_: decimal18-add(5e-18 6e-18);", 11, "5 + 6");
        checkHappy("_: decimal18-add(6e-18 5e-18);", 11, "6 + 5");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to 0 is 0.
    function testOpIntAddNPEval2InputsHappyZero() external {
        checkHappy("_: int-add(0 0);", 0, "0 + 0");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to 0 is 0.
    function testOpDecimal18AddNPEval2InputsHappyZero() external {
        checkHappy("_: decimal18-add(0 0);", 0, "0 + 0");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to 1 is 1.
    function testOpIntAddNPEval2InputsHappyZeroOne() external {
        checkHappy("_: int-add(0 1e-18);", 1, "0 + 1");
        checkHappy("_: int-add(1e-18 0);", 1, "1 + 0");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to 1 is 1.
    function testOpDecimal18AddNPEval2InputsHappyZeroOne() external {
        checkHappy("_: decimal18-add(0 1e-18);", 1, "0 + 1");
        checkHappy("_: decimal18-add(1e-18 0);", 1, "1 + 0");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to max-value() is max-value().
    function testOpIntAddNPEval2InputsHappyZeroMax() external {
        checkHappy("_: int-add(0 max-value());", type(uint256).max, "0 + max-value()");
        checkHappy("_: int-add(max-value() 0);", type(uint256).max, "max-value() + 0");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to max-value() is max-value().
    function testOpDecimal18AddNPEval2InputsHappyZeroMax() external {
        checkHappy("_: decimal18-add(0 max-value());", type(uint256).max, "0 + max-value()");
        checkHappy("_: decimal18-add(max-value() 0);", type(uint256).max, "max-value() + 0");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpIntAddNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: int-add(max-value() 1e-18);");
        checkUnhappyOverflow("_: int-add(1e-18 max-value());");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpDecimal18AddNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: decimal18-add(max-value() 1e-18);");
        checkUnhappyOverflow("_: decimal18-add(1e-18 max-value());");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpIntAddNPEval3InputsHappy() external {
        checkHappy("_: int-add(5e-18 6e-18 7e-18);", 18, "5 + 6 + 7");
        checkHappy("_: int-add(6e-18 5e-18 7e-18);", 18, "6 + 5 + 7");
        checkHappy("_: int-add(7e-18 6e-18 5e-18);", 18, "7 + 6 + 5");
        checkHappy("_: int-add(5e-18 7e-18 6e-18);", 18, "5 + 7 + 6");
        checkHappy("_: int-add(6e-18 7e-18 5e-18);", 18, "6 + 7 + 5");
        checkHappy("_: int-add(7e-18 5e-18 6e-18);", 18, "7 + 5 + 6");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpDecimal18AddNPEval3InputsHappy() external {
        checkHappy("_: decimal18-add(5e-18 6e-18 7e-18);", 18, "5 + 6 + 7");
        checkHappy("_: decimal18-add(6e-18 5e-18 7e-18);", 18, "6 + 5 + 7");
        checkHappy("_: decimal18-add(7e-18 6e-18 5e-18);", 18, "7 + 6 + 5");
        checkHappy("_: decimal18-add(5e-18 7e-18 6e-18);", 18, "5 + 7 + 6");
        checkHappy("_: decimal18-add(6e-18 7e-18 5e-18);", 18, "6 + 7 + 5");
        checkHappy("_: decimal18-add(7e-18 5e-18 6e-18);", 18, "7 + 5 + 6");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpIntAddNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: int-add(max-value() 1e-18 1e-18);");
        checkUnhappyOverflow("_: int-add(1e-18 max-value() 1e-18);");
        checkUnhappyOverflow("_: int-add(1e-18 1e-18 max-value());");
        checkUnhappyOverflow("_: int-add(max-value() max-value() 1e-18);");
        checkUnhappyOverflow("_: int-add(max-value() 1e-18 max-value());");
        checkUnhappyOverflow("_: int-add(1e-18 max-value() max-value());");
        checkUnhappyOverflow("_: int-add(max-value() max-value() max-value());");
        checkUnhappyOverflow("_: int-add(max-value() 1e-18 0);");
        checkUnhappyOverflow("_: int-add(1e-18 max-value() 0);");
        checkUnhappyOverflow("_: int-add(1e-18 0 max-value());");
        checkUnhappyOverflow("_: int-add(max-value() max-value() 0);");
        checkUnhappyOverflow("_: int-add(max-value() 0 max-value());");
        checkUnhappyOverflow("_: int-add(0 max-value() max-value());");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpDecimal18AddNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: decimal18-add(max-value() 1e-18 1e-18);");
        checkUnhappyOverflow("_: decimal18-add(1e-18 max-value() 1e-18);");
        checkUnhappyOverflow("_: decimal18-add(1e-18 1e-18 max-value());");
        checkUnhappyOverflow("_: decimal18-add(max-value() max-value() 1e-18);");
        checkUnhappyOverflow("_: decimal18-add(max-value() 1e-18 max-value());");
        checkUnhappyOverflow("_: decimal18-add(1e-18 max-value() max-value());");
        checkUnhappyOverflow("_: decimal18-add(max-value() max-value() max-value());");
        checkUnhappyOverflow("_: decimal18-add(max-value() 1e-18 0);");
        checkUnhappyOverflow("_: decimal18-add(1e-18 max-value() 0);");
        checkUnhappyOverflow("_: decimal18-add(1e-18 0 max-value());");
        checkUnhappyOverflow("_: decimal18-add(max-value() max-value() 0);");
        checkUnhappyOverflow("_: decimal18-add(max-value() 0 max-value());");
        checkUnhappyOverflow("_: decimal18-add(0 max-value() max-value());");
    }

    /// Test the eval of `int-add` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntAddNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-add<0>(0 0 0);");
        checkDisallowedOperand("_: int-add<1>(0 0 0);");
        checkDisallowedOperand("_: int-add<2>(0 0 0);");
        checkDisallowedOperand("_: int-add<0 0>(0 0 0);");
        checkDisallowedOperand("_: int-add<0 1>(0 0 0);");
        checkDisallowedOperand("_: int-add<1 0>(0 0 0);");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests that operands are disallowed.
    function testOpDecimal18AddNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: decimal18-add<0>(0 0 0);");
        checkDisallowedOperand("_: decimal18-add<1>(0 0 0);");
        checkDisallowedOperand("_: decimal18-add<2>(0 0 0);");
        checkDisallowedOperand("_: decimal18-add<0 0>(0 0 0);");
        checkDisallowedOperand("_: decimal18-add<0 1>(0 0 0);");
        checkDisallowedOperand("_: decimal18-add<1 0>(0 0 0);");
    }
}
