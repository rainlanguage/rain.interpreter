// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibUint256Array.sol";

import "test/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOpIntModNP} from "src/lib/op/math/int/LibOpIntModNP.sol";

contract LibOpIntModNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIntModNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntModNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntModNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntModNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntModNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntModNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntModNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntModNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntModNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntModNP.
    function testOpIntModNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        uint256 modZeros = 0;
        for (uint256 i = 1; i < inputs.length; i++) {
            if (inputs[i] == 0) {
                modZeros++;
            }
        }
        if (modZeros > 0) {
            vm.expectRevert(stdError.divisionError);
        }
        opReferenceCheck(state, operand, LibOpIntModNP.referenceFn, LibOpIntModNP.integrity, LibOpIntModNP.run, inputs);
    }

    /// Test the eval of `int-mod` opcode parsed from a string. Tests zero inputs.
    function testOpIntModNPEvalZeroInputs() external {
        checkBadInputs("_: int-mod();", 0, 2, 0);
    }

    /// Test the eval of `int-mod` opcode parsed from a string. Tests one input.
    function testOpIntModNPEvalOneInput() external {
        checkBadInputs("_: int-mod(5);", 1, 2, 1);
        checkBadInputs("_: int-mod(0);", 1, 2, 1);
        checkBadInputs("_: int-mod(1);", 1, 2, 1);
        checkBadInputs("_: int-mod(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `int-mod` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where we do not mod by zero.
    function testOpIntModNPEval2InputsHappy() external {
        // Show that the modulo truncates (rounds down).
        checkHappy("_: int-mod(6 1);", 0, "6 1");
        checkHappy("_: int-mod(6 2);", 0, "6 2");
        checkHappy("_: int-mod(6 3);", 0, "6 3");
        checkHappy("_: int-mod(6 4);", 2, "6 4");
        checkHappy("_: int-mod(6 5);", 1, "6 5");
        checkHappy("_: int-mod(6 6);", 0, "6 6");
        checkHappy("_: int-mod(6 7);", 6, "6 7");
        checkHappy("_: int-mod(6 max-int-value());", 6, "6 max-int-value()");

        // Anything module by 1 is 0.
        checkHappy("_: int-mod(0 1);", 0, "0 1");
        checkHappy("_: int-mod(1 1);", 0, "1 1");
        checkHappy("_: int-mod(2 1);", 0, "2 1");
        checkHappy("_: int-mod(3 1);", 0, "3 1");
        checkHappy("_: int-mod(max-int-value() 1);", 0, "max-int-value() 1");

        // Anything mod by itself is 0 (except 0).
        checkHappy("_: int-mod(1 1);", 0, "1 1");
        checkHappy("_: int-mod(2 2);", 0, "2 2");
        checkHappy("_: int-mod(3 3);", 0, "3 3");
        checkHappy("_: int-mod(max-int-value() max-int-value());", 0, "max-int-value() max-int-value()");
    }

    /// Test the eval of `int-mod` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where we modulo by zero.
    function testOpIntModNPEval2InputsUnhappy() external {
        checkUnhappy("_: int-mod(0 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(1 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(max-int-value() 0);", stdError.divisionError);
    }

    /// Test the eval of `int-mod` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where we do not modulo by zero.
    function testOpIntModNPEval3InputsHappy() external {
        // Show that the modulo truncates (rounds down).
        checkHappy("_: int-mod(6 1 1);", 0, "6 1 1");
        checkHappy("_: int-mod(6 2 1);", 0, "6 2 1");
        checkHappy("_: int-mod(6 3 1);", 0, "6 3 1");
        checkHappy("_: int-mod(26 20 4);", 2, "26 20 4");
        checkHappy("_: int-mod(6 4 1);", 0, "6 4 1");
        checkHappy("_: int-mod(6 5 1);", 0, "6 5 1");
        checkHappy("_: int-mod(6 6 1);", 0, "6 6 1");
        checkHappy("_: int-mod(6 7 1);", 0, "6 7 1");
        checkHappy("_: int-mod(6 max-int-value() 1);", 0, "6 max-int-value() 1");
        checkHappy("_: int-mod(6 1 2);", 0, "6 1 2");
        checkHappy("_: int-mod(6 2 2);", 0, "6 2 2");
        checkHappy("_: int-mod(6 3 2);", 0, "6 3 2");
        checkHappy("_: int-mod(6 4 2);", 0, "6 4 2");
        checkHappy("_: int-mod(6 5 2);", 1, "6 5 2");
        checkHappy("_: int-mod(6 6 2);", 0, "6 6 2");
        checkHappy("_: int-mod(6 7 2);", 0, "6 7 2");
        checkHappy("_: int-mod(6 max-int-value() 2);", 0, "6 max-int-value() 2");

        // Anything modulo by 1 is 0.
        checkHappy("_: int-mod(0 1 1);", 0, "0 1 1");
        checkHappy("_: int-mod(1 1 1);", 0, "1 1 1");
        checkHappy("_: int-mod(2 1 1);", 0, "2 1 1");
        checkHappy("_: int-mod(3 1 1);", 0, "3 1 1");
        checkHappy("_: int-mod(max-int-value() 1 1);", 0, "max-int-value() 1 1");

        // Anything modulo by itself is 0 (except 0).
        checkHappy("_: int-mod(1 1 1);", 0, "1 1 1");
        checkHappy("_: int-mod(2 2 1);", 0, "2 2 1");
        checkHappy("_: int-mod(2 1 2);", 0, "2 1 2");
        checkHappy("_: int-mod(3 3 1);", 0, "3 3 1");
        checkHappy("_: int-mod(3 1 3);", 0, "3 1 3");
        checkHappy("_: int-mod(max-int-value() max-int-value() 1);", 0, "max-int-value() max-int-value() 1");
        checkHappy("_: int-mod(max-int-value() 1 max-int-value());", 0, "max-int-value() 1 max-int-value()");
    }

    /// Test the eval of `int-mod` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where we modulo by zero.
    function testOpIntModNPEval3InputsUnhappy() external {
        checkUnhappy("_: int-mod(0 0 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(1 0 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(max-int-value() 0 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(0 1 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(1 1 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(max-int-value() max-int-value() 0);", stdError.divisionError);
        checkUnhappy("_: int-mod(0 0 1);", stdError.divisionError);
        checkUnhappy("_: int-mod(1 0 1);", stdError.divisionError);
        checkUnhappy("_: int-mod(max-int-value() 0 1);", stdError.divisionError);
    }

    /// Test the eval of `int-mod` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntModNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-mod<0>(0 0 0);");
        checkDisallowedOperand("_: int-mod<1>(0 0 0);");
        checkDisallowedOperand("_: int-mod<2>(0 0 0);");
        checkDisallowedOperand("_: int-mod<3 1>(0 0 0);");
    }
}
