// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import "src/lib/state/LibInterpreterStateNP.sol";
import "src/lib/integrity/LibIntegrityCheckNP.sol";
import "src/lib/caller/LibContext.sol";

import "src/lib/op/evm/LibOpBlockNumberNP.sol";

/// @title LibOpBlockNumberNPTest
/// @notice Test the runtime and integrity time logic of LibOpBlockNumberNP.
contract LibOpBlockNumberNPTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpBlockNumberNP.
    function testOpBlockNumberNPIntegrity(IntegrityCheckStateNP memory state, Operand operand) external {
        (uint256 inputs, uint256 outputs) = LibOpBlockNumberNP.integrity(state, operand);

        assertEq(inputs, 0);
        assertEq(outputs, 1);
    }

    /// Directly test the runtime logic of LibOpBlockNumber. This tests that the
    /// opcode correctly pushes the block number onto the stack.
    function testOpBlockNumberNPRun(
        InterpreterStateNP memory state,
        Operand operand,
        uint256 pre,
        uint256 post,
        uint256 blockNumber
    ) external {
        vm.roll(blockNumber);
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

        // Block number doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpBlockNumberNP.run(state, operand, stackTop);

        // Check that the opcode didn't modify the state.
        assertEq(state.fingerprint(), stateFingerprintBefore);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // The block number should be on the stack without modifying any other
        // data.
        uint256 actualPost;
        uint256 actualBlockNumber;
        uint256 actualPre;
        assembly ("memory-safe") {
            actualPost := mload(end)
            actualBlockNumber := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, post);
        assertEq(actualBlockNumber, blockNumber);
        assertEq(actualPre, pre);
    }

    /// Test the eval of a block number opcode parsed from a string.
    function testOpBlockNumberNPEval(uint256 blockNumber) public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-number();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        // @todo support fuzzing all block numbers.
        // Seems to be a bug in foundry, perhaps fixed in newer versions.
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
}
