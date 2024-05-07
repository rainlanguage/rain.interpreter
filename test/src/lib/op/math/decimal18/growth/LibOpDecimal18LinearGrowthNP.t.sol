// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18LinearGrowthNP} from "src/lib/op/math/decimal18/growth/LibOpDecimal18LinearGrowthNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18LinearGrowthNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18LinearGrowthNP.
    /// Inputs are always 3, outputs are always 1.
    function testOpDecimal18LinearGrowthNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18LinearGrowthNP.integrity(state, operand);
        assertEq(calcInputs, 3);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18LinearGrowthNP.
    function testOpDecimal18LinearGrowthNPRun(uint256 a, uint256 r, uint256 t, uint16 operandData) public {
        // @TODO This is a hack to cover some range that we can definitely
        // handle but it doesn't cover the full range of the function.
        a = bound(a, 0, type(uint128).max);
        r = bound(r, 0, type(uint128).max);
        // PRB math can't reliably handle t beyond 44e18 with a and r both up to
        // ~18e18 (uint64 max).
        t = bound(t, 0, type(uint64).max);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(3, 1, operandData);
        uint256[] memory inputs = new uint256[](3);
        inputs[0] = a;
        inputs[1] = r;
        inputs[2] = t;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18LinearGrowthNP.referenceFn,
            LibOpDecimal18LinearGrowthNP.integrity,
            LibOpDecimal18LinearGrowthNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-linear-growth`.
    function testOpDecimal18LinearGrowthNPEval() external {
        checkHappy("_: decimal18-linear-growth(0 0 0);", 0, "0 0 0");
        checkHappy("_: decimal18-linear-growth(0 0.1 0);", 0, "0 0.1 0");
        checkHappy("_: decimal18-linear-growth(0 0.1 1);", 1e17, "0 0.1 1");
        checkHappy("_: decimal18-linear-growth(1 0.1 0);", 1e18, "1 0.1 0");
        checkHappy("_: decimal18-linear-growth(1 0.1 1);", 1.1e18, "1 0.1 1");
        checkHappy("_: decimal18-linear-growth(1 0.1 2);", 1.2e18, "1 0.1 2");
        checkHappy("_: decimal18-linear-growth(1 0.1 2.5);", 1.25e18, "1 0.1 2.5");
        checkHappy("_: decimal18-linear-growth(1 0 2);", 1e18, "1 0 2");
        checkHappy("_: decimal18-linear-growth(1 0.1 0.5);", 1.05e18, "1 0.1 0.5");
        checkHappy("_: decimal18-linear-growth(2 0.1 0);", 2e18, "2 0.1 0");
        checkHappy("_: decimal18-linear-growth(2 0.1 1);", 2.1e18, "2 0.1 1");
        checkHappy("_: decimal18-linear-growth(2 0.1 2);", 2.2e18, "2 0.1 2");
    }

    function testOpDecimal18LinearGrowthNPEvalZeroInputs() external {
        checkBadInputs(": decimal18-linear-growth();", 0, 3, 0);
    }

    function testOpDecimal18LinearGrowthNPEvalOneInput() external {
        checkBadInputs("_: decimal18-linear-growth(1e18);", 1, 3, 1);
    }

    function testOpDecimal18LinearGrowthNPEvalTwoInputs() external {
        checkBadInputs("_: decimal18-linear-growth(1e18 0);", 2, 3, 2);
    }

    function testOpDecimal18LinearGrowthNPEvalFourInputs() external {
        checkBadInputs("_: decimal18-linear-growth(1e18 0 0 1e18);", 4, 3, 4);
    }

    function testOpDecimal18LinearGrowthNPEvalZeroOutputs() external {
        checkBadOutputs(": decimal18-linear-growth(1e18 0 0);", 3, 1, 0);
    }

    function testOpDecimal18LinearGrowthNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-linear-growth(1e18 0 0);", 3, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18LinearGrowthNPEvalOperandDisallowed() external {
        checkUnhappyParse(
            "_: decimal18-linear-growth<0>(1e18 0 0);", abi.encodeWithSelector(UnexpectedOperand.selector)
        );
    }
}
