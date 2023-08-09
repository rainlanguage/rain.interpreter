// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "src/lib/caller/LibContext.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibOpStackNPTest
/// @notice Test the runtime and integrity time logic of LibOpStackNP.
contract LibOpStackNPTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpStackNP. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the stack.
    function testOpStackNPIntegrity(bytes memory bytecode, uint256 stackIndex, uint256 constantsLength, Operand operand)
        external
    {
        stackIndex = bound(stackIndex, 1, type(uint256).max);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, stackIndex - 1));
        IntegrityCheckStateNP memory state = LibIntegrityCheckNP.newState(bytecode, stackIndex, constantsLength);

        (uint256 inputs, uint256 outputs) = LibOpStackNP.integrity(state, operand);

        assertEq(inputs, 0);
        assertEq(outputs, 1);
    }

    /// Directly test the integrity logic of LibOpStackNP. This tests the case
    /// where the operand points past the end of the stack, which MUST always
    /// error as an OOB read.
    function testOpStackNPIntegrityOOBStack(
        bytes memory bytecode,
        uint256 stackIndex,
        uint256 constantsLength,
        Operand operand,
        uint256 opIndex
    ) external {
        stackIndex = bound(stackIndex, 1, type(uint256).max);
        operand = Operand.wrap(bound(Operand.unwrap(operand), stackIndex, type(uint256).max));
        IntegrityCheckStateNP memory state = LibIntegrityCheckNP.newState(bytecode, stackIndex, constantsLength);
        state.opIndex = opIndex;

        vm.expectRevert(
            abi.encodeWithSelector(OutOfBoundsStackRead.selector, state.opIndex, stackIndex, Operand.unwrap(operand))
        );
        LibOpStackNP.integrity(state, operand);
    }

    /// Directly test the runtime logic of LibOpStackNP. This tests that the
    /// operand always puts a single value on the stack.
    function testOpStackNPRun(
        InterpreterStateNP memory state,
        uint256 pre,
        uint256 post,
        uint256[][] memory stacks,
        uint256 stackIndex
    ) external {
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

        assertEq(actualPost, post, "post");
        assertEq(actualStackValue, stackValue, "stackValue");
        assertEq(actualPre, pre, "pre");
    }

    /// Test the eval of a stack opcode parsed from a string.
    function testOpStackEval() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("foo: 1, bar: foo;");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 2);
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
