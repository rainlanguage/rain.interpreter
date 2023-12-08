// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibInterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IInterpreterV2, Operand, SourceIndexV2} from "src/interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {IInterpreterStoreV1, FullyQualifiedNamespace} from "src/interface/IInterpreterStoreV1.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";

import {LibOpTimestampNP} from "src/lib/op/evm/LibOpTimestampNP.sol";

/// @title LibOpTimestampNPTest
/// @notice Test the runtime and integrity time logic of LibOpTimestampNP.
contract LibOpTimestampNPTest is OpTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpTimestampNP.
    function testOpTimestampNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpTimestampNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpTimestamp. This tests that the
    /// opcode correctly pushes the timestamp onto the stack.
    function testOpTimestampNPRun(uint256 blockTimestamp) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.warp(blockTimestamp);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state, operand, LibOpTimestampNP.referenceFn, LibOpTimestampNP.integrity, LibOpTimestampNP.run, inputs
        );
    }

    /// Test the eval of a timestamp opcode parsed from a string.
    function testOpTimestampNPEval(uint256 blockTimestamp) external {
        vm.warp(blockTimestamp);
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: block-timestamp();");
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
        assertEq(stack[0], blockTimestamp);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that a block timestamp with inputs fails integrity check.
    function testOpBlockTimestampNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: block-timestamp(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }
}
