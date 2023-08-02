// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import "src/lib/state/LibInterpreterState.sol";
import "src/lib/integrity/LibIntegrityCheck.sol";
import "src/lib/caller/LibContext.sol";

import "src/lib/op/evm/LibOpBlockNumber.sol";

/// @title LibOpBlockNumberTest
/// @notice Test the runtime and integrity time logic of LibOpBlockNumber.
contract LibOpBlockNumberTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpBlockNumber.
    function testOpBlockNumberIntegrity(Operand operand) external {
        function(IntegrityCheckState memory, Operand, Pointer)
        view
        returns (Pointer)[] memory integrityCheckers =
                new function(IntegrityCheckState memory, Operand, Pointer) view returns (Pointer)[](1);
        integrityCheckers[0] = LibOpBlockNumber.integrity;

        IntegrityCheckState memory state =
            LibIntegrityCheck.newState(new bytes[](0), new uint256[](0), integrityCheckers);
        Pointer stackTop = state.stackBottom;

        Pointer stackTopAfter = LibOpBlockNumber.integrity(state, operand, stackTop);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(stackTop.unsafeAddWord()));
        assertEq(Pointer.unwrap(state.stackBottom), Pointer.unwrap(stackTop));
        assertEq(Pointer.unwrap(state.stackHighwater), Pointer.unwrap(INITIAL_STACK_HIGHWATER));
        assertEq(Pointer.unwrap(state.stackMaxTop), Pointer.unwrap(stackTopAfter));
    }

    /// Directly test the runtime logic of LibOpBlockNumber. This tests that the
    /// opcode correctly pushes the block number onto the stack.
    function testOpBlockNumberRun(
        InterpreterState memory state,
        Operand operand,
        uint256 pre,
        uint256 post,
        uint256 blockNumber
    ) external {
        vm.roll(blockNumber);
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }

        // Block number doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpBlockNumber.run(state, operand, stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        // The block number should be on the stack without modifying any other
        // data.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), blockNumber);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }

    /// Test the eval of a block number opcode parsed from a string.
    function testOpBlockNumberEval(uint256 blockNumber) external {
        vm.roll(blockNumber);
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-number();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
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
}
