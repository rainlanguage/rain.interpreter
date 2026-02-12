// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/lib/LibIntOrAString.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpConditions
/// @notice Opcode to return the first nonzero item on the stack up to the inputs
/// limit.
library LibOpConditions {
    using LibIntOrAString for IntOrAString;
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
        inputs = inputs > 2 ? inputs : 2;
        return (inputs, 1);
    }

    /// `conditions`
    /// Pairwise list of conditions and values. The first nonzero condition
    /// evaluated puts its corresponding value on the stack. `conditions` is
    /// eagerly evaluated. If no condition is nonzero, the expression will
    /// revert. The number of inputs must be even. The number of outputs is 1.
    /// If an author wants to provide some default value, they can set the last
    /// condition to some nonzero constant value such as 1.
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            Float condition;
            IntOrAString reason = IntOrAString.wrap(0);
            uint256 inputs;
            bool oddInputs;
            Pointer cursor;
            Pointer end;
            assembly ("memory-safe") {
                inputs := and(shr(0x10, operand), 0x0F)
                oddInputs := mod(inputs, 2)
                cursor := stackTop
                end := add(cursor, mul(sub(inputs, oddInputs), 0x20))
                stackTop := sub(end, mul(iszero(oddInputs), 0x20))
                if oddInputs { reason := mload(end) }
            }
            bool conditionIsZero;
            while (Pointer.unwrap(cursor) < Pointer.unwrap(end)) {
                assembly ("memory-safe") {
                    condition := mload(cursor)
                }
                conditionIsZero = condition.isZero();
                if (!conditionIsZero) {
                    assembly ("memory-safe") {
                        mstore(stackTop, mload(add(cursor, 0x20)))
                    }
                    break;
                }

                cursor = Pointer.wrap(Pointer.unwrap(cursor) + 0x40);
            }

            if (conditionIsZero) {
                revert(reason.toString());
            }
            // require(condition > 0, reason.toString());
            return stackTop;
        }
    }

    /// Gas intensive reference implementation of `condition` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        // Unchecked so that any overflow errors come from the real
        // implementation.
        unchecked {
            uint256 length = inputs.length;
            outputs = new StackItem[](1);
            for (uint256 i = 0; i < length; i += 2) {
                if (!Float.wrap(StackItem.unwrap(inputs[i])).isZero()) {
                    outputs[0] = inputs[i + 1];
                    return outputs;
                }
            }
            if (inputs.length % 2 != 0) {
                IntOrAString reason = IntOrAString.wrap(uint256(StackItem.unwrap(inputs[length - 1])));
                require(false, reason.toString());
            } else {
                require(false, "");
            }
        }
    }
}
