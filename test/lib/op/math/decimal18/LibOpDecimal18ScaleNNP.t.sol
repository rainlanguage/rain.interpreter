// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

contract LibOpDecimal18ScaleNNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18ScaleNNP.
    /// Inputs are always 1, outputs are always 1.
    function testOpDecimal18ScaleNNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs, uint16 op) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpDecimal18ScaleNNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10 | uint256(op)));
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18ScaleNNP.
    function testOpDecimal18ScaleNNPRun(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
        scale = bound(scale, 0, type(uint8).max);
        round = bound(round, 0, 1);
        saturate = bound(saturate, 0, 1);
        uint256 flags = round | (saturate << 1);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = Operand.wrap((1 << 0x10) | (flags << 8) | scale);
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = value;

        if (LibWillOverflow.scaleNWillOverflow(value, scale, flags)) {
            vm.expectRevert(stdError.arithmeticError);
        }

        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18ScaleNNP.referenceFn,
            LibOpDecimal18ScaleNNP.integrity,
            LibOpDecimal18ScaleNNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-scale-n`.
    function testOpDecimal18ScaleNNPEval() external {
        // Scale 0 value 0 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<0>(0);", 0, "0 0 0 0");
        // Scale 0 value 0 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<0 0 1>(0);", 0, "0 0 0 1");
        // Scale 0 value 0 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<0 1 0>(0);", 0, "0 0 1 0");
        // Scale 0 value 0 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<0 1 1>(0);", 0, "0 0 1 1");
        // Scale 0 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<0>(1);", 0, "0 1 0 0");
        // Scale 0 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<0 0 1>(1);", 0, "0 1 0 1");
        // Scale 0 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<0 1 0>(1);", 1, "0 1 1 0");
        // Scale 0 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<0 1 1>(1);", 1, "0 1 1 1");
        // Scale 1 value 0 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<1>(0);", 0, "1 0 0 0");
        // Scale 1 value 0 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<1 0 1>(0);", 0, "1 0 0 1");
        // Scale 1 value 0 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<1 1 0>(0);", 0, "1 0 1 0");
        // Scale 1 value 0 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<1 1 1>(0);", 0, "1 0 1 1");
        // Scale 1 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<1>(1);", 0, "1 1 0 0");
        // Scale 1 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<1 0 1>(1);", 0, "1 1 0 1");
        // Scale 1 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<1 1 0>(1);", 1, "1 1 1 0");
        // Scale 1 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<1 1 1>(1);", 1, "1 1 1 1");
        // Scale 18 value 1 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<18>(1);", 1, "18 1 0 0");
        // Scale 18 value 1 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<18 0 1>(1);", 1, "18 1 0 1");
        // Scale 18 value 1 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<18 1 0>(1);", 1, "18 1 1 0");
        // Scale 18 value 1 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<18 1 1>(1);", 1, "18 1 1 1");
        // Scale 18 value 1e18 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<18>(1e18);", 1e18, "18 1e18 0 0");
        // Scale 18 value 1e18 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<18 0 1>(1e18);", 1e18, "18 1e18 0 1");
        // Scale 18 value 1e18 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<18 1 0>(1e18);", 1e18, "18 1e18 1 0");
        // Scale 18 value 1e18 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<18 1 1>(1e18);", 1e18, "18 1e18 1 1");
        // Scale 19 value 1e18 round 0 saturate 0
        checkHappy("_: decimal18-scale-n<19>(1e18);", 1e19, "19 1e18 0 0");
        // Scale 19 value 1e18 round 0 saturate 1
        checkHappy("_: decimal18-scale-n<19 0 1>(1e18);", 1e19, "19 1e18 0 1");
        // Scale 19 value 1e18 round 1 saturate 0
        checkHappy("_: decimal18-scale-n<19 1 0>(1e18);", 1e19, "19 1e18 1 0");
        // Scale 19 value 1e18 round 1 saturate 1
        checkHappy("_: decimal18-scale-n<19 1 1>(1e18);", 1e19, "19 1e18 1 1");

        // Test rounding down while scaling down.
        checkHappy("_: decimal18-scale-n<17>(1);", 0, "19 1 0 0");
        // Test rounding up while scaling down.
        checkHappy("_: decimal18-scale-n<17 1>(1);", 1, "19 1 1 0");
        // Test saturating while scaling up.
        checkHappy("_: decimal18-scale-n<36 0 1>(1e70);", type(uint256).max, "0 1e70 0 1");
        // Test error while scaling up.
        checkUnhappy("_: decimal18-scale-n<36>(1e70);", stdError.arithmeticError);
    }

    /// Test the eval of `decimal18-scale-n` opcode parsed from a string.
    /// Tests zero inputs.
    function testOpDecimal18ScaleNNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-scale-n<0>();", 0, 1, 0);
    }

    /// Test the eval of `decimal18-scale-n` opcode parsed from a string.
    /// Tests two inputs.
    function testOpDecimal18ScaleNNPEvalOneInput() external {
        checkBadInputs("_: decimal18-scale-n<0>(0 5);", 2, 1, 2);
        checkBadInputs("_: decimal18-scale-n<0>(0 0);", 2, 1, 2);
        checkBadInputs("_: decimal18-scale-n<0>(0 1);", 2, 1, 2);
        checkBadInputs("_: decimal18-scale-n<0>(0 max-int-value());", 2, 1, 2);
    }
}
