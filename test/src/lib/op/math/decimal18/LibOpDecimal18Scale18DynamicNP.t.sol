// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest, IntegrityCheckStateNP, InterpreterStateNP, Operand, stdError} from "test/abstract/OpTest.sol";
import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
import {LibOpDecimal18Scale18DynamicNP} from "src/lib/op/math/decimal18/LibOpDecimal18Scale18DynamicNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpDecimal18Scale18DynamicNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18Scale18DynamicNP.
    /// Inputs are always 2, outputs are always 1.
    function testOpDecimal18Scale18DynamicNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs, uint16 op)
        external
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpDecimal18Scale18DynamicNP.integrity(state, LibOperand.build(inputs, 1, op));
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18Scale18DynamicNP.
    function testOpDecimal18Scale18DynamicNPRun(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
        round = bound(round, 0, 1);
        saturate = bound(saturate, 0, 1);
        uint256 flags = round | (saturate << 1);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = LibOperand.build(2, 1, uint16(flags));
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = scale;
        inputs[1] = value;

        if (LibWillOverflow.scale18WillOverflow(value, scale, flags)) {
            vm.expectRevert(stdError.arithmeticError);
        }

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18Scale18DynamicNP.referenceFn,
            LibOpDecimal18Scale18DynamicNP.integrity,
            LibOpDecimal18Scale18DynamicNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-scale18-dynamic`.
    function testOpDecimal18Scale18DynamicNPEval() external {
        // Scale 0 value 0 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(0 0);", 0, "0 0 0 0");
        // Scale 0 value 0 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(0 0);", 0, "0 0 0 1");
        // Scale 0 value 0 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(0 0);", 0, "0 0 1 0");
        // Scale 0 value 0 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(0 0);", 0, "0 0 1 1");
        // Scale 0 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(0 1);", 1e18, "0 1 0 0");
        // Scale 0 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(0 1);", 1e18, "0 1 0 1");
        // Scale 0 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(0 1);", 1e18, "0 1 1 0");
        // Scale 0 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(0 1);", 1e18, "0 1 1 1");
        // Scale 1 value 0 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(1 0);", 0, "1 0 0 0");
        // Scale 1 value 0 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(1 0);", 0, "1 0 0 1");
        // Scale 1 value 0 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(1 0);", 0, "1 0 1 0");
        // Scale 1 value 0 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(1 0);", 0, "1 0 1 1");
        // Scale 1 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(1 1);", 1e17, "1 1 0 0");
        // Scale 1 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(1 1);", 1e17, "1 1 0 1");
        // Scale 1 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(1 1);", 1e17, "1 1 1 0");
        // Scale 1 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(1 1);", 1e17, "1 1 1 1");
        // Scale 18 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(18 1);", 1, "18 1 0 0");
        // Scale 18 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(18 1);", 1, "18 1 0 1");
        // Scale 18 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(18 1);", 1, "18 1 1 0");
        // Scale 18 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(18 1);", 1, "18 1 1 1");
        // Scale 18 value 1e18 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(18 1e18);", 1e18, "18 1e18 0 0");
        // Scale 18 value 1e18 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(18 1e18);", 1e18, "18 1e18 0 1");
        // Scale 18 value 1e18 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(18 1e18);", 1e18, "18 1e18 1 0");
        // Scale 18 value 1e18 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(18 1e18);", 1e18, "18 1e18 1 1");
        // Scale 19 value 1e18 round 0 saturate 0
        checkHappy("_: decimal18-scale18-dynamic(19 1e18);", 1e17, "19 1e18 0 0");
        // Scale 19 value 1e18 round 0 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<0 1>(19 1e18);", 1e17, "19 1e18 0 1");
        // Scale 19 value 1e18 round 1 saturate 0
        checkHappy("_: decimal18-scale18-dynamic<1 0>(19 1e18);", 1e17, "19 1e18 1 0");
        // Scale 19 value 1e18 round 1 saturate 1
        checkHappy("_: decimal18-scale18-dynamic<1 1>(19 1e18);", 1e17, "19 1e18 1 1");

        // Test rounding down while scaling down.
        checkHappy("_: decimal18-scale18-dynamic(19 1);", 0, "19 1 0 0");
        // Test rounding up while scaling down.
        checkHappy("_: decimal18-scale18-dynamic<1>(19 1);", 1, "19 1 1 0");
        // Test saturating while scaling up.
        checkHappy("_: decimal18-scale18-dynamic<0 1>(0 1e70);", type(uint256).max, "0 1e70 0 1");
        // Test error while scaling up.
        checkUnhappy("_: decimal18-scale18-dynamic(0 1e70);", stdError.arithmeticError);
    }

    /// Test the eval of `decimal18-scale18-dynamic` opcode parsed from a string.
    /// Tests zero inputs.
    function testOpDecimal18Scale18DynamicNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-scale18-dynamic();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-scale18-dynamic` opcode parsed from a string.
    /// Tests one input.
    function testOpDecimal18Scale18DynamicNPEvalOneInput() external {
        checkBadInputs("_: decimal18-scale18-dynamic(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-scale18-dynamic(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-scale18-dynamic(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-scale18-dynamic(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-scale18-dynamic` opcode parsed from a string.
    /// Tests three inputs.
    function testOpDecimal18Scale18DynamicNPEvalThreeInputs() external {
        checkBadInputs("_: decimal18-scale18-dynamic(0 0 0);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(0 0 1);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(0 1 0);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(0 1 1);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(1 0 0);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(1 0 1);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(1 1 0);", 3, 2, 3);
        checkBadInputs("_: decimal18-scale18-dynamic(1 1 1);", 3, 2, 3);
    }
}
