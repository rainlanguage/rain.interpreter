// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {IMetaV1} from "rain.metadata/interface/deprecated/IMetaV1.sol";

import {OpTest} from "test/abstract/OpTest.sol";
import {INVALID_BYTECODE} from "test/lib/etch/LibEtch.sol";

import {LibInterpreterState, InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {LibOpChainId} from "src/lib/op/evm/LibOpChainId.sol";

import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore, FullyQualifiedNamespace} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {
    OperandV2,
    IInterpreterV4,
    SourceIndexV2,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpChainIdTest
/// @notice Test the runtime and integrity time logic of LibOpChainId.
contract LibOpChainIdTest is OpTest {
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpChainId.
    function testOpChainIDIntegrity(IntegrityCheckState memory state, uint8 inputs, uint8 outputs, uint16 operandData)
        external
        pure
    {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpChainId.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpChainId. This tests that the
    /// opcode correctly pushes the chain ID onto the stack.
    function testOpChainIdRun(uint64 chainId, uint16 operandData) external {
        InterpreterState memory state = opTestDefaultInterpreterState();
        vm.chainId(chainId);
        StackItem[] memory inputs = new StackItem[](0);
        OperandV2 operand = LibOperand.build(0, 1, operandData);
        opReferenceCheck(state, operand, LibOpChainId.referenceFn, LibOpChainId.integrity, LibOpChainId.run, inputs);
    }

    /// Test the eval of a chain ID opcode parsed from a string.
    function testOpChainIDEval(uint64 chainId) public {
        vm.chainId(chainId);
        checkHappy("_: chain-id();", bytes32(uint256(chainId)), "");
    }

    /// Test that a chain ID with inputs fails integrity check.
    function testOpChainIdEvalFail() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        bytes memory bytecode = iDeployer.parse2("_: chain-id(0x00);");
        (bytecode);
    }

    function testOpChainIdZeroOutputs() external {
        checkBadOutputs(": chain-id();", 0, 1, 0);
    }

    function testOpChainIdTwoOutputs() external {
        checkBadOutputs("_ _: chain-id();", 0, 1, 2);
    }
}
