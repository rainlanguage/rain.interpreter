// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {
    OpTest,
    IntegrityCheckStateNP,
    Operand,
    InterpreterStateNP,
    UnexpectedOperand
} from "test/abstract/OpTest.sol";
import {LibOpDecimal18LnNP} from "src/lib/op/math/decimal18/LibOpDecimal18LnNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18LnNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18LnNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18LnNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18LnNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18LnNP.
    function testOpDecimal18LnNPRun(uint256 a, uint16 operandData) public {
        // e lifted from prb math.
        a = bound(a, 2_718281828459045235, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state, operand, LibOpDecimal18LnNP.referenceFn, LibOpDecimal18LnNP.integrity, LibOpDecimal18LnNP.run, inputs
        );
    }

    /// Test the eval of `decimal18-ln`.
    function testOpDecimal18LnNPEval() external {
        // Any number less than e other than 1 is negative which doesn't exist
        // in unsigned integers.
        checkHappy("_: decimal18-ln(1e18);", 0, "ln 1");
        checkHappy("_: decimal18-ln(2718281828459045235);", 999999999999999990, "ln e");
        checkHappy("_: decimal18-ln(3e18);", 1098612288668109680, "ln 3");
        checkHappy("_: decimal18-ln(4e18);", 1386294361119890619, "ln 4");
        checkHappy("_: decimal18-ln(5e18);", 1609437912434100365, "ln 5");
    }

    /// Test the eval of `decimal18-ln` for bad inputs.
    function testOpDecimal18LnNPEvalBad() external {
        checkBadInputs("_: decimal18-ln();", 0, 1, 0);
        checkBadInputs("_: decimal18-ln(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18LnNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-ln<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
