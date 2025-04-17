// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Float, LibDecimalFloat, PackedFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

uint256 constant MAX_VALUE = uint256(0x7fffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffff);

/// @title LibOpMaxValue
/// Exposes the maximum representable float value as a Rainlang opcode.
library LibOpMaxValue {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        uint256 value = MAX_VALUE;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)
        internal
        pure
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(
            PackedFloat.unwrap(Float({signedCoefficient: type(int224).max, exponent: type(int32).max}).pack())
        );
        return outputs;
    }
}
