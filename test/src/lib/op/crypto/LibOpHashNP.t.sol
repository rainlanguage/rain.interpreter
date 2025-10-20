// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";

import {LibOpHashNP} from "src/lib/op/crypto/LibOpHashNP.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {
    OperandV2,
    SourceIndexV2,
    EvalV4,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {InterpreterState, LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpHashNPTest
/// @notice Test the runtime and integrity time logic of LibOpHashNP.
contract LibOpHashNPTest is OpTest {
    using LibInterpreterState for InterpreterState;
    using LibPointer for Pointer;
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpHashNP. This tests the happy
    /// path where the operand is valid.
    function testOpHashNPIntegrityHappy(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        OperandV2 operand = LibOperand.build(inputs, outputs, operandData);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpHashNP.integrity(state, operand);

        assertEq(inputs, calcInputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpHashNP.
    function testOpHashNPRun(StackItem[] memory inputs) external view {
        vm.assume(inputs.length <= 0x0F);
        InterpreterState memory state = opTestDefaultInterpreterState();
        OperandV2 operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(state, operand, LibOpHashNP.referenceFn, LibOpHashNP.integrity, LibOpHashNP.run, inputs);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 0 inputs.
    function testOpHashNPEval0Inputs() external view {
        checkHappy("_: hash();", keccak256(""), "");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 1 input.
    function testOpHashNPEval1Input() external view {
        checkHappy("_: hash(0x1234567890abcdef);", keccak256(abi.encodePacked(uint256(0x1234567890abcdef))), "");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are identical to each other.
    function testOpHashNPEval2Inputs() external view {
        checkHappy(
            "_: hash(0x1234567890abcdef 0x1234567890abcdef);",
            keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0x1234567890abcdef))),
            ""
        );
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are different from each other.
    function testOpHashNPEval2InputsDifferent() external view {
        checkHappy(
            "_: hash(0x1234567890abcdef 0xfedcba0987654321);",
            keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))),
            ""
        );
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs and
    /// other stack items.
    function testOpHashNPEval2InputsOtherStack() external view {
        bytes memory bytecode = I_DEPLOYER.parse2("_ _ _: 5 hash(0x1234567890abcdef 0xfedcba0987654321) 9;");
        (StackItem[] memory stack, bytes32[] memory kvs) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: LibContext.build(new bytes32[][](0), new SignedContextV1[](0)),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
        assertEq(stack.length, 3);
        assertEq(StackItem.unwrap(stack[0]), Float.unwrap(LibDecimalFloat.packLossless(9, 0)));
        assertEq(
            StackItem.unwrap(stack[1]),
            keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321)))
        );
        assertEq(StackItem.unwrap(stack[2]), Float.unwrap(LibDecimalFloat.packLossless(5, 0)));
        assertEq(kvs.length, 0);
    }

    function testOpHashNPZeroOutputs() external {
        checkBadOutputs(":hash();", 0, 1, 0);
    }

    function testOpHashNPTwoOutputs() external {
        checkBadOutputs("_ _: hash();", 0, 1, 2);
    }
}
