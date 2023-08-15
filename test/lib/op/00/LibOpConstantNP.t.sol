// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

import "src/lib/caller/LibContext.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibOpConstantNPTest
/// @notice Test the runtime and integrity time logic of LibOpConstantNP.
contract LibOpConstantNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpConstantNP. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the constants array.
    function testOpConstantNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        state.constantsLength = bound(state.constantsLength, 1, type(uint256).max);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, state.constantsLength - 1));

        (uint256 calcInputs, uint256 calcOutputs) = LibOpConstantNP.integrity(state, operand);

        assertEq(calcInputs, 0, "inputs");
        assertEq(calcOutputs, 1, "outputs");
    }

    /// Directly test the integrity logic of LibOpConstantNP. This tests the case
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

    /// Directly test the runtime logic of LibOpConstantNP. This tests that the
    /// operand always puts a single value on the stack.
    function testOpConstantNPRun(
        InterpreterStateNP memory state,
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
        uint256[] memory inputs = new uint256[](0);
        opReferenceCheck(state, Operand.wrap(constantIndex), LibOpConstantNP.referenceFn, LibOpConstantNP.integrity, LibOpConstantNP.run, inputs);
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
