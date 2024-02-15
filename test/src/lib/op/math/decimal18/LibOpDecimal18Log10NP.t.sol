// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18Log10NP} from "src/lib/op/math/decimal18/LibOpDecimal18Log10NP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18Log10NPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18Log10NP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18Log10NPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18Log10NP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18Log10NP.
    function testOpDecimal18Log10NPRun(uint256 a, uint16 operandData) public {
        // e lifted from prb math.
        a = bound(a, 2_718281828459045235, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18Log10NP.referenceFn,
            LibOpDecimal18Log10NP.integrity,
            LibOpDecimal18Log10NP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-log10`.
    function testOpDecimal18Log10NPEval() external {
        checkHappy("_: decimal18-log10(1e18);", 0, "log10 1");
        checkHappy("_: decimal18-log10(2e18);", 301029995663981195, "log10 2");
        checkHappy("_: decimal18-log10(2718281828459045235);", 434294481903251823, "log2 e");
        checkHappy("_: decimal18-log10(3e18);", 477121254719662432, "log2 3");
        checkHappy("_: decimal18-log10(4e18);", 602059991327962390, "log2 4");
        checkHappy("_: decimal18-log10(5e18);", 698970004336018800, "log2 5");
    }

    /// Test the eval of `decimal18-log10` for bad inputs.
    function testOpDecimal18Log10NPZeroInputs() external {
        checkBadInputs("_: decimal18-log10();", 0, 1, 0);
    }

    function testOpDecimal18Log10NPTwoInputs() external {
        checkBadInputs("_: decimal18-log10(1 1);", 2, 1, 2);
    }

    function testOpDecimal18Log10NPZeroOutputs() external {
        checkBadOutputs(": decimal18-log10(1);", 1, 1, 0);
    }

    function testOpDecimal18Log10NPTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-log10(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18Log10NPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-log10<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
