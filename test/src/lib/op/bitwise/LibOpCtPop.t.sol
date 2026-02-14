// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {LibOpCtPop} from "src/lib/op/bitwise/LibOpCtPop.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {LibCtPop} from "rain.math.binary/lib/LibCtPop.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract LibOpCtPopTest is OpTest {
    /// Directly test the integrity logic of LibOpCtPop. All possible operands
    /// result in the same number of inputs and outputs, (1, 1).
    function testOpCtPopIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpCtPop.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpCtPop. This tests that the
    /// opcode correctly pushes the ct pop onto the stack.
    function testOpCtPopRun(StackItem x) external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] = x;
        OperandV2 operand = LibOperand.build(1, 1, 0);
        opReferenceCheck(state, operand, LibOpCtPop.referenceFn, LibOpCtPop.integrity, LibOpCtPop.run, inputs);
    }

    /// Test the eval of a ct pop opcode parsed from a string.
    function testOpCtPopEval(StackItem x) external view {
        StackItem[] memory stack = new StackItem[](1);
        stack[0] = StackItem.wrap(bytes32(LibCtPop.ctpop(uint256(StackItem.unwrap(x)))));
        checkHappy(
            bytes(string.concat("_: bitwise-count-ones(", Strings.toHexString(uint256(StackItem.unwrap(x))), ");")),
            stack,
            ""
        );
    }

    /// Test that a bitwise count with bad inputs fails integrity.
    function testOpCtPopZeroInputs() external {
        checkBadInputs("_: bitwise-count-ones();", 0, 1, 0);
    }

    function testOpCtPopTwoInputs() external {
        checkBadInputs("_: bitwise-count-ones(0 0);", 2, 1, 2);
    }

    function testOpCtPopZeroOutputs() external {
        checkBadOutputs(": bitwise-count-ones(0);", 1, 1, 0);
    }

    function testOpCtPopTwoOutputs() external {
        checkBadOutputs("_ _: bitwise-count-ones(0);", 1, 1, 2);
    }
}
