// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibOpMinPositiveValue} from "src/lib/op/math/LibOpMinPositiveValue.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {
    IInterpreterV4,
    OperandV2,
    SourceIndexV2,
    FullyQualifiedNamespace,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState, LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpMinPositiveValueTest
/// @notice Test the runtime and integrity time logic of LibOpMinPositiveValue.
contract LibOpMinPositiveValueTest is OpTest {
    using LibInterpreterState for InterpreterState;
    using LibDecimalFloat for Float;

    /// Directly test the integrity logic of LibOpMinPositiveValue.
    function testOpMinPositiveValueIntegrity(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpMinPositiveValue.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpMinPositiveValue. This tests that
    /// the opcode correctly pushes the min positive value onto the stack.
    function testOpMinPositiveValueRun() external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        StackItem[] memory inputs = new StackItem[](0);
        OperandV2 operand = LibOperand.build(0, 1, 0);
        opReferenceCheck(
            state,
            operand,
            LibOpMinPositiveValue.referenceFn,
            LibOpMinPositiveValue.integrity,
            LibOpMinPositiveValue.run,
            inputs
        );
    }

    /// Test the eval of LibOpMinPositiveValue parsed from a string.
    function testOpMinPositiveValueEval() external view {
        checkHappy("_: min-positive-value();", Float.unwrap(LibDecimalFloat.FLOAT_MIN_POSITIVE_VALUE), "");
    }

    /// Test that a min-positive-value with inputs fails integrity check.
    function testOpMinPositiveValueEvalFail() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        bytes memory bytecode = iDeployer.parse2("_: min-positive-value(0x00);");
        (bytecode);
    }

    function testOpMinPositiveValueZeroOutputs() external {
        checkBadOutputs(": min-positive-value();", 0, 1, 0);
    }

    function testOpMinPositiveValueTwoOutputs() external {
        checkBadOutputs("_ _: min-positive-value();", 0, 1, 2);
    }
}
