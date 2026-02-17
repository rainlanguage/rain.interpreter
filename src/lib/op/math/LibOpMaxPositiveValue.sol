// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpMaxPositiveValue
/// Exposes the maximum representable float value as a Rainlang opcode.
library LibOpMaxPositiveValue {
    using LibDecimalFloat for Float;

    /// `max-positive-value` integrity check. Requires 0 inputs and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    /// `max-positive-value` opcode. Pushes the maximum representable positive float onto the stack.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float value = LibDecimalFloat.FLOAT_MAX_POSITIVE_VALUE;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    /// Reference implementation of `max-positive-value` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)
        internal
        pure
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(type(int224).max, type(int32).max)));
        return outputs;
    }
}
