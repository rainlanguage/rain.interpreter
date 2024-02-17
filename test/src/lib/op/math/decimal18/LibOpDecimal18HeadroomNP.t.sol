// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18HeadroomNP} from "src/lib/op/math/decimal18/LibOpDecimal18HeadroomNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18HeadroomNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18HeadroomNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18HeadroomNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18HeadroomNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18HeadroomNP.
    function testOpDecimal18HeadroomNPRun(uint256 a, uint16 operandData) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18HeadroomNP.referenceFn,
            LibOpDecimal18HeadroomNP.integrity,
            LibOpDecimal18HeadroomNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-headroom`.
    function testOpDecimal18HeadroomNPEval() external {
        checkHappy("_: decimal18-headroom(0);", 1e18, "0");
        checkHappy("_: decimal18-headroom(1e18);", 1e18, "1");
        checkHappy("_: decimal18-headroom(5e17);", 0.5e18, "0.5");
        checkHappy("_: decimal18-headroom(2e18);", 1e18, "2");
        checkHappy("_: decimal18-headroom(3e18);", 1e18, "3");
        checkHappy("_: decimal18-headroom(38e17);", 0.2e18, "3.8");
    }

    /// Test the eval of `decimal18-headroom` for bad inputs.
    function testOpDecimal18HeadroomNPZeroInputs() external {
        checkBadInputs("_: decimal18-headroom();", 0, 1, 0);
    }

    function testOpDecimal18HeadroomNPTwoInputs() external {
        checkBadInputs("_: decimal18-headroom(1 1);", 2, 1, 2);
    }

    function testOpDecimal18HeadroomNPZeroOutputs() external {
        checkBadOutputs(": decimal18-headroom(1);", 1, 1, 0);
    }

    function testOpDecimal18HeadroomNPTwoOutputs() external {
        checkBadOutputs("_ _: decimal18-headroom(1);", 1, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18HeadroomNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-headroom<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
