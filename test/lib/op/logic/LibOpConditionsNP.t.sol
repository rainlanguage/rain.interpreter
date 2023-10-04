// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibUint256Array.sol";

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";
import {NoConditionsMet} from "src/lib/op/logic/LibOpConditionsNP.sol";

contract LibOpConditionsNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpConditionsNP. This tests the happy
    /// path where the operand is valid.
    function testOpConditionsNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpConditionsNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        uint256 expectedCalcInputs;
        // Calc inputs will be minimum 2.
        if (inputs < 2) {
            expectedCalcInputs = 2;
        }
        // Calc inputs will be even, adding 1 if necessary.
        else if (inputs % 2 == 0) {
            expectedCalcInputs = inputs;
        } else {
            expectedCalcInputs = uint256(inputs) + 1;
        }
        assertEq(calcInputs, expectedCalcInputs, "calc inputs");
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpConditionsNP.
    function testOpConditionsNPRun(uint256[] memory inputs, uint16 conditionCode, uint256 finalNonZero) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        // Ensure that we have inputs that are a valid pairwise conditions.
        vm.assume(inputs.length > 1);
        if (inputs.length % 2 != 0) {
            inputs.truncate(inputs.length - 1);
        }
        // Ensure the final condition is nonzero so that we don't error.
        if (inputs[inputs.length - 2] == 0) {
            vm.assume(finalNonZero != 0);
            inputs[inputs.length - 2] = finalNonZero;
        }
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10 | uint256(conditionCode));
        opReferenceCheck(
            state, operand, LibOpConditionsNP.referenceFn, LibOpConditionsNP.integrity, LibOpConditionsNP.run, inputs
        );
    }

    /// Test the error case where no conditions are met.
    function testOpConditionsNPRunNoConditionsMet(uint256[] memory inputs, uint16 conditionCode) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();

        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10 | uint256(conditionCode));
        // Ensure that we have inputs that are a valid pairwise conditions.
        vm.assume(inputs.length > 1);
        if (inputs.length % 2 != 0) {
            inputs.truncate(inputs.length - 1);
        }
        // Ensure all the conditions are zero so that we error.
        for (uint256 i = 0; i < inputs.length; i += 2) {
            inputs[i] = 0;
        }

        vm.expectRevert(abi.encodeWithSelector(NoConditionsMet.selector, uint256(conditionCode)));
        opReferenceCheck(
            state, operand, LibOpConditionsNP.referenceFn, LibOpConditionsNP.integrity, LibOpConditionsNP.run, inputs
        );
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 1 true input 1 zero output.
    function testOpConditionsNPEval1TrueInputZeroOutput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(5 0);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 1 nonzero
    /// input 1 nonzero output.
    function testOpConditionsNPEval2MixedInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(5 6);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 6);
        assertEq(kvs.length, 0);
    }

    /// Test that if conditions are NOT met, the expression reverts.
    function testOpConditionsNPEval1FalseInputRevert() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(0 5);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 0;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        vm.expectRevert(abi.encodeWithSelector(NoConditionsMet.selector, 0));
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 0),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        (stack);
        (kvs);
    }

    /// Test that conditions can take an error code as an operand.
    function testOpConditionsNPEvalErrorCode() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions<7>(0x00 0x00 0x00 0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        vm.expectRevert(abi.encodeWithSelector(NoConditionsMet.selector, 7));
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        (stack);
        (kvs);
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 1 zero
    /// then 1 nonzero condition.
    function testOpConditionsNPEval1FalseInput1TrueInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(0 9 3 4);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 4);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 2 true
    /// conditions. The first should be used.
    function testOpConditionsNPEval2TrueInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(5 6 7 8);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 6);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of conditions opcode parsed from a string. Tests 1 nonzero
    /// condition then 1 zero condition.
    function testOpConditionsNPEval1TrueInput1FalseInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(5 6 0 9);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 6);
        assertEq(kvs.length, 0);
    }

    /// Test that conditions without inputs fails integrity check.
    function testOpConditionsNPEvalFail0Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that conditions with 1 inputs fails integrity check.
    function testOpConditionsNPEvalFail1Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that conditions with 3 inputs fails integrity check.
    function testOpConditionsNPEvalFail3Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: conditions(0x00 0x00 0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 4, 3));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that conditions with 5 inputs fails integrity check.
    function testOpConditionsNPEvalFail5Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("_: conditions(0x00 0x00 0x00 0x00 0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 5, 6, 5));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
