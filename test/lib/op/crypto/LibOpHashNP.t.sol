// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";

import "src/lib/op/crypto/LibOpHashNP.sol";
import "src/lib/caller/LibContext.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibUint256Array.sol";

/// @title LibOpHashNPTest
/// @notice Test the runtime and integrity time logic of LibOpHashNP.
contract LibOpHashNPTest is RainterpreterExpressionDeployerDeploymentTest {
    using LibInterpreterStateNP for InterpreterStateNP;
    using LibPointer for Pointer;
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpHashNP. This tests the happy
    /// path where the operand is valid.
    function testOpHashNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        Operand operand = Operand.wrap(uint256(inputs) << 0x10);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpHashNP.integrity(state, operand);

        assertEq(inputs, calcInputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpHashNP. This tests the unhappy
    /// path where the operand is invalid.
    function testOpHashNPIntegrityUnhappy(IntegrityCheckStateNP memory state, uint8 inputs, uint16 badOperand)
        external
    {
        // 0 is the only valid operand.
        vm.assume(badOperand != 0);
        Operand operand = Operand.wrap(uint256(inputs) << 0x10 | uint256(badOperand));
        vm.expectRevert(abi.encodeWithSelector(UnsupportedOperand.selector, state.opIndex, operand));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpHashNP.integrity(state, operand);
        (calcInputs);
        (calcOutputs);
    }

    /// Directly test the runtime logic of LibOpHashNP. This tests that a 0
    /// length hash is correctly calculated.
    function testOpHashNPRun0Inputs(InterpreterStateNP memory state, uint256 pre, uint256 post) external {
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

        // Hash doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();
        Pointer stackTopAfter = LibOpHashNP.run(state, Operand.wrap(0), stackTop);
        bytes32 stateFingerprintAfter = state.fingerprint();
        assertEq(stateFingerprintBefore, stateFingerprintAfter);

        // The stack should have been updated with a 0 length hash.
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // Check that the opcode didn't modify the stack beyond the first element.
        uint256 actualPost;
        bytes32 actualHash;
        uint256 actualPre;
        assembly {
            actualPost := mload(end)
            actualHash := mload(add(end, 0x20))
            actualPre := mload(add(end, 0x40))
        }

        assertEq(actualPost, post);
        assertEq(actualHash, keccak256(""));
        assertEq(actualPre, pre);
    }

    /// Directly test the runtime logic of LibOpHashNP. This tests that a list
    /// of inputs are hashed in the same way as hashing the packed abi encoding.
    function testOpHashNPRunManyInputs(
        InterpreterStateNP memory state,
        uint256 pre,
        uint256[] memory inputs,
        uint256 post
    ) external {
        // 0 length inputs is already tested in testOpHashNPRun0Inputs.
        vm.assume(inputs.length > 0);

        Pointer prePointer;
        Pointer postPointer;
        Pointer stackTop;
        Pointer expectedStackTopAfter;
        Pointer cursor;
        uint256 bytesLength = inputs.length * 0x20;
        assembly ("memory-safe") {
            cursor := mload(0x40)
            // allocate the bytes and pre/post.
            mstore(0x40, add(cursor, add(bytesLength, 0x40)))
            // store the post and move past it.
            mstore(cursor, post)
            postPointer := cursor
            cursor := add(cursor, 0x20)
        }
        // Copy all the inputs.
        LibMemCpy.unsafeCopyWordsTo(inputs.dataPointer(), cursor, inputs.length);
        assembly ("memory-safe") {
            // Set the stack top to the end of the inputs then move the cursor
            // over them.
            stackTop := cursor
            cursor := add(cursor, bytesLength)
            mstore(cursor, pre)
            prePointer := cursor
            // The expected stack top after is 1 word above the base of the
            // inputs being hashed.
            expectedStackTopAfter := sub(cursor, 0x20)
        }

        // Hash doesn't modify the state.
        Pointer stackTopAfter;
        {
            bytes32 stateFingerprintBefore = state.fingerprint();
            stackTopAfter = LibOpHashNP.run(state, Operand.wrap(uint256(inputs.length) << 0x10), stackTop);
            bytes32 stateFingerprintAfter = state.fingerprint();
            assertEq(stateFingerprintBefore, stateFingerprintAfter);
        }

        // The stack should have been updated with the hash of the inputs.
        assertEq(Pointer.unwrap(stackTopAfter), Pointer.unwrap(expectedStackTopAfter));

        // Check that the opcode didn't modify the stack beyond the inputs.
        uint256 actualPost;
        bytes32 actualHash;
        uint256 actualPre;
        assembly {
            actualPost := mload(postPointer)
            actualHash := mload(stackTopAfter)
            actualPre := mload(prePointer)
        }

        assertEq(actualPost, post);
        assertEq(actualHash, keccak256(abi.encodePacked(inputs)));
        assertEq(actualPre, pre);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 0 inputs.
    function testOpHashNPEval0Inputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: hash();");
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
        assertEq(stack.length, 1, "stack length");
        assertEq(stack[0], uint256(keccak256("")), "stack[0]");
        assertEq(kvs.length, 0, "kvs length");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 1 input.
    function testOpHashNPEval1Input() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: hash(0x1234567890abcdef);");
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
        assertEq(stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef)))));
        assertEq(kvs.length, 0);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are identical to each other.
    function testOpHashNPEval2Inputs() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("_: hash(0x1234567890abcdef 0x1234567890abcdef);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(
            stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0x1234567890abcdef))))
        );
        assertEq(kvs.length, 0);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are different from each other.
    function testOpHashNPEval2InputsDifferent() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("_: hash(0x1234567890abcdef 0xfedcba0987654321);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 2),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(
            stack[0], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(kvs.length, 0);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs and
    /// other stack items.
    function testOpHashNPEval2InputsOtherStack() external {
        (bytes memory bytecode, uint256[] memory constants) =
            iDeployer.parse("_ _ _: 5 hash(0x1234567890abcdef 0xfedcba0987654321) 9;");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 3;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 3),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 3);
        assertEq(stack[0], uint256(5));
        assertEq(
            stack[1], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(stack[2], uint256(9));
        assertEq(kvs.length, 0);
    }
}
