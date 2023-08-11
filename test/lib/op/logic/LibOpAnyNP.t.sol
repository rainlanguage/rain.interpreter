// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";

contract LibOpAnyNPTest is OpTest {
    /// Directly test the integrity logic of LibOpAnyNP. This tests the happy
    /// path where the operand is valid.
    function testOpAnyNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        vm.assume(inputs != 0);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpAnyNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpAnyNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 1.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpAnyNP. This tests the unhappy
    /// path where the operand body is non zero.
    function testOpAnyNPIntegrityUnhappyNonZeroBody(IntegrityCheckStateNP memory state, uint8 inputs, uint16 badOp)
        external
    {
        vm.assume(inputs != 0);
        checkUnsupportedNonZeroOperandBody(state, inputs, badOp);
    }

    /// Directly test the runtime logic of LibOpAnyNP.
    function testOpAnyNPRun(InterpreterStateNP memory state, uint256 seed, uint256[] memory inputs) external {
        vm.assume(inputs.length != 0);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        opReferenceCheck(state, seed, operand, LibOpAnyNP.referenceFn, LibOpAnyNP.integrity, LibOpAnyNP.run, inputs);
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
}
