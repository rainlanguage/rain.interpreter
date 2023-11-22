// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OpTest} from "test/util/abstract/OpTest.sol";

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IInterpreterV2, Operand, SourceIndexV2, FullyQualifiedNamespace} from "src/interface/unstable/IInterpreterV2.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {IMetaV1} from "rain.metadata/IMetaV1.sol";
import {IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibEncodedDispatch} from "src/lib/caller/LibEncodedDispatch.sol";
import {LibContext} from "src/lib/caller/LibContext.sol";
import {SignedContextV1} from "src/interface/IInterpreterCallerV2.sol";
import {LibOpBlockNumberNP} from "src/lib/op/evm/LibOpBlockNumberNP.sol";

/// @title LibOpBlockNumberNPTest
/// @notice Test the runtime and integrity time logic of LibOpBlockNumberNP.
contract LibOpBlockNumberNPTest is OpTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpBlockNumberNP.
    function testOpBlockNumberNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpBlockNumberNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpBlockNumberNP. This tests that the
    /// opcode correctly pushes the block number onto the stack.
    function testOpBlockNumberNPRun(uint256 blockNumber) external {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        vm.roll(blockNumber);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state, operand, LibOpBlockNumberNP.referenceFn, LibOpBlockNumberNP.integrity, LibOpBlockNumberNP.run, inputs
        );
    }

    /// Test the eval of a block number opcode parsed from a string.
    function testOpBlockNumberNPEval(uint256 blockNumber) public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: block-number();");
        (IInterpreterV2 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression, bytes memory io) =
            iDeployer.deployExpression2(bytecode, constants);

        vm.roll(blockNumber);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval2(
            storeDeployer,
            FullyQualifiedNamespace.wrap(0),
            LibEncodedDispatch.encode2(expression, SourceIndexV2.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
            new uint256[](0)
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], blockNumber);
        assertEq(kvs.length, 0);
        assertEq(io, hex"0001");
    }

    /// Test that a block number with inputs fails integrity check.
    function testOpBlockNumberNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iParser.parse("_: block-number(0x00);");
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.deployExpression2(bytecode, constants);
    }
}
