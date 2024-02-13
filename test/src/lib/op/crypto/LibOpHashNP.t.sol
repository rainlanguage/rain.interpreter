// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";

import {LibOpHashNP} from "src/lib/op/crypto/LibOpHashNP.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {IInterpreterV2, Operand, SourceIndexV2} from "src/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1, FullyQualifiedNamespace} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP, LibInterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";

/// @title LibOpHashNPTest
/// @notice Test the runtime and integrity time logic of LibOpHashNP.
contract LibOpHashNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;
    using LibPointer for Pointer;
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpHashNP. This tests the happy
    /// path where the operand is valid.
    function testOpHashNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        Operand operand = Operand.wrap(uint256(inputs) << 0x10);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpHashNP.integrity(state, operand);

        assertEq(inputs, calcInputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpHashNP.
    function testOpHashNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        opReferenceCheck(state, operand, LibOpHashNP.referenceFn, LibOpHashNP.integrity, LibOpHashNP.run, inputs);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 0 inputs.
    function testOpHashNPEval0Inputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: hash();");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], uint256(keccak256("")), "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
        assertEq(io, hex"0001", "io");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 1 input.
    function testOpHashNPEval1Input() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: hash(0x1234567890abcdef);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef)))));
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are identical to each other.
    function testOpHashNPEval2Inputs() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("_: hash(0x1234567890abcdef 0x1234567890abcdef);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(
            stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0x1234567890abcdef))))
        );
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are different from each other.
    function testOpHashNPEval2InputsDifferent() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("_: hash(0x1234567890abcdef 0xfedcba0987654321);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(
            stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs and
    /// other stack items.
    function testOpHashNPEval2InputsOtherStack() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("_ _ _: 5 hash(0x1234567890abcdef 0xfedcba0987654321) 9;");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 3),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 3);
        assertEq(stack[0], uint256(9));
        assertEq(
            stack[1], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(stack[2], uint256(5));
        assertEq(kvs.length, 0);
        assertEq(io, hex"0003");
    }
}
