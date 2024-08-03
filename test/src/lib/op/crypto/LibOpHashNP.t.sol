// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";

import {LibOpHashNP} from "src/lib/op/crypto/LibOpHashNP.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {IInterpreterV2, Operand, SourceIndexV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {
    IInterpreterStoreV2, FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP, LibInterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpHashNPTest
/// @notice Test the runtime and integrity time logic of LibOpHashNP.
contract LibOpHashNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;
    using LibPointer for Pointer;
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpHashNP. This tests the happy
    /// path where the operand is valid.
    function testOpHashNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        Operand operand = LibOperand.build(inputs, outputs, operandData);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpHashNP.integrity(state, operand);

        assertEq(inputs, calcInputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpHashNP.
    function testOpHashNPRun(uint256[] memory inputs) external {
        vm.assume(inputs.length <= 0x0F);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(state, operand, LibOpHashNP.referenceFn, LibOpHashNP.integrity, LibOpHashNP.run, inputs);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 0 inputs.
    function testOpHashNPEval0Inputs() external {
        bytes memory bytecode = iDeployer.parse2("_: hash();");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], uint256(keccak256("")), "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 1 input.
    function testOpHashNPEval1Input() external {
        bytes memory bytecode = iDeployer.parse2("_: hash(0x1234567890abcdef);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef)))));
        assertEq(kvs.length, 0);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are identical to each other.
    function testOpHashNPEval2Inputs() external {
        bytes memory bytecode = iDeployer.parse2("_: hash(0x1234567890abcdef 0x1234567890abcdef);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(
            stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0x1234567890abcdef))))
        );
        assertEq(kvs.length, 0);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are different from each other.
    function testOpHashNPEval2InputsDifferent() external {
        bytes memory bytecode = iDeployer.parse2("_: hash(0x1234567890abcdef 0xfedcba0987654321);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(
            stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(kvs.length, 0);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs and
    /// other stack items.
    function testOpHashNPEval2InputsOtherStack() external {
        bytes memory bytecode = iDeployer.parse2("_ _ _: 5 hash(0x1234567890abcdef 0xfedcba0987654321) 9;");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 3);
        assertEq(stack[0], uint256(9e18));
        assertEq(
            stack[1], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(stack[2], uint256(5e18));
        assertEq(kvs.length, 0);
    }

    function testOpHashNPZeroOutputs() external {
        checkBadOutputs(":hash();", 0, 1, 0);
    }

    function testOpHashNPTwoOutputs() external {
        checkBadOutputs("_ _: hash();", 0, 1, 2);
    }
}
