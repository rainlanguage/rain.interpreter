// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpBitwiseOrNP
/// @notice Opcode for computing bitwise OR from the top two items on the stack.
library LibOpBitwiseOrNP {
    /// The operand does nothing. Always 2 inputs and 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 2 inputs and 1 output.
        return (2, 1);
    }

    /// Bitwise OR the top two items on the stack.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Pointer stackTopAfter;
        assembly ("memory-safe") {
            stackTopAfter := add(stackTop, 0x20)
            mstore(stackTopAfter, or(mload(stackTop), mload(stackTopAfter)))
        }
        return stackTopAfter;
    }

    /// Reference implementation for bitwise OR.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(StackItem.unwrap(inputs[0]) | StackItem.unwrap(inputs[1]));
        return outputs;
    }
}
