// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";

contract LibOpSetNPTest is OpTest {
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
        opReferenceCheck(
            state,
            operand,
            LibOpSetNP.referenceFn,
            LibOpSetNP.integrity,
            LibOpSetNP.run,
            inputs,
            // kv modifies the state.
            true
        );
    }

    /// Test the eval of `set` opcode parsed from a string. Tests zero inputs.
    function testLibOpSetNPEvalZeroInputs() external {
        checkBadInputs(":set();", 0, 2, 0);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests one input.
    function testLibOpSetNPEvalOneInput() external {
        checkBadInputs(":set(0x1234);", 1, 2, 1);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests three inputs.
    function testLibOpSetNPEvalThreeInputs() external {
        checkBadInputs(":set(0x1234 0x5678 0x9abc);", 3, 2, 3);
    }
}
