// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "rain.solmem/lib/LibUint256Array.sol";

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";

contract LibOpAnyNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpAnyNP. This tests the happy
    /// path where the operand is valid.
    function testOpAnyNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        vm.assume(inputs != 0);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Sample the gas cost of the integrity check.
    function testOpAnyNPIntegrityGas0() external {
        vm.pauseGasMetering();
        IntegrityCheckStateNP memory state = IntegrityCheckStateNP(6, 6, 6, 3, 9, "");
        Operand operand = Operand.wrap(0x50000);
        vm.resumeGasMetering();
        // 5 inputs. Any stack index above this is fine for the state.
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, operand);
        (calcInputs);
        (calcOutputs);
    }

    /// Directly test the integrity logic of LibOpAnyNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpAnyNPIntegrityUnhappyZeroInputs(IntegrityCheckStateNP memory state) external {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 1.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpAnyNP.
    function testOpAnyNPRun(InterpreterStateNP memory state, uint256[] memory inputs) external {
        vm.assume(inputs.length != 0);
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        opReferenceCheck(state, operand, LibOpAnyNP.referenceFn, LibOpAnyNP.integrity, LibOpAnyNP.run, inputs);
    }

    /// Sample the gas cost of the run function.
    function testOpAnyNPRunGas0() external {
        vm.pauseGasMetering();
        uint256[][] memory stacks = new uint256[][](1);
        stacks[0] = new uint256[](1);
        Pointer stackTop = stacks[0].dataPointer();
        InterpreterStateNP memory state = InterpreterStateNP(
            LibInterpreterStateNP.stackBottoms(stacks),
            new uint256[](0),
            0,
            MemoryKV.wrap(0),
            FullyQualifiedNamespace.wrap(0),
            IInterpreterStoreV1(address(0)),
            new uint256[][](0),
            "",
            ""
        );
        Operand operand = Operand.wrap(0x10000);
        vm.resumeGasMetering();
        // 1 inputs. Any stack index above this is fine for the state.
        LibOpAnyNP.run(state, operand, stackTop);
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

    /// Test that any without inputs fails integrity check.
    function testOpAnyNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: any();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 1, 0));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
