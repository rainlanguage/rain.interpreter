// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {
    IInterpreterV2,
    FullyQualifiedNamespace,
    Operand,
    SourceIndexV2
} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {OpTest} from "test/abstract/OpTest.sol";
import {BytecodeTest} from "rain.interpreter.interface/../test/abstract/BytecodeTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpCallNP, CallOutputsExceedSource} from "src/lib/op/call/LibOpCallNP.sol";
import {LibBytecode, SourceIndexOutOfBounds} from "rain.interpreter.interface/lib/bytecode/LibBytecode.sol";
import {BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {STACK_TRACER} from "src/lib/state/LibInterpreterStateNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpCallNPTest
/// @notice Test the LibOpCallNP library that includes the "call" word.
contract LibOpCallNPTest is OpTest, BytecodeTest {
    /// Directly test the integrity logic of LibOpCallNP. This tests that if the
    /// outputs in the operand exceed the outputs available from the source, then
    /// the call will revert.
    function testOpCallNPIntegrityTooManyOutputs(
        IntegrityCheckStateNP memory state,
        uint256 inputs,
        uint256 outputs,
        uint8 sourceCount,
        bytes32 seed
    ) external {
        inputs = bound(inputs, 0, 0x0F);

        conformBytecode(state.bytecode, sourceCount, seed);

        uint256 sourcePosition = randomSourcePosition(state.bytecode, seed);
        uint256 sourceOutputs = uint8(state.bytecode[sourcePosition + 3]);
        vm.assume(sourceOutputs < 0x0F);
        outputs = bound(outputs, sourceOutputs + 1, 0x0F);

        uint256 sourceIndex = randomSourceIndex(state.bytecode, seed);
        assertTrue(sourceIndex <= type(uint16).max);

        Operand operand = LibOperand.build(uint8(inputs), uint8(outputs), uint16(sourceIndex));
        vm.expectRevert(abi.encodeWithSelector(CallOutputsExceedSource.selector, sourceOutputs, outputs));
        LibOpCallNP.integrity(state, operand);
    }

    /// Directly test the integrity logic of LibOpCallNP. This tests that if the
    /// source index in the operand is outside the source count of the bytecode,
    /// this will revert as `SourceIndexOutOfBounds`.
    function testOpCallNPIntegritySourceIndexOutOfBounds(
        IntegrityCheckStateNP memory state,
        uint256 inputs,
        uint256 outputs,
        uint256 sourceCount,
        uint256 sourceIndex,
        bytes32 seed
    ) external {
        inputs = bound(inputs, 0, 0x0F);
        outputs = bound(outputs, 0, 0x0F);

        conformBytecode(state.bytecode, sourceCount, seed);
        sourceCount = LibBytecode.sourceCount(state.bytecode);

        sourceIndex = bound(sourceIndex, sourceCount, type(uint16).max);

        Operand operand = LibOperand.build(uint8(inputs), uint8(outputs), uint16(sourceIndex));
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, state.bytecode, sourceIndex));
        LibOpCallNP.integrity(state, operand);
    }

    /// Directly test the integrity logic of LibOpCallNP. This tests that if the
    /// outputs in the operand are within the bounds set by the source, then the
    /// inputs is always specified by the source (callee), and the outputs are
    /// always specified by the operand (caller).
    function testOpCallNPIntegrityIO(
        IntegrityCheckStateNP memory state,
        uint256 inputs,
        uint256 outputs,
        uint8 sourceCount,
        bytes32 seed
    ) external {
        inputs = bound(inputs, 0, 0x0F);

        conformBytecode(state.bytecode, sourceCount, seed);

        uint256 sourcePosition = randomSourcePosition(state.bytecode, seed);
        uint256 sourceOutputs = uint8(state.bytecode[sourcePosition + 3]);
        outputs = bound(outputs, 0, sourceOutputs > 0x0F ? 0x0F : sourceOutputs);

        uint256 sourceIndex = randomSourceIndex(state.bytecode, seed);
        assertTrue(sourceIndex <= type(uint8).max);

        Operand operand = LibOperand.build(uint8(inputs), uint8(outputs), uint16(sourceIndex));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpCallNP.integrity(state, operand);
        uint256 sourceInputs = uint8(state.bytecode[sourcePosition + 2]);
        assertEq(calcInputs, sourceInputs, "inputs");
        assertEq(calcOutputs, outputs, "outputs");
    }

    /// Boilerplate for testing that a source does not exist.
    function checkSourceDoesNotExist(bytes memory rainlang, uint256 sourceIndex) internal {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainlang);
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, bytecode, sourceIndex));
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (interpreterDeployer, storeDeployer, expression, io);
    }

    /// Test that the eval of a call into a source that doesn't exist reverts
    /// upon deploy.
    function testOpCallNPRunSourceDoesNotExist() external {
        // 0 inputs and outputs different source indexes.
        checkSourceDoesNotExist(": call<1>();", 1);
        checkSourceDoesNotExist(": call<2>();", 2);
        // 1 input and 0 outputs different source indexes.
        checkSourceDoesNotExist(": call<1>(1);", 1);
        checkSourceDoesNotExist(": call<2>(1);", 2);
        // 0 inputs and 1 output different source indexes.
        checkSourceDoesNotExist("_: call<1>();", 1);
        checkSourceDoesNotExist("_: call<2>();", 2);
        // Several inputs and outputs different source indexes.
        checkSourceDoesNotExist("a b: call<1>(10 5);", 1);
        checkSourceDoesNotExist("a b: call<2>(10 5);", 2);
        // Multiple sources.
        checkSourceDoesNotExist(": call<2>();:;", 2);
        checkSourceDoesNotExist(": call<3>();:;", 3);
    }

    struct ExpectedTrace {
        uint256 parentSourceIndex;
        uint256 sourceIndex;
        uint256[] stack;
    }

    function checkCallNPTraces(bytes memory rainlang, ExpectedTrace[] memory traces) internal {
        for (uint256 i = 0; i < traces.length; ++i) {
            vm.expectCall(
                STACK_TRACER,
                abi.encodePacked(
                    bytes2(uint16(traces[i].parentSourceIndex)), bytes2(uint16(traces[i].sourceIndex)), traces[i].stack
                ),
                1
            );
        }
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainlang);
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), type(uint8).max),
            new uint256[][](0),
            new uint256[](0)
        );
        (stack, kvs);
    }

    function testCallTraceOuterOnly() external {
        ExpectedTrace[] memory traces = new ExpectedTrace[](1);
        traces[0].sourceIndex = 0;
        traces[0].stack = new uint256[](1);
        traces[0].stack[0] = 1e18;
        checkCallNPTraces("_: 1;", traces);
    }

    function testCallTraceInnerOnly() external {
        ExpectedTrace[] memory traces = new ExpectedTrace[](2);
        traces[0].sourceIndex = 0;
        traces[0].stack = new uint256[](0);
        traces[1].sourceIndex = 1;
        traces[1].stack = new uint256[](1);
        traces[1].stack[0] = 1e18;
        checkCallNPTraces(":call<1>();_:1;", traces);
    }

    function testCallTraceOuterAndInner() external {
        ExpectedTrace[] memory traces = new ExpectedTrace[](2);
        traces[0].sourceIndex = 0;
        traces[0].stack = new uint256[](1);
        traces[0].stack[0] = 2e18;
        traces[1].sourceIndex = 1;
        traces[1].stack = new uint256[](1);
        traces[1].stack[0] = 1e18;
        checkCallNPTraces("_:int-add(call<1>() 1);_:1;", traces);
    }

    function testCallTraceOuterAndTwoInner() external {
        ExpectedTrace[] memory traces = new ExpectedTrace[](3);
        traces[0].sourceIndex = 0;
        traces[0].stack = new uint256[](1);
        traces[0].stack[0] = 12e18;
        traces[1].parentSourceIndex = 0;
        traces[1].sourceIndex = 1;
        traces[1].stack = new uint256[](2);
        traces[1].stack[1] = 2e18;
        traces[1].stack[0] = 11e18;
        traces[2].parentSourceIndex = 1;
        traces[2].sourceIndex = 2;
        traces[2].stack = new uint256[](1);
        traces[2].stack[0] = 10e18;
        checkCallNPTraces("_:int-add(call<1>(2) 1);two:,_:int-add(call<2>() 1);_:10;", traces);
    }

    /// Boilerplate for checking the stack and kvs of a call.
    function checkCallNPRun(bytes memory rainlang, uint256[] memory stack, uint256[] memory kvs) internal {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainlang);
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        (uint256[] memory actualStack, uint256[] memory actualKVs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), type(uint8).max),
            new uint256[][](0),
            new uint256[](0)
        );
        assertEq(actualStack.length, stack.length, "stack length");
        for (uint256 i = 0; i < stack.length; i++) {
            assertEq(actualStack[i], stack[i], "stack[i]");
        }
        assertEq(actualKVs.length, kvs.length, "kvs length");
        for (uint256 i = 0; i < kvs.length; i++) {
            assertEq(actualKVs[i], kvs[i], "kvs[i]");
        }
    }

    /// Test the eval of call to see various stacks.
    function testOpCallNPRunNoIO() external {
        // Check evals that result in no stack or kvs.
        uint256[] memory stack = new uint256[](0);
        uint256[] memory kvs = new uint256[](0);
        // 0 IO, call noop.
        checkCallNPRun(":call<1>();:;", stack, kvs);
        // Single input and no outputs.
        checkCallNPRun(":call<1>(10);ten:;", stack, kvs);

        // Check evals that result in a stack of one item but no kvs.
        stack = new uint256[](1);
        // Single input and single output.
        stack[0] = 10e18;
        checkCallNPRun("ten:call<1>(10);ten:;", stack, kvs);
        // zero input single output.
        checkCallNPRun("ten:call<1>();ten:10;", stack, kvs);
        // Two inputs and one output.
        stack[0] = 12e18;
        checkCallNPRun("a: call<1>(10 11); ten eleven:,a b c:ten eleven 12;", stack, kvs);

        // Check evals that result in a stack of two items but no kvs.
        stack = new uint256[](2);
        // Order dependent inputs and outputs.
        stack[0] = 9e18;
        stack[1] = 2e18;
        checkCallNPRun("a b: call<1>(10 5); ten five:, a b: decimal18-div(ten five) 9;", stack, kvs);

        // One input two outputs.
        stack[0] = 11e18;
        stack[1] = 10e18;
        checkCallNPRun("a b: call<1>(10); ten:,a b:ten 11;", stack, kvs);

        // Can call something with no IO purely for the kv side effects.
        stack = new uint256[](0);
        kvs = new uint256[](2);
        kvs[0] = 10e18;
        kvs[1] = 11e18;
        checkCallNPRun(":call<1>();:set(10 11);", stack, kvs);

        // Can call for side effects and also get a stack based on IO.
        stack = new uint256[](1);
        stack[0] = 10e18;
        checkCallNPRun("a:call<1>(9);nine:,:set(10 11),ret:decimal18-add(nine 1);", stack, kvs);

        // Can call a few different things without a final stack.
        stack = new uint256[](0);
        kvs = new uint256[](0);
        checkCallNPRun(":call<1>();one two three: 1 2 3, :call<2>();five six: 5 6;", stack, kvs);
    }

    /// Boilerplate to check a generic runtime error happens upon recursion.
    function checkCallNPRunRecursive(bytes memory rainlang) internal {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse(rainlang);
        // Recursion isn't caught at deploy time.
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        // But it will unconditionally happen at runtime.
        vm.expectRevert();
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), type(uint8).max),
            new uint256[][](0),
            new uint256[](0)
        );
        (stack, kvs);
    }

    /// Test that recursive calls are a (very gas intensive) runtime error.
    function testOpCallNPRunRecursive() external {
        // Simple call self.
        checkCallNPRunRecursive(":call<0>();");
        // Ping pong between two calls.
        checkCallNPRunRecursive(":call<1>();:call<0>();");
        // If is eager so doesn't help.
        checkCallNPRunRecursive("a:call<1>(1);do-call:,a:if(do-call call<1>(0) 5);");
    }

    /// Test a mismatch in the inputs from caller and callee.
    function testOpCallNPRunInputsMismatch() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("a: call<1>(10 11); ten:,a b c:ten 11 12;");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 1, 2));
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (interpreterDeployer, storeDeployer, expression, io);
    }

    /// Test a mismatch in the outputs from caller and callee.
    function testOpCallNPRunOutputsMismatch() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("ten eleven a b: call<1>(10 11); ten eleven:,a:9;");
        vm.expectRevert(abi.encodeWithSelector(CallOutputsExceedSource.selector, 3, 4));
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (interpreterDeployer, storeDeployer, expression, io);
    }
}
