// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpMinPositiveValue
/// Exposes the minimum positive representable float value as a Rainlang opcode.
library LibOpMinPositiveValue {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float value = LibDecimalFloat.FLOAT_MIN_POSITIVE_VALUE;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)
        internal
        pure
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, type(int32).min)));
        return outputs;
    }
}
