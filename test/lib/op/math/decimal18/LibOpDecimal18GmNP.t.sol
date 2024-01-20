// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {
    OpTest,
    IntegrityCheckStateNP,
    Operand,
    InterpreterStateNP,
    UnexpectedOperand
} from "test/util/abstract/OpTest.sol";
import {LibOpDecimal18GmNP} from "src/lib/op/math/decimal18/LibOpDecimal18GmNP.sol";

contract LibOpDecimal18GmNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18GmNP.
    /// Inputs are always 2, outputs are always 1.
    function testOpDecimal18GmNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18GmNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18GmNP.
    function testOpDecimal18GmNPRun(uint256 a, uint256 b) public {
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
            state, operand, LibOpDecimal18GmNP.referenceFn, LibOpDecimal18GmNP.integrity, LibOpDecimal18GmNP.run, inputs
        );
    }

    /// Test the eval of `decimal18-gm`.
    function testOpDecimal18GmNPEval() external {
        checkHappy("_: decimal18-gm(0 0);", 0, "0 0");
        checkHappy("_: decimal18-gm(0 1e18);", 0, "0 1");
        checkHappy("_: decimal18-gm(1e18 0);", 0, "1e18 0");
        checkHappy("_: decimal18-gm(1e18 1e18);", 1e18, "1e18 1");
        checkHappy("_: decimal18-gm(1e18 2e18);", 1414213562373095048, "1e18 2");
        checkHappy("_: decimal18-gm(2e18 2e18);", 2e18, "2e18 2");
        checkHappy("_: decimal18-gm(2e18 3e18);", 2449489742783178098, "2e18 3");
        checkHappy("_: decimal18-gm(2e18 4e18);", 2828427124746190097, "2e18 4");
        checkHappy("_: decimal18-gm(4e18 5e17);", 1414213562373095048, "4e18 5");
    }

    /// Test the eval of `decimal18-gm` for bad inputs.
    function testOpDecimal18GmNPEvalBad() external {
        checkBadInputs("_: decimal18-gm(1e18);", 1, 2, 1);
        checkBadInputs("_: decimal18-gm(1 1 1);", 3, 2, 3);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18GmNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-gm<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
