// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "src/lib/caller/LibContext.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibOpConstantTest
/// @notice Test the runtime and integrity time logic of LibOpConstant.
contract LibOpConstantTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibUint256Array for uint256[];
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpConstant. This tests the happy
    /// path where the operand points to a constant in the constants array.
    function testOpConstantIntegrity(Operand operand, uint256[] memory constants) external {
        vm.assume(constants.length > 0);
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpConstant.integrity;

        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, constants.length - 1));

        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), constants, integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpConstant.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the integrity logic of LibOpConstant. This tests the case
    /// where the operand points past the end of the constants array, which MUST
    /// always error as an OOB read.
    function testOpConstantIntegrityOOBConstants(Operand operand, uint256[] memory constants) external {
        function(IntegrityCheckState memory, Operand, Pointer)
            view
            returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpConstant.integrity;

        // Bound the operand at or past the constants array.
        operand = Operand.wrap(bound(Operand.unwrap(operand), constants.length, type(uint256).max));

        IntegrityCheckState memory state = LibIntegrityCheck.newState(new bytes[](0), constants, integrityCheckers);
        Pointer stackTop = state.stackBottom;

        vm.expectRevert(
            abi.encodeWithSelector(OutOfBoundsConstantsRead.selector, constants.length, Operand.unwrap(operand))
        );
        LibOpConstant.integrity(state, operand, stackTop);
    }

    /// Directly test the runtime logic of LibOpConstant. This tests that the
    /// opcode correctly pushes the constant onto the stack. This tests the
    /// happy path where the operand points to a constant in the constants array
    /// for a non-empty constants array.
    ///
    /// We rely on the deployer to force the integrity check to pass, so we don't
    /// run into the unhappy path where out of bounds constants reads occur.
    function testOpConstantRun(
        InterpreterState memory state,
        Operand operand,
        uint256 pre,
        uint256 post,
        uint256[] memory constants
    ) external {
        vm.assume(constants.length > 0);
        state.constantsBottom = constants.dataPointer();

        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, constants.length - 1));

        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }
        // Constants don't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpConstant.run(state, operand, stackTop);

        // Check we didn't modify state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // The constant should be pushed onto the stack without modifying the
        // stack beyond the first element.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), constants[Operand.unwrap(operand)]);
        assertEq(stackTopAfter.unsafeReadWord(), post);
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
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 3);
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
        vm.expectRevert(abi.encodeWithSelector(OutOfBoundsConstantsRead.selector, 0, 0));
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOuputs);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
    }

    /// Test the eval of a constant opcode parsed from a string.
    function testOpConstantEval() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_ _: max-uint-256() 1001e15;");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 2);
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
            // "max-uint-256()"
            hex"04000000"
            // "1001e15"
            hex"01000000"
        );
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
