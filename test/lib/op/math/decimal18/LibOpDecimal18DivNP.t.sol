// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibPointer.sol";

import {Math as OZMath} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import "test/util/abstract/OpTest.sol";
import {PRBMath_MulDiv_Overflow} from "prb-math/Common.sol";
import "rain.math.fixedpoint/lib/LibWillOverflow.sol";
import {LibOpDecimal18DivNP} from "src/lib/op/math/decimal18/LibOpDecimal18DivNP.sol";

contract LibOpDecimal18DivNPTest is OpTest {
    /// Directly test the integrity logic of LibOpDecimal18DivNP. This tests the
    /// happy path where the inputs input and calc match.
    function testOpDecimal18DivNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        inputs = uint8(bound(inputs, 2, type(uint8).max));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpDecimal18DivNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpDecimal18DivNP. This tests the
    /// unhappy path where the operand is invalid due to 0 inputs.
    function testOpDecimal18DivNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18DivNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpDecimal18DivNP. This tests the
    /// unhappy path where the operand is invalid due to 1 inputs.
    function testOpDecimal18DivNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpDecimal18DivNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpDecimal18DivNP.
    function testOpDecimal18DivNPRun(uint256[] memory inputs) public {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        // This is kinda shitty because it just duplicates what the reference
        // fn is doing, but because neither PRB nor Open Zeppelin expose a
        // try/catch for overflow, we have to do this.
        uint256 a = inputs[0];
        for (uint256 i = 1; i < inputs.length; i++) {
            uint256 b = inputs[i];
            if (b == 0) {
                // There's two different errors that we can get for the same
                // basic issue (divide by zero). This is bad juju replicating
                // so much of the SUT logic here, but it's the only way to
                // test this.
                uint256 prod0; // Least significant 256 bits of the product
                uint256 prod1; // Most significant 256 bits of the product
                uint256 one = 1e18;
                assembly ("memory-safe") {
                    let mm := mulmod(a, one, not(0))
                    prod0 := mul(a, one)
                    prod1 := sub(sub(mm, prod0), lt(mm, prod0))
                }
                if (prod1 == 0) {
                    vm.expectRevert(stdError.divisionError);
                    break;
                } else {
                    vm.expectRevert(abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, a, 1e18, 0));
                    break;
                }
            } else if (LibWillOverflow.mulDivWillOverflow(a, 1e18, b)) {
                vm.expectRevert(abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, a, 1e18, b));
                break;
            }
            a = OZMath.mulDiv(a, 1e18, b);
        }
        opReferenceCheck(
            state,
            operand,
            LibOpDecimal18DivNP.referenceFn,
            LibOpDecimal18DivNP.integrity,
            LibOpDecimal18DivNP.run,
            inputs
        );
    }

    function testDebugOpDecimal18DivNPRun() external {
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = 115792089237316195423570985008687907853269984665640564039458;
        testOpDecimal18DivNPRun(inputs);
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests zero inputs.
    function testOpDecimal18DivNPEvalZeroInputs() external {
        checkBadInputs("_: decimal18-div();", 0, 2, 0);
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests one input.
    function testOpDecimal18DivNPEvalOneInput() external {
        checkBadInputs("_: decimal18-div(5);", 1, 2, 1);
        checkBadInputs("_: decimal18-div(0);", 1, 2, 1);
        checkBadInputs("_: decimal18-div(1);", 1, 2, 1);
        checkBadInputs("_: decimal18-div(max-int-value());", 1, 2, 1);
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests the happy path where we do not divide by zero or overflow.
    function testOpDecimal18DivNPEvalTwoInputsHappy() external {
        checkHappy("_: decimal18-div(0 1e18);", 0, "0 1");
        checkHappy("_: decimal18-div(1e18 1e18);", 1e18, "1 1");
        checkHappy("_: decimal18-div(1e18 2e18);", 5e17, "1 2");
        checkHappy("_: decimal18-div(2e18 1e18);", 2e18, "2 1");
        checkHappy("_: decimal18-div(2e18 2e18);", 1e18, "2 2");
        checkHappy("_: decimal18-div(2e18 1e17);", 2e19, "2 0.1");
        // This one is interesting because it overflows internally before
        // reaching a final result.
        checkHappy("_: decimal18-div(max-int-value() 1e18);", type(uint256).max, "max-int-value() 1");
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests the unhappy path where we divide by zero.
    function testOpDecimal18DivNPEvalTwoInputsUnhappy() external {
        checkUnhappy("_: decimal18-div(0 0);", stdError.divisionError);
        checkUnhappy("_: decimal18-div(1e18 0);", stdError.divisionError);
        checkUnhappy(
            "_: decimal18-div(max-int-value() 0);",
            abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 0)
        );
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests two inputs.
    /// Tests the unhappy path where the final result overflows.
    function testOpDecimal18DivNPEvalTwoInputsUnhappyOverflow() external {
        checkUnhappy(
            "_: decimal18-div(max-int-value() 1);",
            abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 1)
        );
        checkUnhappy(
            "_: decimal18-div(1e70 1e10);", abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, 1e70, 1e18, 1e10)
        );
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests the happy path where we do not divide by zero or overflow.
    function testOpDecimal18DivNPEvalThreeInputsHappy() external {
        checkHappy("_: decimal18-div(0 1e18 1e18);", 0, "0 1 1");
        checkHappy("_: decimal18-div(1e18 1e18 1e18);", 1e18, "1 1 1");
        checkHappy("_: decimal18-div(1e18 1e18 2e18);", 5e17, "1 1 2");
        checkHappy("_: decimal18-div(1e18 2e18 1e18);", 5e17, "1 2 1");
        checkHappy("_: decimal18-div(1e18 2e18 2e18);", 25e16, "1 2 2");
        checkHappy("_: decimal18-div(1e18 2e18 1e17);", 5e18, "1 2 0.1");
        // This one is interesting because it overflows internally before
        // reaching a final result.
        checkHappy("_: decimal18-div(max-int-value() 1e18 1e18);", type(uint256).max, "max-int-value() 1 1");
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests the unhappy path where we divide by zero.
    function testOpDecimal18DivNPEvalThreeInputsUnhappy() external {
        checkUnhappy("_: decimal18-div(0 0 0);", stdError.divisionError);
        checkUnhappy("_: decimal18-div(1e18 0 0);", stdError.divisionError);
        checkUnhappy("_: decimal18-div(1e18 1e18 0);", stdError.divisionError);
        checkUnhappy(
            "_: decimal18-div(max-int-value() 0 0);",
            abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 0)
        );
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests three inputs.
    /// Tests the unhappy path where the final result overflows.
    function testOpDecimal18DivNPEvalThreeInputsUnhappyOverflow() external {
        checkUnhappy(
            "_: decimal18-div(max-int-value() 1 1);",
            abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 1)
        );
        checkUnhappy(
            "_: decimal18-div(1e70 1e18 1e10);",
            abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, 1e70, 1e18, 1e10)
        );
        checkUnhappy(
            "_: decimal18-div(1e70 1e10 1e18);",
            abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, 1e70, 1e18, 1e10)
        );
    }

    /// Test the eval of `decimal18-div` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpDecimal18DivNPEvalOperandsDisallowed() external {
        checkDisallowedOperand("_: decimal18-div<0>(1e18 1e18 1e18);");
        checkDisallowedOperand("_: decimal18-div<1>(1e18 1e18 1e18);");
        checkDisallowedOperand("_: decimal18-div<2>(1e18 1e18 1e18);");
        checkDisallowedOperand("_: decimal18-div<0 0>(1e18 1e18 1e18);");
        checkDisallowedOperand("_: decimal18-div<0 1>(1e18 1e18 1e18);");
        checkDisallowedOperand("_: decimal18-div<1 0>(1e18 1e18 1e18);");
    }
}
