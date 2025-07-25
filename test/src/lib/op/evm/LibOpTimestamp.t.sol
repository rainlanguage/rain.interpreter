// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {
    IInterpreterV4,
    OperandV2,
    SourceIndexV2,
    EvalV4,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheck.sol";
import {
    IInterpreterStoreV2, FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";

import {LibOpTimestamp} from "src/lib/op/evm/LibOpTimestamp.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpTimestampTest
/// @notice Test the runtime and integrity time logic of LibOpTimestamp.
contract LibOpTimestampTest is OpTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    function timestampWords() internal pure returns (string[] memory) {
        string[] memory words = new string[](2);
        words[0] = "block-timestamp";
        words[1] = "now";
        return words;
    }

    /// Directly test the integrity logic of LibOpTimestamp.
    function testOpTimestampIntegrity(IntegrityCheckState memory state, uint8 inputs, uint8 outputs, uint16 operandData)
        external
        pure
    {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpTimestamp.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpTimestamp. This tests that the
    /// opcode correctly pushes the timestamp onto the stack.
    function testOpTimestampRun(uint256 blockTimestamp) external {
        blockTimestamp = bound(blockTimestamp, 0, uint128(type(int128).max));
        InterpreterState memory state = opTestDefaultInterpreterState();
        vm.warp(blockTimestamp);
        StackItem[] memory inputs = new StackItem[](0);
        OperandV2 operand = LibOperand.build(0, 1, 0);
        opReferenceCheck(
            state, operand, LibOpTimestamp.referenceFn, LibOpTimestamp.integrity, LibOpTimestamp.run, inputs
        );
    }

    /// Test the eval of a timestamp opcode parsed from a string.
    function testOpTimestampEval(uint256 blockTimestamp) external {
        string[] memory words = timestampWords();

        for (uint256 i; i < words.length; ++i) {
            blockTimestamp = bound(blockTimestamp, 0, uint256(type(uint64).max));
            vm.warp(blockTimestamp);
            bytes memory bytecode = iDeployer.parse2(bytes(string.concat("_: ", words[i], "();")));
            (StackItem[] memory stack, bytes32[] memory kvs) = iInterpreter.eval4(
                EvalV4({
                    store: iStore,
                    namespace: FullyQualifiedNamespace.wrap(0),
                    bytecode: bytecode,
                    sourceIndex: SourceIndexV2.wrap(0),
                    context: LibContext.build(new bytes32[][](0), new SignedContextV1[](0)),
                    inputs: new StackItem[](0),
                    stateOverlay: new bytes32[](0)
                })
            );
            assertEq(stack.length, 1);
            assertEq(StackItem.unwrap(stack[0]), bytes32(blockTimestamp));
            assertEq(kvs.length, 0);
        }
    }

    /// Test that a block timestamp with inputs fails integrity check.
    function testOpBlockTimestampNPEvalFail() external {
        string[] memory words = timestampWords();

        for (uint256 i; i < words.length; ++i) {
            vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
            bytes memory bytecode = iDeployer.parse2(bytes(string.concat("_: ", words[i], "(0x00);")));
            (bytecode);
        }
    }

    function testOpBlockTimestampNPZeroOutputs() external {
        string[] memory words = timestampWords();

        for (uint256 i; i < words.length; ++i) {
            checkBadOutputs(bytes(string.concat(": ", words[i], "();")), 0, 1, 0);
        }
    }

    function testOpBlockTimestampNPTwoOutputs() external {
        string[] memory words = timestampWords();

        for (uint256 i; i < words.length; ++i) {
            checkBadOutputs(bytes(string.concat("_ _: ", words[i], "();")), 0, 1, 2);
        }
    }
}
