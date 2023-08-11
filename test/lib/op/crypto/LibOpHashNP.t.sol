// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

import "src/lib/op/crypto/LibOpHashNP.sol";
import "src/lib/caller/LibContext.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibMemCpy.sol";
import "rain.solmem/lib/LibUint256Array.sol";

/// @title LibOpHashNPTest
/// @notice Test the runtime and integrity time logic of LibOpHashNP.
contract LibOpHashNPTest is OpTest {
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

    /// Directly test the runtime logic of LibOpHashNP.
    function testOpHashNPRun(InterpreterStateNP memory state, uint256 seed, uint256[] memory inputs) external {
        Operand operand = Operand.wrap(uint256(inputs.length) << 0x10);
        opReferenceCheck(state, seed, operand, LibOpHashNP.referenceFn, LibOpHashNP.integrity, LibOpHashNP.run, inputs);
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
