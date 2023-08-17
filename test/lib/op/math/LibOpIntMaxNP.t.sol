// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibUint256Array.sol";

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/lib/parse/LibParseOperand.sol";

contract LibOpIntMaxNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIntMaxNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntMaxNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntMaxNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntMaxNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntMaxNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntMaxNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntMaxNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntMaxNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntMaxNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntMaxNP.
    function testOpIntMaxNPRun(InterpreterStateNP memory state, uint256[] memory inputs) external {
        vm.assume(inputs.length >= 2);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        opReferenceCheck(state, operand, LibOpIntMaxNP.referenceFn, LibOpIntMaxNP.integrity, LibOpIntMaxNP.run, inputs);
    }

    /// Test the eval of `int-max` opcode parsed from a string. Tests zero inputs.
    function testOpIntMaxNPEvalZeroInputs() external {
        checkBadInputs("_: int-max();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-max` opcode parsed from a string.
    /// Tests zero inputs.
    /// MUST be identical to `int-max`.
    function testOpDecimal18MaxNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-max();", 0, 2, 0);
    }

    /// Test the eval of `int-max` opcode parsed from a string. Tests one input.
    function testOpIntMaxNPEvalOneInput() external {
        checkBadInputs("_: int-max(5);", 1, 2, 1);
        checkBadInputs("_: int-max(0);", 1, 2, 1);
        checkBadInputs("_: int-max(1);", 1, 2, 1);
        checkBadInputs("_: int-max(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-max` opcode parsed from a string.
    /// Tests one input.
    /// MUST be identical to `int-max`.
    function testOpDecimal18MaxNPEvalOneInput() external {
        checkBadInputs("_: decimal18-max(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-max(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-max(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-max(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `int-max` opcode parsed from a string. Tests two inputs.
    function testOpIntMaxNPEval2InputsHappy() external {
        checkHappy("_: int-max(0 0);", 0, "0 > 0 ? 0 : 1");
        checkHappy("_: int-max(1 0);", 1, "1 > 0 ? 1 : 0");
        checkHappy("_: int-max(max-int-value() 0);", type(uint256).max, "max-int-value() > 0 ? max-int-value() : 0");
        checkHappy("_: int-max(0 1);", 1, "0 > 1 ? 0 : 1");
        checkHappy("_: int-max(1 1);", 1, "1 > 1 ? 1 : 1");
        checkHappy("_: int-max(0 max-int-value());", type(uint256).max, "0 > max-int-value() ? 0 : max-int-value()");
        checkHappy("_: int-max(1 max-int-value());", type(uint256).max, "1 > max-int-value() ? 1 : max-int-value()");
        checkHappy("_: int-max(max-int-value() 1);", type(uint256).max, "1 > max-int-value() ? 1 : max-int-value()");
        checkHappy(
            "_: int-max(max-int-value() max-int-value());",
            type(uint256).max,
            "max-int-value() > max-int-value() ? max-int-value() : max-int-value()"
        );
        checkHappy("_: int-max(0 2);", 2, "0 > 2 ? 0 : 2");
        checkHappy("_: int-max(1 2);", 2, "1 > 2 ? 1 : 2");
        checkHappy("_: int-max(2 2);", 2, "2 > 2 ? 2 : 2");
    }

    /// Test the eval of `decimal18-max` opcode parsed from a string.
    /// Tests two inputs.
    /// MUST be identical to `int-max`.
    function testOpDecimal18MaxNPEval2InputsHappy() external {
        checkHappy("_: decimal18-max(0 0);", 0, "0 > 0 ? 0 : 1");
        checkHappy("_: decimal18-max(1 0);", 1, "1 > 0 ? 1 : 0");
        checkHappy(
            "_: decimal18-max(max-int-value() 0);", type(uint256).max, "max-int-value() > 0 ? max-int-value() : 0"
        );
        checkHappy("_: decimal18-max(0 1);", 1, "0 > 1 ? 0 : 1");
        checkHappy("_: decimal18-max(1 1);", 1, "1 > 1 ? 1 : 1");
        checkHappy(
            "_: decimal18-max(0 max-int-value());", type(uint256).max, "0 > max-int-value() ? 0 : max-int-value()"
        );
        checkHappy(
            "_: decimal18-max(1 max-int-value());", type(uint256).max, "1 > max-int-value() ? 1 : max-int-value()"
        );
        checkHappy(
            "_: decimal18-max(max-int-value() 1);", type(uint256).max, "1 > max-int-value() ? 1 : max-int-value()"
        );
        checkHappy(
            "_: decimal18-max(max-int-value() max-int-value());",
            type(uint256).max,
            "max-int-value() > max-int-value() ? max-int-value() : max-int-value()"
        );
        checkHappy("_: decimal18-max(0 2);", 2, "0 > 2 ? 0 : 2");
        checkHappy("_: decimal18-max(1 2);", 2, "1 > 2 ? 1 : 2");
        checkHappy("_: decimal18-max(2 2);", 2, "2 > 2 ? 2 : 2");
    }

    /// Test the eval of `int-max` opcode parsed from a string. Tests three inputs.
    function testOpIntMaxNPEval3InputsHappy() external {
        checkHappy("_: int-max(0 0 0);", 0, "0 0 0");
        checkHappy("_: int-max(1 0 0);", 1, "1 0 0");
        checkHappy("_: int-max(2 0 0);", 2, "2 0 0");
        checkHappy("_: int-max(0 1 0);", 1, "0 1 0");
        checkHappy("_: int-max(1 1 0);", 1, "1 1 0");
        checkHappy("_: int-max(2 1 0);", 2, "2 1 0");
        checkHappy("_: int-max(0 2 0);", 2, "0 2 0");
        checkHappy("_: int-max(1 2 0);", 2, "1 2 0");
        checkHappy("_: int-max(2 2 0);", 2, "2 2 0");
        checkHappy("_: int-max(0 0 1);", 1, "0 0 1");
        checkHappy("_: int-max(1 0 1);", 1, "1 0 1");
        checkHappy("_: int-max(2 0 1);", 2, "2 0 1");
        checkHappy("_: int-max(0 1 1);", 1, "0 1 1");
        checkHappy("_: int-max(1 1 1);", 1, "1 1 1");
        checkHappy("_: int-max(2 1 1);", 2, "2 1 1");
        checkHappy("_: int-max(0 2 1);", 2, "0 2 1");
        checkHappy("_: int-max(1 2 1);", 2, "1 2 1");
        checkHappy("_: int-max(2 2 1);", 2, "2 2 1");
        checkHappy("_: int-max(0 0 2);", 2, "0 0 2");
        checkHappy("_: int-max(1 0 2);", 2, "1 0 2");
        checkHappy("_: int-max(2 0 2);", 2, "2 0 2");
        checkHappy("_: int-max(0 1 2);", 2, "0 1 2");
        checkHappy("_: int-max(1 1 2);", 2, "1 1 2");
        checkHappy("_: int-max(2 1 2);", 2, "2 1 2");
        checkHappy("_: int-max(0 2 2);", 2, "0 2 2");
        checkHappy("_: int-max(1 2 2);", 2, "1 2 2");
        checkHappy("_: int-max(2 2 2);", 2, "2 2 2");
        checkHappy("_: int-max(0 0 max-int-value());", type(uint256).max, "0 0 max-int-value()");
        checkHappy("_: int-max(1 0 max-int-value());", type(uint256).max, "1 0 max-int-value()");
        checkHappy("_: int-max(2 0 max-int-value());", type(uint256).max, "2 0 max-int-value()");
        checkHappy("_: int-max(0 1 max-int-value());", type(uint256).max, "0 1 max-int-value()");
        checkHappy("_: int-max(1 1 max-int-value());", type(uint256).max, "1 1 max-int-value()");
        checkHappy("_: int-max(2 1 max-int-value());", type(uint256).max, "2 1 max-int-value()");
        checkHappy("_: int-max(0 2 max-int-value());", type(uint256).max, "0 2 max-int-value()");
        checkHappy("_: int-max(1 2 max-int-value());", type(uint256).max, "1 2 max-int-value()");
        checkHappy("_: int-max(2 2 max-int-value());", type(uint256).max, "2 2 max-int-value()");
    }

    /// Test the eval of `decimal18-max` opcode parsed from a string.
    /// Tests three inputs.
    /// MUST be identical to `int-max`.
    function testOpDecimal18MaxNPEval3InputsHappy() external {
        checkHappy("_: decimal18-max(0 0 0);", 0, "0 0 0");
        checkHappy("_: decimal18-max(1 0 0);", 1, "1 0 0");
        checkHappy("_: decimal18-max(2 0 0);", 2, "2 0 0");
        checkHappy("_: decimal18-max(0 1 0);", 1, "0 1 0");
        checkHappy("_: decimal18-max(1 1 0);", 1, "1 1 0");
        checkHappy("_: decimal18-max(2 1 0);", 2, "2 1 0");
        checkHappy("_: decimal18-max(0 2 0);", 2, "0 2 0");
        checkHappy("_: decimal18-max(1 2 0);", 2, "1 2 0");
        checkHappy("_: decimal18-max(2 2 0);", 2, "2 2 0");
        checkHappy("_: decimal18-max(0 0 1);", 1, "0 0 1");
        checkHappy("_: decimal18-max(1 0 1);", 1, "1 0 1");
        checkHappy("_: decimal18-max(2 0 1);", 2, "2 0 1");
        checkHappy("_: decimal18-max(0 1 1);", 1, "0 1 1");
        checkHappy("_: decimal18-max(1 1 1);", 1, "1 1 1");
        checkHappy("_: decimal18-max(2 1 1);", 2, "2 1 1");
        checkHappy("_: decimal18-max(0 2 1);", 2, "0 2 1");
        checkHappy("_: decimal18-max(1 2 1);", 2, "1 2 1");
        checkHappy("_: decimal18-max(2 2 1);", 2, "2 2 1");
        checkHappy("_: decimal18-max(0 0 2);", 2, "0 0 2");
        checkHappy("_: decimal18-max(1 0 2);", 2, "1 0 2");
        checkHappy("_: decimal18-max(2 0 2);", 2, "2 0 2");
        checkHappy("_: decimal18-max(0 1 2);", 2, "0 1 2");
        checkHappy("_: decimal18-max(1 1 2);", 2, "1 1 2");
        checkHappy("_: decimal18-max(2 1 2);", 2, "2 1 2");
        checkHappy("_: decimal18-max(0 2 2);", 2, "0 2 2");
        checkHappy("_: decimal18-max(1 2 2);", 2, "1 2 2");
        checkHappy("_: decimal18-max(2 2 2);", 2, "2 2 2");
        checkHappy("_: decimal18-max(0 0 max-int-value());", type(uint256).max, "0 0 max-int-value()");
        checkHappy("_: decimal18-max(1 0 max-int-value());", type(uint256).max, "1 0 max-int-value()");
        checkHappy("_: decimal18-max(2 0 max-int-value());", type(uint256).max, "2 0 max-int-value()");
        checkHappy("_: decimal18-max(0 1 max-int-value());", type(uint256).max, "0 1 max-int-value()");
        checkHappy("_: decimal18-max(1 1 max-int-value());", type(uint256).max, "1 1 max-int-value()");
        checkHappy("_: decimal18-max(2 1 max-int-value());", type(uint256).max, "2 1 max-int-value()");
        checkHappy("_: decimal18-max(0 2 max-int-value());", type(uint256).max, "0 2 max-int-value()");
        checkHappy("_: decimal18-max(1 2 max-int-value());", type(uint256).max, "1 2 max-int-value()");
        checkHappy("_: decimal18-max(2 2 max-int-value());", type(uint256).max, "2 2 max-int-value()");
    }

    /// Test the eval of `int-max` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntMaxNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-max<>(0 0 0);", 10);
        checkDisallowedOperand("_: int-max<0>(0 0 0);", 10);
        checkDisallowedOperand("_: int-max<1>(0 0 0);", 10);
        checkDisallowedOperand("_: int-max<2>(0 0 0);", 10);
        checkDisallowedOperand("_: int-max<3 1>(0 0 0);", 10);
    }

    /// Test the eval of `decimal18-max` opcode parsed from a string.
    /// Tests that operands are disallowed.
    /// MUST be identical to `int-max`.
    function testOpDecimal18MaxNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: decimal18-max<>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-max<0>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-max<1>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-max<2>(0 0 0);", 16);
        checkDisallowedOperand("_: decimal18-max<3 1>(0 0 0);", 16);
    }
}
