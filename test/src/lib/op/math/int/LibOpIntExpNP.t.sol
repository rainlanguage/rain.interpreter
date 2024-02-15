// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {stdError} from "forge-std/Test.sol";

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {OpTest} from "test/abstract/OpTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOpIntExpNP} from "src/lib/op/math/int/LibOpIntExpNP.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpIntExpNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIntExpNP. This tests the happy
    /// path where the inputs input and calc match.
    function testOpIntExpNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 operandData)
        external
    {
        inputs = uint8(bound(inputs, 2, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIntExpNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntExpNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpIntExpNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntExpNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIntExpNP. This tests the unhappy
    /// path where the operand is invalid due to 1 inputs.
    function testOpIntExpNPIntegrityUnhappyOneInput(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIntExpNP.integrity(state, Operand.wrap(0x010000));
        // Calc inputs will be minimum 2.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIntExpNP.
    function testOpIntExpNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length >= 2);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        uint256 overflows = 0;
        unchecked {
            uint256 a = inputs[0];
            for (uint256 i = 1; i < inputs.length; i++) {
                uint256 b = inputs[i];
                if (b == 0) {
                    a = 1;
                    continue;
                } else if (b == 1 || a == 0) {
                    continue;
                } else {
                    uint256 c = a;
                    for (uint256 j = 1; j < b; j++) {
                        uint256 d = a * c;
                        if (d / c != a) {
                            overflows++;
                            break;
                        }
                        if (d == a) {
                            break;
                        }
                        a = d;
                    }
                }
            }
        }
        if (overflows > 0) {
            vm.expectRevert(stdError.arithmeticError);
        }
        opReferenceCheck(state, operand, LibOpIntExpNP.referenceFn, LibOpIntExpNP.integrity, LibOpIntExpNP.run, inputs);
    }

    /// Test the eval of `int-exp` opcode parsed from a string. Tests zero inputs.
    function testOpIntExpNPEvalZeroInputs() external {
        checkBadInputs("_: int-exp();", 0, 2, 0);
    }

    /// Test the eval of `int-exp` opcode parsed from a string. Tests one input.
    function testOpIntExpNPEvalOneInput() external {
        checkBadInputs("_: int-exp(5);", 1, 2, 1);
        checkBadInputs("_: int-exp(0);", 1, 2, 1);
        checkBadInputs("_: int-exp(1);", 1, 2, 1);
        checkBadInputs("_: int-exp(max-int-value());", 1, 2, 1);
    }

    function testOpIntExpNPEvalZeroOutputs() external {
        checkBadOutputs(": int-exp(0 0);", 2, 1, 0);
    }

    function testOpIntExpNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: int-exp(0 0);", 2, 1, 2);
    }

    /// Test the eval of `int-exp` opcode parsed from a string. Tests two inputs.
    /// Tests the happy path where we do not overflow.
    function testOpIntExpNPEval2InputsHappy() external {
        // Anything exp 0 is 1.
        checkHappy("_: int-exp(0 0);", 1, "0 ** 0");
        checkHappy("_: int-exp(1 0);", 1, "1 ** 0");
        checkHappy("_: int-exp(max-int-value() 0);", 1, "max-int-value() ** 0");

        // 1 exp anything is 1.
        checkHappy("_: int-exp(1 0);", 1, "1 ** 0");
        checkHappy("_: int-exp(1 1);", 1, "1 ** 1");
        checkHappy("_: int-exp(1 2);", 1, "1 ** 2");
        checkHappy("_: int-exp(1 3);", 1, "1 ** 3");
        checkHappy("_: int-exp(1 max-int-value());", 1, "1 ** max-int-value()");

        // Anything exp 1 is itself.
        checkHappy("_: int-exp(0 1);", 0, "0 ** 1");
        checkHappy("_: int-exp(1 1);", 1, "1 ** 1");
        checkHappy("_: int-exp(max-int-value() 1);", type(uint256).max, "max-int-value() ** 1");

        // Anything exp 2 is itself squared.
        checkHappy("_: int-exp(0 2);", 0, "0 ** 2");
        checkHappy("_: int-exp(1 2);", 1, "1 ** 2");
        checkHappy("_: int-exp(2 2);", 4, "2 ** 2");
        checkHappy("_: int-exp(3 2);", 9, "3 ** 2");

        // Anything exp 3 is itself cubed.
        checkHappy("_: int-exp(0 3);", 0, "0 ** 3");
        checkHappy("_: int-exp(1 3);", 1, "1 ** 3");
        checkHappy("_: int-exp(2 3);", 8, "2 ** 3");
        checkHappy("_: int-exp(3 3);", 27, "3 ** 3");
    }

    /// Test the eval of `int-exp` opcode parsed from a string. Tests two inputs.
    /// Tests the unhappy path where we overflow.
    function testOpIntExpNPEval2InputsUnhappy() external {
        checkUnhappyOverflow("_: int-exp(2 max-int-value());");
        checkUnhappyOverflow("_: int-exp(3 max-int-value());");
        checkUnhappyOverflow("_: int-exp(max-int-value() max-int-value());");
    }

    /// Test the eval of `int-exp` opcode parsed from a string. Tests three inputs.
    /// Tests the happy path where we do not divide by zero.
    function testOpIntExpNPEval3InputsHappy() external {
        // Anything exp 0 is 1.
        checkHappy("_: int-exp(0 0 0);", 1, "0 ** 0 ** 0");
        checkHappy("_: int-exp(1 0 0);", 1, "1 ** 0 ** 0");
        checkHappy("_: int-exp(max-int-value() 0 0);", 1, "max-int-value() ** 0 ** 0");
        checkHappy("_: int-exp(0 1 0);", 1, "0 ** 1 ** 0");
        checkHappy("_: int-exp(1 1 0);", 1, "1 ** 1 ** 0");
        checkHappy("_: int-exp(0 0 1);", 1, "0 ** 0 ** 1");
        checkHappy("_: int-exp(1 0 1);", 1, "1 ** 0 ** 1");
        checkHappy("_: int-exp(max-int-value() 0 1);", 1, "max-int-value() ** 0 ** 1");

        // 1 exp anything is 1.
        checkHappy("_: int-exp(1 0 0);", 1, "1 ** 0 ** 0");
        checkHappy("_: int-exp(1 0 1);", 1, "1 ** 0 ** 1");
        checkHappy("_: int-exp(1 1 0);", 1, "1 ** 1 ** 0");
        checkHappy("_: int-exp(1 1 1);", 1, "1 ** 1 ** 1");
        checkHappy("_: int-exp(1 2 0);", 1, "1 ** 2 ** 0");
        checkHappy("_: int-exp(1 2 1);", 1, "1 ** 2 ** 1");
        checkHappy("_: int-exp(1 2 2);", 1, "1 ** 2 ** 2");
        checkHappy("_: int-exp(1 3 0);", 1, "1 ** 3 ** 0");

        // Anything exp 1 is itself.
        checkHappy("_: int-exp(0 1 1);", 0, "0 ** 1 ** 1");
        checkHappy("_: int-exp(1 1 1);", 1, "1 ** 1 ** 1");
        checkHappy("_: int-exp(max-int-value() 1 1);", type(uint256).max, "max-int-value() ** 1 ** 1");

        // Anything exp 2 1 is itself squared.
        checkHappy("_: int-exp(0 2 1);", 0, "0 ** 2 ** 0");
        checkHappy("_: int-exp(1 2 1);", 1, "1 ** 2 ** 0");
        checkHappy("_: int-exp(2 2 1);", 4, "2 ** 2 ** 0");
        checkHappy("_: int-exp(3 2 1);", 9, "3 ** 2 ** 0");

        // Anything exp 2 2 is itself squared squared.
        checkHappy("_: int-exp(0 2 2);", 0, "0 ** 2 ** 2");
        checkHappy("_: int-exp(1 2 2);", 1, "1 ** 2 ** 2");
        checkHappy("_: int-exp(2 2 2);", 16, "2 ** 2 ** 2");
        checkHappy("_: int-exp(3 2 2);", 81, "3 ** 2 ** 2");

        // Anything exp 3 1 is itself cubed.
        checkHappy("_: int-exp(0 3 1);", 0, "0 ** 3 ** 0");
        checkHappy("_: int-exp(1 3 1);", 1, "1 ** 3 ** 0");
        checkHappy("_: int-exp(2 3 1);", 8, "2 ** 3 ** 0");
        checkHappy("_: int-exp(3 3 1);", 27, "3 ** 3 ** 0");

        // Anything exp 3 2 is itself cubed squared.
        checkHappy("_: int-exp(0 3 2);", 0, "0 ** 3 ** 2");
        checkHappy("_: int-exp(1 3 2);", 1, "1 ** 3 ** 2");
        checkHappy("_: int-exp(2 3 2);", 64, "2 ** 3 ** 2");
        checkHappy("_: int-exp(3 3 2);", 729, "3 ** 3 ** 2");

        // Anything exp 3 3 is itself cubed cubed.
        checkHappy("_: int-exp(0 3 3);", 0, "0 ** 3 ** 3");
        checkHappy("_: int-exp(1 3 3);", 1, "1 ** 3 ** 3");
        checkHappy("_: int-exp(2 3 3);", 512, "2 ** 3 ** 3");
        checkHappy("_: int-exp(3 3 3);", 19683, "3 ** 3 ** 3");
    }

    /// Test the eval of `int-exp` opcode parsed from a string. Tests three inputs.
    /// Tests the unhappy path where we overflow.
    function testOpIntExpNPEval3InputsUnhappy() external {
        checkUnhappyOverflow("_: int-exp(2 max-int-value() 0);");
        checkUnhappyOverflow("_: int-exp(3 max-int-value() 0);");
        checkUnhappyOverflow("_: int-exp(max-int-value() max-int-value() 0);");
        checkUnhappyOverflow("_: int-exp(2 max-int-value() 1);");
        checkUnhappyOverflow("_: int-exp(3 max-int-value() 1);");
        checkUnhappyOverflow("_: int-exp(max-int-value() max-int-value() 1);");
        checkUnhappyOverflow("_: int-exp(2 max-int-value() 2);");
        checkUnhappyOverflow("_: int-exp(3 max-int-value() 2);");
        checkUnhappyOverflow("_: int-exp(max-int-value() max-int-value() 2);");
        checkUnhappyOverflow("_: int-exp(2 max-int-value() 3);");
        checkUnhappyOverflow("_: int-exp(3 max-int-value() 3);");
        checkUnhappyOverflow("_: int-exp(max-int-value() max-int-value() 3);");
    }

    /// Test the eval of `int-exp` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testOpIntExpNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_: int-exp<0>(0 0 0);");
        checkDisallowedOperand("_: int-exp<1>(0 0 0);");
        checkDisallowedOperand("_: int-exp<2>(0 0 0);");
        checkDisallowedOperand("_: int-exp<3 1>(0 0 0);");
    }
}
