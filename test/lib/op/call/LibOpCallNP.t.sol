// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {IInterpreterV1, StateNamespace, Operand} from "src/interface/IInterpreterV1.sol";
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

    /// Test that the eval of a call into a source that doesn't exist reverts
    /// upon deploy.
    function testOpCallNPRunSourceDoesNotExist() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("a b: call<1 2>(10 5);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 2;
        vm.expectRevert(abi.encodeWithSelector(SourceIndexOutOfBounds.selector, bytecode, 1));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (interpreterDeployer, storeDeployer, expression);
    }

    /// Test the eval of some call that has no inputs or outputs so we can sanity
    /// check the stacks.
    function testOpCallNPRunNoIO() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(":call<1 0>();:;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 0, "stack length");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of some call with a single input and no outputs so we can
    /// sanity check the stacks.
    function testOpCallNPRunSingleInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(": call<1 0>(10); ten:;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 0, "stack length");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of some call with a single input and a single output so we
    /// can sanity check the stacks.
    function testOpCallNPRunSingleInputSingleOutput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("ten: call<1 1>(10); ten:;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], 10, "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of some call with a zero input and a single output so we
    /// can sanity check the stacks.
    function testOpCallNPRunZeroInputSingleOutput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("ten: call<1 1>(); ten:10;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], 10, "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test that recursive calls are a (very gas intensive) runtime error.
    function testOpCallNPRunRecursive() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(":call<0 0>();");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        vm.expectRevert();
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );
        (stack, kvs);
    }

    /// Test that transitive call loops are a (very gas intensive) runtime error.
    function testOpCallNPRunCallLoop() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse(": call<1 0>();: call<0 0>();");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        // vm.expectRevert(abi.encodeWithSelector(LibOpCallNP.run.selector, bytecode, constants, minOutputs, 0, 0, 0, 0, 0, 0));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        vm.expectRevert();
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );
        (stack, kvs);
    }

    /// Test the eval of some call that has order dependent inputs and outputs
    /// so we can sanity check the stacks.
    function testOpCallNPRunOrdering() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("a b: call<1 2>(10 5); ten five:, a b: int-div(ten five) 9;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 2, "stack length");
        assertEq(stack[0], 2, "stack[0]");
        assertEq(stack[1], 9, "stack[1]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval with one input and two outputs.
    function testOpCallNPRunSingleInputDoubleOutput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("a b: call<1 2>(10); ten:,a b:ten 11;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 2, "stack length");
        assertEq(stack[0], 10, "stack[0]");
        assertEq(stack[1], 11, "stack[1]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval with two inputs and one output.
    function testOpCallNPRunDoubleInputSingleOutput() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("a: call<1 1>(10 11); ten eleven:,a b c:ten eleven 12;");
        // The second source is for internal calls only, it is not an entrypoint.
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            new uint256[][](0)
        );

        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], 12, "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
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
