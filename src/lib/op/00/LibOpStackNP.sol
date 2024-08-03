// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";

/// Thrown when a stack read index is outside the current stack top.
error OutOfBoundsStackRead(uint256 opIndex, uint256 stackTopIndex, uint256 stackRead);

/// @title LibOpStackNP
/// Implementation of copying a stack item from the stack to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpStackNP {
    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal pure returns (uint256, uint256) {
        uint256 readIndex = Operand.unwrap(operand) & 0xFFFF;
        // Operand is the index so ensure it doesn't exceed the stack index.
        if (readIndex >= state.stackIndex) {
            revert OutOfBoundsStackRead(state.opIndex, state.stackIndex, readIndex);
        }

        // Move the read highwater if needed.
        if (readIndex > state.readHighwater) {
            state.readHighwater = readIndex;
        }

        return (0, 1);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 sourceIndex = state.sourceIndex;
        assembly ("memory-safe") {
            let stackBottom := mload(add(mload(state), mul(0x20, add(sourceIndex, 1))))
            let stackValue := mload(sub(stackBottom, mul(0x20, add(and(operand, 0xFFFF), 1))))
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, stackValue)
        }
        return stackTop;
    }
}
