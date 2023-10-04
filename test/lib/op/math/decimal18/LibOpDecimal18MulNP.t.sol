// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibPointer.sol";
import {LibOpDecimal18MulNP} from "src/lib/op/math/decimal18/LibOpDecimal18MulNP.sol";
import {Math as OZMath} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import "test/util/abstract/OpTest.sol";
import {PRBMath_MulDiv18_Overflow} from "prb-math/Common.sol";
import "rain.math.fixedpoint/lib/LibWillOverflow.sol";

contract LibOpDecimal18MulNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18MulNP. This tests the
    /// happy path where the inputs input and calc match.
    function testOpDecimal18MulNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpDecimal18MulNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpDecimal18MulNP. This tests the
    /// unhappy path where the operand is invalid due to 0 inputs.
    function testOpDecimal18MulNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18MulNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpDecimal18MulNP. This tests the
    /// unhappy path where the operand is invalid due to 1 inputs.
    function testOpDecimal18MulNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18MulNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18MulNP.
    function testOpDecimal18MulNPRun(uint256[] memory inputs) public {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        // This is kinda shitty because it just duplicates what the reference
        // fn is doing, but because neither PRB nor Open Zeppelin expose a
        // try/catch for overflow, we have to do this.
        uint256 a = inputs[0];
        for (uint256 i = 1; i < inputs.length; i++) {
            uint256 b = inputs[i];
            if (LibWillOverflow.mulDivWillOverflow(a, b, 1e18)) {
                vm.expectRevert(abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, a, b));
                break;
            }
            a = OZMath.mulDiv(a, b, 1e18);
        }
        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18MulNP.referenceFn,
            LibOpDecimal18MulNP.integrity,
            LibOpDecimal18MulNP.run,
            inputs
        );
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests zero inputs.
    function testOpDecimal18MulNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-mul();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests one input.
    function testOpDecimal18MulNPEvalOneInput() external {
        checkBadInputs("_: decimal18-mul(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-mul(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-mul(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-mul(max-decimal18-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests the happy path where we do not overflow.
    function testOpDecimal18MulNPEvalTwoInputsHappy() external {
        checkHappy("_: decimal18-mul(0 1e18);", 0, "0 1");
        checkHappy("_: decimal18-mul(1e18 1e18);", 1e18, "1 1");
        checkHappy("_: decimal18-mul(1e18 2e18);", 2e18, "1 2");
        checkHappy("_: decimal18-mul(2e18 1e18);", 2e18, "2 1");
        checkHappy("_: decimal18-mul(2e18 2e18);", 4e18, "2 2");
        checkHappy("_: decimal18-mul(2e18 1e17);", 2e17, "2 0.1");
        checkHappy("_: decimal18-mul(1e18 1e17);", 1e17, "1 0.1");
        checkHappy("_: decimal18-mul(1e18 1e16);", 1e16, "1 0.01");
        checkHappy("_: decimal18-mul(1e15 1e15);", 1e12, "0.001 0.001");
        checkHappy("_: decimal18-mul(1e19 1e19);", 1e20, "10 10");
        // Test an intermediate overflow.
        checkHappy("_: decimal18-mul(1e18 max-decimal18-value());", type(uint256).max, "1 max-decimal18-value()");
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests the unhappy path where the final result overflows.
    function testOpDecimal18MulNPEvalTwoInputsUnhappyOverflow() external {
        checkUnhappy(
            "_: decimal18-mul(max-decimal18-value() 1e19);",
            abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, type(uint256).max, 1e19)
        );
        checkUnhappy(
            "_: decimal18-mul(1e70 1e30);", abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, 1e70, 1e30)
        );
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests the happy path where we do not divide by zero or overflow.
    function testOpDecimal18MulNPEvalThreeInputsHappy() external {
        checkHappy("_: decimal18-mul(0 0 0);", 0, "0 0 0");
        checkHappy("_: decimal18-mul(1e18 0 0);", 0, "1 0 0");
        checkHappy("_: decimal18-mul(1e18 1e18 0);", 0, "1 1 0");
        checkHappy("_: decimal18-mul(1e18 1e18 1e18);", 1e18, "1 1 1");
        checkHappy("_: decimal18-mul(1e18 1e18 2e18);", 2e18, "1 1 2");
        checkHappy("_: decimal18-mul(1e18 2e18 1e18);", 2e18, "1 2 1");
        checkHappy("_: decimal18-mul(2e18 1e18 1e18);", 2e18, "2 1 1");
        checkHappy("_: decimal18-mul(2e18 2e18 2e18);", 8e18, "2 2 2");
        checkHappy("_: decimal18-mul(2e18 1e17 1e18);", 2e17, "2 0.1 1");
        checkHappy("_: decimal18-mul(1e18 1e17 1e18);", 1e17, "1 0.1 1");
        checkHappy("_: decimal18-mul(1e18 1e16 1e18);", 1e16, "1 0.01 1");
        checkHappy("_: decimal18-mul(1e15 1e15 1e15);", 1e9, "0.001 0.001 0.001");
        checkHappy("_: decimal18-mul(1e19 1e19 1e19);", 1e21, "10 10 10");
        // Test an intermediate overflow.
        checkHappy("_: decimal18-mul(1e18 max-decimal18-value() 1e18);", type(uint256).max, "1 max-decimal18-value() 1");
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests the unhappy path where the final result overflows.
    function testOpDecimal18MulNPEvalThreeInputsUnhappyOverflow() external {
        checkUnhappy(
            "_: decimal18-mul(max-decimal18-value() 1e18 1e19);",
            abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, type(uint256).max, 1e19)
        );
        checkUnhappy(
            "_: decimal18-mul(1e70 1e18 1e26);", abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, 1e70, 1e26)
        );
        checkUnhappy(
            "_: decimal18-mul(1e70 1e26 1e18);", abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, 1e70, 1e26)
        );
    }

    /// Test the eval of `decimal18-mul` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpDecimal18MulNPEvalOperandsDisallowed() external {
        checkDisallowedOperand("_: decimal18-mul<>(1e18 1e18 1e18 1e18);", 16);
        checkDisallowedOperand("_: decimal18-mul<0>(1e18 1e18 1e18);", 16);
        checkDisallowedOperand("_: decimal18-mul<1>(1e18 1e18 1e18);", 16);
        checkDisallowedOperand("_: decimal18-mul<2>(1e18 1e18 1e18);", 16);
        checkDisallowedOperand("_: decimal18-mul<0 0>(1e18 1e18 1e18);", 16);
        checkDisallowedOperand("_: decimal18-mul<0 1>(1e18 1e18 1e18);", 16);
        checkDisallowedOperand("_: decimal18-mul<1 0>(1e18 1e18 1e18);", 16);
    }
}
