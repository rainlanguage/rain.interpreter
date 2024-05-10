// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18InvNP} from "src/lib/op/math/decimal18/LibOpDecimal18InvNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18InvNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18InvNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18InvNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18InvNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18InvNP.
    function testOpDecimal18InvNPRun(uint256 a, uint16 operandData) public {
        // 0 is division by 0.
        a = bound(a, 1, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18InvNP.referenceFn,
            LibOpDecimal18InvNP.integrity,
            LibOpDecimal18InvNP.run,
            inputs
        );
    }

    /// Test the eval of `inv`.
    function testOpDecimal18InvNPEval() external {
        checkHappy("_: inv(1);", 1e18, "1");
        checkHappy("_: inv(0.5);", 2e18, "0.5");
        checkHappy("_: inv(2);", 0.5e18, "2");
        checkHappy("_: inv(3);", 333333333333333333, "3");
    }

    /// Test the eval of `inv` for bad inputs.
    function testOpDecimal18InvNPZeroInputs() external {
        checkBadInputs("_: inv();", 0, 1, 0);
    }

    function testOpDecimal18InvNPTwoInputs() external {
        checkBadInputs("_: inv(1 1);", 2, 1, 2);
    }

    function testOpDecimal18InvNPZeroOutputs() external {
        checkBadOutputs(": inv(1);", 1, 1, 0);
    }

    function testOpDecimal18InvNPTwoOutputs() external {
        checkBadOutputs("_ _: inv(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18ExpNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: inv<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
