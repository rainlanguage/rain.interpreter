// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import {LibOpDecimal18PowUNP} from "src/lib/op/math/decimal18/LibOpDecimal18PowUNP.sol";

contract LibOpDecimal18PowUNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18PowUNP.
    /// Inputs are always 2, outputs are always 1.
    function testOpDecimal18PowUNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18PowUNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18PowUNP.
    function testOpDecimal18PowUNPRun(uint256 a, uint256 b) public {
        // @TODO This is a hack to get around the fact that we are very likely
        // to overflow uint256 if we just fuzz it, and that it's clunky to
        // determine whether it will overflow or not. Basically the overflow
        // check is exactly the same as the implementation, including all the
        // intermediate squaring, so it seems like a bit of circular logic to
        // do things that way.
        a = bound(a, 0, type(uint64).max);
        b = bound(b, 0, 10);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = Operand.wrap((2 << 0x10) | 0);
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18PowUNP.referenceFn,
            LibOpDecimal18PowUNP.integrity,
            LibOpDecimal18PowUNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-power-int`.
    function testOpDecimal18PowUNPEval() external {
        // 0 ^ 0
        checkHappy("_: decimal18-power-int(0 0);", 1e18, "0 0");
        // 0 ^ 1
        checkHappy("_: decimal18-power-int(0 1);", 0, "0 1");
        // 1e18 ^ 0
        checkHappy("_: decimal18-power-int(1e18 0);", 1e18, "1e18 0");
        // 1 ^ 1
        checkHappy("_: decimal18-power-int(1e18 1);", 1e18, "1e18 1");
        // 1 ^ 2
        checkHappy("_: decimal18-power-int(1e18 2);", 1e18, "1e18 2");
    }

    /// Test the eval of `decimal18-power-int` for bad inputs.
    function testOpDecimal18PowUNPEvalBad() external {
        checkBadInputs("_: decimal18-power-int(1e18);", 1, 2, 1);
        checkBadInputs("_: decimal18-power-int(1 1 1);", 3, 2, 3);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18PowUNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-power-int<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector, 22));
    }
}
