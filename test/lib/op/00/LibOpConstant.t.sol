// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "src/lib/caller/LibContext.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibOpConstantTest
/// @notice Test the runtime and integrity time logic of LibOpConstant.
contract LibOpConstantTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpConstant. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the constants array.
    function testOpConstantNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        state.constantsLength = bound(state.constantsLength, 1, type(uint256).max);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, state.constantsLength - 1));

        (uint256 inputs, uint256 outputs) = LibOpConstantNP.integrity(state, operand);

        assertEq(inputs, 0);
        assertEq(outputs, 1);
    }

    /// Directly test the integrity logic of LibOpConstant. This tests the case
    /// where the operand points past the end of the constants array, which MUST
    /// always error as an OOB read.
    function testOpConstantNPIntegrityOOBConstants(IntegrityCheckStateNP memory state, Operand operand) external {
        operand = Operand.wrap(bound(Operand.unwrap(operand), state.constantsLength, type(uint256).max));

        vm.expectRevert(
            abi.encodeWithSelector(
                OutOfBoundsConstantRead.selector, state.opIndex, state.constantsLength, Operand.unwrap(operand)
            )
        );
        LibOpConstantNP.integrity(state, operand);
    }

    /// Directly test the runtime logic of LibOpConstant. This tests that the
    /// operand always puts a single value on the stack.
    function testOpConstantNPRun(
        InterpreterStateNP memory state,
        uint256 pre,
        uint256 post,
        uint256[] memory constants,
        uint256 constantIndex
    ) external {
        vm.assume(constants.length > 0);
        constantIndex = bound(constantIndex, 0, constants.length - 1);

        Pointer firstConstant;
        assembly {
            firstConstant := add(constants, 0x20)
        }
        state.firstConstant = firstConstant;

        Pointer stackBottom;
        Pointer stackTop;
        Pointer expectedStackTopAfter;
        Pointer end;
        assembly {
            end := mload(0x40)
            mstore(end, post)
            expectedStackTopAfter := add(end, 0x20)
            mstore(expectedStackTopAfter, 0)
            stackTop := add(expectedStackTopAfter, 0x20)
            mstore(stackTop, pre)
            stackBottom := add(stackTop, 0x20)
            mstore(0x40, stackBottom)
        }

        // Constants don't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpConstantNP.run(state, Operand.wrap(constantIndex), stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // The constant should be on the stack without modifying any other
        // data.
        uint256 actualPost;
        uint256 actualConstant;
        uint256 actualPre;
        assembly {
            actualPost := mload(end)
            actualConstant := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, post);
        assertEq(actualConstant, constants[constantIndex]);
        assertEq(actualPre, pre);
    }

    /// Test the case of an empty constants array via. an end to end test. We
    /// expect the deployer to revert, as the integrity check MUST fail.
    function testOpConstantEvalZeroConstants() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("_ _ _: constant() constant() constant();");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 3);

        assertEq(
            bytecode,
            // 1 source.
            hex"01"
            // offset 0
            hex"0000"
            // 3 ops
            hex"03"
            // 3 stack allocation
            hex"03"
            // 0 inputs
            hex"00"
            // 3 outputs
            hex"03"
            // constant 0
            hex"01000000"
            // constant 0
            hex"01000000"
            // constant 0
            hex"01000000"
        );

        assertEq(constants.length, 0);

        uint256[] memory minOuputs = new uint256[](1);
        minOuputs[0] = 3;
        vm.expectRevert(abi.encodeWithSelector(OutOfBoundsConstantRead.selector, 0, 0, 0));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOuputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    /// Test the eval of a constant opcode parsed from a string.
    function testOpConstantEvalNPE2E() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_ _: max-uint-256() 1001e15;");

        assertEq(constants.length, 1);
        assertEq(constants[0], 1001e15);

        uint256[] memory minOuputs = new uint256[](1);
        minOuputs[0] = 2;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOuputs);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 2);
        assertEq(stack[0], type(uint256).max);
        assertEq(stack[1], 1001e15);
        assertEq(kvs.length, 0);
    }
}
