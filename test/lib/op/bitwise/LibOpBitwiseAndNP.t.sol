// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibOpBitwiseAndNP} from "src/lib/op/bitwise/LibOpBitwiseAndNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";

contract LibOpBitwiseAndNPTest is OpTest {
    /// Directly test the integrity logic of LibOpBitwiseAndNP. All possible
    /// operands result in the same number of inputs and outputs, (2, 1).
    function testOpBitwiseAndNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpBitwiseAndNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpBitwiseAndNP. This tests that the
    /// opcode correctly pushes the bitwise AND onto the stack.
    function testOpBitwiseAndNPRun(uint256 x, uint256 y) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = x;
        inputs[1] = y;
        Operand operand = Operand.wrap(2 << 0x10);
        opReferenceCheck(
            state, operand, LibOpBitwiseAndNP.referenceFn, LibOpBitwiseAndNP.integrity, LibOpBitwiseAndNP.run, inputs
        );
    }

    /// Test the eval of bitwise AND parsed from a string.
    function testOpBitwiseAndNPEvalHappy() external {
        checkHappy("_: bitwise-and(0 0);", 0, "0 0");
        checkHappy("_: bitwise-and(0 1);", 0, "0 1");
        checkHappy("_: bitwise-and(1 0);", 0, "1 0");
        checkHappy("_: bitwise-and(1 1);", 1, "1 1");
        checkHappy("_: bitwise-and(0 2);", 0, "0 2");
        checkHappy("_: bitwise-and(2 0);", 0, "2 0");
        checkHappy("_: bitwise-and(1 2);", 0, "1 2");
        checkHappy("_: bitwise-and(2 1);", 0, "2 1");
        checkHappy("_: bitwise-and(2 2);", 2, "2 2");
        checkHappy("_: bitwise-and(0 3);", 0, "0 3");
        checkHappy("_: bitwise-and(3 0);", 0, "3 0");
        checkHappy("_: bitwise-and(1 3);", 1, "1 3");
        checkHappy("_: bitwise-and(3 1);", 1, "3 1");
        checkHappy("_: bitwise-and(2 3);", 2, "2 3");
        checkHappy("_: bitwise-and(3 2);", 2, "3 2");
        checkHappy("_: bitwise-and(3 3);", 3, "3 3");
    }

    /// Test that a bitwise OR with bad inputs fails integrity.
    function testOpBitwiseORNPEvalBadInputs() external {
        checkBadInputs("_: bitwise-and();", 0, 2, 0);
        checkBadInputs("_: bitwise-and(0);", 1, 2, 1);
        checkBadInputs("_: bitwise-and(0 0 0);", 3, 2, 3);
    }

    /// Test that operand is disallowed.
    function testOpBitwiseORNPEvalBadOperand() external {
        checkUnhappyParse("_: bitwise-and<0>(0 0);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
