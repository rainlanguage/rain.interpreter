// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {IMetaV1} from "rain.metadata/interface/IMetaV1.sol";

import {OpTest} from "test/util/abstract/OpTest.sol";
import {INVALID_BYTECODE} from "test/util/lib/etch/LibEtch.sol";

import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpChainIdNP} from "src/lib/op/evm/LibOpChainIdNP.sol";

import {RainterpreterNPE2} from "src/concrete/RainterpreterNPE2.sol";
import {RainterpreterStoreNPE2, FullyQualifiedNamespace} from "src/concrete/RainterpreterStoreNPE2.sol";
import {RainterpreterExpressionDeployerNPE2} from "src/concrete/RainterpreterExpressionDeployerNPE2.sol";
import {Operand, IInterpreterV2, SourceIndexV2} from "src/interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";

/// @title LibOpChainIdNPTest
/// @notice Test the runtime and integrity time logic of LibOpChainIdNP.
contract LibOpChainIdNPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpChainIdNP.
    function testOpChainIDNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpChainIdNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpChainId. This tests that the
    /// opcode correctly pushes the chain ID onto the stack.
    function testOpChainIdNPRun(uint64 chainId) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.chainId(chainId);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state, operand, LibOpChainIdNP.referenceFn, LibOpChainIdNP.integrity, LibOpChainIdNP.run, inputs
        );
    }

    /// Test the eval of a chain ID opcode parsed from a string.
    function testOpChainIDNPEval(uint64 chainId, FullyQualifiedNamespace namespace) public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: chain-id();");

        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
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
}
