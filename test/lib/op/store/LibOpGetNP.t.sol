// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

contract LibOpGetNPTest is OpTest {
    using LibMemoryKV for MemoryKV;

    /// Directly test the integrity logic of LibOpGetNP. The inputs are always
    /// 1 and the outputs are always 1.
    function testLibOpGetNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) public {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpGetNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));
        assertEq(calcInputs, 1, "inputs");
        assertEq(calcOutputs, 1, "outputs");
    }

    /// Test the eval of `get` opcode parsed from a string. Tests zero inputs.
    function testLibOpGetNPEvalZeroInputs() external {
        checkBadInputs("_:get();", 0, 1, 0);
    }

    /// Test the eval of `get` opcode parsed from a string. Tests that if
    /// the key is not set in the store, the value is 0.
    function testLibOpGetNPEvalKeyNotSet() external {
        uint256[] memory stack;
        uint256[] memory kvs;
        (stack, kvs) = parseAndEval("_:get(0x1234);");
        assertEq(stack.length, 1, "stack.length");
        assertEq(stack[0], 0, "stack[0]");
        assertEq(kvs.length, 2, "kvs.length");
        assertEq(kvs[0], 0x1234, "kvs[0]");
        assertEq(kvs[1], 0, "kvs[1]");

        (stack, kvs) = parseAndEval("_:get(0x1234),_:get(0x1234);");
        assertEq(stack.length, 2, "stack.length");
        assertEq(stack[0], 0, "stack[0]");
        assertEq(stack[1], 0, "stack[1]");
        assertEq(kvs.length, 2, "kvs.length");
        assertEq(kvs[0], 0x1234, "kvs[0]");
        assertEq(kvs[1], 0, "kvs[1]");

        (stack, kvs) = parseAndEval("_:get(0x1234),_:get(0x5678);");
        assertEq(stack.length, 2, "stack.length");
        assertEq(stack[0], 0, "stack[0]");
        assertEq(stack[1], 0, "stack[1]");
        assertEq(kvs.length, 4, "kvs.length");
        assertEq(kvs[2], 0x1234, "kvs[0]");
        assertEq(kvs[3], 0, "kvs[1]");
        assertEq(kvs[0], 0x5678, "kvs[2]");
        assertEq(kvs[1], 0, "kvs[3]");

        (stack, kvs) = parseAndEval("_:get(0x5678);");
        assertEq(stack.length, 1, "stack.length");
        assertEq(stack[0], 0, "stack[0]");
        assertEq(kvs.length, 2, "kvs.length");
        assertEq(kvs[0], 0x5678, "kvs[0]");
        assertEq(kvs[1], 0, "kvs[1]");

        (stack, kvs) = parseAndEval("_:get(0);");
        assertEq(stack.length, 1, "stack.length");
        assertEq(stack[0], 0, "stack[0]");
        assertEq(kvs.length, 2, "kvs.length");
        assertEq(kvs[0], 0, "kvs[0]");
        assertEq(kvs[1], 0, "kvs[1]");

        (stack, kvs) = parseAndEval("_:get(max-int-value());");
        assertEq(stack.length, 1, "stack.length");
        assertEq(stack[0], 0, "stack[0]");
        assertEq(kvs.length, 2, "kvs.length");
        assertEq(kvs[0], type(uint256).max, "kvs[0]");
        assertEq(kvs[1], 0, "kvs[1]");
    }

    /// Test the eval of `get` opcode parsed from a string. Tests two inputs.
    function testLibOpGetNPEvalTwoInputs() external {
        checkBadInputs("_:get(0x1234 0x5678);", 2, 1, 2);
    }

    /// Test the eval of `get` opcode parsed from a string. Tests three inputs.
    function testLibOpGetNPEvalThreeInputs() external {
        checkBadInputs("_:get(0x1234 0x5678 0x9abc);", 3, 1, 3);
    }

    /// Test the eval of `get` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testLibOpGetNPEvalOperandDisallowed() external {
        checkDisallowedOperand("_:get<>(0x1234);", 5);
        checkDisallowedOperand("_:get<0>(0x1234);", 5);
        checkDisallowedOperand("_:get<1>(0x1234);", 5);
        checkDisallowedOperand("_:get<2>(0x1234);", 5);
        checkDisallowedOperand("_:get<3 1>(0x1234);", 5);
    }
}