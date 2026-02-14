// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {MemoryKV, MemoryKVKey, MemoryKVVal, LibMemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheck.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpSet
/// @notice Opcode for recording k/v state changes to be set in storage.
library LibOpSet {
    using LibMemoryKV for MemoryKV;

    /// `set` integrity check. Requires 2 inputs (key, value) and produces 0 outputs.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 2 inputs. The key and the value. `hash()` is recommended to
        // build compound keys.
        return (2, 0);
    }

    /// `set` opcode. Records a key/value pair in the in-memory state KV store to be persisted to storage after eval.
    function run(InterpreterState memory state, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            bytes32 key;
            bytes32 value;
            assembly ("memory-safe") {
                key := mload(stackTop)
                value := mload(add(stackTop, 0x20))
                stackTop := add(stackTop, 0x40)
            }

            state.stateKV = state.stateKV.set(MemoryKVKey.wrap(key), MemoryKVVal.wrap(value));
            return stackTop;
        }
    }

    /// Reference implementation of `set` for testing.
    function referenceFn(InterpreterState memory state, OperandV2, StackItem[] memory inputs)
        internal
        pure
        returns (StackItem[] memory)
    {
        bytes32 key = StackItem.unwrap(inputs[0]);
        bytes32 value = StackItem.unwrap(inputs[1]);
        state.stateKV = state.stateKV.set(MemoryKVKey.wrap(key), MemoryKVVal.wrap(value));
        return new StackItem[](0);
    }
}
