// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import {LibOpIntAddNP} from "src/lib/op/math/int/LibOpIntAddNP.sol";

contract LibOpIntAddNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIntAddNP. This tests the happy
    /// path where the inputs and calc match.
    function testOpIntAddNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntAddNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

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
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
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
        checkBadInputs("_: int-add(5);", 1, 2, 1);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests one input.
    function testOpDecimal18AddNPEvalOneInput() external {
        checkBadInputs("_: decimal18-add(5);", 1, 2, 1);
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpIntAddNPEval2InputsHappy() external {
        checkHappy("_: int-add(5 6);", 11, "5 + 6");
        checkHappy("_: int-add(6 5);", 11, "6 + 5");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpDecimal18AddNPEval2InputsHappy() external {
        checkHappy("_: decimal18-add(5 6);", 11, "5 + 6");
        checkHappy("_: decimal18-add(6 5);", 11, "6 + 5");
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
        checkHappy("_: int-add(0 1);", 1, "0 + 1");
        checkHappy("_: int-add(1 0);", 1, "1 + 0");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to 1 is 1.
    function testOpDecimal18AddNPEval2InputsHappyZeroOne() external {
        checkHappy("_: decimal18-add(0 1);", 1, "0 + 1");
        checkHappy("_: decimal18-add(1 0);", 1, "1 + 0");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to max-int-value() is max-int-value().
    function testOpIntAddNPEval2InputsHappyZeroMax() external {
        checkHappy("_: int-add(0 max-int-value());", type(uint256).max, "0 + max-int-value()");
        checkHappy("_: int-add(max-int-value() 0);", type(uint256).max, "max-int-value() + 0");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests that adding 0 to max-int-value() is max-int-value().
    function testOpDecimal18AddNPEval2InputsHappyZeroMax() external {
        checkHappy("_: decimal18-add(0 max-int-value());", type(uint256).max, "0 + max-int-value()");
        checkHappy("_: decimal18-add(max-int-value() 0);", type(uint256).max, "max-int-value() + 0");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpIntAddNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: int-add(max-int-value() 1);");
        checkUnhappyOverflow("_: int-add(1 max-int-value());");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests two inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpDecimal18AddNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: decimal18-add(max-int-value() 1);");
        checkUnhappyOverflow("_: decimal18-add(1 max-int-value());");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpIntAddNPEval3InputsHappy() external {
        checkHappy("_: int-add(5 6 7);", 18, "5 + 6 + 7");
        checkHappy("_: int-add(6 5 7);", 18, "6 + 5 + 7");
        checkHappy("_: int-add(7 6 5);", 18, "7 + 6 + 5");
        checkHappy("_: int-add(5 7 6);", 18, "5 + 7 + 6");
        checkHappy("_: int-add(6 7 5);", 18, "6 + 7 + 5");
        checkHappy("_: int-add(7 5 6);", 18, "7 + 5 + 6");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpDecimal18AddNPEval3InputsHappy() external {
        checkHappy("_: decimal18-add(5 6 7);", 18, "5 + 6 + 7");
        checkHappy("_: decimal18-add(6 5 7);", 18, "6 + 5 + 7");
        checkHappy("_: decimal18-add(7 6 5);", 18, "7 + 6 + 5");
        checkHappy("_: decimal18-add(5 7 6);", 18, "5 + 7 + 6");
        checkHappy("_: decimal18-add(6 7 5);", 18, "6 + 7 + 5");
        checkHappy("_: decimal18-add(7 5 6);", 18, "7 + 5 + 6");
    }

    /// Test the eval of `int-add` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpIntAddNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: int-add(max-int-value() 1 1);");
        checkUnhappyOverflow("_: int-add(1 max-int-value() 1);");
        checkUnhappyOverflow("_: int-add(1 1 max-int-value());");
        checkUnhappyOverflow("_: int-add(max-int-value() max-int-value() 1);");
        checkUnhappyOverflow("_: int-add(max-int-value() 1 max-int-value());");
        checkUnhappyOverflow("_: int-add(1 max-int-value() max-int-value());");
        checkUnhappyOverflow("_: int-add(max-int-value() max-int-value() max-int-value());");
        checkUnhappyOverflow("_: int-add(max-int-value() 1 0);");
        checkUnhappyOverflow("_: int-add(1 max-int-value() 0);");
        checkUnhappyOverflow("_: int-add(1 0 max-int-value());");
        checkUnhappyOverflow("_: int-add(max-int-value() max-int-value() 0);");
        checkUnhappyOverflow("_: int-add(max-int-value() 0 max-int-value());");
        checkUnhappyOverflow("_: int-add(0 max-int-value() max-int-value());");
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpDecimal18AddNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: decimal18-add(max-int-value() 1 1);");
        checkUnhappyOverflow("_: decimal18-add(1 max-int-value() 1);");
        checkUnhappyOverflow("_: decimal18-add(1 1 max-int-value());");
        checkUnhappyOverflow("_: decimal18-add(max-int-value() max-int-value() 1);");
        checkUnhappyOverflow("_: decimal18-add(max-int-value() 1 max-int-value());");
        checkUnhappyOverflow("_: decimal18-add(1 max-int-value() max-int-value());");
        checkUnhappyOverflow("_: decimal18-add(max-int-value() max-int-value() max-int-value());");
        checkUnhappyOverflow("_: decimal18-add(max-int-value() 1 0);");
        checkUnhappyOverflow("_: decimal18-add(1 max-int-value() 0);");
        checkUnhappyOverflow("_: decimal18-add(1 0 max-int-value());");
        checkUnhappyOverflow("_: decimal18-add(max-int-value() max-int-value() 0);");
        checkUnhappyOverflow("_: decimal18-add(max-int-value() 0 max-int-value());");
        checkUnhappyOverflow("_: decimal18-add(0 max-int-value() max-int-value());");
    }

    /// Test the eval of `int-add` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntAddNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-add<>(0 0);", 10);
        checkDisallowedOperand("_: int-add<0>(0 0 0);", 10);
        checkDisallowedOperand("_: int-add<1>(0 0 0);", 10);
        checkDisallowedOperand("_: int-add<2>(0 0 0);", 10);
        checkDisallowedOperand("_: int-add<0 0>(0 0 0);", 10);
        checkDisallowedOperand("_: int-add<0 1>(0 0 0);", 10);
        checkDisallowedOperand("_: int-add<1 0>(0 0 0);", 10);
    }

    /// Test the eval of `decimal18-add` opcode parsed from a string.
    /// MUST behave identically to `int-add`.
    /// Tests that operands are disallowed.
    function testOpDecimal18AddNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: decimal18-add<>(0 0);", 16);
        checkDisallowedOperand("_: decimal18-add<0>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-add<1>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-add<2>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-add<0 0>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-add<0 1>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-add<1 0>(0 0 0);", 16);
    }
}
