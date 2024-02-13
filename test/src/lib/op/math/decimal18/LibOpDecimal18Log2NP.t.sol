// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18Log2NP} from "src/lib/op/math/decimal18/LibOpDecimal18Log2NP.sol";

contract LibOpDecimal18Log2NPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18Log2NP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18Log2NPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18Log2NP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18Log2NP.
    function testOpDecimal18Log2NPRun(uint256 a) public {
        // e lifted from prb math.
        a = bound(a, 2_718281828459045235, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = Operand.wrap((1 << 0x10) | 0);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18Log2NP.referenceFn,
            LibOpDecimal18Log2NP.integrity,
            LibOpDecimal18Log2NP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-log2`.
    function testOpDecimal18Log2NPEval() external {
        // Any number less than 2 other than 1 is negative which doesn't exist
        // in unsigned integers.
        checkHappy("_: decimal18-log2(1e18);", 0, "log2 1");
        checkHappy("_: decimal18-log2(2e18);", 1e18, "log2 2");
        checkHappy("_: decimal18-log2(2718281828459045235);", 1442695040888963394, "log2 e");
        checkHappy("_: decimal18-log2(3e18);", 1584962500721156166, "log2 3");
        checkHappy("_: decimal18-log2(4e18);", 2000000000000000000, "log2 4");
        checkHappy("_: decimal18-log2(5e18);", 2321928094887362334, "log2 5");
    }

    /// Test the eval of `decimal18-log2` for bad inputs.
    function testOpDecimal18Log2NPEvalBad() external {
        checkBadInputs("_: decimal18-log2();", 0, 1, 0);
        checkBadInputs("_: decimal18-log2(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18Log2NPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-log2<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
