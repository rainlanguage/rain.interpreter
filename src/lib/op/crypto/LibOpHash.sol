// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";

/// @title LibOpHash
/// Implementation of keccak256 hashing as a standard Rainlang opcode.
library LibOpHash {
    /// `hash` integrity check. Inputs count is operand-defined, produces 1 output.
    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        // Any number of inputs are valid.
        // 0 inputs will be the hash of empty (0 length) bytes.
        uint256 inputs = uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F;
        return (inputs, 1);
    }

    /// `hash` opcode. Computes keccak256 over the operand-specified number of stack items.
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let length := mul(and(shr(0x10, operand), 0x0F), 0x20)
            let value := keccak256(stackTop, length)
            stackTop := sub(add(stackTop, length), 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    /// Reference implementation of `hash` for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(keccak256(abi.encodePacked(inputs)));
    }
}
