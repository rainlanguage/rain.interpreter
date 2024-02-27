// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpShiftBitsLeftNP} from "src/lib/op/bitwise/LibOpShiftBitsLeftNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {
    IInterpreterV2,
    FullyQualifiedNamespace,
    Operand,
    SourceIndexV2
} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "rain.interpreter.interface/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {UnsupportedBitwiseShiftAmount} from "src/error/ErrBitwise.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpShiftBitsLeftNPTest is OpTest {
    /// Directly test the integrity logic of LibOpShiftBitsLeftNP. Tests the
    /// happy path where the integrity check does not error due to an unsupported
    /// shift amount.
    function testOpShiftBitsLeftNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint8 shiftAmount
    ) external {
        vm.assume(shiftAmount != 0);
        inputs = uint8(bound(inputs, 1, 0x0F));
        outputs = uint8(bound(outputs, 1, 0x0F));
        Operand operand = LibOperand.build(inputs, outputs, shiftAmount);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsLeftNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the execution logic of LibOpShiftBitsLeftNP. Tests that
    /// any shift amount that always results in an output of 0 will error as
    /// an unsupported shift amount.
    function testOpShiftBitsLeftNPIntegrityZero(IntegrityCheckStateNP memory state, uint8 inputs, uint16 shiftAmount16)
        external
    {
        inputs = uint8(bound(inputs, 0, 0x0F));
        uint256 shiftAmount = bound(uint256(shiftAmount16), uint256(type(uint8).max) + 1, type(uint16).max);
        Operand operand = LibOperand.build(inputs, 1, uint16(shiftAmount));
        vm.expectRevert(abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, shiftAmount));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsLeftNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the execution logic of LibOpShiftBitsLeftNP. Tests that
    /// any shift amount that is a noop (0) will error as an unsupported shift
    /// amount.
    function testOpShiftBitsLeftNPIntegrityNoop(IntegrityCheckStateNP memory state, uint8 inputs) external {
        Operand operand = Operand.wrap(uint256(inputs) << 0x10);
        vm.expectRevert(abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 0));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsLeftNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the runtime logic of LibOpShiftBitsLeftNP. This tests that
    /// the opcode correctly shifts bits left.
    function testOpShiftBitsLeftNPRun(uint256 x, uint8 shiftAmount) external {
        vm.assume(shiftAmount != 0);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = x;
        Operand operand = LibOperand.build(1, 1, shiftAmount);
        opReferenceCheck(
            state,
            operand,
            LibOpShiftBitsLeftNP.referenceFn,
            LibOpShiftBitsLeftNP.integrity,
            LibOpShiftBitsLeftNP.run,
            inputs
        );
    }

    /// Test the eval of a shift bits left opcode parsed from a string.
    function testOpShiftBitsLeftNPEval() external {
        checkHappy("_: bitwise-shift-left<1>(0);", 0, "1, 0");
        checkHappy("_: bitwise-shift-left<2>(0);", 0, "2, 0");
        checkHappy("_: bitwise-shift-left<3>(0);", 0, "3, 0");
        checkHappy("_: bitwise-shift-left<255>(0);", 0, "255, 0");

        checkHappy("_: bitwise-shift-left<1>(1);", 1 << 1, "1, 1");
        checkHappy("_: bitwise-shift-left<2>(1);", 1 << 2, "2, 1");
        checkHappy("_: bitwise-shift-left<3>(1);", 1 << 3, "3, 1");
        checkHappy("_: bitwise-shift-left<255>(1);", 1 << 255, "255, 1");

        checkHappy("_: bitwise-shift-left<1>(2);", 2 << 1, "1, 2");
        checkHappy("_: bitwise-shift-left<2>(2);", 2 << 2, "2, 2");
        checkHappy("_: bitwise-shift-left<3>(2);", 2 << 3, "3, 2");
        // 2 gets shifted out of the 256 bit word, so this is 0.
        checkHappy("_: bitwise-shift-left<255>(2);", 0, "255, 2");

        checkHappy("_: bitwise-shift-left<1>(3);", 3 << 1, "1, 3");
        checkHappy("_: bitwise-shift-left<2>(3);", 3 << 2, "2, 3");
        checkHappy("_: bitwise-shift-left<3>(3);", 3 << 3, "3, 3");
        // The high bit of 3 gets shifted out of the 256 bit word, so this is the
        // same as shifting 1.
        checkHappy("_: bitwise-shift-left<255>(3);", 1 << 255, "255, 3");

        checkHappy("_: bitwise-shift-left<1>(max-int-value());", type(uint256).max << 1, "1, max");
        checkHappy("_: bitwise-shift-left<2>(max-int-value());", type(uint256).max << 2, "2, max");
        checkHappy("_: bitwise-shift-left<3>(max-int-value());", type(uint256).max << 3, "3, max");
        // The high bit of max gets shifted out of the 256 bit word, so this is the
        // same as shifting 1.
        checkHappy("_: bitwise-shift-left<255>(max-int-value());", 1 << 255, "255, max");
    }

    /// Test that a bitwise shift with bad inputs fails integrity.
    function testOpShiftBitsLeftNPIntegrityFailZeroInputs() external {
        checkBadInputs("_: bitwise-shift-left<1>();", 0, 1, 0);
    }

    function testOpShiftBitsLeftNPIntegrityFailTwoInputs() external {
        checkBadInputs("_: bitwise-shift-left<1>(0 0);", 2, 1, 2);
    }

    function testOpShiftBitsLeftNPIntegrityFailZeroOutputs() external {
        checkBadOutputs(": bitwise-shift-left<1>(0);", 1, 1, 0);
    }

    function testOpShiftBitsLeftNPIntegrityFailTwoOutputs() external {
        checkBadOutputs("_ _: bitwise-shift-left<1>(0);", 1, 1, 2);
    }

    /// Test that a bitwise shift with bad shift amount fails integrity.
    function testOpShiftBitsLeftNPIntegrityFailBadShiftAmount() external {
        checkUnhappyDeploy(
            "_: bitwise-shift-left<0>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 0)
        );
        checkUnhappyDeploy(
            "_: bitwise-shift-left<256>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 256)
        );
        // Something even bigger than 256, but without overflowing the uint16
        // for the operand itself.
        checkUnhappyDeploy(
            "_: bitwise-shift-left<65535>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 65535)
        );
        // Lets go ahead and overflow the operand.
        checkUnhappyParse("_: bitwise-shift-left<65536>(0);", abi.encodeWithSelector(OperandOverflow.selector));
    }
}
