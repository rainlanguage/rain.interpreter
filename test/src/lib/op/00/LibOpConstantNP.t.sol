// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/abstract/OpTest.sol";

import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {OutOfBoundsConstantRead, LibOpConstantNP} from "src/lib/op/00/LibOpConstantNP.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "rain.interpreter.interface/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {BadOpOutputsLength} from "src/error/ErrIntegrity.sol";

/// @title LibOpConstantNPTest
/// @notice Test the runtime and integrity time logic of LibOpConstantNP.
contract LibOpConstantNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpConstantNP. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the constants array.
    function testOpConstantNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        vm.assume(state.constants.length > 0);
        operand = Operand.wrap(bound(Operand.unwrap(operand), 0, state.constants.length - 1));

        (uint256 calcInputs, uint256 calcOutputs) = LibOpConstantNP.integrity(state, operand);

        assertEq(calcInputs, 0, "inputs");
        assertEq(calcOutputs, 1, "outputs");
    }

    /// Directly test the integrity logic of LibOpConstantNP. This tests the case
    /// where the operand points past the end of the constants array, which MUST
    /// always error as an OOB read.
    function testOpConstantNPIntegrityOOBConstants(IntegrityCheckStateNP memory state, Operand operand) external {
        operand = Operand.wrap(bound(Operand.unwrap(operand), state.constants.length, type(uint16).max));

        vm.expectRevert(
            abi.encodeWithSelector(
                OutOfBoundsConstantRead.selector, state.opIndex, state.constants.length, Operand.unwrap(operand)
            )
        );
        LibOpConstantNP.integrity(state, operand);
    }

    /// Directly test the runtime logic of LibOpConstantNP. This tests that the
    /// operand always puts a single value on the stack.
    function testOpConstantNPRun(uint256[] memory constants, uint16 constantIndex) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        state.constants = constants;
        vm.assume(state.constants.length > 0);
        vm.assume(state.constants.length <= type(uint16).max);
        constantIndex = uint16(bound(constantIndex, 0, uint16(state.constants.length - 1)));

        uint256[] memory inputs = new uint256[](0);
        opReferenceCheck(
            state,
            LibOperand.build(0, 1, constantIndex),
            LibOpConstantNP.referenceFn,
            LibOpConstantNP.integrity,
            LibOpConstantNP.run,
            inputs
        );
    }

    /// Test the case of an empty constants array via. an end to end test. We
    /// expect the deployer to revert, as the integrity check MUST fail.
    function testOpConstantEvalZeroConstants() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_ _ _: constant() constant() constant();");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        (uint256 sourceInputs, uint256 sourceOutputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(sourceInputs, 0);
        assertEq(sourceOutputs, 3);

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
            hex"01100000"
            // constant 0
            hex"01100000"
            // constant 0
            hex"01100000"
        );

        assertEq(constants.length, 0);

        vm.expectRevert(abi.encodeWithSelector(OutOfBoundsConstantRead.selector, 0, 0, 0));
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (interpreterDeployer);
        (storeDeployer);
        (expression);
        (io);
    }

    /// Test the eval of a constant opcode parsed from a string.
    function testOpConstantEvalNPE2E() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_ _: max-int-value() 1001e15;");

        assertEq(constants.length, 1);
        assertEq(constants[0], 1001e15);

        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 2);
        assertEq(stack[0], 1001e15);
        assertEq(stack[1], type(uint256).max);
        assertEq(kvs.length, 0);
    }

    /// It is an error to have multiple outputs for a constant.
    function testOpConstantNPMultipleOutputErrorSugared() external {
        checkUnhappyDeploy("_ _: 1;", abi.encodeWithSelector(BadOpOutputsLength.selector, 0, 1, 2));
    }

    /// It is an error to have multiple outputs for a constant.
    function testOpConstantNPMultipleOutputErrorUnsugared() external {
        checkUnhappyDeploy("_:1,_ _: constant<0>();", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 2));
    }

    /// It is an error to have zero outputs for a constant.
    function testOpConstantNPZeroOutputErrorSugared() external {
        checkUnhappyDeploy(":1;", abi.encodeWithSelector(BadOpOutputsLength.selector, 0, 1, 0));
    }

    /// It is an error to have zero outputs for a constant.
    function testOpConstantNPZeroOutputErrorUnsugared() external {
        checkUnhappyDeploy("_:1,:constant<0>();", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 0));
    }
}
