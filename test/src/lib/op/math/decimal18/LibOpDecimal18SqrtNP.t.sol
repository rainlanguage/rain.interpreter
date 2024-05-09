// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18SqrtNP} from "src/lib/op/math/decimal18/LibOpDecimal18SqrtNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18SqrtNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18SqrtNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18SqrtNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18SqrtNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18SqrtNP.
    function testOpDecimal18SqrtNPRun(uint256 a) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, 0);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18SqrtNP.referenceFn,
            LibOpDecimal18SqrtNP.integrity,
            LibOpDecimal18SqrtNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-sqrt`.
    function testOpDecimal18SqrtNPEval() external {
        checkHappy("_: decimal18-sqrt(0);", 0, "0");
        checkHappy("_: decimal18-sqrt(1);", 1e18, "1");
        checkHappy("_: decimal18-sqrt(0.5);", 707106781186547524, "0.5");
        checkHappy("_: decimal18-sqrt(2);", 1414213562373095048, "2");
        checkHappy("_: decimal18-sqrt(2.5);", 1581138830084189665, "2.5");
    }

    /// Test the eval of `decimal18-sqrt` for bad inputs.
    function testOpDecimal18SqrtNPEvalBad() external {
        checkBadInputs("_: decimal18-sqrt();", 0, 1, 0);
        checkBadInputs("_: decimal18-sqrt(1 1);", 2, 1, 2);
    }

    function testOpDecimal18SqrtNPEvalZeroOutputs() external {
        checkBadOutputs(": decimal18-sqrt(1);", 1, 1, 0);
    }

    function testOpDecimal18SqrtNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-sqrt(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18SqrtNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-sqrt<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
