// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18FracNP} from "src/lib/op/math/decimal18/LibOpDecimal18FracNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18FracNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18FracNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18FracNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18FracNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18FracNP.
    function testOpDecimal18FracNPRun(uint256 a, uint16 operandData) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18FracNP.referenceFn,
            LibOpDecimal18FracNP.integrity,
            LibOpDecimal18FracNP.run,
            inputs
        );
    }

    /// Test the eval of `frac`.
    function testOpDecimal18FracNPEval() external {
        checkHappy("_: frac(0);", 0, "0");
        checkHappy("_: frac(1);", 0, "1");
        checkHappy("_: frac(0.5);", 0.5e18, "0.5");
        checkHappy("_: frac(2);", 0, "2");
        checkHappy("_: frac(3);", 0, "3");
        checkHappy("_: frac(3.8);", 0.8e18, "3.8");
    }

    /// Test the eval of `frac` for bad inputs.
    function testOpDecimal18FracNPZeroInputs() external {
        checkBadInputs("_: frac();", 0, 1, 0);
    }

    function testOpDecimal18FracNPTwoInputs() external {
        checkBadInputs("_: frac(1 1);", 2, 1, 2);
    }

    function testOpDecimal18FracNPZeroOutputs() external {
        checkBadOutputs(": frac(1);", 1, 1, 0);
    }

    function testOpDecimal18FracNPTwoOutputs() external {
        checkBadOutputs("_ _: frac(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18FracNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: frac<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
