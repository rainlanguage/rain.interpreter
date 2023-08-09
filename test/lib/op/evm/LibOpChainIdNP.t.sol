// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
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
contract LibOpChainIdNPTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpChainIdNP.
    function testOpChainIDNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 inputs, uint256 outputs) = LibOpChainIdNP.integrity(state, operand);

        assertEq(inputs, 0);
        assertEq(outputs, 1);
    }

    /// Directly test the runtime logic of LibOpChainId. This tests that the
    /// opcode correctly pushes the chain ID onto the stack.
    function testOpChainIDNPRun(
        InterpreterStateNP memory state,
        Operand operand,
        uint256 pre,
        uint256 post,
        uint64 chainId
    ) external {
        vm.chainId(chainId);
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        Pointer stackBottom;
        Pointer stackTop;
        Pointer expectedStackTopAfter;
        Pointer end;
        assembly ("memory-safe") {
            end := mload(0x40)
            mstore(end, post)
            expectedStackTopAfter := add(end, 0x20)
            mstore(expectedStackTopAfter, 0)
            stackTop := add(expectedStackTopAfter, 0x20)
            mstore(stackTop, pre)
            stackBottom := add(stackTop, 0x20)
            mstore(0x40, stackBottom)
        }

        // Chain ID doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpChainIdNP.run(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // The chain ID should be on the stack without modifying any other data.
        uint256 actualPost;
        uint256 actualChainId;
        uint256 actualPre;
        assembly ("memory-safe") {
            actualPost := mload(end)
            actualChainId := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, post);
        assertEq(actualChainId, chainId);
        assertEq(actualPre, pre);
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
}
