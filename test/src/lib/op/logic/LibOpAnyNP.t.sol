// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";

import {OpTest} from "test/abstract/OpTest.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibOpAnyNP} from "src/lib/op/logic/LibOpAnyNP.sol";
import {IInterpreterV2, Operand, SourceIndexV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {
    IInterpreterStoreV2, FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpAnyNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpAnyNP. This tests the happy
    /// path where the operand is valid.
    function testOpAnyNPIntegrityHappy(uint8 inputs, uint16 operandData) external {
        IntegrityCheckStateNP memory state = opTestDefaultIngegrityCheckState();
        inputs = uint8(bound(uint256(inputs), 1, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpAnyNP.integrity(state, LibOperand.build(inputs, 1, operandData));

        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, 1);
    }

    /// Sample the gas cost of the integrity check.
    function testOpAnyNPIntegrityGas0() external {
        vm.pauseGasMetering();
        IntegrityCheckStateNP memory state = IntegrityCheckStateNP(6, 6, 6, new uint256[](3), 9, "");
        Operand operand = Operand.wrap(0x50000);
        vm.resumeGasMetering();
        // 5 inputs. Any stack index above this is fine for the state.
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, operand);
        (calcInputs);
        (calcOutputs);
    }

    /// Directly test the integrity logic of LibOpAnyNP. This tests the unhappy
    /// path where the operand is invalid due to 0 inputs.
    function testOpAnyNPIntegrityUnhappyZeroInputs() external {
        IntegrityCheckStateNP memory state = opTestDefaultIngegrityCheckState();
        (uint256 calcInputs, uint256 calcOutputs) = LibOpAnyNP.integrity(state, Operand.wrap(0));
        // Calc inputs will be minimum 1.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpAnyNP.
    function testOpAnyNPRun(uint256[] memory inputs, uint16 operandData) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.assume(inputs.length != 0);
        vm.assume(inputs.length <= 0x0F);
        Operand operand = LibOperand.build(uint8(inputs.length), 1, operandData);
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
            IInterpreterStoreV2(address(0)),
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
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any(5);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 5e18);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of any opcode parsed from a string. Tests 1 false input.
    function testOpAnyNPEval1FalseInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any(0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
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

    /// Test the eval of any opcode parsed from a string. Tests 2 true inputs.
    /// The first true input should be the overall result.
    function testOpAnyNPEval2TrueInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any(5 6);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 5e18);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of any opcode parsed from a string. Tests 2 false inputs.
    function testOpAnyNPEval2FalseInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any(0 0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
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

    /// Test the eval of any opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The first true input should be the overall result.
    /// The first value is the true value.
    function testOpAnyNPEval2MixedInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any(5 0);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 5e18);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test the eval of any opcode parsed from a string. Tests 2 inputs, one
    /// true and one false. The first true input should be the overall result.
    /// The first value is the false value.
    function testOpAnyNPEval2MixedInputs2() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any(0 5);");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 5e18);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that any without inputs fails integrity check.
    function testOpAnyNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: any();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 1, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }

    function testOpAnyNPZeroOutputs() external {
        checkBadOutputs(": any(0);", 1, 1, 0);
    }

    function testOpAnyNPTwoOutputs() external {
        checkBadOutputs("_ _: any(0);", 1, 1, 2);
    }
}
