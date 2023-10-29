// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";

import {RainterpreterExpressionDeployerNPDeploymentTest} from
    "test/util/abstract/deprecated/RainterpreterExpressionDeployerNPDeploymentTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {
    LibIntegrityCheck,
    IntegrityCheckState,
    INITIAL_STACK_HIGHWATER
} from "src/lib/integrity/deprecated/LibIntegrityCheck.sol";
import {LibInterpreterState, InterpreterState} from "src/lib/state/deprecated/LibInterpreterState.sol";
import {LibOpStack, BadStackRead} from "src/lib/op/00/deprecated/LibOpStack.sol";
import {Operand, IInterpreterV1, SourceIndex} from "src/interface/IInterpreterV1.sol";
import {IInterpreterStoreV1, StateNamespace, FullyQualifiedNamespace} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";

/// @title LibOpStackTest
/// @notice Test the runtime and integrity time logic of LibOpStack.
contract LibOpStackTest is RainterpreterExpressionDeployerNPDeploymentTest {
    using LibPointer for Pointer;
    using LibUint256Array for uint256[];
    using LibIntegrityCheck for IntegrityCheckState;

    /// Directly test the integrity logic of LibOpStack. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the stack.
    function testOpStackIntegrity(Operand operand, uint8 stackHeight) external {
        vm.assume(stackHeight > 0);
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpStack.integrity;

        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, stackHeight - 1));

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackBottomBefore = state.stackBottom;
        Pointer stackTop = state.stackBottom.unsafeAddWords(stackHeight);
        state.syncStackMaxTop(stackTop);

        Pointer stackTopAfter = LibOpStack.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackBottomBefore));
        // Stack highwater needs to move PAST the operand index.
        assertEq(
            Pointer.unwrap(state.stackHighwater),
            Pointer.unwrap(INITIAL_STACK_HIGHWATER.unsafeAddWords(Operand.unwrap(operand)).unsafeAddWord())
        );
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the integrity logic of LibOpStack. This tests the case
    /// where the operand points past the end of the stack, which MUST always
    /// error as an OOB read.
    function testOpStackIntegrityOOBStack(Operand operand, uint8 stackHeight) external {
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpStack.integrity;

        // Bound the operand at or past the stack.
        // Give it uint128 only so it doesn't overflow. Normal code will never
        // have an operand this large.
        operand = Operand.wrap(bound(Operand.unwrap(operand), stackHeight, type(uint128).max));

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackTop = state.stackBottom.unsafeAddWords(stackHeight);
        state.syncStackMaxTop(stackTop);

        vm.expectRevert(abi.encodeWithSelector(BadStackRead.selector, stackHeight, Operand.unwrap(operand)));
        LibOpStack.integrity(state, operand, stackTop);
    }

    /// Directly test the runtime logic of LibOpStack. This tests that the
    /// operand always puts a single value on the stack. This tests the happy
    /// path where the operand points to a value in the stack.
    ///
    /// We rely on the integrity logic to ensure that the operand is in bounds.
    function testOpStackRun(Operand operand, uint256[] memory stack, uint8 stackHeight) external {
        vm.assume(stack.length > 0);

        stackHeight = uint8(bound(stackHeight, 1, stack.length));
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, stackHeight - 1));

        InterpreterState memory state = InterpreterState(
            stack.dataPointer(),
            new uint256[](0).dataPointer(),
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            iStore,
            new uint256[][](0),
            new bytes[](0)
        );
        Pointer stackBottomBefore = state.stackBottom;
        Pointer stackTop = state.stackBottom.unsafeAddWords(stackHeight);
        Pointer stackTopAfter = LibOpStack.run(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackBottomBefore));

        // Check the stack value was copied correctly.
        assertEq(stackTop.unsafeReadWord(), stack[Operand.unwrap(operand)]);
    }

    /// Test the eval of a stack opcode parsed from a string.
    function testOpStackEval() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("foo: 1, bar: foo;");
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
            hex"01000000"
            // stack 0
            hex"00000000"
        );

        assertEq(constants.length, 1);
        assertEq(constants[0], 1);

        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 2);
        assertEq(stack[0], 1);
        assertEq(stack[1], 1);
        assertEq(kvs.length, 0);
    }
}
