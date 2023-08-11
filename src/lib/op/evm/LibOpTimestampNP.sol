// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpTimestampNP
/// Implementation of the EVM `TIMESTAMP` opcode as a standard Rainlang opcode.
library LibOpTimestampNP {
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
            mstore(stackTop, timestamp())
        }
        return stackTop;
    }

    function referenceFn(uint256[] memory) internal view returns (uint256[] memory) {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = block.timestamp;
        return outputs;
    }
}
