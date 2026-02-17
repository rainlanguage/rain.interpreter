// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpMaxUint256
/// Exposes `type(uint256).max` as a Rainlang opcode.
library LibOpMaxUint256 {
    /// `max-uint256` integrity check. Requires 0 inputs and produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    /// `max-uint256` opcode. Pushes type(uint256).max onto the stack.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        uint256 value = type(uint256).max;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    /// Reference implementation of `max-uint256` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)
        internal
        pure
        returns (StackItem[] memory)
    {
        StackItem[] memory outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(bytes32(type(uint256).max));
        return outputs;
    }
}
