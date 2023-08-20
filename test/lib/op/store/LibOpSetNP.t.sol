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
    function testLibOpSetNP(InterpreterStateNP memory state, uint8 inputs) public {
        // todo
    }

    /// Test the eval of `set` opcode parsed from a string. Tests zero inputs.
    function testLibOpSetNPEvalZeroInputs() external {
        checkBadInputs(":set();", 0, 2, 0);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests two inputs.
    function testLibOpSetNPEvalTwoInputs() external {
        checkBadInputs(":set(0x1234 0x5678);", 2, 2, 0);
    }

    /// Test the eval of `set` opcode parsed from a string. Tests three inputs.
    function testLibOpSetNPEvalThreeInputs() external {
        checkBadInputs(":set(0x1234 0x5678 0x9abc);", 3, 2, 0);
    }
}
