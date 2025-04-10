// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";

import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibBytecode} from "rain.interpreter.interface/lib/bytecode/LibBytecode.sol";
import {OutOfBoundsConstantRead, LibOpConstantNP} from "src/lib/op/00/LibOpConstantNP.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/deprecated/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/deprecated/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {BadOpOutputsLength} from "src/error/ErrIntegrity.sol";

/// @title LibOpConstantNPTest
/// @notice Test the runtime and integrity time logic of LibOpConstantNP.
contract LibOpConstantNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpConstantNP. The operand always
    /// puts a single value on the stack. This tests the happy path where the
    /// operand points to a value in the constants array.
    function testOpConstantNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external pure {
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
    function testOpConstantNPRun(uint256[] memory constants, uint16 constantIndex) external view {
        state.constants = constants;
        vm.assume(state.constants.length > 0);
        vm.assume(state.constants.length <= type(uint16).max);
        constantIndex = uint16(bound(constantIndex, 0, uint16(state.constants.length - 1)));

        uint256[] memory inputs = new uint256[](0);
        opReferenceCheck(
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
        vm.expectRevert(abi.encodeWithSelector(OutOfBoundsConstantRead.selector, 0, 0, 0));
        bytes memory bytecode = iDeployer.parse2("_ _ _: constant() constant() constant();");
        (bytecode);
    }

    /// Test the eval of a constant opcode parsed from a string.
    function testOpConstantEvalNPE2E() external view {
        bytes memory bytecode = iDeployer.parse2("_ _: max-value() 1.001;");

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
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
        checkUnhappyParse2("_ _: 1;", abi.encodeWithSelector(BadOpOutputsLength.selector, 0, 1, 2));
    }

    /// It is an error to have multiple outputs for a constant.
    function testOpConstantNPMultipleOutputErrorUnsugared() external {
        checkUnhappyParse2("_:1,_ _: constant<0>();", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 2));
    }

    /// It is an error to have zero outputs for a constant.
    function testOpConstantNPZeroOutputErrorSugared() external {
        checkUnhappyParse2(":1;", abi.encodeWithSelector(BadOpOutputsLength.selector, 0, 1, 0));
    }

    /// It is an error to have zero outputs for a constant.
    function testOpConstantNPZeroOutputErrorUnsugared() external {
        checkUnhappyParse2("_:1,:constant<0>();", abi.encodeWithSelector(BadOpOutputsLength.selector, 1, 1, 0));
    }
}
