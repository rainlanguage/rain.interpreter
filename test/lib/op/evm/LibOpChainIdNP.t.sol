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
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;

    // /// Directly test the integrity logic of LibOpChainId.
    // function testOpChainIDNPIntegrity(Operand operand) external {
    //     function(IntegrityCheckState memory, Operand, Pointer)
    //     view
    //     returns (Pointer)[] memory integrityCheckers =
    //             new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
    //     integrityCheckers[0] = LibOpChainId.integrity;

    //     IntegrityCheckState memory state =
    //         LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
    //     Pointer stackTop = state.stackBottom;

    //     Pointer stackTopAfter = LibOpChainIdNP.integrity(state, operand, stackTop);

    //     assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
    //     assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
    //     assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
    //     assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    // }

    // /// Directly test the runtime logic of LibOpChainId. This tests that the
    // /// opcode correctly pushes the chain ID onto the stack.
    // function testOpChainIDNPRun(InterpreterState memory state, Operand operand, uint256 pre, uint256 post, uint64 chainId)
    //     external
    // {
    //     vm.chainId(chainId);
    //     // Build a stack with two zeros on it. The first zero will be overridden
    //     // by the opcode. The second zero will be used to check that the opcode
    //     // doesn't modify the stack beyond the first element.
    //     state.stackBottom = LibPointer.allocatedMemoryPointer();
    //     Pointer stackTop = state.stackBottom.unsafePush(pre);
    //     Pointer end = stackTop.unsafePush(0).unsafePush(post);
    //     assembly ("memory-safe") {
    //         mstore(0x40, end)
    //     }

    //     // Chain ID doesn't modify the state.
    //     bytes32 stateFingerprintBefore = state.fingerprint();

    //     // Run the opcode.
    //     Pointer stackTopAfter = LibOpChainIdNP.run(state, operand, stackTop);

    //     // Check that the opcode didn't modify the state.
    //     assertEq(state.fingerprint(), stateFingerprintBefore);

    //     // The chain ID should be on the stack without modifying any other data.
    //     assertEq(state.stackBottom.unsafeReadWord(), pre);
    //     assertEq(stackTop.unsafeReadWord(), chainId);
    //     assertEq(stackTopAfter.unsafeReadWord(), post);
    // }

    /// Test the eval of a chain ID opcode parsed from a string.
    function testOpChainIDNPEval(uint64 chainId, StateNamespace namespace) public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: chain-id();");
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // chain id
            hex"03000000"
        );

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
