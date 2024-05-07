// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18CeilNP} from "src/lib/op/math/decimal18/LibOpDecimal18CeilNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18CeilNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18CeilNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18CeilNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18CeilNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18CeilNP.
    function testOpDecimal18CeilNPRun(uint256 a, uint16 operandData) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18CeilNP.referenceFn,
            LibOpDecimal18CeilNP.integrity,
            LibOpDecimal18CeilNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-ceil`.
    function testOpDecimal18CeilNPEval() external {
        checkHappy("_: decimal18-ceil(0);", 0, "0");
        checkHappy("_: decimal18-ceil(1e18);", 1e18, "1e18");
        checkHappy("_: decimal18-ceil(5e17);", 1e18, "5e17");
        checkHappy("_: decimal18-ceil(2e18);", 2e18, "2e18");
        checkHappy("_: decimal18-ceil(25e17);", 3e18, "25e17");
    }

    /// Test the eval of `decimal18-ceil` for bad inputs.
    function testOpDecimal18CeilNPZeroInputs() external {
        checkBadInputs("_: decimal18-ceil();", 0, 1, 0);
    }

    function testOpDecimal18CeilNPTwoInputs() external {
        checkBadInputs("_: decimal18-ceil(1 1);", 2, 1, 2);
    }

    function testOpDecimal18CeilNPZeroOutputs() external {
        checkBadOutputs(": decimal18-ceil(1);", 1, 1, 0);
    }

    function testOpDecimal18CeilNPTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-ceil(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18CeilNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-ceil<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
