// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibStackPointer.sol";
import "rain.metadata/IMetaV1.sol";

import "src/lib/state/LibInterpreterStateNP.sol";
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

    /// Directly test the integrity logic of LibOpTimestampNP. This tests the
    /// unhappy path where the operand is invalid.
    function testOpTimestampNPIntegrityUnhappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 badOp)
        external
    {
        checkUnsupportedNonZeroOperandBody(state, inputs, badOp);
    }

    /// Directly test the runtime logic of LibOpTimestamp. This tests that the
    /// opcode correctly pushes the timestamp onto the stack.
    function testOpTimestampNPRun(
        InterpreterStateNP memory state,
        Operand operand,
        uint256 pre,
        uint256 post,
        uint256 blockTimestamp
    ) external {
        vm.warp(blockTimestamp);
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

        // Timestamp doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();
        Pointer stackTopAfter = LibOpTimestampNP.run(state, operand, stackTop);
        bytes32 stateFingerprintAfter = state.fingerprint();
        assertEq(stateFingerprintBefore, stateFingerprintAfter);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // Check that the opcode didn't modify the stack beyond the first element.
        uint256 actualPost;
        uint256 actualTimestamp;
        uint256 actualPre;
        assembly {
            actualPost := mload(end)
            actualTimestamp := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, post);
        assertEq(actualTimestamp, blockTimestamp);
        assertEq(actualPre, pre);
    }

    /// Test the eval of a timestamp opcode parsed from a string.
    function testOpTimestampNPEval(uint256 blockTimestamp) external {
        vm.warp(blockTimestamp);
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: block-timestamp();");
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
        assertEq(stack[0], blockTimestamp);
        assertEq(kvs.length, 0);
    }
}
