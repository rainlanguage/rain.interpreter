// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibOpEveryNP} from "src/lib/op/logic/LibOpEveryNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {IInterpreterV2, Operand, SourceIndexV2, FullyQualifiedNamespace} from "src/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";

contract LibOpEveryNPTest is OpTest {
    /// Directly test the integrity logic of LibOpEveryNP. This tests the happy
    /// path where the operand is valid.
    function testOpEveryNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        vm.assume(inputs != 0);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEveryNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpEveryNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpEveryNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpEveryNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 1.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpEveryNP.
    function testOpEveryNPRun(uint256[] memory inputs) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length != 0);
        Operand operand = Operand.wrap(inputs.length << 0x10);
        opReferenceCheck(state, operand, LibOpEveryNP.referenceFn, LibOpEveryNP.integrity, LibOpEveryNP.run, inputs);
    }

    /// Test the eval of every opcode parsed from a string. Tests 1 true input.
    function testOpEveryNPEval1TrueInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every(5);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 5);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of every opcode parsed from a string. Tests 1 false input.
    function testOpEveryNPEval1FalseInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every(0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 true inputs.
    /// The last true input should be the overall result.
    function testOpEveryNPEval2TrueInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every(5 6);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 6);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 false inputs.
    function testOpEveryNPEval2FalseInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every(0 0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The overall result is false.
    function testOpEveryNPEval2MixedInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every(5 0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of every opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The overall result is false.
    function testOpEveryNPEval2MixedInputs2() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every(0 5);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that every without inputs fails integrity check.
    function testOpAnyNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: every();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 1, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }
}
