// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibOpEqualToNP} from "src/lib/op/logic/LibOpEqualToNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/deprecated/caller/LibEncodedDispatch.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpEqualToNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEqualToNP. No matter the
    /// operand inputs, the calc inputs must be 2, and the calc outputs must be
    /// 1.
    function testOpEqualToNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpEqualToNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        // The inputs from the operand are ignored. The op is always 2 inputs.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpEqualToNP.
    function testOpEqualToNPRun(uint256 input1, uint256 input2) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = input1;
        inputs[1] = input2;
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(
            state, operand, LibOpEqualToNP.referenceFn, LibOpEqualToNP.integrity, LibOpEqualToNP.run, inputs
        );
    }

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. Both inputs are 0.
    function testOpEqualToNPEval2ZeroInputs() external {
        bytes memory bytecode = iDeployer.parse2("_: equal-to(0 0);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 1);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. The first input is 0, the second input is 1.
    function testOpEqualToNPEval2InputsFirstZeroSecondOne() external {
        bytes memory bytecode = iDeployer.parse2("_: equal-to(0 1);");
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

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. The first input is 1, the second input is 0.
    function testOpEqualToNPEval2InputsFirstOneSecondZero() external {
        bytes memory bytecode = iDeployer.parse2("_: equal-to(1 0);");
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

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. Both inputs are 1.
    function testOpEqualToNPEval2InputsBothOne() external {
        bytes memory bytecode = iDeployer.parse2("_: equal-to(1 1);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 1);
        assertEq(kvs.length, 0);
    }

    /// Test that an equal to without inputs fails integrity check.
    function testOpEqualToNPEvalFail0Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        bytes memory bytecode = iDeployer.parse2("_: equal-to();");
        (bytecode);
    }

    /// Test that an equal to with 1 input fails integrity check.
    function testOpEqualToNPEvalFail1Input() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        bytes memory bytecode = iDeployer.parse2("_: equal-to(0x00);");
        (bytecode);
    }

    /// Test that an equal to with 3 inputs fails integrity check.
    function testOpEqualToNPEvalFail3Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        bytes memory bytecode = iDeployer.parse2("_: equal-to(0x00 0x00 0x00);");
        (bytecode);
    }

    function testOpEqualToNPZeroOutputs() external {
        checkBadOutputs(": equal-to(0 0);", 2, 1, 0);
    }

    function testOpEqualToNPTwoOutputs() external {
        checkBadOutputs("_ _: equal-to(0 0);", 2, 1, 2);
    }
}
