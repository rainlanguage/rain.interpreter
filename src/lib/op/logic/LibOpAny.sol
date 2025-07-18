// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

/// @title LibOpAny
/// @notice Opcode to return the first nonzero item on the stack up to the inputs
/// limit.
library LibOpAny {
    function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
        // There must be at least one input.
        uint256 inputs = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
        inputs = inputs > 0 ? inputs : 1;
        return (inputs, 1);
    }

    /// ANY
    /// ANY is the first nonzero item, else 0.
    function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let length := mul(and(shr(0x10, operand), 0x0F), 0x20)
            let cursor := stackTop
            stackTop := sub(add(stackTop, length), 0x20)
            for { let end := add(cursor, length) } lt(cursor, end) { cursor := add(cursor, 0x20) } {
                let item := mload(cursor)
                if gt(item, 0) {
                    mstore(stackTop, item)
                    break
                }
            }
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of ANY for testing.
    function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        // Zero length inputs is not supported so this 0 will always be written
        // over.
        bytes32 value = 0;
        for (uint256 i = 0; i < inputs.length; i++) {
            value = StackItem.unwrap(inputs[i]);
            if (value != bytes32(0)) {
                break;
            }
        }
        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(value);
    }
}
