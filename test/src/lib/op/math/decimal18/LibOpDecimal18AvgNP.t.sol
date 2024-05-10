// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18AvgNP} from "src/lib/op/math/decimal18/LibOpDecimal18AvgNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18AvgNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18AvgNP.
    /// Inputs are always 2, outputs are always 1.
    function testOpDecimal18AvgNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18AvgNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18AvgNP.
    function testOpDecimal18AvgNPRun(uint256 a, uint256 b, uint16 operandData) public {
        // @TODO This is a hack to get around the fact that we are very likely
        // to overflow uint256 if we just fuzz it, and that it's clunky to
        // determine whether it will overflow or not. Basically the overflow
        // check is exactly the same as the implementation, including all the
        // intermediate squaring, so it seems like a bit of circular logic to
        // do things that way.
        a = bound(a, 0, type(uint64).max);
        b = bound(b, 0, 10);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(2, 1, operandData);
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18AvgNP.referenceFn,
            LibOpDecimal18AvgNP.integrity,
            LibOpDecimal18AvgNP.run,
            inputs
        );
    }

    /// Test the eval of `avg`.
    function testOpDecimal18AvgNPEval() external {
        checkHappy("_: avg(0 0);", 0, "0 0");
        checkHappy("_: avg(0 1);", 5e17, "0 1");
        checkHappy("_: avg(1 0);", 5e17, "1 0");
        checkHappy("_: avg(1 1);", 1e18, "1 1");
        checkHappy("_: avg(1 2);", 1.5e18, "1 2");
        checkHappy("_: avg(2 2);", 2e18, "2 2");
        checkHappy("_: avg(2 3);", 2.5e18, "2 3");
        checkHappy("_: avg(2 4);", 3e18, "2 4");
        checkHappy("_: avg(4 0.5);", 2.25e18, "4 5");
    }

    /// Test the eval of `avg` for bad inputs.
    function testOpDecimal18AvgNPEvalOneInput() external {
        checkBadInputs("_: avg(1);", 1, 2, 1);
    }

    function testOpDecimal18AvgNPEvalThreeInputs() external {
        checkBadInputs("_: avg(1 1 1);", 3, 2, 3);
    }

    function testOpDecimal18AvgNPEvalZeroOutputs() external {
        checkBadOutputs(": avg(0 0);", 2, 1, 0);
    }

    function testOpDecimal18AvgNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: avg(0 0);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18AvgNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: avg<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
