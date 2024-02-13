// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUint256Array} from  "rain.solmem/lib/LibUint256Array.sol";

import {OpTest, IntegrityCheckStateNP, InterpreterStateNP} from "test/abstract/OpTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOpIntMinNP} from "src/lib/op/math/int/LibOpIntMinNP.sol";
import {LibOperand, Operand} from "test/lib/operand/LibOperand.sol";

contract LibOpIntMinNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIntMinNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntMinNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 operandData) external {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntMinNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntMinNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntMinNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntMinNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntMinNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntMinNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntMinNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntMinNP.
    function testOpIntMinNPRun(uint256[] memory inputs, uint16 operandData) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, operandData);
        opReferenceCheck(state, operand, LibOpIntMinNP.referenceFn, LibOpIntMinNP.integrity, LibOpIntMinNP.run, inputs);
    }

    /// Test the eval of `int-min` opcode parsed from a string. Tests zero inputs.
    function testOpIntMinNPEvalZeroInputs() external {
        checkBadInputs("_: int-min();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-min` opcode parsed from a string.
    /// Tests zero inputs.
    /// MUST be identical to `int-min`.
    function testOpDecimal18MinNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-min();", 0, 2, 0);
    }

    /// Test the eval of `int-min` opcode parsed from a string. Tests one input.
    function testOpIntMinNPEvalOneInput() external {
        checkBadInputs("_: int-min(5);", 1, 2, 1);
        checkBadInputs("_: int-min(0);", 1, 2, 1);
        checkBadInputs("_: int-min(1);", 1, 2, 1);
        checkBadInputs("_: int-min(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-min` opcode parsed from a string.
    /// Tests one input.
    /// MUST be identical to `int-min`.
    function testOpDecimal18MinNPEvalOneInput() external {
        checkBadInputs("_: decimal18-min(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-min(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-min(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-min(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `int-min` opcode parsed from a string. Tests two inputs.
    function testOpIntMinNPEval2InputsHappy() external {
        checkHappy("_: int-min(0 0);", 0, "0 > 0 ? 0 : 1");
        checkHappy("_: int-min(1 0);", 0, "1 > 0 ? 1 : 0");
        checkHappy("_: int-min(max-int-value() 0);", 0, "max-int-value() > 0 ? max-int-value() : 0");
        checkHappy("_: int-min(0 1);", 0, "0 > 1 ? 0 : 1");
        checkHappy("_: int-min(1 1);", 1, "1 > 1 ? 1 : 1");
        checkHappy("_: int-min(0 max-int-value());", 0, "0 > max-int-value() ? 0 : max-int-value()");
        checkHappy("_: int-min(1 max-int-value());", 1, "1 > max-int-value() ? 1 : max-int-value()");
        checkHappy("_: int-min(max-int-value() 1);", 1, "1 > max-int-value() ? 1 : max-int-value()");
        checkHappy(
            "_: int-min(max-int-value() max-int-value());",
            type(uint256).max,
            "max-int-value() > max-int-value() ? max-int-value() : max-int-value()"
        );
        checkHappy("_: int-min(0 2);", 0, "0 > 2 ? 0 : 2");
        checkHappy("_: int-min(1 2);", 1, "1 > 2 ? 1 : 2");
        checkHappy("_: int-min(2 2);", 2, "2 > 2 ? 2 : 2");
    }

    /// Test the eval of `decimal18-min` opcode parsed from a string.
    /// Tests two inputs.
    /// MUST be identical to `int-min`.
    function testOpDecimal18MinNPEval2InputsHappy() external {
        checkHappy("_: decimal18-min(0 0);", 0, "0 > 0 ? 0 : 1");
        checkHappy("_: decimal18-min(1 0);", 0, "1 > 0 ? 1 : 0");
        checkHappy(
            "_: decimal18-min(max-decimal18-value() 0);", 0, "max-decimal18-value() > 0 ? max-decimal18-value() : 0"
        );
        checkHappy("_: decimal18-min(0 1);", 0, "0 > 1 ? 0 : 1");
        checkHappy("_: decimal18-min(1 1);", 1, "1 > 1 ? 1 : 1");
        checkHappy(
            "_: decimal18-min(0 max-decimal18-value());", 0, "0 > max-decimal18-value() ? 0 : max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(1 max-decimal18-value());", 1, "1 > max-decimal18-value() ? 1 : max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() 1);", 1, "1 > max-decimal18-value() ? 1 : max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() max-decimal18-value());",
            type(uint256).max,
            "max-decimal18-value() > max-decimal18-value() ? max-decimal18-value() : max-decimal18-value()"
        );
        checkHappy("_: decimal18-min(0 2);", 0, "0 > 2 ? 0 : 2");
        checkHappy("_: decimal18-min(1 2);", 1, "1 > 2 ? 1 : 2");
        checkHappy("_: decimal18-min(2 2);", 2, "2 > 2 ? 2 : 2");
    }

    /// Test the eval of `int-min` opcode parsed from a string. Tests three inputs.
    function testOpIntMinNPEval3InputsHappy() external {
        checkHappy("_: int-min(0 0 0);", 0, "0 0 0");
        checkHappy("_: int-min(1 0 0);", 0, "1 0 0");
        checkHappy("_: int-min(2 0 0);", 0, "2 0 0");
        checkHappy("_: int-min(0 1 0);", 0, "0 1 0");
        checkHappy("_: int-min(1 1 0);", 0, "1 1 0");
        checkHappy("_: int-min(2 1 0);", 0, "2 1 0");
        checkHappy("_: int-min(0 2 0);", 0, "0 2 0");
        checkHappy("_: int-min(1 2 0);", 0, "1 2 0");
        checkHappy("_: int-min(2 2 0);", 0, "2 2 0");
        checkHappy("_: int-min(0 0 1);", 0, "0 0 1");
        checkHappy("_: int-min(1 0 1);", 0, "1 0 1");
        checkHappy("_: int-min(2 0 1);", 0, "2 0 1");
        checkHappy("_: int-min(0 1 1);", 0, "0 1 1");
        checkHappy("_: int-min(1 1 1);", 1, "1 1 1");
        checkHappy("_: int-min(2 1 1);", 1, "2 1 1");
        checkHappy("_: int-min(0 2 1);", 0, "0 2 1");
        checkHappy("_: int-min(1 2 1);", 1, "1 2 1");
        checkHappy("_: int-min(2 2 1);", 1, "2 2 1");
        checkHappy("_: int-min(0 0 2);", 0, "0 0 2");
        checkHappy("_: int-min(1 0 2);", 0, "1 0 2");
        checkHappy("_: int-min(2 0 2);", 0, "2 0 2");
        checkHappy("_: int-min(0 1 2);", 0, "0 1 2");
        checkHappy("_: int-min(1 1 2);", 1, "1 1 2");
        checkHappy("_: int-min(2 1 2);", 1, "2 1 2");
        checkHappy("_: int-min(0 2 2);", 0, "0 2 2");
        checkHappy("_: int-min(1 2 2);", 1, "1 2 2");
        checkHappy("_: int-min(2 2 2);", 2, "2 2 2");
        checkHappy("_: int-min(0 0 max-int-value());", 0, "0 0 max-int-value()");
        checkHappy("_: int-min(1 0 max-int-value());", 0, "1 0 max-int-value()");
        checkHappy("_: int-min(2 0 max-int-value());", 0, "2 0 max-int-value()");
        checkHappy("_: int-min(0 1 max-int-value());", 0, "0 1 max-int-value()");
        checkHappy("_: int-min(1 1 max-int-value());", 1, "1 1 max-int-value()");
        checkHappy("_: int-min(2 1 max-int-value());", 1, "2 1 max-int-value()");
        checkHappy("_: int-min(0 2 max-int-value());", 0, "0 2 max-int-value()");
        checkHappy("_: int-min(1 2 max-int-value());", 1, "1 2 max-int-value()");
        checkHappy("_: int-min(2 2 max-int-value());", 2, "2 2 max-int-value()");
        checkHappy("_: int-min(0 max-int-value() 0);", 0, "0 max-int-value() 0");
        checkHappy("_: int-min(1 max-int-value() 0);", 0, "1 max-int-value() 0");
        checkHappy("_: int-min(2 max-int-value() 0);", 0, "2 max-int-value() 0");
        checkHappy("_: int-min(0 max-int-value() 1);", 0, "0 max-int-value() 1");
        checkHappy("_: int-min(1 max-int-value() 1);", 1, "1 max-int-value() 1");
        checkHappy("_: int-min(2 max-int-value() 1);", 1, "2 max-int-value() 1");
        checkHappy("_: int-min(0 max-int-value() 2);", 0, "0 max-int-value() 2");
        checkHappy("_: int-min(1 max-int-value() 2);", 1, "1 max-int-value() 2");
        checkHappy("_: int-min(2 max-int-value() 2);", 2, "2 max-int-value() 2");
        checkHappy("_: int-min(0 max-int-value() max-int-value());", 0, "0 max-int-value() max-int-value()");
        checkHappy("_: int-min(1 max-int-value() max-int-value());", 1, "1 max-int-value() max-int-value()");
        checkHappy("_: int-min(2 max-int-value() max-int-value());", 2, "2 max-int-value() max-int-value()");
        checkHappy("_: int-min(max-int-value() 0 0);", 0, "max-int-value() 0 0");
        checkHappy("_: int-min(max-int-value() 1 0);", 0, "max-int-value() 1 0");
        checkHappy("_: int-min(max-int-value() 2 0);", 0, "max-int-value() 2 0");
        checkHappy("_: int-min(max-int-value() 0 1);", 0, "max-int-value() 0 1");
        checkHappy("_: int-min(max-int-value() 1 1);", 1, "max-int-value() 1 1");
        checkHappy("_: int-min(max-int-value() 2 1);", 1, "max-int-value() 2 1");
        checkHappy("_: int-min(max-int-value() 0 2);", 0, "max-int-value() 0 2");
        checkHappy("_: int-min(max-int-value() 1 2);", 1, "max-int-value() 1 2");
        checkHappy("_: int-min(max-int-value() 2 2);", 2, "max-int-value() 2 2");
        checkHappy("_: int-min(max-int-value() 0 max-int-value());", 0, "max-int-value() 0 max-int-value()");
        checkHappy("_: int-min(max-int-value() 1 max-int-value());", 1, "max-int-value() 1 max-int-value()");
        checkHappy("_: int-min(max-int-value() 2 max-int-value());", 2, "max-int-value() 2 max-int-value()");
        checkHappy("_: int-min(max-int-value() max-int-value() 0);", 0, "max-int-value() max-int-value() 0");
        checkHappy("_: int-min(max-int-value() max-int-value() 1);", 1, "max-int-value() max-int-value() 1");
        checkHappy("_: int-min(max-int-value() max-int-value() 2);", 2, "max-int-value() max-int-value() 2");
        checkHappy(
            "_: int-min(max-int-value() max-int-value() max-int-value());",
            type(uint256).max,
            "max-int-value() max-int-value() max-int-value()"
        );
    }

    /// Test the eval of `decimal18-min` opcode parsed from a string.
    /// Tests three inputs.
    /// MUST be identical to `int-min`.
    function testOpDecimal18MinNPEval3InputsHappy() external {
        checkHappy("_: decimal18-min(0 0 0);", 0, "0 0 0");
        checkHappy("_: decimal18-min(1 0 0);", 0, "1 0 0");
        checkHappy("_: decimal18-min(2 0 0);", 0, "2 0 0");
        checkHappy("_: decimal18-min(0 1 0);", 0, "0 1 0");
        checkHappy("_: decimal18-min(1 1 0);", 0, "1 1 0");
        checkHappy("_: decimal18-min(2 1 0);", 0, "2 1 0");
        checkHappy("_: decimal18-min(0 2 0);", 0, "0 2 0");
        checkHappy("_: decimal18-min(1 2 0);", 0, "1 2 0");
        checkHappy("_: decimal18-min(2 2 0);", 0, "2 2 0");
        checkHappy("_: decimal18-min(0 0 1);", 0, "0 0 1");
        checkHappy("_: decimal18-min(1 0 1);", 0, "1 0 1");
        checkHappy("_: decimal18-min(2 0 1);", 0, "2 0 1");
        checkHappy("_: decimal18-min(0 1 1);", 0, "0 1 1");
        checkHappy("_: decimal18-min(1 1 1);", 1, "1 1 1");
        checkHappy("_: decimal18-min(2 1 1);", 1, "2 1 1");
        checkHappy("_: decimal18-min(0 2 1);", 0, "0 2 1");
        checkHappy("_: decimal18-min(1 2 1);", 1, "1 2 1");
        checkHappy("_: decimal18-min(2 2 1);", 1, "2 2 1");
        checkHappy("_: decimal18-min(0 0 2);", 0, "0 0 2");
        checkHappy("_: decimal18-min(1 0 2);", 0, "1 0 2");
        checkHappy("_: decimal18-min(2 0 2);", 0, "2 0 2");
        checkHappy("_: decimal18-min(0 1 2);", 0, "0 1 2");
        checkHappy("_: decimal18-min(1 1 2);", 1, "1 1 2");
        checkHappy("_: decimal18-min(2 1 2);", 1, "2 1 2");
        checkHappy("_: decimal18-min(0 2 2);", 0, "0 2 2");
        checkHappy("_: decimal18-min(1 2 2);", 1, "1 2 2");
        checkHappy("_: decimal18-min(2 2 2);", 2, "2 2 2");
        checkHappy("_: decimal18-min(0 0 max-decimal18-value());", 0, "0 0 max-decimal18-value()");
        checkHappy("_: decimal18-min(1 0 max-decimal18-value());", 0, "1 0 max-decimal18-value()");
        checkHappy("_: decimal18-min(2 0 max-decimal18-value());", 0, "2 0 max-decimal18-value()");
        checkHappy("_: decimal18-min(0 1 max-decimal18-value());", 0, "0 1 max-decimal18-value()");
        checkHappy("_: decimal18-min(1 1 max-decimal18-value());", 1, "1 1 max-decimal18-value()");
        checkHappy("_: decimal18-min(2 1 max-decimal18-value());", 1, "2 1 max-decimal18-value()");
        checkHappy("_: decimal18-min(0 2 max-decimal18-value());", 0, "0 2 max-decimal18-value()");
        checkHappy("_: decimal18-min(1 2 max-decimal18-value());", 1, "1 2 max-decimal18-value()");
        checkHappy("_: decimal18-min(2 2 max-decimal18-value());", 2, "2 2 max-decimal18-value()");
        checkHappy("_: decimal18-min(0 max-decimal18-value() 0);", 0, "0 max-decimal18-value() 0");
        checkHappy("_: decimal18-min(1 max-decimal18-value() 0);", 0, "1 max-decimal18-value() 0");
        checkHappy("_: decimal18-min(2 max-decimal18-value() 0);", 0, "2 max-decimal18-value() 0");
        checkHappy("_: decimal18-min(0 max-decimal18-value() 1);", 0, "0 max-decimal18-value() 1");
        checkHappy("_: decimal18-min(1 max-decimal18-value() 1);", 1, "1 max-decimal18-value() 1");
        checkHappy("_: decimal18-min(2 max-decimal18-value() 1);", 1, "2 max-decimal18-value() 1");
        checkHappy("_: decimal18-min(0 max-decimal18-value() 2);", 0, "0 max-decimal18-value() 2");
        checkHappy("_: decimal18-min(1 max-decimal18-value() 2);", 1, "1 max-decimal18-value() 2");
        checkHappy("_: decimal18-min(2 max-decimal18-value() 2);", 2, "2 max-decimal18-value() 2");
        checkHappy(
            "_: decimal18-min(0 max-decimal18-value() max-decimal18-value());",
            0,
            "0 max-decimal18-value() max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(1 max-decimal18-value() max-decimal18-value());",
            1,
            "1 max-decimal18-value() max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(2 max-decimal18-value() max-decimal18-value());",
            2,
            "2 max-decimal18-value() max-decimal18-value()"
        );
        checkHappy("_: decimal18-min(max-decimal18-value() 0 0);", 0, "max-decimal18-value() 0 0");
        checkHappy("_: decimal18-min(max-decimal18-value() 1 0);", 0, "max-decimal18-value() 1 0");
        checkHappy("_: decimal18-min(max-decimal18-value() 2 0);", 0, "max-decimal18-value() 2 0");
        checkHappy("_: decimal18-min(max-decimal18-value() 0 1);", 0, "max-decimal18-value() 0 1");
        checkHappy("_: decimal18-min(max-decimal18-value() 1 1);", 1, "max-decimal18-value() 1 1");
        checkHappy("_: decimal18-min(max-decimal18-value() 2 1);", 1, "max-decimal18-value() 2 1");
        checkHappy("_: decimal18-min(max-decimal18-value() 0 2);", 0, "max-decimal18-value() 0 2");
        checkHappy("_: decimal18-min(max-decimal18-value() 1 2);", 1, "max-decimal18-value() 1 2");
        checkHappy("_: decimal18-min(max-decimal18-value() 2 2);", 2, "max-decimal18-value() 2 2");
        checkHappy(
            "_: decimal18-min(max-decimal18-value() 0 max-decimal18-value());",
            0,
            "max-decimal18-value() 0 max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() 1 max-decimal18-value());",
            1,
            "max-decimal18-value() 1 max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() 2 max-decimal18-value());",
            2,
            "max-decimal18-value() 2 max-decimal18-value()"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() max-decimal18-value() 0);",
            0,
            "max-decimal18-value() max-decimal18-value() 0"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() max-decimal18-value() 1);",
            1,
            "max-decimal18-value() max-decimal18-value() 1"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() max-decimal18-value() 2);",
            2,
            "max-decimal18-value() max-decimal18-value() 2"
        );
        checkHappy(
            "_: decimal18-min(max-decimal18-value() max-decimal18-value() max-decimal18-value());",
            type(uint256).max,
            "max-decimal18-value() max-decimal18-value() max-decimal18-value()"
        );
    }

    /// Test the eval of `int-min` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntMinNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-min<0>(0 0 0);");
        checkDisallowedOperand("_: int-min<1>(0 0 0);");
        checkDisallowedOperand("_: int-min<2>(0 0 0);");
        checkDisallowedOperand("_: int-min<3 1>(0 0 0);");
    }

    /// Test the eval of `decimal18-min` opcode parsed from a string.
    /// Tests that operands are disallowed.
    /// MUST be identical to `int-min`.
    function testOpDecimal18MinNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: decimal18-min<0>(0 0 0);");
        checkDisallowedOperand("_: decimal18-min<1>(0 0 0);");
        checkDisallowedOperand("_: decimal18-min<2>(0 0 0);");
        checkDisallowedOperand("_: decimal18-min<3 1>(0 0 0);");
    }
}
