// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import "src/lib/state/LibInterpreterStateNP.sol";
import "src/lib/integrity/LibIntegrityCheckNP.sol";
import "src/lib/caller/LibContext.sol";

import "src/lib/op/evm/LibOpBlockNumberNP.sol";

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
    function testOpBlockNumberNPRun(InterpreterStateNP memory state, uint256 seed, uint256 blockNumber) external {
        vm.roll(blockNumber);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state,
            seed,
            operand,
            LibOpBlockNumberNP.referenceFn,
            LibOpBlockNumberNP.integrity,
            LibOpBlockNumberNP.run,
            inputs
        );
    }

    /// Test the eval of a block number opcode parsed from a string.
    function testOpBlockNumberNPEval(uint256 blockNumber) public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-number();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        vm.roll(blockNumber);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], blockNumber);
        assertEq(kvs.length, 0);
    }

    /// Test that a block number with inputs fails integrity check.
    function testOpBlockNumberNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-number(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
