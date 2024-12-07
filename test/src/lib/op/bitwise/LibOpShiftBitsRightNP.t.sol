// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpShiftBitsRightNP} from "src/lib/op/bitwise/LibOpShiftBitsRightNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {
    IInterpreterV2,
    FullyQualifiedNamespace,
    Operand,
    SourceIndexV2
} from "rain.interpreter.interface/interface/deprecated/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/deprecated/IInterpreterCallerV2.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {UnsupportedBitwiseShiftAmount} from "src/error/ErrBitwise.sol";
import {IntegerOverflow} from "rain.math.fixedpoint/error/ErrScale.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpShiftBitsRightNPTest is OpTest {
    /// Directly test the integrity logic of LibOpShiftBitsRightNP. Tests the
    /// happy path where the integrity check does not error due to an unsupported
    /// shift amount.
    function testOpShiftBitsRightNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint8 shiftAmount
    ) external pure {
        vm.assume(shiftAmount != 0);
        inputs = uint8(bound(inputs, 1, 0x0F));
        outputs = uint8(bound(outputs, 1, 0x0F));
        Operand operand = LibOperand.build(inputs, outputs, shiftAmount);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsRightNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the execution logic of LibOpShiftBitsRightNP. Tests that
    /// any shift amount that always results in an output of 0 will error as
    /// an unsupported shift amount.
    function testOpShiftBitsRightNPIntegrityZero(IntegrityCheckStateNP memory state, uint8 inputs, uint16 shiftAmount16)
        external
    {
        uint256 shiftAmount = bound(uint256(shiftAmount16), uint256(type(uint8).max) + 1, type(uint16).max);
        Operand operand = Operand.wrap(uint256(inputs) << 0x10 | shiftAmount);
        vm.expectRevert(abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, shiftAmount));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsRightNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the execution logic of LibOpShiftBitsRightNP. Tests that
    /// any shift amount that is a noop (0) will error as an unsupported shift
    /// amount.
    function testOpShiftBitsRightNPIntegrityNoop(IntegrityCheckStateNP memory state, uint8 inputs) external {
        Operand operand = Operand.wrap(uint256(inputs) << 0x10);
        vm.expectRevert(abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 0));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsRightNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the runtime logic of LibOpShiftBitsRightNP. This tests that
    /// the opcode correctly shifts bits right.
    function testOpShiftBitsRightNPRun(uint256 x, uint8 shiftAmount) external view {
        vm.assume(shiftAmount != 0);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = x;
        Operand operand = LibOperand.build(uint8(inputs.length), 1, shiftAmount);
        opReferenceCheck(
            state,
            operand,
            LibOpShiftBitsRightNP.referenceFn,
            LibOpShiftBitsRightNP.integrity,
            LibOpShiftBitsRightNP.run,
            inputs
        );
    }

    /// Test the eval of a shift bits right opcode parsed from a string.
    function testOpShiftBitsRightNPEval() external view {
        checkHappy("_: bitwise-shift-right<1>(0);", 0, "1, 0");
        checkHappy("_: bitwise-shift-right<2>(0);", 0, "2, 0");
        checkHappy("_: bitwise-shift-right<3>(0);", 0, "3, 0");
        checkHappy("_: bitwise-shift-right<255>(0);", 0, "255, 0");

        checkHappy("_: bitwise-shift-right<1>(1e-18);", 0, "1, 1");
        checkHappy("_: bitwise-shift-right<2>(1e-18);", 0, "2, 1");
        checkHappy("_: bitwise-shift-right<3>(1e-18);", 0, "3, 1");
        checkHappy("_: bitwise-shift-right<255>(1e-18);", 0, "255, 1");

        checkHappy("_: bitwise-shift-right<1>(2e-18);", 1, "1, 2");
        checkHappy("_: bitwise-shift-right<2>(2e-18);", 0, "2, 2");
        checkHappy("_: bitwise-shift-right<3>(2e-18);", 0, "3, 2");
        checkHappy("_: bitwise-shift-right<255>(2e-18);", 0, "255, 2");

        checkHappy("_: bitwise-shift-right<1>(3e-18);", 1, "1, 3");
        checkHappy("_: bitwise-shift-right<2>(3e-18);", 0, "2, 3");
        checkHappy("_: bitwise-shift-right<3>(3e-18);", 0, "3, 3");
        checkHappy("_: bitwise-shift-right<255>(3e-18);", 0, "255, 3");

        checkHappy("_: bitwise-shift-right<1>(4e-18);", 2, "1, 4");
        checkHappy("_: bitwise-shift-right<2>(4e-18);", 1, "2, 4");
        checkHappy("_: bitwise-shift-right<3>(4e-18);", 0, "3, 4");
        checkHappy("_: bitwise-shift-right<255>(4e-18);", 0, "255, 4");

        checkHappy("_: bitwise-shift-right<1>(max-value());", type(uint256).max >> 1, "1, max");
        checkHappy("_: bitwise-shift-right<2>(max-value());", type(uint256).max >> 2, "2, max");
        checkHappy("_: bitwise-shift-right<3>(max-value());", type(uint256).max >> 3, "3, max");
        checkHappy("_: bitwise-shift-right<255>(max-value());", 1, "255, max");
    }

    /// Test that a bitwise shift with bad inputs fails integrity.
    function testOpShiftBitsRightNPZeroInputs() external {
        checkBadInputs("_: bitwise-shift-right<1>();", 0, 1, 0);
    }

    function testOpShiftBitsRightNPTwoInputs() external {
        checkBadInputs("_: bitwise-shift-right<1>(0 0);", 2, 1, 2);
    }

    function testOpShiftBitsRightNPZeroOutputs() external {
        checkBadOutputs(": bitwise-shift-right<1>(0);", 1, 1, 0);
    }

    function testOpShiftBitsRightNPTwoOutputs() external {
        checkBadOutputs("_ _: bitwise-shift-right<1>(0);", 1, 1, 2);
    }

    /// Test that a bitwise shift with bad shift amount fails integrity.
    function testOpShiftBitsRightNPIntegrityFailBadShiftAmount() external {
        checkUnhappyParse2(
            "_: bitwise-shift-right<0>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 0)
        );
        checkUnhappyParse2(
            "_: bitwise-shift-right<256>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 256)
        );
        // Something even bigger than 256, but without overflowing the uint16
        // for the operand itself.
        checkUnhappyParse2(
            "_: bitwise-shift-right<65535>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 65535)
        );
        // Lets go ahead and overflow the operand.
        checkUnhappyParse(
            "_: bitwise-shift-right<65536>(0);", abi.encodeWithSelector(IntegerOverflow.selector, 65536, 65535)
        );
    }
}
