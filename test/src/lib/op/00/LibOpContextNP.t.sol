// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {stdError} from "forge-std/Test.sol";

import {LibOpContextNP} from "src/lib/op/00/LibOpContextNP.sol";
import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpContextNPTest
/// @notice Test the LibOpContextNP library that includes the "context" word.
contract LibOpContextNPTest is OpTest {
    /// Directly test the integrity logic of LibOpContextNP. All operands are
    /// valid, so the integrity check should always pass. The inputs and
    /// outputs are always 0 and 1 respectively.
    function testOpContextNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpContextNP.integrity(state, operand);

        assertEq(calcInputs, 0, "inputs");
        assertEq(calcOutputs, 1, "outputs");
    }

    /// Directly test the runtime logic of LibOpContextNP. This tests that the
    /// values in the context matrix can be pushed to the stack via. the operand.
    function testOpContextNPRun(uint256[][] memory context, uint256 i, uint256 j) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        state.context = context;
        vm.assume(state.context.length > 0);
        vm.assume(state.context.length < type(uint8).max);
        i = bound(i, 0, state.context.length - 1);
        vm.assume(state.context[i].length > 0);
        vm.assume(state.context[i].length < type(uint8).max);
        j = bound(j, 0, state.context[i].length - 1);
        Operand operand = LibOperand.build(0, 1, uint16(uint256(i) | uint256(j) << 8));
        uint256[] memory inputs = new uint256[](0);
        opReferenceCheck(
            state, operand, LibOpContextNP.referenceFn, LibOpContextNP.integrity, LibOpContextNP.run, inputs
        );
    }

    /// Directly test the reference logic of LibOpContextNP. This tests that the
    /// runtime logic will revert if the indexes are OOB. Tests that i is OOB.
    function testOpContextNPRunOOBi(uint256[][] memory context, uint256 i, uint256 j) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        state.context = context;
        vm.assume(state.context.length < type(uint8).max);
        i = bound(i, state.context.length, type(uint8).max);
        j = bound(j, 0, type(uint8).max);
        Operand operand = LibOperand.build(0, 1, uint16(uint256(i) | uint256(j) << 8));
        uint256[] memory inputs = new uint256[](0);
        vm.expectRevert(stdError.indexOOBError);
        opReferenceCheck(
            state, operand, LibOpContextNP.referenceFn, LibOpContextNP.integrity, LibOpContextNP.run, inputs
        );
    }

    /// Directly test the reference logic of LibOpContextNP. This tests that the
    /// runtime logic will revert if the indexes are OOB. Tests that j is OOB.
    function testOpContextNPRunOOBj(uint256[][] memory context, uint256 i, uint256 j) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        state.context = context;
        vm.assume(state.context.length > 0);
        vm.assume(state.context.length < type(uint8).max);
        i = bound(i, 0, state.context.length - 1);
        vm.assume(state.context[i].length < type(uint8).max);
        j = bound(j, state.context[i].length, type(uint8).max);
        Operand operand = LibOperand.build(0, 1, uint16(uint256(i) | uint256(j) << 8));
        uint256[] memory inputs = new uint256[](0);
        vm.expectRevert(stdError.indexOOBError);
        opReferenceCheck(
            state, operand, LibOpContextNP.referenceFn, LibOpContextNP.integrity, LibOpContextNP.run, inputs
        );
    }

    /// Test the eval of context opcode parsed from a string. This tests 0 0.
    function testOpContextNPEval00(uint256[][] memory context) external {
        vm.assume(context.length > 0);
        vm.assume(context[0].length > 0);
        bytes memory bytecode = iDeployer.parse2("_: context<0 0>();");

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore, FullyQualifiedNamespace.wrap(0), bytecode, SourceIndexV2.wrap(0), context, new uint256[](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], context[0][0], "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of context opcode parsed from a string. This tests 0 1.
    function testOpContextNPEval01(uint256[][] memory context) external {
        vm.assume(context.length > 0);
        vm.assume(context[0].length > 1);
        bytes memory bytecode = iDeployer.parse2("_: context<0 1>();");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore, FullyQualifiedNamespace.wrap(0), bytecode, SourceIndexV2.wrap(0), context, new uint256[](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], context[0][1], "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of context opcode parsed from a string. This tests 1 0.
    function testOpContextNPEval10(uint256[][] memory context) external {
        vm.assume(context.length > 1);
        vm.assume(context[1].length > 0);
        bytes memory bytecode = iDeployer.parse2("_: context<1 0>();");

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore, FullyQualifiedNamespace.wrap(0), bytecode, SourceIndexV2.wrap(0), context, new uint256[](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], context[1][0], "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of context opcode parsed from a string. This tests 1 1.
    function testOpContextNPEval11(uint256[][] memory context) external {
        vm.assume(context.length > 1);
        vm.assume(context[1].length > 1);
        bytes memory bytecode = iDeployer.parse2("_: context<1 1>();");

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore, FullyQualifiedNamespace.wrap(0), bytecode, SourceIndexV2.wrap(0), context, new uint256[](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], context[1][1], "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of context opcode parsed from a string. This tests OOB i.
    function testOpContextNPEvalOOBi(uint256[] memory context0) external {
        uint256[][] memory context = new uint256[][](1);
        context[0] = context0;
        bytes memory bytecode = iDeployer.parse2("_: context<1 0>();");

        vm.expectRevert(stdError.indexOOBError);
        iInterpreter.eval3(
            iStore, FullyQualifiedNamespace.wrap(0), bytecode, SourceIndexV2.wrap(0), context, new uint256[](0)
        );
    }

    /// Test the eval of context opcode parsed from a string. This tests OOB j.
    function testOpContextNPEvalOOBj(uint256 v) external {
        uint256[][] memory context = new uint256[][](1);
        uint256[] memory context0 = new uint256[](1);
        context0[0] = v;
        bytes memory bytecode = iDeployer.parse2("_: context<0 1>();");

        vm.expectRevert(stdError.indexOOBError);
        iInterpreter.eval3(
            iStore, FullyQualifiedNamespace.wrap(0), bytecode, SourceIndexV2.wrap(0), context, new uint256[](0)
        );
    }

    function testOpContextNPOneInput() external {
        checkBadInputs("_: context<0 0>(0);", 1, 0, 1);
    }

    function testOpContextNPTwoInputs() external {
        checkBadInputs("_: context<0 0>(0 0);", 2, 0, 2);
    }

    function testOpContextNPZeroOutputs() external {
        checkBadOutputs(": context<0 0>();", 0, 1, 0);
    }

    function testOpContextNPTwoOutputs() external {
        checkBadOutputs("_ _: context<0 0>();", 0, 1, 2);
    }
}
