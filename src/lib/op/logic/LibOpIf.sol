// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpIf
/// @notice Opcode to choose between two values based on a condition. If is
/// eager, meaning both values are evaluated before the condition is checked.
library LibOpIf {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (3, 1);
    }

    /// IF
    /// IF is a conditional. If the first item on the stack is nonero, the second
    /// item is returned, else the third item is returned.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float condition;
        assembly ("memory-safe") {
            condition := mload(stackTop)
            stackTop := add(stackTop, 0x40)
        }

        bool isZero = condition.isZero();

        assembly ("memory-safe") {
            mstore(stackTop, mload(sub(stackTop, mul(0x20, iszero(isZero)))))
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of IF for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        outputs = new StackItem[](1);
        outputs[0] = Float.wrap(StackItem.unwrap(inputs[0])).isZero() ? inputs[2] : inputs[1];
    }
}
