// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import "test/util/lib/etch/LibEtch.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import "src/lib/state/deprecated/LibInterpreterState.sol";
import "src/lib/op/evm/deprecated/LibOpChainId.sol";
import "src/lib/caller/LibContext.sol";

import "src/concrete/RainterpreterStore.sol";
import "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title LibOpChainIdTest
/// @notice Test the runtime and integrity time logic of LibOpChainId.
contract LibOpChainIdTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpChainId.
    function testOpChainIDIntegrity(Operand operand) external {
        function(IntegrityCheckState memory, Operand, Pointer)
        view
        returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpChainId.integrity;

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpChainId.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the runtime logic of LibOpChainId. This tests that the
    /// opcode correctly pushes the chain ID onto the stack.
    function testOpChainIDRun(Operand operand, uint256 pre, uint256 post, uint64 chainId)
        external
    {
        InterpreterState memory state;
        vm.chainId(chainId);
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }

        // Chain ID doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpChainId.run(state, operand, stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // The chain ID should be on the stack without modifying any other data.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), chainId);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }
}
