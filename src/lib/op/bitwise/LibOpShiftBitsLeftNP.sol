// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {UnsupportedBitwiseShiftAmount} from "../../../error/ErrBitwise.sol";

/// @title LibOpShiftBitsLeftNP
/// @notice Opcode for shifting bits left. The shift amount is taken from the
/// operand so it is compile time constant.
library LibOpShiftBitsLeftNP {
    /// Shift bits left by the amount specified in the operand.
    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        uint256 shiftAmount = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));

        if (
            // Shift amount must not result in the output always being 0.
            shiftAmount > uint256(type(uint8).max)
            // Shift amount must not result in a noop.
            || shiftAmount == 0
        ) {
            revert UnsupportedBitwiseShiftAmount(shiftAmount);
        }

        // Always 1 input and 1 output.
        return (1, 1);
    }

    /// Shift bits left by the amount specified in the operand.
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(stackTop, shl(and(operand, 0xFF), mload(stackTop)))
        }
        return stackTop;
    }

    /// Reference implementation for shifting bits left.
    function referenceFn(InterpreterState memory, OperandV2 operand, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory)
    {
        uint256 shiftAmount = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));
        inputs[0] = StackItem.wrap(bytes32(uint256(StackItem.unwrap(inputs[0])) << shiftAmount));
        return inputs;
    }
}
