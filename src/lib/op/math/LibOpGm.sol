// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {LibDecimalFloat, Float} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpGm
/// @notice Opcode for the geometric average of two decimal floating point
/// numbers.
library LibOpGm {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be two inputs and one output.
        return (2, 1);
    }

    /// gm
    /// decimal floating point geometric average of two numbers.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        Float a;
        Float b;
        assembly ("memory-safe") {
            a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            b := mload(stackTop)
        }
        a = a.mul(b).pow(LibDecimalFloat.FLOAT_HALF, LibDecimalFloat.LOG_TABLES_ADDRESS);

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of gm for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        // The geometric mean is sqrt(a * b).
        Float a = Float.wrap(StackItem.unwrap(inputs[0]));
        Float b = Float.wrap(StackItem.unwrap(inputs[1]));
        a = a.mul(b).pow(LibDecimalFloat.FLOAT_HALF, LibDecimalFloat.LOG_TABLES_ADDRESS);
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(a));
        return outputs;
    }
}
