// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "../../../interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {UnsupportedBitwiseShiftAmount} from "../../../error/ErrBitwise.sol";

/// @title LibOpShiftBitsRightNP
/// @notice Opcode for shifting bits right. The shift amount is taken from the
/// operand so it is compile time constant.
library LibOpShiftBitsRightNP {
    /// Shift bits right by the amount specified in the operand.
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        uint256 shiftAmount = Operand.unwrap(operand) & 0xFFFF;

        if (
            // Shift amount must not result in the output always being 0.
            shiftAmount > type(uint8).max
            // Shift amount must not result in a noop.
            || shiftAmount == 0
        ) {
            revert UnsupportedBitwiseShiftAmount(shiftAmount);
        }

        // Always 1 input and 1 output.
        return (1, 1);
    }

    /// Shift bits right by the amount specified in the operand.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(stackTop, shr(and(operand, 0xFF), mload(stackTop)))
        }
        return stackTop;
    }

    /// Reference implementation for shifting bits right.
    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256 shiftAmount = Operand.unwrap(operand) & 0xFFFF;
        inputs[0] = inputs[0] >> shiftAmount;
        return inputs;
    }
}
