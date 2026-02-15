// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheck.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpExponentialGrowth
/// @notice Exponential growth is base(1 + rate)^t where base is the initial
/// value, rate is the growth rate, and t is time.
library LibOpExponentialGrowth {
    using LibDecimalFloat for Float;

    /// `exponential-growth` integrity check. Requires exactly 3 inputs and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be three inputs and one output.
        return (3, 1);
    }

    /// exponential-growth
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        Float base;
        Float rate;
        Float t;
        assembly ("memory-safe") {
            base := mload(stackTop)
            rate := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
            t := mload(stackTop)
        }
        base = base.mul(rate.add(LibDecimalFloat.FLOAT_ONE).pow(t, LibDecimalFloat.LOG_TABLES_ADDRESS));

        assembly ("memory-safe") {
            mstore(stackTop, base)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory)
    {
        Float base = Float.wrap(StackItem.unwrap(inputs[0]));
        Float rate = Float.wrap(StackItem.unwrap(inputs[1]));
        Float t = Float.wrap(StackItem.unwrap(inputs[2]));
        base = base.mul(rate.add(LibDecimalFloat.FLOAT_ONE).pow(t, LibDecimalFloat.LOG_TABLES_ADDRESS));
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(base));
        return outputs;
    }
}
