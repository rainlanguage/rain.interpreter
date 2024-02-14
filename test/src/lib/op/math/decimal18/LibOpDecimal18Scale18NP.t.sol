// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, InterpreterStateNP, Operand, stdError} from "test/abstract/OpTest.sol";
import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
import {LibOpDecimal18Scale18NP} from "src/lib/op/math/decimal18/LibOpDecimal18Scale18NP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18Scale18NPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18Scale18NP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18Scale18NPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs, uint16 op) external {
        inputs = uint8(bound(inputs, 1, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpDecimal18Scale18NP.integrity(state, LibOperand.build(inputs, 1, op));
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18Scale18NP.
    function testOpDecimal18Scale18NPRun(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
        scale = bound(scale, 0, type(uint8).max);
        round = bound(round, 0, 1);
        saturate = bound(saturate, 0, 1);
        uint256 flags = round | (saturate << 1);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(1, 1, uint16((flags << 8) | scale));
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = value;

        if (LibWillOverflow.scale18WillOverflow(value, scale, flags)) {
            vm.expectRevert(stdError.arithmeticError);
        }

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18Scale18NP.referenceFn,
            LibOpDecimal18Scale18NP.integrity,
            LibOpDecimal18Scale18NP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-scale18`.
    function testOpDecimal18Scale18NPEval() external {
        // Scale 0 value 0 round 0 saturate 0
        checkHappy("_: decimal18-scale18<0>(0);", 0, "0 0 0 0");
        // Scale 0 value 0 round 0 saturate 1
        checkHappy("_: decimal18-scale18<0 0 1>(0);", 0, "0 0 0 1");
        // Scale 0 value 0 round 1 saturate 0
        checkHappy("_: decimal18-scale18<0 1 0>(0);", 0, "0 0 1 0");
        // Scale 0 value 0 round 1 saturate 1
        checkHappy("_: decimal18-scale18<0 1 1>(0);", 0, "0 0 1 1");
        // Scale 0 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale18<0>(1);", 1e18, "0 1 0 0");
        // Scale 0 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale18<0 0 1>(1);", 1e18, "0 1 0 1");
        // Scale 0 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale18<0 1 0>(1);", 1e18, "0 1 1 0");
        // Scale 0 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale18<0 1 1>(1);", 1e18, "0 1 1 1");
        // Scale 1 value 0 round 0 saturate 0
        checkHappy("_: decimal18-scale18<1>(0);", 0, "1 0 0 0");
        // Scale 1 value 0 round 0 saturate 1
        checkHappy("_: decimal18-scale18<1 0 1>(0);", 0, "1 0 0 1");
        // Scale 1 value 0 round 1 saturate 0
        checkHappy("_: decimal18-scale18<1 1 0>(0);", 0, "1 0 1 0");
        // Scale 1 value 0 round 1 saturate 1
        checkHappy("_: decimal18-scale18<1 1 1>(0);", 0, "1 0 1 1");
        // Scale 1 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale18<1>(1);", 1e17, "1 1 0 0");
        // Scale 1 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale18<1 0 1>(1);", 1e17, "1 1 0 1");
        // Scale 1 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale18<1 1 0>(1);", 1e17, "1 1 1 0");
        // Scale 1 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale18<1 1 1>(1);", 1e17, "1 1 1 1");
        // Scale 18 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale18<18>(1);", 1, "18 1 0 0");
        // Scale 18 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale18<18 0 1>(1);", 1, "18 1 0 1");
        // Scale 18 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale18<18 1 0>(1);", 1, "18 1 1 0");
        // Scale 18 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale18<18 1 1>(1);", 1, "18 1 1 1");
        // Scale 18 value 1e18 round 0 saturate 0
        checkHappy("_: decimal18-scale18<18>(1e18);", 1e18, "18 1e18 0 0");
        // Scale 18 value 1e18 round 0 saturate 1
        checkHappy("_: decimal18-scale18<18 0 1>(1e18);", 1e18, "18 1e18 0 1");
        // Scale 18 value 1e18 round 1 saturate 0
        checkHappy("_: decimal18-scale18<18 1 0>(1e18);", 1e18, "18 1e18 1 0");
        // Scale 18 value 1e18 round 1 saturate 1
        checkHappy("_: decimal18-scale18<18 1 1>(1e18);", 1e18, "18 1e18 1 1");
        // Scale 19 value 1e18 round 0 saturate 0
        checkHappy("_: decimal18-scale18<19>(1e18);", 1e17, "19 1e18 0 0");
        // Scale 19 value 1e18 round 0 saturate 1
        checkHappy("_: decimal18-scale18<19 0 1>(1e18);", 1e17, "19 1e18 0 1");
        // Scale 19 value 1e18 round 1 saturate 0
        checkHappy("_: decimal18-scale18<19 1 0>(1e18);", 1e17, "19 1e18 1 0");
        // Scale 19 value 1e18 round 1 saturate 1
        checkHappy("_: decimal18-scale18<19 1 1>(1e18);", 1e17, "19 1e18 1 1");

        // Test rounding down while scaling down.
        checkHappy("_: decimal18-scale18<19>(1);", 0, "19 1 0 0");
        // Test rounding up while scaling down.
        checkHappy("_: decimal18-scale18<19 1>(1);", 1, "19 1 1 0");
        // Test saturating while scaling up.
        checkHappy("_: decimal18-scale18<0 0 1>(1e70);", type(uint256).max, "0 1e70 0 1");
        // Test error while scaling up.
        checkUnhappy("_: decimal18-scale18<0>(1e70);", stdError.arithmeticError);
    }

    /// Test the eval of `int-to-decimal18` which is an alias of `decimal18-scale18<0>`.
    function testOpIntToDecimal18NPEval() external {
        checkHappy("_: int-to-decimal18(0);", 0, "0");
        checkHappy("_: int-to-decimal18(1);", 1e18, "1");
        checkHappy("_: int-to-decimal18(2);", 2e18, "2");
        checkHappy("_: int-to-decimal18(1e18);", 1e36, "1e18");
    }

    /// Test the eval of `decimal18-scale18` opcode parsed from a string.
    /// Tests zero inputs.
    function testOpDecimal18Scale18NPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-scale18<0>();", 0, 1, 0);
    }

    /// Test the eval of `decimal18-scale18` opcode parsed from a string.
    /// Tests two inputs.
    function testOpDecimal18Scale18NPEvalOneInput() external {
        checkBadInputs("_: decimal18-scale18<0>(0 5);", 2, 1, 2);
        checkBadInputs("_: decimal18-scale18<0>(0 0);", 2, 1, 2);
        checkBadInputs("_: decimal18-scale18<0>(0 1);", 2, 1, 2);
        checkBadInputs("_: decimal18-scale18<0>(0 max-int-value());", 2, 1, 2);
    }
}
