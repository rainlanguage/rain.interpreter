// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpBitwiseAnd
/// @notice Opcode for computing bitwise AND from the top two items on the stack.
library LibOpBitwiseAnd {
    /// The operand does nothing. Always 2 inputs and 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 2 inputs and 1 output.
        return (2, 1);
    }

    /// Bitwise AND the top two items on the stack.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Pointer stackTopAfter;
        assembly ("memory-safe") {
            stackTopAfter := add(stackTop, 0x20)
            mstore(stackTopAfter, and(mload(stackTop), mload(stackTopAfter)))
        }
        return stackTopAfter;
    }

    /// Reference implementation for bitwise AND.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(StackItem.unwrap(inputs[0]) & StackItem.unwrap(inputs[1]));
        return outputs;
    }
}
