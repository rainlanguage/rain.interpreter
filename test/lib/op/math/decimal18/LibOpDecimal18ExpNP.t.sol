// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {
    OpTest,
    IntegrityCheckStateNP,
    Operand,
    InterpreterStateNP,
    UnexpectedOperand
} from "test/util/abstract/OpTest.sol";
import {LibOpDecimal18ExpNP} from "src/lib/op/math/decimal18/LibOpDecimal18ExpNP.sol";

contract LibOpDecimal18ExpNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18ExpNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18ExpNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18ExpNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18ExpNP.
    function testOpDecimal18ExpNPRun(uint256 a) public {
        a = bound(a, 0, type(uint64).max - 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = Operand.wrap((1 << 0x10) | 0);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = a;

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18ExpNP.referenceFn,
            LibOpDecimal18ExpNP.integrity,
            LibOpDecimal18ExpNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-exp`.
    function testOpDecimal18ExpNPEval() external {
        checkHappy("_: decimal18-exp(0);", 1e18, "e^0");
        checkHappy("_: decimal18-exp(1e18);", 2718281828459045234, "e^1");
        checkHappy("_: decimal18-exp(5e17);", 1648721270700128145, "e^0.5");
        checkHappy("_: decimal18-exp(2e18);", 7389056098930650223, "e^2");
        checkHappy("_: decimal18-exp(3e18);", 20085536923187667724, "e^3");
    }

    /// Test the eval of `decimal18-exp` for bad inputs.
    function testOpDecimal18ExpNPEvalBad() external {
        checkBadInputs("_: decimal18-exp();", 0, 1, 0);
        checkBadInputs("_: decimal18-exp(1 1);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpDecimal18ExpNPEvalOperandDisallowed() external {
        checkUnhappyParse("_: decimal18-exp<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
