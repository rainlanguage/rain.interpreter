// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpIsZero
/// @notice Opcode to return 1 if the top item on the stack is zero, else 0.
library LibOpIsZero {
    using LibDecimalFloat for Float;

    /// `is-zero` integrity check. Requires exactly 1 input and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (1, 1);
    }

    /// ISZERO
    /// ISZERO is 1 if the top item is zero, else 0.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        bool isZero = a.isZero();
        assembly ("memory-safe") {
            mstore(stackTop, isZero)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of ISZERO for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(Float.wrap(StackItem.unwrap(inputs[0])).isZero() ? uint256(1) : 0));
    }
}
