// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18SnapToUnitNP} from "src/lib/op/math/decimal18/LibOpDecimal18SnapToUnitNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18SnapToUnitNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18SnapToUnitNP.
    /// Inputs are always 2, outputs are always 1.
    function testOpDecimal18SnapToUnitNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18SnapToUnitNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18SnapToUnitNP.
    function testOpDecimal18SnapToUnitNPRun(uint256 threshold, uint256 value) public {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        value = bound(value, 0, type(uint64).max - 1e18);

        Operand operand = LibOperand.build(2, 1, 0);
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = threshold;
        inputs[1] = value;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18SnapToUnitNP.referenceFn,
            LibOpDecimal18SnapToUnitNP.integrity,
            LibOpDecimal18SnapToUnitNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-snap-to-unit`.
    function testOpDecimal18SnapToUnitNPEval() external {
        // If the threshold is 1 then we always floor.
        checkHappy("_: decimal18-snap-to-unit(1e18 1e18);", 1e18, "1e18 1e18");
        checkHappy("_: decimal18-snap-to-unit(1e18 5e17);", 0, "1e18 5e17");
        checkHappy("_: decimal18-snap-to-unit(1e18 2e18);", 2e18, "1e18 2e18");
        checkHappy("_: decimal18-snap-to-unit(1e18 25e17);", 2e18, "1e18 25e17");

        // If the threshold is 0.2 then we floor or ceil anything within the
        // threshold.
        checkHappy("_: decimal18-snap-to-unit(2e17 1e18);", 1e18, "2e17 1e18");
        checkHappy("_: decimal18-snap-to-unit(2e17 5e17);", 5e17, "2e17 5e17");
        checkHappy("_: decimal18-snap-to-unit(2e17 2e18);", 2e18, "2e17 2e18");
        checkHappy("_: decimal18-snap-to-unit(2e17 2e17);", 0, "2e17 2e17");
        checkHappy("_: decimal18-snap-to-unit(2e17 8e17);", 1e18, "2e17 8e17");
        checkHappy("_: decimal18-snap-to-unit(2e17 25e17);", 2.5e18, "2e17 25e17");
        checkHappy("_: decimal18-snap-to-unit(2e17 3e18);", 3e18, "2e17 3e18");
        checkHappy("_: decimal18-snap-to-unit(2e17 31e17);", 3e18, "2e17 31e17");
        checkHappy("_: decimal18-snap-to-unit(2e17 39e17);", 4e18, "2e17 39e17");
    }

    /// Test the eval of `decimal18-snap-to-unit` for bad inputs.
    function testOpDecimal18SnapToUnitNPEvalBad() external {
        checkBadInputs("_: decimal18-snap-to-unit();", 0, 2, 0);
        checkBadInputs("_: decimal18-snap-to-unit(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-snap-to-unit(1 1 1);", 3, 2, 3);
    }

    function testOpDecimal18SnapToUnitNPEvalZeroOutputs() external {
        checkBadOutputs(": decimal18-snap-to-unit(1 1);", 2, 1, 0);
    }

    function testOpDecimal18SnapToUnitNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-snap-to-unit(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18SnapToUnitNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-snap-to-unit<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
