// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpBlockNumberNP
/// Implementation of the EVM `BLOCKNUMBER` opcode as a standard Rainlang opcode.
library LibOpBlockNumberNP {
    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal pure returns (uint256, uint256) {
        // Operand body must be zero.
        if (uint16(Operand.unwrap(operand)) != 0) {
            revert UnsupportedOperand(state.opIndex, operand);
        }
        return (0, 1);
    }

    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal view returns (Pointer) {
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, number())
        }
        return stackTop;
    }
}
