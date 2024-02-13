// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibMemoryKV, MemoryKV, MemoryKVVal, MemoryKVKey} from "rain.lib.memkv/lib/LibMemoryKV.sol";

import {OpTest} from "test/abstract/OpTest.sol";
import {LibOpSetNP} from "src/lib/op/store/LibOpSetNP.sol";
import {IntegrityCheckStateNP} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "src/lib/state/LibInterpreterStateNP.sol";
import {Operand} from "src/interface/unstable/IInterpreterV2.sol";

contract LibOpSetNPTest is OpTest {
    using LibMemoryKV for MemoryKV;

    /// Directly test the integrity logic of LibOpSetNP. The inputs are always
    /// 2 and the outputs are always 0.
    function testLibOpSetNPIntegrity(IntegrityCheckStateNP memory state, uint8 inputs) public {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpSetNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));
        assertEq(calcInputs, 2, "inputs");
        assertEq(calcOutputs, 0, "outputs");
    }

    /// Directly test the runtime logic of LibOpSetNP.
    function testLibOpSetNP(uint256 key, uint256 value) public {
        InterpreterStateNP memory state = opTestDefaultInterpreterState();
        Operand operand = Operand.wrap(uint256(2) << 0x10);
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = key;
        inputs[1] = value;
        state.stateKV = MemoryKV.wrap(0);

        uint256 calcOutputs = opReferenceCheckIntegrity(LibOpSetNP.integrity, operand, state.constants, inputs);
        ReferenceCheckPointers memory pointers = opReferenceCheckPointers(inputs, calcOutputs);
        assertEq(MemoryKV.unwrap(state.stateKV), 0);
        pointers.actualStackTopAfter = LibOpSetNP.run(state, operand, pointers.stackTop);

        (uint256 exists, MemoryKVVal actualValue) = state.stateKV.get(MemoryKVKey.wrap(key));
        assertEq(exists, 1, "exists");
        assertEq(MemoryKVVal.unwrap(actualValue), value, "value");

        uint256[] memory kvs = state.stateKV.toUint256Array();
        assertEq(kvs.length, 2, "kvs.length");
        assertEq(kvs[0], key, "kvs[0]");
        assertEq(kvs[1], value, "kvs[1]");

        state.stateKV = MemoryKV.wrap(0);
        opReferenceCheckExpectations(state, operand, LibOpSetNP.referenceFn, pointers, inputs, calcOutputs);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests zero inputs.
    function testLibOpSetNPEvalZeroInputs() external {
        checkBadInputs(":set();", 0, 2, 0);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests two inputs.
    function testLibOpSetNPEvalTwoInputs() external {
        uint256[] memory expectedKVs = new uint256[](2);
        expectedKVs[0] = 0x1234;
        expectedKVs[1] = 0x5678;
        checkHappyKVs(":set(0x1234 0x5678);", expectedKVs, "0x1234 0x5678");

        expectedKVs[0] = 0;
        expectedKVs[1] = 0;
        checkHappyKVs(":set(0 0);", expectedKVs, "0 0");

        expectedKVs[0] = 0x1234;
        expectedKVs[1] = 0;
        checkHappyKVs(":set(0x1234 0);", expectedKVs, "0x1234 0");

        expectedKVs[0] = 0;
        expectedKVs[1] = 0x5678;
        checkHappyKVs(":set(0 0x5678);", expectedKVs, "0 0x5678");

        // Setting the same key twice should overwrite the value.
        expectedKVs[0] = 0x1234;
        expectedKVs[1] = 0x9abc;
        checkHappyKVs(":set(0x1234 0x5678),:set(0x1234 0x9abc);", expectedKVs, "0x1234 0x5678 0x9abc");
    }

    /// Test the eval of `set` opcode parsed from a string. Tests setting twice.
    function testLibOpSetNPEvalSetTwice() external {
        uint256[] memory expectedKVs = new uint256[](4);
        // The ordering of the expectedKVs is based on internal hashing not the
        // order of setting.
        expectedKVs[2] = 0x1234;
        expectedKVs[3] = 0x5678;
        expectedKVs[0] = 0x5678;
        expectedKVs[1] = 0x9abc;
        checkHappyKVs(":set(0x1234 0x5678),:set(0x5678 0x9abc);", expectedKVs, "0x1234 0x5678 0x5678 0x9abc");
    }

    /// Test the eval of `set` opcode parsed from a string. Tests one input.
    function testLibOpSetNPEvalOneInput() external {
        checkBadInputs(":set(0x1234);", 1, 2, 1);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests three inputs.
    function testLibOpSetNPEvalThreeInputs() external {
        checkBadInputs(":set(0x1234 0x5678 0x9abc);", 3, 2, 3);
    }

    /// Test the eval of `set` opcode parsed from a string.
    /// Tests that operands are disallowed.
    function testLibOpSetNPEvalOperandsDisallowed() external {
        checkDisallowedOperand(":set<0>(0x1234 0x5678);");
        checkDisallowedOperand(":set<1>(0x1234 0x5678);");
        checkDisallowedOperand(":set<2>(0x1234 0x5678);");
        checkDisallowedOperand(":set<3 1>(0x1234 0x5678);");
    }
}
