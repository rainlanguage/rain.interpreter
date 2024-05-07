// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18Exp2NP} from "src/lib/op/math/decimal18/LibOpDecimal18Exp2NP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18Exp2NPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18Exp2NP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18Exp2NPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18Exp2NP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18Exp2NP.
    function testOpDecimal18Exp2NPRun(uint256 a, uint16 operandData) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18Exp2NP.referenceFn,
            LibOpDecimal18Exp2NP.integrity,
            LibOpDecimal18Exp2NP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-exp2`.
    function testOpDecimal18Exp2NPEval() external {
        checkHappy("_: decimal18-exp2(0);", 1e18, "2^0");
        checkHappy("_: decimal18-exp2(1e18);", 2e18, "2^1");
        checkHappy("_: decimal18-exp2(5e17);", 1414213562373095048, "2^0.5");
        checkHappy("_: decimal18-exp2(2e18);", 4e18, "2^2");
        checkHappy("_: decimal18-exp2(3e18);", 8e18, "2^3");
    }

    /// Test the eval of `decimal18-exp2` for bad inputs.
    function testOpDecimal18Exp2NPEvalBad() external {
        checkBadInputs("_: decimal18-exp2();", 0, 1, 0);
        checkBadInputs("_: decimal18-exp2(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18Exp2NPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-exp2<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }

    function testOpDecimal18Exp2NPZeroOutputs() external {
        checkBadOutputs(": decimal18-exp2(1);", 1, 1, 0);
    }

    function testOpDecimal18Exp2NPTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-exp2(1);", 1, 1, 2);
    }
}
