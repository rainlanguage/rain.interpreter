// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";

import {IInterpreterV2, Operand, SourceIndexV2} from "src/interface/unstable/IInterpreterV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {OutOfBoundsStackRead, LibOpStackNP} from "src/lib/op/00/LibOpStackNP.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterStoreV1, FullyQualifiedNamespace} from "src/interface/IInterpreterStoreV1.sol";
import {OpTest, PRE, POST} from "test/abstract/OpTest.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {BadOpOutputsLength} from "src/error/ErrIntegrity.sol";

/// @title LibOpStackNPTest
/// @notice Test the runtime and integrity time logic of LibOpStackNP.
contract LibOpStackNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpStackNP. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the stack.
    function testOpStackNPIntegrity(
        bytes memory bytecode,
        uint256 stackIndex,
        uint256[] memory constants,
        Operand operand
    ) external {
        stackIndex = bound(stackIndex, 1, type(uint256).max);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, stackIndex - 1));
        IntegrityCheckStateNP memory state = LibIntegrityCheckNP.newState(bytecode, stackIndex, constants);

        (uint256 inputs, uint256 outputs) = LibOpStackNP.integrity(state, operand);

        assertEq(inputs, 0);
        assertEq(outputs, 1);
    }

    /// Directly test the integrity logic of LibOpStackNP. This tests the case
    /// where the operand points past the end of the stack, which MUST always
    /// error as an OOB read.
    function testOpStackNPIntegrityOOBStack(
        bytes memory bytecode,
        uint16 stackIndex,
        uint256[] memory constants,
        uint16 readIndex,
        uint256 opIndex
    ) external {
        stackIndex = uint16(bound(stackIndex, 0, uint256(type(uint16).max)));
        readIndex = uint16(bound(readIndex, stackIndex, uint256(type(uint16).max)));
        Operand operand = LibOperand.build(0, 1, readIndex);
        IntegrityCheckStateNP memory state = LibIntegrityCheckNP.newState(bytecode, stackIndex, constants);
        state.opIndex = opIndex;

        vm.expectRevert(abi.encodeWithSelector(OutOfBoundsStackRead.selector, state.opIndex, stackIndex, readIndex));
        LibOpStackNP.integrity(state, operand);
    }

    /// Directly test the runtime logic of LibOpStackNP. This tests that the
    /// operand always puts a single value on the stack.
    function testOpStackNPRun(uint256[][] memory stacks, uint256 stackIndex) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256 stackValue;
        {
            vm.assume(stacks.length > 0);
            state.stackBottoms = LibInterpreterStateNP.stackBottoms(stacks);
            state.sourceIndex = bound(state.sourceIndex, 0, stacks.length - 1);
            uint256[] memory stack = stacks[state.sourceIndex];
            vm.assume(stack.length > 0);
            stackIndex = bound(stackIndex, 0, stack.length - 1);
            stackValue = stack[stack.length - (stackIndex + 1)];
        }

        Pointer stackBottom;
        Pointer stackTop;
        Pointer expectedStackTopAfter;
        Pointer end;
        {
            uint256 pre = PRE;
            uint256 post = POST;
            assembly ("memory-safe") {
                end := mload(0x40)
                mstore(end, post)
                expectedStackTopAfter := add(end, 0x20)
                mstore(expectedStackTopAfter, 0)
                stackTop := add(expectedStackTopAfter, 0x20)
                mstore(stackTop, pre)
                stackBottom := add(stackTop, 0x20)
                mstore(0x40, stackBottom)
            }
        }

        // Stack doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpStackNP.run(state, Operand.wrap(stackIndex), stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore, "state");

        // The stack value should be on the stack without modifying any other data.
        uint256 actualPost;
        uint256 actualStackValue;
        uint256 actualPre;
        assembly ("memory-safe") {
            actualPost := mload(end)
            actualStackValue := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, POST, "post");
        assertEq(actualStackValue, stackValue, "stackValue");
        assertEq(actualPre, PRE, "pre");
    }

    /// Test the eval of a stack opcode parsed from a string.
    function testOpStackEval() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("foo: 1, bar: foo;");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 sourceInputs, uint256 sourceOutputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(sourceInputs, 0);
        assertEq(sourceOutputs, 2);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 2 ops
            hex"02"
            // 2 stack allocation
            hex"02"
            // 0 inputs
            hex"00"
            // 2 outputs
            hex"02"
            // constant 0
            hex"01100000"
            // stack 0
            hex"00100000"
        );

        assertEq(constants.length, 1);
        assertEq(constants[0], 1);

        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 2);
        assertEq(stack[0], 1);
        assertEq(stack[1], 1);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of several stack opcodes parsed from a string.
    function testOpStackEvalSeveral() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("foo: 1, bar: foo, _ baz: bar bar, bing _:foo baz;");
        assertEq(constants.length, 1);
        assertEq(constants[0], 1);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 6 ops
            hex"06"
            // 6 stack allocation
            hex"06"
            // 0 inputs
            hex"00"
            // 6 outputs
            hex"06"
            // constant 0 (1)
            hex"01100000"
            // stack 0 (foo)
            hex"00100000"
            // stack 1 (bar)
            hex"00100001"
            // stack 1 (bar)
            hex"00100001"
            // stack 0 (foo)
            hex"00100000"
            // stack 3 (baz)
            hex"00100003"
        );

        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 6),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 6);
        assertEq(stack[0], 1);
        assertEq(stack[1], 1);
        assertEq(stack[2], 1);
        assertEq(stack[3], 1);
        assertEq(stack[4], 1);
        assertEq(stack[5], 1);
        assertEq(kvs.length, 0);
    }

    /// It is an error to have multiple outputs for a stack item.
    function testOpStackNPMultipleOutputErrorSugared() external {
        checkUnhappyDeploy("foo: 1, _ _: foo;", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 2));
    }

    /// It is an error to have multiple outputs for a stack item.
    function testOpStackNPMultipleOutputErrorUnsugared() external {
        checkUnhappyDeploy("foo: 1, _ _: stack<0>();", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 2));
    }

    /// It is an error to have zero outputs for a stack item.
    function testOpStackNPZeroOutputErrorSugared() external {
        checkUnhappyDeploy("foo: 1,: foo;", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 0));
    }

    /// It is an error to have zero outputs for a stack item.
    function testOpStackNPZeroOutputErrorUnsugared() external {
        checkUnhappyDeploy("foo: 1,: stack<0>();", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 0));
    }
}
