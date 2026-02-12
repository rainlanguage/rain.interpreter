// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheck.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpLinearGrowth
/// @notice Linear growth is base + rate * t where a is the initial value, r is
/// the growth rate, and t is time.
library LibOpLinearGrowth {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be three inputs and one output.
        return (3, 1);
    }

    /// linear-growth
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        Float base;
        Float rate;
        Float t;
        assembly ("memory-safe") {
            base := mload(stackTop)
            rate := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
            t := mload(stackTop)
        }

        base = LibDecimalFloat.add(base, LibDecimalFloat.mul(rate, t));

        assembly ("memory-safe") {
            mstore(stackTop, base)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory)
    {
        Float base = Float.wrap(StackItem.unwrap(inputs[0]));
        Float rate = Float.wrap(StackItem.unwrap(inputs[1]));
        Float t = Float.wrap(StackItem.unwrap(inputs[2]));
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.add(base, LibDecimalFloat.mul(rate, t))));
        return outputs;
    }
}
