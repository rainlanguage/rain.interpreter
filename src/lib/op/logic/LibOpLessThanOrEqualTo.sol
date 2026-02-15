// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpLessThanOrEqualTo
/// @notice Opcode to return 1 if the first item on the stack is less than or
/// equal to the second item on the stack, else 0.
library LibOpLessThanOrEqualTo {
    /// `less-than-or-equal-to` integrity check. Requires exactly 2 inputs and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// LTE
    /// LTE is 1 if the first item is less than or equal to the second item,
    /// else 0.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float a;
        Float b;
        assembly ("memory-safe") {
            a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            b := mload(stackTop)
        }
        bool lessThanOrEqual = LibDecimalFloat.lte(a, b);
        assembly ("memory-safe") {
            mstore(stackTop, lessThanOrEqual)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of LTE for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        Float a = Float.wrap(StackItem.unwrap(inputs[0]));
        Float b = Float.wrap(StackItem.unwrap(inputs[1]));
        bool lessThanOrEqual = LibDecimalFloat.lte(a, b);
        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(uint256(lessThanOrEqual ? 1 : 0)));
    }
}
