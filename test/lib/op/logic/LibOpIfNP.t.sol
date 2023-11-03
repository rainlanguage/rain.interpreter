// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";
import {LibOpIfNP} from "src/lib/op/logic/LibOpIfNP.sol";

contract LibOpIfNPTest is OpTest {
    /// Directly test the integrity logic of LibOpIfNP. No matter the
    /// operand inputs, the calc inputs must be 2, and the calc outputs must be
    /// 1.
    function testOpIfNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpIfNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

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
        Operand operand = Operand.wrap(inputs.length << 0x10);
        opReferenceCheck(state, operand, LibOpIfNP.referenceFn, LibOpIfNP.integrity, LibOpIfNP.run, inputs);
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 1, the third input is 2.
    function testOpIfNPEval3InputsFirstZeroSecondOneThirdTwo() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0 1 2);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 2);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 1, the second input is 2, the third input is 3.
    function testOpIfNPEval3InputsFirstOneSecondTwoThirdThree() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(1 2 3);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 2);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 0, the third input is 3.
    function testOpIfNPEval3InputsFirstZeroSecondZeroThirdThree() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0 0 3);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 3);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 1, the second input is 0, the third input is 3.
    function testOpIfNPEval3InputsFirstOneSecondZeroThirdThree() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(1 0 3);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 1, the third input is 0.
    function testOpIfNPEval3InputsFirstZeroSecondOneThirdZero() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0 1 0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 0, the second input is 0, the third input is 1.
    function testOpIfNPEval3InputsFirstZeroSecondZeroThirdOne() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0 0 1);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 1);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 2, the second input is 3, the third input is 4.
    function testOpIfNPEval3InputsFirstTwoSecondThreeThirdFour() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(2 3 4);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 3);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of if parsed from a string. Tests 3 inputs. The first input
    /// is 2, the second input is 0, the third input is 4.
    function testOpIfNPEval3InputsFirstTwoSecondZeroThirdFour() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(2 0 4);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that an if without inputs fails integrity check.
    function testOpIfNPEvalFail0Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 3, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that an if with 1 input fails integrity check.
    function testOpIfNPEvalFail1Input() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 3, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that an if with 2 inputs fails integrity check.
    function testOpIfNPEvalFail2Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0x00 0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 3, 2));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that an if with 4 inputs fails integrity check.
    function testOpIfNPEvalFail4Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: if(0x00 0x00 0x00 0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 4, 3, 4));
        iDeployer.deployExpression2(bytecode, constants);
    }
}
