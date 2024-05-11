// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibEncodedDispatch} from "rain.interpreter.interface/lib/caller/LibEncodedDispatch.sol";
import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibInterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterV2, Operand, SourceIndexV2} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterStoreV2, FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV2.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";

import {LibOpTimestampNP} from "src/lib/op/evm/LibOpTimestampNP.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpTimestampNPTest
/// @notice Test the runtime and integrity time logic of LibOpTimestampNP.
contract LibOpTimestampNPTest is OpTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpTimestampNP.
    function testOpTimestampNPIntegrity(
        IntegrityCheckStateNP memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpTimestampNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpTimestamp. This tests that the
    /// opcode correctly pushes the timestamp onto the stack.
    function testOpTimestampNPRun(uint256 blockTimestamp) external {
        blockTimestamp = bound(blockTimestamp, 0, type(uint256).max / 1e18);
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.warp(blockTimestamp);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = LibOperand.build(0, 1, 0);
        opReferenceCheck(
            state, operand, LibOpTimestampNP.referenceFn, LibOpTimestampNP.integrity, LibOpTimestampNP.run, inputs
        );
    }

    /// Test the eval of a timestamp opcode parsed from a string.
    function testOpTimestampNPEval(uint256 blockTimestamp) external {
        blockTimestamp = bound(blockTimestamp, 0, type(uint256).max / 1e18);
        vm.warp(blockTimestamp);
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: block-timestamp();");
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
        assertEq(stack[0], blockTimestamp * 1e18);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that a block timestamp with inputs fails integrity check.
    function testOpBlockTimestampNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: block-timestamp(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }

    function testOpBlockTimestampNPZeroOutputs() external {
        checkBadOutputs(": block-timestamp();", 0, 1, 0);
    }

    function testOpBlockTimestampNPTwoOutputs() external {
        checkBadOutputs("_ _: block-timestamp();", 0, 1, 2);
    }
}
