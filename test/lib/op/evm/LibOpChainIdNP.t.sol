// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import "test/util/lib/etch/LibEtch.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import "src/lib/state/LibInterpreterStateNP.sol";
import "src/lib/op/evm/LibOpChainIdNP.sol";
import "src/lib/caller/LibContext.sol";

import "src/concrete/RainterpreterNP.sol";
import "src/concrete/RainterpreterStore.sol";
import "src/concrete/RainterpreterExpressionDeployerNP.sol";

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
    function testOpChainIdNPRun(InterpreterStateNP memory state, uint64 chainId) external {
        vm.chainId(chainId);
        uint256[] memory inputs = new uint256[](0);
        Operand operand = Operand.wrap(0);
        opReferenceCheck(
            state, operand, LibOpChainIdNP.referenceFn, LibOpChainIdNP.integrity, LibOpChainIdNP.run, inputs
        );
    }

    /// Test the eval of a chain ID opcode parsed from a string.
    function testOpChainIDNPEval(uint64 chainId, StateNamespace namespace) public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: chain-id();");

        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        vm.chainId(chainId);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            namespace,
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], chainId, "stack item");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test that a chain ID with inputs fails integrity check.
    function testOpChainIdNPEvalFail() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: chain-id(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}
