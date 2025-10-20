// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibOpMaxUint256} from "src/lib/op/math/uint256/LibOpMaxUint256.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {
    OperandV2,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState, LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpMaxUint256Test
/// @notice Test the runtime and integrity time logic of LibOpMaxUint256.
contract LibOpMaxUint256Test is OpTest {
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpMaxUint256.
    function testOpMaxUint256Integrity(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpMaxUint256.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpMaxUint256. This tests that the
    /// opcode correctly pushes the max uint256 onto the stack.
    function testOpMaxUint256Run() external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        StackItem[] memory inputs = new StackItem[](0);
        OperandV2 operand = LibOperand.build(0, 1, 0);
        opReferenceCheck(
            state, operand, LibOpMaxUint256.referenceFn, LibOpMaxUint256.integrity, LibOpMaxUint256.run, inputs
        );
    }

    /// Test the eval of LibOpMaxUint256 parsed from a string.
    function testOpMaxUint256Eval() external view {
        checkHappy("_: uint256-max-value();", bytes32(type(uint256).max), "");
    }

    /// Test that a max-value with inputs fails integrity check.
    function testOpMaxUint256EvalFail() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        bytes memory bytecode = I_DEPLOYER.parse2("_: uint256-max-value(0x00);");
        (bytecode);
    }

    function testOpMaxUint256ZeroOutputs() external {
        checkBadOutputs(": uint256-max-value();", 0, 1, 0);
    }

    function testOpMaxUint256TwoOutputs() external {
        checkBadOutputs("_ _: uint256-max-value();", 0, 1, 2);
    }
}
