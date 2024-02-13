// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {
    OpTest,
    IntegrityCheckStateNP,
    Operand,
    InterpreterStateNP,
    UnexpectedOperand
} from "test/abstract/OpTest.sol";
import {LibOpDecimal18InvNP} from "src/lib/op/math/decimal18/LibOpDecimal18InvNP.sol";

contract LibOpDecimal18InvNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18InvNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18InvNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18InvNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18InvNP.
    function testOpDecimal18InvNPRun(uint256 a) public {
        // 0 is division by 0.
        a = bound(a, 1, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = Operand.wrap((1 << 0x10) | 0);
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

    /// Test the eval of `decimal18-inv`.
    function testOpDecimal18InvNPEval() external {
        checkHappy("_: decimal18-inv(1e18);", 1e18, "1");
        checkHappy("_: decimal18-inv(5e17);", 2e18, "0.5");
        checkHappy("_: decimal18-inv(2e18);", 0.5e18, "2");
        checkHappy("_: decimal18-inv(3e18);", 333333333333333333, "3");
    }

    /// Test the eval of `decimal18-inv` for bad inputs.
    function testOpDecimal18InvNPEvalBad() external {
        checkBadInputs("_: decimal18-inv();", 0, 1, 0);
        checkBadInputs("_: decimal18-inv(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18ExpNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-inv<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
