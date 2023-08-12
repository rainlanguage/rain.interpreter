// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibUint256Array.sol";

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";

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
    function testOpConditionsNPRun(
        InterpreterStateNP memory state,
        uint256 seed,
        uint256[] memory inputs,
        uint16 conditionCode
    ) external {
        // Ensure that we have inputs that are a valid pairwise conditions.
        vm.assume(inputs.length > 1);
        if (inputs.length % 2 != 0) {
            inputs.truncate(inputs.length - 1);
        }
        // Ensure the final condition is nonzero so that we don't error.
        if (inputs[inputs.length - 2] == 0) {
            inputs[inputs.length - 2] = uint256(keccak256(abi.encodePacked(seed)));
        }
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10 | uint256(conditionCode));
        opReferenceCheck(
            state,
            seed,
            operand,
            LibOpConditionsNP.referenceFn,
            LibOpConditionsNP.integrity,
            LibOpConditionsNP.run,
            inputs
        );
    }

    /// Test the error case where no conditions are met.
    function testOpConditionsNPRunNoConditionsMet(
        InterpreterStateNP memory state,
        uint256 seed,
        uint256[] memory inputs,
        uint16 conditionCode
    ) external {
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
            state,
            seed,
            operand,
            LibOpConditionsNP.referenceFn,
            LibOpConditionsNP.integrity,
            LibOpConditionsNP.run,
            inputs
        );
    }

    /// Test the eval of any opcode parsed from a string. Tests 1 true input.
    function testOpAnyNPEval1TrueInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any(5);");
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
        assertEq(stack[0], 5);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of any opcode parsed from a string. Tests 1 false input.
    function testOpAnyNPEval1FalseInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any(0);");
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

    /// Test the eval of any opcode parsed from a string. Tests 2 true inputs.
    /// The first true input should be the overall result.
    function testOpAnyNPEval2TrueInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any(5 6);");
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
        assertEq(stack[0], 5);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of any opcode parsed from a string. Tests 2 false inputs.
    function testOpAnyNPEval2FalseInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any(0 0);");
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

    /// Test the eval of any opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The first true input should be the overall result.
    /// The first value is the true value.
    function testOpAnyNPEval2MixedInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any(5 0);");
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
        assertEq(stack[0], 5);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of any opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The first true input should be the overall result.
    /// The first value is the false value.
    function testOpAnyNPEval2MixedInputs2() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any(0 5);");
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
        assertEq(stack[0], 5);
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
