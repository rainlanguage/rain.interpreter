// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "../../../../lib/rain.solmem/src/lib/LibPointer.sol";
import "../../../../lib/rain.solmem/src/lib/LibStackPointer.sol";
import "../../../../lib/rain.metadata/src/IMetaV1.sol";

import "../../../../src/lib/state/LibInterpreterState.sol";
import "../../../../src/lib/integrity/LibIntegrityCheck.sol";
import "../../../../src/lib/caller/LibContext.sol";

import "../../../../src/lib/op/evm/LibOpTimestamp.sol";

/// @title LibOpTimestampTest
/// @notice Test the runtime and integrity time logic of LibOpTimestamp.
contract LibOpTimestampTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpTimestamp.
    function testOpTimestampIntegrity(Operand operand) external {
        function(IntegrityCheckState memory, Operand, Pointer)
        view
        returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpTimestamp.integrity;

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpTimestamp.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the runtime logic of LibOpTimestamp. This tests that the
    /// opcode correctly pushes the timestamp onto the stack.
    function testOpTimestampRun(
        InterpreterState memory state,
        Operand operand,
        uint256 pre,
        uint256 post,
        uint256 blockTimestamp
    ) external {
        vm.warp(blockTimestamp);
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }

        // Timestamp doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpTimestamp.run(state, operand, stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // Check that the opcode pushed the correct value onto the stack without
        // modifying the stack beyond the first element.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), blockTimestamp);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }

    /// Test the eval of a timestamp opcode parsed from a string.
    function testOpTimestampEval(uint256 blockTimestamp) external {
        vm.warp(blockTimestamp);
        (bytes[] memory sources, uint256[] memory constants) = iDeployer.parse("_: block-timestamp();");
        uint8[] memory minOutputs = new uint8[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(sources, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], blockTimestamp);
        assertEq(kvs.length, 0);
    }
}
