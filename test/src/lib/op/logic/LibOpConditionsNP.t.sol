// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {OpTest, UnexpectedOperand} from "test/abstract/OpTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibOpConditionsNP} from "src/lib/op/logic/LibOpConditionsNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {
    IInterpreterV2,
    Operand,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "rain.interpreter.interface/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpConditionsNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpConditionsNP. This tests the happy
    /// path where the operand is valid.
    function testOpConditionsNPIntegrityHappy(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpConditionsNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        uint256 expectedCalcInputs = inputs;
        // Calc inputs will be minimum 2.
        if (inputs < 2) {
            expectedCalcInputs = 2;
        }
        assertEq(calcInputs, expectedCalcInputs, "calc inputs");
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpConditionsNP.
    function testOpConditionsNPRun(uint256[] memory inputs, uint256 finalNonZero) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        // Ensure that we have inputs that are a valid pairwise conditions.
        vm.assume(inputs.length > 1);
        vm.assume(inputs.length <= 0x0F);
        if (inputs.length % 2 != 0) {
            inputs.truncate(inputs.length - 1);
        }
        // Ensure the final condition is nonzero so that we don't error.
        if (inputs[inputs.length - 2] == 0) {
            vm.assume(finalNonZero != 0);
            inputs[inputs.length - 2] = finalNonZero;
        }
        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(
            state, operand, LibOpConditionsNP.referenceFn, LibOpConditionsNP.integrity, LibOpConditionsNP.run, inputs
        );
    }

    /// Test the error case where no conditions are met.
    function testOpConditionsNPRunNoConditionsMet(uint256[] memory inputs, string memory reason) external {
        vm.assume(bytes(reason).length <= 31);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        // Ensure that we have inputs that are a valid pairwise conditions.
        vm.assume(inputs.length > 1);
        if (inputs.length > 0x0F) {
            inputs.truncate(0x0F);
        }

        Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);

        // Ensure all the conditions are zero so that we error.
        for (uint256 i = 0; i < inputs.length; i += 2) {
            inputs[i] = 0;
        }

        if (inputs.length % 2 != 0) {
            inputs[inputs.length - 1] = IntOrAString.unwrap(LibIntOrAString.fromString(reason));
        } else {
            reason = "";
        }

        vm.expectRevert(bytes(reason));
        opReferenceCheck(
            state, operand, LibOpConditionsNP.referenceFn, LibOpConditionsNP.integrity, LibOpConditionsNP.run, inputs
        );
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 1 true input 1 zero output.
    function testOpConditionsNPEval1TrueInputZeroOutput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(5 0);");
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

    /// Test the eval of conditions opcode parsed from a string. Tests 1 nonzero
    /// input 1 nonzero output.
    function testOpConditionsNPEval2MixedInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(5 6);");
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

    /// Test that if conditions are NOT met, the expression reverts.
    function testOpConditionsNPEval1FalseInputRevert() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(0 5);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        vm.expectRevert(bytes(""));
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        (stack);
        (kvs);
    }

    /// Test that conditions can take an error code as an operand.
    function testOpConditionsNPEvalErrorCode() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iParser.parse("_: conditions(0x00 0x00 0x00 0x00 \"fail\");");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (io);
        vm.expectRevert(abi.encodeWithSelector("fail"));
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        (stack);
        (kvs);
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 1 zero
    /// then 1 nonzero condition.
    function testOpConditionsNPEval1FalseInput1TrueInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(0 9 3 4);");
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
        assertEq(stack[0], 4);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 2 true
    /// conditions. The first should be used.
    function testOpConditionsNPEval2TrueInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(5 6 7 8);");
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

    /// Test the eval of conditions opcode parsed from a string. Tests 1 nonzero
    /// condition then 1 zero condition.
    function testOpConditionsNPEval1TrueInput1FalseInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(5 6 0 9);");
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

    /// Test that conditions without inputs fails integrity check.
    function testOpConditionsNPEvalFail0Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that conditions with 1 inputs fails integrity check.
    function testOpConditionsNPEvalFail1Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: conditions(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test the eval of `conditions` parsed from a string. Tests the unhappy path
    /// where an operand is provided.
    function testOpConditionsNPEvalUnhappyOperand() external {
        checkUnhappyParse("_ :conditions<0>(1 1 \"foo\");", abi.encodeWithSelector(UnexpectedOperand.selector));
    }

    function testOpConditionsNPZeroOutputs() external {
        checkBadOutputs(": conditions(0x00 0x00);", 2, 1, 0);
    }

    function testOpConditionsNPTwoOutputs() external {
        checkBadOutputs("_ _: conditions(0x00 0x00);", 2, 1, 2);
    }
}
