// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18FloorNP} from "src/lib/op/math/decimal18/LibOpDecimal18FloorNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18FloorNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18FloorNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18FloorNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18FloorNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18FloorNP.
    function testOpDecimal18FloorNPRun(uint256 a, uint16 operandData) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18FloorNP.referenceFn,
            LibOpDecimal18FloorNP.integrity,
            LibOpDecimal18FloorNP.run,
            inputs
        );
    }

    /// Test the eval of `floor`.
    function testOpDecimal18FloorNPEval() external {
        checkHappy("_: floor(0);", 0, "0");
        checkHappy("_: floor(1);", 1e18, "1");
        checkHappy("_: floor(0.5);", 0, "0.5");
        checkHappy("_: floor(2);", 2e18, "2");
        checkHappy("_: floor(3);", 3e18, "3");
        checkHappy("_: floor(3.8);", 3e18, "3.8");
    }

    /// Test the eval of `floor` for bad inputs.
    function testOpDecimal18FloorNPZeroInputs() external {
        checkBadInputs("_: floor();", 0, 1, 0);
    }

    function testOpDecimal18FloorNPTwoInputs() external {
        checkBadInputs("_: floor(1 1);", 2, 1, 2);
    }

    function testOpDecimal18FloorNPZeroOutputs() external {
        checkBadOutputs(": floor(1);", 1, 1, 0);
    }

    function testOpDecimal18FloorNPTwoOutputs() external {
        checkBadOutputs("_ _: floor(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18ExpNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: floor<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
