// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpEqualTo
/// @notice Opcode to return 1 if the first item on the stack is equal to
/// the second item on the stack, else 0. Equality is defined as decimal float
/// equality, so 1.0 == 1 etc.
library LibOpEqualTo {
    using LibDecimalFloat for Float;

    /// `equal-to` integrity check. Requires exactly 2 inputs and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Float equality
    /// Float equality is 1 if the first item is equal to the second item,
    /// else 0. Equality is defined as decimal float equality.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float a;
        Float b;

        assembly ("memory-safe") {
            a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            b := mload(stackTop)
        }

        bool areEqual = a.eq(b);

        assembly ("memory-safe") {
            mstore(stackTop, areEqual)
        }

        return stackTop;
    }

    /// Gas intensive reference implementation of float equal for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        Float a = Float.wrap(StackItem.unwrap(inputs[0]));
        Float b = Float.wrap(StackItem.unwrap(inputs[1]));

        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(uint256(a.eq(b) ? 1 : 0)));
    }
}
