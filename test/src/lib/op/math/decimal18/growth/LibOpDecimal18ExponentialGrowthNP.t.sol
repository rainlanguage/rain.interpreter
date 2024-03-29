// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18ExponentialGrowthNP} from "src/lib/op/math/decimal18/growth/LibOpDecimal18ExponentialGrowthNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18ExponentialGrowthNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18ExponentialGrowthNP.
    /// Inputs are always 3, outputs are always 1.
    function testOpDecimal18ExponentialGrowthNPIntegrity(IntegrityCheckStateNP memory state, Operand operand)
        external
    {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18ExponentialGrowthNP.integrity(state, operand);
        assertEq(calcInputs, 3);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18ExponentialGrowthNP.
    function testOpDecimal18ExponentialGrowthNPRun(uint256 a, uint256 r, uint256 t, uint16 operandData) public {
        // @TODO This is a hack to cover some range that we can definitely
        // handle but it doesn't cover the full range of the function.
        a = bound(a, 0, type(uint64).max);
        r = bound(r, 0, type(uint64).max);
        // PRB math can't reliably handle t beyond 44e18 with a and r both up to
        // ~18e18 (uint64 max).
        t = bound(t, 0, 44e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(3, 1, operandData);
        uint256[] memory inputs = new uint256[](3);
        inputs[0] = a;
        inputs[1] = r;
        inputs[2] = t;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18ExponentialGrowthNP.referenceFn,
            LibOpDecimal18ExponentialGrowthNP.integrity,
            LibOpDecimal18ExponentialGrowthNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-exponential-growth`.
    function testOpDecimal18ExponentialGrowthNPEval() external {
        checkHappy("_: decimal18-exponential-growth(0 0 0);", 0, "0 0 0");
        checkHappy("_: decimal18-exponential-growth(0 1e17 0);", 0, "0 1e17 0");
        checkHappy("_: decimal18-exponential-growth(0 1e17 1e18);", 0, "0 1e17 1e18");
        checkHappy("_: decimal18-exponential-growth(1e18 1e17 0);", 1e18, "1e18 1e17 0");
        checkHappy("_: decimal18-exponential-growth(1e18 1e17 1e18);", 1.1e18, "1e18 1e17 1e18");
        // Not exactly 1.21
        checkHappy("_: decimal18-exponential-growth(1e18 1e17 2e18);", 1209999999999999974, "1e18 1e17 2e18");
        // Not exactly 1.26905870629
        checkHappy("_: decimal18-exponential-growth(1e18 1e17 25e17);", 1269058706285883337, "1e18 1e17 25e17");
        checkHappy("_: decimal18-exponential-growth(1e18 0 2e18);", 1e18, "1e18 0 2e18");
        checkHappy("_: decimal18-exponential-growth(1e18 1e17 5e17);", 1048808848170151541, "1e18 1e17 5e17");
        checkHappy("_: decimal18-exponential-growth(2e18 1e17 0);", 2e18, "2e18 1e17 0");
        checkHappy("_: decimal18-exponential-growth(2e18 1e17 1e18);", 2.2e18, "2e18 1e17 1e18");
        // Not exactly 2.42
        checkHappy("_: decimal18-exponential-growth(2e18 1e17 2e18);", 2419999999999999948, "2e18 1e17 2e18");
    }

    function testOpDecimal18ExponentialGrowthNPEvalZeroInputs() external {
        checkBadInputs(": decimal18-exponential-growth();", 0, 3, 0);
    }

    function testOpDecimal18ExponentialGrowthNPEvalOneInput() external {
        checkBadInputs("_: decimal18-exponential-growth(1e18);", 1, 3, 1);
    }

    function testOpDecimal18ExponentialGrowthNPEvalTwoInputs() external {
        checkBadInputs("_: decimal18-exponential-growth(1e18 0);", 2, 3, 2);
    }

    function testOpDecimal18ExponentialGrowthNPEvalFourInputs() external {
        checkBadInputs("_: decimal18-exponential-growth(1e18 0 0 1e18);", 4, 3, 4);
    }

    function testOpDecimal18ExponentialGrowthNPEvalZeroOutputs() external {
        checkBadOutputs(": decimal18-exponential-growth(1e18 0 0);", 3, 1, 0);
    }

    function testOpDecimal18ExponentialGrowthNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-exponential-growth(1e18 0 0);", 3, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18ExponentialGrowthNPEvalOperandDisallowed() external {
        checkUnhappyParse(
            "_: decimal18-exponential-growth<0>(1e18 0 0);", abi.encodeWithSelector(UnexpectedOperand.selector)
        );
    }
}
