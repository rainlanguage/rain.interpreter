// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

import "src/lib/caller/LibContext.sol";

/// @title LibOpMaxUint256NPTest
/// @notice Test the runtime and integrity time logic of LibOpMaxUint256NP.
contract LibOpMaxUint256NPTest is OpTest {
    using LibInterpreterStateNP for InterpreterStateNP;

    /// Directly test the integrity logic of LibOpMaxUint256NP.
    function testOpMaxUint256NPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpMaxUint256NP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpMaxUint256NP. This tests that the
    /// opcode correctly pushes the max uint256 onto the stack.
    function testOpMaxUint256NPRun(InterpreterStateNP memory state, Operand operand, uint256 pre, uint256 post)
        external
    {
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

        // Max uint256 doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();
        Pointer stackTopAfter = LibOpMaxUint256NP.run(state, operand, stackTop);
        bytes32 stateFingerprintAfter = state.fingerprint();
        assertEq(stateFingerprintBefore, stateFingerprintAfter);

        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // Check that the opcode didn't modify the stack beyond the first element.
        uint256 actualPost;
        uint256 actualMaxUint256;
        uint256 actualPre;
        assembly {
            actualPost := mload(end)
            actualMaxUint256 := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, post);
        assertEq(actualMaxUint256, type(uint256).max);
        assertEq(actualPre, pre);
    }

    /// Test the eval of LibOpMaxUint256NP parsed from a string.
    function testOpMaxUint256NPEval(StateNamespace namespace) external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: max-uint-256();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);

        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            namespace,
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], type(uint256).max);
        assertEq(kvs.length, 0);
    }
}
