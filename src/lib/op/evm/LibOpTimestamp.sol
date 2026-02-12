// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpTimestamp
/// Implementation of the EVM `TIMESTAMP` opcode as a standard Rainlang opcode.
library LibOpTimestamp {
    using LibDecimalFloat for Float;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, timestamp())
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)
        internal
        view
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(block.timestamp, 0)));
        return outputs;
    }
}
