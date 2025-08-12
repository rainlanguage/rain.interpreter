// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, OperandV2, InterpreterState} from "test/abstract/OpTest.sol";
import {LibOpAdd} from "src/lib/op/math/LibOpAdd.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";
import {LibDecimalFloatImplementation} from "rain.math.float/lib/implementation/LibDecimalFloatImplementation.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract LibOpAddTest is OpTest {
    /// Directly test the integrity logic of LibOpAdd. This tests the happy
    /// path where the inputs and calc match.
    function testOpAddIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
        external
        pure
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAdd.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpAdd. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpAddIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAdd.integrity(state, OperandV2.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpAdd. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpAddIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpAdd.integrity(state, OperandV2.wrap(bytes32(uint256(0x010000))));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function _testOpAddRun(OperandV2 operand, StackItem[] memory inputs) external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        opReferenceCheck(state, operand, LibOpAdd.referenceFn, LibOpAdd.integrity, LibOpAdd.run, inputs);
    }

    /// Directly test the runtime logic of LibOpAdd.
    function testOpAddRun(StackItem[] memory inputs) external {
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        OperandV2 operand = LibOperand.build(uint8(inputs.length), 1, 0);
        uint256 overflows = 0;
        (int256 signedCoefficientA, int256 exponentA) = LibDecimalFloat.unpack(Float.wrap(StackItem.unwrap(inputs[0])));
        if (int32(exponentA) != exponentA) {
            overflows++;
        }

        for (uint256 i = 1; i < inputs.length; i++) {
            (int256 signedCoefficientB, int256 exponentB) =
                LibDecimalFloat.unpack(Float.wrap(StackItem.unwrap(inputs[i])));

            if (int32(exponentB) != exponentB) {
                overflows++;
            }

            (signedCoefficientA, exponentA) =
                LibDecimalFloatImplementation.add(signedCoefficientA, exponentA, signedCoefficientB, exponentB);

            if (int32(exponentA) != exponentA) {
                overflows++;
            }
        }

        if (overflows > 0) {
            vm.expectRevert();
        }
        this._testOpAddRun(operand, inputs);
    }

    /// Test the eval of `add` opcode parsed from a string. Tests zero inputs.
    function testOpAddEvalZeroInputs() external {
        checkBadInputs("_: add();", 0, 2, 0);
    }

    /// Test the eval of `add` opcode parsed from a string. Tests one input.
    function testOpAddEvalOneInput() external {
        checkBadInputs("_: add(5e-18);", 1, 2, 1);
    }

    function testOpAddEvalZeroOutputs() external {
        checkBadOutputs(": add(5e-18 6e-18);", 2, 1, 0);
    }

    function testOpAddEvalTwoOutput() external {
        checkBadOutputs("_ _: add(5e-18 6e-18);", 2, 1, 2);
    }

    /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
    function testOpAddEval2InputsHappy() external view {
        checkHappy("_: add(5 6);", Float.unwrap(LibDecimalFloat.packLossless(11e66, -66)), "5 + 6");
        checkHappy("_: add(6 5);", Float.unwrap(LibDecimalFloat.packLossless(11e66, -66)), "6 + 5");

        checkHappy("_: add(-5 -6);", Float.unwrap(LibDecimalFloat.packLossless(-11e66, -66)), "-5 + -6");
        checkHappy("_: add(-6 -5);", Float.unwrap(LibDecimalFloat.packLossless(-11e66, -66)), "-6 + -5");

        checkHappy("_: add(-5 6);", Float.unwrap(LibDecimalFloat.packLossless(1e67, -67)), "-5 + 6");
        checkHappy("_: add(6 -5);", Float.unwrap(LibDecimalFloat.packLossless(1e67, -67)), "6 + -5");

        // Mixed-sign cancellation to zero should canonicalize to the zero encoding.
        checkHappy("_: add(5 -5);", Float.unwrap(LibDecimalFloat.packLossless(0, -75)), "5 + -5");
        checkHappy("_: add(-5 5);", Float.unwrap(LibDecimalFloat.packLossless(0, -75)), "-5 + 5");
    }

    /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to 0 is 0.
    function testOpAddEval2InputsHappyZero() external view {
        checkHappy("_: add(0 0);", 0, "0 + 0");
    }

    /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to 1 is 1.
    function testOpAddEval2InputsHappyZeroOne() external view {
        checkHappy("_: add(0 1);", Float.unwrap(LibDecimalFloat.packLossless(1, 0)), "0 + 1");
        checkHappy("_: add(1 0);", Float.unwrap(LibDecimalFloat.packLossless(1, 0)), "0 + 1");
        checkHappy("_: add(0 1e-18);", Float.unwrap(LibDecimalFloat.packLossless(1, -18)), "0 + 1");
        checkHappy("_: add(1e-18 0);", Float.unwrap(LibDecimalFloat.packLossless(1, -18)), "1 + 0");
    }

    /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
    /// Tests that adding 0 to max-positive-value() is max-positive-value().
    function testOpAddEval2InputsHappyZeroMax() external view {
        checkHappy(
            "_: add(0 max-positive-value());",
            Float.unwrap(LibDecimalFloat.packLossless(type(int224).max, type(int32).max)),
            "0 + max-positive-value()"
        );
        checkHappy(
            "_: add(max-positive-value() 0);",
            Float.unwrap(LibDecimalFloat.packLossless(type(int224).max, type(int32).max)),
            "max-positive-value() + 0"
        );
    }

    /// Test the eval of `add` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where the addition does not overflow.
    function testOpAddEval3InputsHappy() external view {
        checkHappy("_: add(5 6 7);", Float.unwrap(LibDecimalFloat.packLossless(18e65, -65)), "5 + 6 + 7");
        checkHappy("_: add(6 5 7);", Float.unwrap(LibDecimalFloat.packLossless(18e65, -65)), "6 + 5 + 7");
        checkHappy("_: add(7 6 5);", Float.unwrap(LibDecimalFloat.packLossless(18e65, -65)), "7 + 6 + 5");
        checkHappy("_: add(5 7 6);", Float.unwrap(LibDecimalFloat.packLossless(18e65, -65)), "5 + 7 + 6");
        checkHappy("_: add(7 5 6);", Float.unwrap(LibDecimalFloat.packLossless(18e65, -65)), "7 + 5 + 6");
        checkHappy("_: add(5 -6 1);", Float.unwrap(LibDecimalFloat.packLossless(0, -75)), "5 + -6 + 1");
    }

    /// Test the eval of `add` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where the addition does overflow.
    function testOpAddEval3InputsUnhappy() external {
        checkUnhappyOverflow(
            "_: add(max-positive-value() max-positive-value() 1e-18);",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
        checkUnhappyOverflow(
            "_: add(max-positive-value() 1e-18 max-positive-value());",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
        checkUnhappyOverflow(
            "_: add(1e-18 max-positive-value() max-positive-value());",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
        checkUnhappyOverflow(
            "_: add(max-positive-value() max-positive-value() max-positive-value());",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
        checkUnhappyOverflow(
            "_: add(max-positive-value() max-positive-value() 0);",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
        checkUnhappyOverflow(
            "_: add(max-positive-value() 0 max-positive-value());",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
        checkUnhappyOverflow(
            "_: add(0 max-positive-value() max-positive-value());",
            2695994666715063979466701508701963067363714442254057248110361024921,
            2147483648
        );
    }

    /// Test the eval of `add` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpAddEvalOperandDisallowed() external {
        checkDisallowedOperand("_: add<0>(0 0 0);");
        checkDisallowedOperand("_: add<1>(0 0 0);");
        checkDisallowedOperand("_: add<2>(0 0 0);");
        checkDisallowedOperand("_: add<0 0>(0 0 0);");
        checkDisallowedOperand("_: add<0 1>(0 0 0);");
        checkDisallowedOperand("_: add<1 0>(0 0 0);");
    }
}
