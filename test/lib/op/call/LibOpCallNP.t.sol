// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {IInterpreterV2, StateNamespace, Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1, SourceIndex} from "src/interface/IInterpreterStoreV1.sol";
import {OpTest} from "test/util/abstract/OpTest.sol";
import {BytecodeTest} from "test/util/abstract/BytecodeTest.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpCallNP, CallOutputsExceedSource} from "src/lib/op/call/LibOpCallNP.sol";
import {LibBytecode, SourceIndexOutOfBounds} from "src/lib/bytecode/LibBytecode.sol";
import {BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";

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
        inputs = bound(inputs, 0, type(uint8).max);

        conformBytecode(state.bytecode, sourceCount, seed);

        uint256 sourcePosition = randomSourcePosition(state.bytecode, seed);
        uint256 sourceOutputs = uint8(state.bytecode[sourcePosition + 3]);
        vm.assume(sourceOutputs < type(uint8).max);
        outputs = bound(outputs, sourceOutputs + 1, type(uint8).max);

        uint256 sourceIndex = randomSourceIndex(state.bytecode, seed);
        assertTrue(sourceIndex <= type(uint8).max);

        Operand operand = Operand.wrap(inputs << 0x10 | outputs << 0x08 | sourceIndex);
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
        inputs = bound(inputs, 0, type(uint8).max);
        outputs = bound(outputs, 0, type(uint8).max);

        conformBytecode(state.bytecode, sourceCount, seed);
        sourceCount = LibBytecode.sourceCount(state.bytecode);

        sourceIndex = bound(sourceIndex, sourceCount, type(uint8).max);

        Operand operand = Operand.wrap(inputs << 0x10 | outputs << 0x08 | sourceIndex);
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
        inputs = bound(inputs, 0, type(uint8).max);

        conformBytecode(state.bytecode, sourceCount, seed);

        uint256 sourcePosition = randomSourcePosition(state.bytecode, seed);
        uint256 sourceOutputs = uint8(state.bytecode[sourcePosition + 3]);
        outputs = bound(outputs, 0, sourceOutputs);

        uint256 sourceIndex = randomSourceIndex(state.bytecode, seed);
        assertTrue(sourceIndex <= type(uint8).max);

        Operand operand = Operand.wrap(inputs << 0x10 | outputs << 0x08 | sourceIndex);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpCallNP.integrity(state, operand);
        uint256 sourceInputs = uint8(state.bytecode[sourcePosition + 2]);
        assertEq(calcInputs, sourceInputs, "inputs");
        assertEq(calcOutputs, outputs, "outputs");
    }

    /// Boilerplate for testing that a source does not exist.
    function checkSourceDoesNotExist(bytes memory rainlang, uint256 sourceIndex) internal {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainlang);
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, bytecode, sourceIndex));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer, storeDeployer, expression);
    }

    /// Test that the eval of a call into a source that doesn't exist reverts
    /// upon deploy.
    function testOpCallNPRunSourceDoesNotExist() external {
        // 0 inputs and outputs different source indexes.
        checkSourceDoesNotExist(": call<1 0>();", 1);
        checkSourceDoesNotExist(": call<2 0>();", 2);
        // 1 input and 0 outputs different source indexes.
        checkSourceDoesNotExist(": call<1 0>(1);", 1);
        checkSourceDoesNotExist(": call<2 0>(1);", 2);
        // 0 inputs and 1 output different source indexes.
        checkSourceDoesNotExist("_: call<1 1>();", 1);
        checkSourceDoesNotExist("_: call<2 1>();", 2);
        // Several inputs and outputs different source indexes.
        checkSourceDoesNotExist("a b: call<1 2>(10 5);", 1);
        checkSourceDoesNotExist("a b: call<2 2>(10 5);", 2);
        // Multiple sources.
        checkSourceDoesNotExist(": call<2 0>();:;", 2);
        checkSourceDoesNotExist(": call<3 0>();:;", 3);
    }

    /// Boilerplate for checking the stack and kvs of a call.
    function checkCallNPRun(bytes memory rainlang, uint256[] memory stack, uint256[] memory kvs) internal {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainlang);
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory actualStack, uint256[] memory actualKVs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), type(uint8).max),
            new uint256[][](0)
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
        checkCallNPRun(":call<1 0>();:;", stack, kvs);
        // Single input and no outputs.
        checkCallNPRun(":call<1 0>(10);ten:;", stack, kvs);

        // Check evals that result in a stack of one item but no kvs.
        stack = new uint256[](1);
        // Single input and single output.
        stack[0] = 10;
        checkCallNPRun("ten:call<1 1>(10);ten:;", stack, kvs);
        // zero input single output.
        checkCallNPRun("ten:call<1 1>();ten:10;", stack, kvs);
        // Two inputs and one output.
        stack[0] = 12;
        checkCallNPRun("a: call<1 1>(10 11); ten eleven:,a b c:ten eleven 12;", stack, kvs);

        // Check evals that result in a stack of two items but no kvs.
        stack = new uint256[](2);
        // Order dependent inputs and outputs.
        stack[0] = 2;
        stack[1] = 9;
        checkCallNPRun("a b: call<1 2>(10 5); ten five:, a b: int-div(ten five) 9;", stack, kvs);

        // One input two outputs.
        stack[0] = 10;
        stack[1] = 11;
        checkCallNPRun("a b: call<1 2>(10); ten:,a b:ten 11;", stack, kvs);

        // Can call something with no IO purely for the kv side effects.
        stack = new uint256[](0);
        kvs = new uint256[](2);
        kvs[0] = 10;
        kvs[1] = 11;
        checkCallNPRun(":call<1 0>();:set(10 11);", stack, kvs);

        // Can call for side effects and also get a stack based on IO.
        stack = new uint256[](1);
        stack[0] = 10;
        checkCallNPRun("a:call<1 1>(9);nine:,:set(10 11),ret:int-add(nine 1);", stack, kvs);
    }

    /// Boilerplate to check a generic runtime error happens upon recursion.
    function checkCallNPRunRecursive(bytes memory rainlang) internal {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(rainlang);
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        // Recursion isn't caught at deploy time.
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        // But it will unconditionally happen at runtime.
        vm.expectRevert();
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), type(uint8).max),
            new uint256[][](0)
        );
        (stack, kvs);
    }

    /// Test that recursive calls are a (very gas intensive) runtime error.
    function testOpCallNPRunRecursive() external {
        // Simple call self.
        checkCallNPRunRecursive(":call<0 0>();");
        // Ping pong between two calls.
        checkCallNPRunRecursive(":call<1 0>();:call<0 0>();");
        // If is eager so doesn't help.
        checkCallNPRunRecursive("a:call<1 1>(1);do-call:,a:if(do-call call<1 1>(0) 5);");
    }

    /// Test a mismatch in the inputs from caller and callee.
    function testOpCallNPRunInputsMismatch() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("a: call<1 1>(10 11); ten:,a b c:ten 11 12;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 1, 2));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer, storeDeployer, expression);
    }

    /// Test a mismatch in the outputs from caller and callee.
    function testOpCallNPRunOutputsMismatch() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("ten eleven a b: call<1 4>(10 11); ten eleven:,a:9;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(CallOutputsExceedSource.selector, 3, 4));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer, storeDeployer, expression);
    }
}
