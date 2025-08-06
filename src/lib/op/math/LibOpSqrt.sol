// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpSqrt
/// @notice Opcode for the square root of a decimal floating point number.
library LibOpSqrt {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be one inputs and one output.
        return (1, 1);
    }

    /// sqrt
    /// decimal floating point square root of a number.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        Float a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = a.sqrt(LibDecimalFloat.LOG_TABLES_ADDRESS);

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of sqrt for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        Float a = Float.wrap(StackItem.unwrap(inputs[0]));
        a = a.sqrt(LibDecimalFloat.LOG_TABLES_ADDRESS);

        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(a));
        return outputs;
    }
}
