// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {IMetaV1} from "rain.metadata/interface/IMetaV1.sol";

import {OpTest} from "test/abstract/OpTest.sol";
import {INVALID_BYTECODE} from "test/lib/etch/LibEtch.sol";

import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpChainIdNP} from "src/lib/op/evm/LibOpChainIdNP.sol";

import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2, FullyQualifiedNamespace} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterExpressionDeployerNPE2} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {
    Operand, IInterpreterV2, SourceIndexV2
} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/unstable/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpChainIdNPTest
/// @notice Test the runtime and integrity time logic of LibOpChainIdNP.
contract LibOpChainIdNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpChainIdNP.
    function testOpChainIDNPIntegrity(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpChainIdNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpChainId. This tests that the
    /// opcode correctly pushes the chain ID onto the stack.
    function testOpChainIdNPRun(uint64 chainId, uint16 operandData) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.chainId(chainId);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = LibOperand.build(0, 1, operandData);
        opReferenceCheck(
            state, operand, LibOpChainIdNP.referenceFn, LibOpChainIdNP.integrity, LibOpChainIdNP.run, inputs
        );
    }

    /// Test the eval of a chain ID opcode parsed from a string.
    function testOpChainIDNPEval(uint64 chainId, FullyQualifiedNamespace namespace) public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: chain-id();");

        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV2 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);

        vm.chainId(chainId);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            namespace,
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], chainId, "stack item");
        assertEq(kvs.length, 0, "kvs length");
        assertEq(io, hex"0001", "io");
    }

    /// Test that a chain ID with inputs fails integrity check.
    function testOpChainIdNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: chain-id(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }

    function testOpChainIdNPZeroOutputs() external {
        checkBadOutputs(": chain-id();", 0, 1, 0);
    }

    function testOpChainIdNPTwoOutputs() external {
        checkBadOutputs("_ _: chain-id();", 0, 1, 2);
    }
}
