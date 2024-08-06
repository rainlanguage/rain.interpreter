// SPDX-License-Identifier: CAL
pragma solidity =0.8.26;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibOpIfNP} from "src/lib/op/logic/LibOpIfNP.sol";
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

contract LibOpIfNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIfNP. No matter the
    /// operand inputs, the calc inputs must be 2, and the calc outputs must be
    /// 1.
    function testOpIfNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIfNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        // The inputs from the operand are ignored. The op is always 2 inputs.
        assertEq(calcInputs, 3);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIfNP.
    function testOpIfNPRun(uint256 a, uint256 b, uint256 c) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](3);
        inputs[0] = a;
        inputs[1] = b;
        inputs[2] = c;
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(state, operand, LibOpIfNP.referenceFn, LibOpIfNP.integrity, LibOpIfNP.run, inputs);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 1, the third input is 2.
    function testOpIfNPEval3InputsFirstZeroSecondOneThirdTwo() external {
        bytes memory bytecode = iDeployer.parse2("_: if(0 1 2);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 2e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 1, the second input is 2, the third input is 3.
    function testOpIfNPEval3InputsFirstOneSecondTwoThirdThree() external {
        bytes memory bytecode = iDeployer.parse2("_: if(1 2 3);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 2e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 0, the third input is 3.
    function testOpIfNPEval3InputsFirstZeroSecondZeroThirdThree() external {
        bytes memory bytecode = iDeployer.parse2("_: if(0 0 3);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 3e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 1, the second input is 0, the third input is 3.
    function testOpIfNPEval3InputsFirstOneSecondZeroThirdThree() external {
        bytes memory bytecode = iDeployer.parse2("_: if(1 0 3);");
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

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 1, the third input is 0.
    function testOpIfNPEval3InputsFirstZeroSecondOneThirdZero() external {
        bytes memory bytecode = iDeployer.parse2("_: if(0 1 0);");
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

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 0, the third input is 1.
    function testOpIfNPEval3InputsFirstZeroSecondZeroThirdOne() external {
        bytes memory bytecode = iDeployer.parse2("_: if(0 0 1);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 1e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 2, the second input is 3, the third input is 4.
    function testOpIfNPEval3InputsFirstTwoSecondThreeThirdFour() external {
        bytes memory bytecode = iDeployer.parse2("_: if(2 3 4);");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval3(
            iStore,
            FullyQualifiedNamespace.wrap(0),
            bytecode,
            SourceIndexV2.wrap(0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 3e18);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 2, the second input is 0, the third input is 4.
    function testOpIfNPEval3InputsFirstTwoSecondZeroThirdFour() external {
        bytes memory bytecode = iDeployer.parse2("_: if(2 0 4);");
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

    /// Test that empty strings are truthy values.
    function testOpIfNPEvalEmptyStringTruthy() external {
        bytes memory bytecode = iDeployer.parse2("_: if(\"\" 5 50);");
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

    /// Test that an if without inputs fails integrity check.
    function testOpIfNPEvalFail0Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 3, 0));
        bytes memory bytecode = iDeployer.parse2("_: if();");
        (bytecode);
    }

    /// Test that an if with 1 input fails integrity check.
    function testOpIfNPEvalFail1Input() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 3, 1));
        bytes memory bytecode = iDeployer.parse2("_: if(0x00);");
        (bytecode);
    }

    /// Test that an if with 2 inputs fails integrity check.
    function testOpIfNPEvalFail2Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 3, 2));
        bytes memory bytecode = iDeployer.parse2("_: if(0x00 0x00);");
        (bytecode);
    }

    /// Test that an if with 4 inputs fails integrity check.
    function testOpIfNPEvalFail4Inputs() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 4, 3, 4));
        bytes memory bytecode = iDeployer.parse2("_: if(0x00 0x00 0x00 0x00);");
        (bytecode);
    }

    function testOpIfNPEvalZeroOutputs() external {
        checkBadOutputs(": if(5 0 0);", 3, 1, 0);
    }

    function testOpIfNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: if(5 0 0);", 3, 1, 2);
    }
}
