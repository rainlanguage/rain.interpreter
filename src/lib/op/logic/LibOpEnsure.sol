// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/lib/LibIntOrAString.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpEnsure
/// @notice Opcode to revert if the condition is zero.
library LibOpEnsure {
    using LibDecimalFloat for Float;
    using LibIntOrAString for IntOrAString;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be exactly 2 inputs.
        return (2, 0);
    }

    /// `ensure`
    /// If the condition is zero, the expression will revert with the given
    /// string.
    /// All conditions are eagerly evaluated and there are no outputs.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float condition;
        IntOrAString reason;
        assembly ("memory-safe") {
            condition := mload(stackTop)
            reason := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }

        if (condition.isZero()) {
            revert(reason.toString());
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of `ensure` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        require(
            !Float.wrap(StackItem.unwrap(inputs[0])).isZero(),
            IntOrAString.wrap(uint256(StackItem.unwrap(inputs[1]))).toString()
        );
        outputs = new StackItem[](0);
    }
}
