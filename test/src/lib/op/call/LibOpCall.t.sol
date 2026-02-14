// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {
    FullyQualifiedNamespace,
    OperandV2,
    SourceIndexV2,
    EvalV4,
    StackItem
} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {OpTest} from "test/abstract/OpTest.sol";
import {BytecodeTest} from "rain.interpreter.interface/../test/abstract/BytecodeTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {LibOpCall, CallOutputsExceedSource} from "src/lib/op/call/LibOpCall.sol";
import {LibBytecode, SourceIndexOutOfBounds} from "rain.interpreter.interface/lib/bytecode/LibBytecode.sol";
import {BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {STACK_TRACER} from "src/lib/state/LibInterpreterState.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpCallTest
/// @notice Test the LibOpCall library that includes the "call" word.
contract LibOpCallTest is OpTest, BytecodeTest {
    function integrityExternal(IntegrityCheckState memory state, OperandV2 operand) external pure {
        LibOpCall.integrity(state, operand);
    }

    /// Directly test the integrity logic of LibOpCall. This tests that if the
    /// outputs in the operand exceed the outputs available from the source, then
    /// the call will revert.
    function testOpCallIntegrityTooManyOutputs(
        IntegrityCheckState memory state,
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

        // Bounds above ensure safe typecast.
        //forge-lint: disable-next-line(unsafe-typecast)
        OperandV2 operand = LibOperand.build(uint8(inputs), uint8(outputs), uint16(sourceIndex));
        vm.expectRevert(abi.encodeWithSelector(CallOutputsExceedSource.selector, sourceOutputs, outputs));
        this.integrityExternal(state, operand);
    }

    /// Directly test the integrity logic of LibOpCall. This tests that if the
    /// source index in the operand is outside the source count of the bytecode,
    /// this will revert as `SourceIndexOutOfBounds`.
    function testOpCallIntegritySourceIndexOutOfBounds(
        IntegrityCheckState memory state,
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

        // Bounds ensure typecast is safe.
        // forge-lint: disable-next-line(unsafe-typecast)
        OperandV2 operand = LibOperand.build(uint8(inputs), uint8(outputs), uint16(sourceIndex));
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, sourceIndex, state.bytecode));
        this.integrityExternal(state, operand);
    }

    /// Directly test the integrity logic of LibOpCall. This tests that if the
    /// outputs in the operand are within the bounds set by the source, then the
    /// inputs is always specified by the source (callee), and the outputs are
    /// always specified by the operand (caller).
    function testOpCallIntegrityIO(
        IntegrityCheckState memory state,
        uint256 inputs,
        uint256 outputs,
        uint8 sourceCount,
        bytes32 seed
    ) external pure {
        inputs = bound(inputs, 0, 0x0F);

        conformBytecode(state.bytecode, sourceCount, seed);

        uint256 sourcePosition = randomSourcePosition(state.bytecode, seed);
        uint256 sourceOutputs = uint8(state.bytecode[sourcePosition + 3]);
        outputs = bound(outputs, 0, sourceOutputs > 0x0F ? 0x0F : sourceOutputs);

        uint256 sourceIndex = randomSourceIndex(state.bytecode, seed);
        assertTrue(sourceIndex <= type(uint8).max);

        // Bounds ensure typecast is safe.
        // forge-lint: disable-next-line(unsafe-typecast)
        OperandV2 operand = LibOperand.build(uint8(inputs), uint8(outputs), uint16(sourceIndex));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpCall.integrity(state, operand);
        uint256 sourceInputs = uint8(state.bytecode[sourcePosition + 2]);
        assertEq(calcInputs, sourceInputs, "inputs");
        assertEq(calcOutputs, outputs, "outputs");
    }

    /// Boilerplate for testing that a source does not exist.
    function checkSourceDoesNotExist(bytes memory rainlang, uint256 sourceIndex, bytes memory bytecode) internal {
        checkUnhappyParse2(rainlang, abi.encodeWithSelector(SourceIndexOutOfBounds.selector, sourceIndex, bytecode));
    }

    /// Test that the eval of a call into a source that doesn't exist reverts
    /// upon deploy.
    function testOpCallRunSourceDoesNotExist() external {
        // 0 inputs and outputs different source indexes.
        checkSourceDoesNotExist(": call<1>();", 1, hex"010000010000000b000001");
        checkSourceDoesNotExist(": call<2>();", 2, hex"010000010000000b000002");
        // 1 input and 0 outputs different source indexes.
        checkSourceDoesNotExist(": call<1>(1);", 1, hex"01000002010000011000000b010001");
        checkSourceDoesNotExist(": call<2>(1);", 2, hex"01000002010000011000000b010002");
        // 0 inputs and 1 output different source indexes.
        checkSourceDoesNotExist("_: call<1>();", 1, hex"010000010100010b100001");
        checkSourceDoesNotExist("_: call<2>();", 2, hex"010000010100010b100002");
        // Several inputs and outputs different source indexes.
        checkSourceDoesNotExist("a b: call<1>(10 5);", 1, hex"0100000302000201100001011000000b220001");
        checkSourceDoesNotExist("a b: call<2>(10 5);", 2, hex"0100000302000201100001011000000b220002");
        // Multiple sources.
        checkSourceDoesNotExist(": call<2>();:;", 2, hex"0200000008010000000b00000200000000");
        checkSourceDoesNotExist(": call<3>();:;", 3, hex"0200000008010000000b00000300000000");
    }

    struct ExpectedTrace {
        uint256 parentSourceIndex;
        uint256 sourceIndex;
        StackItem[] stack;
    }

    function checkCallTraces(bytes memory rainlang, ExpectedTrace[] memory traces) internal {
        for (uint256 i = 0; i < traces.length; ++i) {
            vm.expectCall(
                STACK_TRACER,
                abi.encodePacked(
                    bytes2(uint16(traces[i].parentSourceIndex)), bytes2(uint16(traces[i].sourceIndex)), traces[i].stack
                ),
                1
            );
        }
        bytes memory bytecode = I_DEPLOYER.parse2(rainlang);
        (StackItem[] memory stack, bytes32[] memory kvs) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
        (stack, kvs);
    }

    function testCallTraceOuterOnly() external {
        ExpectedTrace[] memory traces = new ExpectedTrace[](1);
        traces[0].sourceIndex = 0;
        traces[0].stack = new StackItem[](1);
        traces[0].stack[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));
        checkCallTraces("_: 1;", traces);
    }

    function testCallTraceInnerOnly() external {
        ExpectedTrace[] memory traces = new ExpectedTrace[](2);
        traces[0].sourceIndex = 0;
        traces[0].stack = new StackItem[](0);
        traces[1].sourceIndex = 1;
        traces[1].stack = new StackItem[](1);
        traces[1].stack[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));
        checkCallTraces(":call<1>();_:1;", traces);
    }

    // function testCallTraceOuterAndInner() external {
    //     ExpectedTrace[] memory traces = new ExpectedTrace[](2);
    //     traces[0].sourceIndex = 0;
    //     traces[0].stack = new uint256[](1);
    //     traces[0].stack[0] = 2e18;
    //     traces[1].sourceIndex = 1;
    //     traces[1].stack = new uint256[](1);
    //     traces[1].stack[0] = 1e18;
    //     checkCallTraces("_:add(call<1>() 1);_:1;", traces);
    // }

    // function testCallTraceOuterAndTwoInner() external {
    //     ExpectedTrace[] memory traces = new ExpectedTrace[](3);
    //     traces[0].sourceIndex = 0;
    //     traces[0].stack = new uint256[](1);
    //     traces[0].stack[0] = 12e18;
    //     traces[1].parentSourceIndex = 0;
    //     traces[1].sourceIndex = 1;
    //     traces[1].stack = new uint256[](2);
    //     traces[1].stack[1] = 2e18;
    //     traces[1].stack[0] = 11e18;
    //     traces[2].parentSourceIndex = 1;
    //     traces[2].sourceIndex = 2;
    //     traces[2].stack = new uint256[](1);
    //     traces[2].stack[0] = 10e18;
    //     checkCallTraces("_:add(call<1>(2) 1);two:,_:add(call<2>() 1);_:10;", traces);
    // }

    /// Boilerplate for checking the stack and kvs of a call.
    function checkCallRun(bytes memory rainlang, StackItem[] memory stack, bytes32[] memory kvs) internal view {
        bytes memory bytecode = I_DEPLOYER.parse2(rainlang);
        (StackItem[] memory actualStack, bytes32[] memory actualKVs) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
        assertEq(actualStack.length, stack.length, "stack length");
        for (uint256 i = 0; i < stack.length; i++) {
            assertEq(StackItem.unwrap(actualStack[i]), StackItem.unwrap(stack[i]), "stack[i]");
        }
        assertEq(actualKVs.length, kvs.length, "kvs length");
        for (uint256 i = 0; i < kvs.length; i++) {
            assertEq(actualKVs[i], kvs[i], "kvs[i]");
        }
    }

    // /// Test the eval of call to see various stacks.
    // function testOpCallRunNoIO() external view {
    //     // Check evals that result in no stack or kvs.
    //     uint256[] memory stack = new uint256[](0);
    //     uint256[] memory kvs = new uint256[](0);
    //     // 0 IO, call noop.
    //     checkCallRun(":call<1>();:;", stack, kvs);
    //     // Single input and no outputs.
    //     checkCallRun(":call<1>(10);ten:;", stack, kvs);

    //     // Check evals that result in a stack of one item but no kvs.
    //     stack = new uint256[](1);
    //     // Single input and single output.
    //     stack[0] = 10e18;
    //     checkCallRun("ten:call<1>(10);ten:;", stack, kvs);
    //     // zero input single output.
    //     checkCallRun("ten:call<1>();ten:10;", stack, kvs);
    //     // Two inputs and one output.
    //     stack[0] = 12e18;
    //     checkCallRun("a: call<1>(10 11); ten eleven:,a b c:ten eleven 12;", stack, kvs);

    //     // Check evals that result in a stack of two items but no kvs.
    //     stack = new uint256[](2);
    //     // Order dependent inputs and outputs.
    //     stack[0] = 9e18;
    //     stack[1] = 2e18;
    //     checkCallRun("a b: call<1>(10 5); ten five:, a b: div(ten five) 9;", stack, kvs);

    //     // One input two outputs.
    //     stack[0] = 11e18;
    //     stack[1] = 10e18;
    //     checkCallRun("a b: call<1>(10); ten:,a b:ten 11;", stack, kvs);

    //     // Can call something with no IO purely for the kv side effects.
    //     stack = new uint256[](0);
    //     kvs = new uint256[](2);
    //     kvs[0] = 10e18;
    //     kvs[1] = 11e18;
    //     checkCallRun(":call<1>();:set(10 11);", stack, kvs);

    //     // Can call for side effects and also get a stack based on IO.
    //     stack = new uint256[](1);
    //     stack[0] = 10e18;
    //     checkCallRun("a:call<1>(9);nine:,:set(10 11),ret:add(nine 1);", stack, kvs);

    //     // Can call a few different things without a final stack.
    //     stack = new uint256[](0);
    //     kvs = new uint256[](0);
    //     checkCallRun(":call<1>();one two three: 1 2 3, :call<2>();five six: 5 6;", stack, kvs);
    // }

    /// Boilerplate to check a generic runtime error happens upon recursion.
    function checkCallRunRecursive(bytes memory rainlang) internal {
        bytes memory bytecode = I_DEPLOYER.parse2(rainlang);
        // But it will unconditionally happen at runtime.
        vm.expectRevert();
        (StackItem[] memory stack, bytes32[] memory kvs) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
        (stack, kvs);
    }

    // /// Test that recursive calls are a (very gas intensive) runtime error.
    // function testOpCallRunRecursive() external {
    //     // Simple call self.
    //     checkCallRunRecursive(":call<0>();");
    //     // Ping pong between two calls.
    //     checkCallRunRecursive(":call<1>();:call<0>();");
    //     // If is eager so doesn't help.
    //     checkCallRunRecursive("a:call<1>(1);do-call:,a:if(do-call call<1>(0) 5);");
    // }

    /// Test a mismatch in the inputs from caller and callee.
    function testOpCallRunInputsMismatch() external {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 1, 2));
        bytes memory bytecode = I_DEPLOYER.parse2("a: call<1>(10 11); ten:,a b c:ten 11 12;");
        (bytecode);
    }

    /// Test a mismatch in the outputs from caller and callee.
    function testOpCallRunOutputsMismatch() external {
        vm.expectRevert(abi.encodeWithSelector(CallOutputsExceedSource.selector, 3, 4));
        bytes memory bytecode = I_DEPLOYER.parse2("ten eleven a b: call<1>(10 11); ten eleven:,a:9;");
        (bytecode);
    }
}
