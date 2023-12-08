// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibOpIsZeroNP} from "src/lib/op/logic/LibOpIsZeroNP.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {
    IInterpreterV2, Operand, SourceIndexV2, FullyQualifiedNamespace
} from "src/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";

contract LibOpIsZeroNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIsZeroNP. This tests the happy
    /// path where the operand is valid. IsZero is a 1 input, 1 output op.
    function testOpIsZeroNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIsZeroNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        // The inputs from the operand are ignored. The op is always 1 input.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpIsZeroNP.
    function testOpIsZeroNPRun(uint256 input) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = input;
        Operand operand = Operand.wrap(inputs.length << 0x10);
        opReferenceCheck(state, operand, LibOpIsZeroNP.referenceFn, LibOpIsZeroNP.integrity, LibOpIsZeroNP.run, inputs);
    }

    /// Test the eval of isZero opcode parsed from a string. Tests 1 nonzero input.
    function testOpIsZeroNPEval1NonZeroInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: is-zero(30);");
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

    /// Test the eval of isZero opcode parsed from a string. Tests 1 zero input.
    function testOpIsZeroNPEval1ZeroInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: is-zero(0);");
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
        assertEq(stack[0], 1);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that an iszero without inputs fails integrity check.
    function testOpIsZeroNPEvalFail0Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: is-zero();");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 1, 0));
        iDeployer.deployExpression2(bytecode, constants);
    }

    /// Test that an iszero with 2 inputs fails integrity check.
    function testOpIsZeroNPEvalFail2Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: is-zero(0x00 0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 1, 2));
        iDeployer.deployExpression2(bytecode, constants);
    }
}
