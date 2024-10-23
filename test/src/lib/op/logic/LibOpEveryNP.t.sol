// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibOpEveryNP} from "src/lib/op/logic/LibOpEveryNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/deprecated/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/deprecated/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpEveryNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEveryNP. This tests the happy
    /// path where the operand is valid.
    function testOpEveryNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 1, 0x0F));
        outputs = uint8(bound(outputs, 1, 0x0F));

        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpEveryNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpEveryNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpEveryNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEveryNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 1.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpEveryNP.
    function testOpEveryNPRun(uint256[] memory inputs) external view {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length != 0);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(state, operand, LibOpEveryNP.referenceFn, LibOpEveryNP.integrity, LibOpEveryNP.run, inputs);
    }

    /// Test the eval of every opcode parsed from a string. Tests 1 true input.
    function testOpEveryNPEval1TrueInput() external view {
        bytes memory bytecode = iDeployer.parse2("_: every(5);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 5e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of every opcode parsed from a string. Tests 1 false input.
    function testOpEveryNPEval1FalseInput() external view {
        bytes memory bytecode = iDeployer.parse2("_: every(0);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 true inputs.
    /// The last true input should be the overall result.
    function testOpEveryNPEval2TrueInputs() external view {
        bytes memory bytecode = iDeployer.parse2("_: every(5 6);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 6e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 false inputs.
    function testOpEveryNPEval2FalseInputs() external view {
        bytes memory bytecode = iDeployer.parse2("_: every(0 0);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The overall result is false.
    function testOpEveryNPEval2MixedInputs() external view {
        bytes memory bytecode = iDeployer.parse2("_: every(5 0);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The overall result is false.
    function testOpEveryNPEval2MixedInputs2() external view {
        bytes memory bytecode = iDeployer.parse2("_: every(0 5);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
    }

    /// Test that every without inputs fails integrity check.
    function testOpAnyNPEvalFail() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 1, 0));
        bytes memory bytecode = iDeployer.parse2("_: every();");
        (bytecode);
    }

    function testOpEveryNPZeroOutputs() external {
        checkBadOutputs(": every(5);", 1, 1, 0);
    }

    function testOpEveryNPTwoOutputs() external {
        checkBadOutputs("_ _: every(5);", 1, 1, 2);
    }
}
