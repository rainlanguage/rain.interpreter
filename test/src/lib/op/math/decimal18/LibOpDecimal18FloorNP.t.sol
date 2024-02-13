// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, Operand, InterpreterStateNP, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibOpDecimal18FloorNP} from "src/lib/op/math/decimal18/LibOpDecimal18FloorNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18FloorNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18FloorNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18FloorNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18FloorNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18FloorNP.
    function testOpDecimal18FloorNPRun(uint256 a, uint16 operandData) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, operandData);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18FloorNP.referenceFn,
            LibOpDecimal18FloorNP.integrity,
            LibOpDecimal18FloorNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-floor`.
    function testOpDecimal18FloorNPEval() external {
        checkHappy("_: decimal18-floor(0);", 0, "0");
        checkHappy("_: decimal18-floor(1e18);", 1e18, "1");
        checkHappy("_: decimal18-floor(5e17);", 0, "0.5");
        checkHappy("_: decimal18-floor(2e18);", 2e18, "2");
        checkHappy("_: decimal18-floor(3e18);", 3e18, "3");
        checkHappy("_: decimal18-floor(38e17);", 3e18, "3.8");
    }

    /// Test the eval of `decimal18-floor` for bad inputs.
    function testOpDecimal18FloorNPEvalBad() external {
        checkBadInputs("_: decimal18-floor();", 0, 1, 0);
        checkBadInputs("_: decimal18-floor(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18ExpNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-floor<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
