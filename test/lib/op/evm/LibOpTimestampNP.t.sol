// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import {InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import "src/lib/integrity/LibIntegrityCheckNP.sol";
import "src/lib/caller/LibContext.sol";

import "src/lib/op/evm/LibOpTimestampNP.sol";

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
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-timestamp();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], blockTimestamp);
        assertEq(kvs.length, 0);
    }

    /// Test that a block timestamp with inputs fails integrity check.
    function testOpBlockTimestampNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-timestamp(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
