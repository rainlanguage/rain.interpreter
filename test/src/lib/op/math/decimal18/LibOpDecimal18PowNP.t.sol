// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18PowNP} from "src/lib/op/math/decimal18/LibOpDecimal18PowNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18PowNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18PowNP.
    /// Inputs are always 2, outputs are always 1.
    function testOpDecimal18PowNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18PowNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18PowNP.
    function testOpDecimal18PowNPRun(uint256 a, uint256 b) public {
        // @TODO This is a hack to get around the fact that we are very likely
        // to overflow uint256 if we just fuzz it, and that it's clunky to
        // determine whether it will overflow or not. Basically the overflow
        // check is exactly the same as the implementation, including all the
        // intermediate squaring, so it seems like a bit of circular logic to
        // do things that way.
        a = bound(a, 0, type(uint64).max);
        b = bound(b, 0, 10);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(2, 1, 0);
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18PowNP.referenceFn,
            LibOpDecimal18PowNP.integrity,
            LibOpDecimal18PowNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-power`.
    function testOpDecimal18PowNPEval() external {
        // 0 ^ 0
        checkHappy("_: decimal18-power(0 0);", 1e18, "0 0");
        // 0 ^ 1
        checkHappy("_: decimal18-power(0 1e18);", 0, "0 1");
        // 1e18 ^ 0
        checkHappy("_: decimal18-power(1e18 0);", 1e18, "1e18 0");
        // 1 ^ 1
        checkHappy("_: decimal18-power(1e18 1e18);", 1e18, "1e18 1");
        // 1 ^ 2
        checkHappy("_: decimal18-power(1e18 2e18);", 1e18, "1e18 2");
        // 2 ^ 2
        checkHappy("_: decimal18-power(2e18 2e18);", 4e18, "2e18 2");
        // 2 ^ 3
        checkHappy("_: decimal18-power(2e18 3e18);", 8e18, "2e18 3");
        // 2 ^ 4
        checkHappy("_: decimal18-power(2e18 4e18);", 16e18, "2e18 4");
        // sqrt 4 = 2
        checkHappy("_: decimal18-power(4e18 5e17);", 2e18, "4e18 5");
    }

    /// Test the eval of `decimal18-power` for bad inputs.
    function testOpDecimal18PowNPEvalOneInput() external {
        checkBadInputs("_: decimal18-power(1e18);", 1, 2, 1);
    }

    function testOpDecimal18PowNPThreeInputs() external {
        checkBadInputs("_: decimal18-power(1 1 1);", 3, 2, 3);
    }

    function testOpDecimal18PowNPZeroOutputs() external {
        checkBadOutputs(": decimal18-power(1 1);", 2, 1, 0);
    }

    function testOpDecimal18PowNPTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-power(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18PowNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-power<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
