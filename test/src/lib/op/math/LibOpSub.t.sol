// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckState, InterpreterState, OperandV2, stdError} from "test/abstract/OpTest.sol";
import {LibOpSub} from "src/lib/op/math/LibOpSub.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";
import {LibDecimalFloatImplementation} from "rain.math.float/lib/implementation/LibDecimalFloatImplementation.sol";

contract LibOpSubTest is OpTest {
    /// Directly test the integrity logic of LibOpSub. This tests the happy
    /// path where the inputs input and calc match.
    function testOpSubIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
        external
        pure
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpSub.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpSub. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpSubIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpSub.integrity(state, OperandV2.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpSub. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpSubIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpSub.integrity(state, OperandV2.wrap(bytes32(uint256(0x010000))));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function _testOpSubRun(OperandV2 operand, StackItem[] memory inputs) external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        opReferenceCheck(state, operand, LibOpSub.referenceFn, LibOpSub.integrity, LibOpSub.run, inputs);
    }

    /// Directly test the runtime logic of LibOpSub.
    function testOpSubRun(StackItem[] memory inputs) external {
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
                LibDecimalFloatImplementation.sub(signedCoefficientA, exponentA, signedCoefficientB, exponentB);
            if (int32(exponentA) != exponentA) {
                overflows++;
            }
        }

        if (overflows > 0) {
            vm.expectRevert();
        }

        this._testOpSubRun(operand, inputs);
    }

    /// Test the eval of `sub` opcode parsed from a string. Tests zero inputs.
    function testOpSubEvalZeroInputs() external {
        checkBadInputs("_: sub();", 0, 2, 0);
    }

    /// Test the eval of `sub` opcode parsed from a string. Tests zero inputs.
    function testOpSubEvalZeroInputsSaturating() external {
        checkBadInputs("_: sub<1>();", 0, 2, 0);
    }

    /// Test the eval of `sub` opcode parsed from a string. Tests one input.
    function testOpSubEvalOneInput() external {
        checkBadInputs("_: sub(5e-18);", 1, 2, 1);
        checkBadInputs("_: sub(0);", 1, 2, 1);
        checkBadInputs("_: sub(1e-18);", 1, 2, 1);
        checkBadInputs("_: sub(max-value());", 1, 2, 1);
    }

    /// Test the eval of `sub` opcode parsed from a string. Tests one input.
    function testOpSubEvalOneInputSaturating() external {
        checkBadInputs("_: sub<1>(5e-18);", 1, 2, 1);
        checkBadInputs("_: sub<1>(0);", 1, 2, 1);
        checkBadInputs("_: sub<1>(1e-18);", 1, 2, 1);
        checkBadInputs("_: sub<1>(max-value());", 1, 2, 1);
    }

    /// Test the eval of `sub` opcode parsed from a string. Tests two inputs.
    function testOpSubEvalTwoInputs() external view {
        checkHappy("_: sub(1 0);", Float.unwrap(LibDecimalFloat.packLossless(1, 0)), "1 0");
        checkHappy("_: sub(1 1);", Float.unwrap(LibDecimalFloat.packLossless(0e37, -37)), "1 1");
        checkHappy("_: sub(2 1);", Float.unwrap(LibDecimalFloat.packLossless(1e37, -37)), "2 1");
        checkHappy("_: sub(2 2);", Float.unwrap(LibDecimalFloat.packLossless(0e37, -37)), "2 2");
        checkHappy(
            "_: sub(max-value() 0);",
            Float.unwrap(LibDecimalFloat.packLossless(type(int224).max, type(int32).max)),
            "max-value() 0"
        );
        checkHappy("_: sub(1 2);", Float.unwrap(LibDecimalFloat.packLossless(-1e37, -37)), "1 2");
        checkHappy("_: sub(1 0.1);", Float.unwrap(LibDecimalFloat.packLossless(9e37, -38)), "1 0.1");

        // Subtracting 1 from max value is still max value because floats.
        // https://github.com/rainlanguage/rain.math.float/issues/74
        // checkHappy("_: sub(max-value() 1);", Float.unwrap(LibDecimalFloat.packLossless(type(int224).max, type(int32).max)), "max-value() 1");
        // https://github.com/rainlanguage/rain.math.float/issues/75
        // checkHappy("_: sub(max-value() max-value());", 0, "max-value() max-value()");
    }

    /// Test the eval of `sub` opcode parsed from a string. Tests three inputs.
    function testOpSubEvalThreeInputs() external view {
        checkHappy("_: sub(1 0 0);", Float.unwrap(LibDecimalFloat.packLossless(1, 0)), "1 0 0");
        checkHappy("_: sub(1 1 0);", Float.unwrap(LibDecimalFloat.packLossless(0, 0)), "1 1 0");
        checkHappy("_: sub(2 1 1);", Float.unwrap(LibDecimalFloat.packLossless(0, -37)), "2 1 1");
        checkHappy("_: sub(2 2 0);", Float.unwrap(LibDecimalFloat.packLossless(0, 0)), "2 2 0");
    }
}
