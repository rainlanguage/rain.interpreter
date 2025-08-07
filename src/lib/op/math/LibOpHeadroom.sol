// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpHeadroom
/// @notice Opcode for the headroom (distance to ceil) of an decimal floating
/// point number.
library LibOpHeadroom {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be one input and one output.
        return (1, 1);
    }

    /// headroom
    /// decimal floating headroom of a number.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = LibDecimalFloat.FLOAT_ONE.sub(a.frac());

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of headroom for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory)
    {
        // The headroom is 1 - frac(x).
        Float a = Float.wrap(StackItem.unwrap(inputs[0]));
        Float headroom = LibDecimalFloat.FLOAT_ONE.sub(a.frac());

        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(headroom));
        return outputs;
    }
}
