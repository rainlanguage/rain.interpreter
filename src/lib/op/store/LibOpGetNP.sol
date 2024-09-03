// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {MemoryKVKey, MemoryKVVal, MemoryKV, LibMemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpGetNP
/// @notice Opcode for reading from storage.
library LibOpGetNP {
    using LibMemoryKV for MemoryKV;

    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // Always 1 input. The key. `hash()` is recommended to build compound
        // keys.
        return (1, 1);
    }

    /// Implements runtime behaviour of the `get` opcode. Attempts to lookup the
    /// key in the memory key/value store then falls back to the interpreter's
    /// storage interface as an external call. If the key is not found in either,
    /// the value will fallback to `0` as per default Solidity/EVM behaviour.
    /// @param state The interpreter state of the current eval.
    /// @param stackTop Pointer to the current stack top.
    function run(InterpreterStateNP memory state, Operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 key;
        assembly ("memory-safe") {
            key := mload(stackTop)
        }
        (uint256 exists, MemoryKVVal value) = state.stateKV.get(MemoryKVKey.wrap(key));

        // Cache MISS, get from external store.
        if (exists == 0) {
            uint256 storeValue = state.store.get(state.namespace, key);

            // Push fetched value to memory to make subsequent lookups on the
            // same key find a cache HIT.
            state.stateKV = state.stateKV.set(MemoryKVKey.wrap(key), MemoryKVVal.wrap(storeValue));

            assembly ("memory-safe") {
                mstore(stackTop, storeValue)
            }
        }
        // Cache HIT.
        else {
            assembly ("memory-safe") {
                mstore(stackTop, value)
            }
        }

        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory state, Operand, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 key = inputs[0];
        (uint256 exists, MemoryKVVal value) = state.stateKV.get(MemoryKVKey.wrap(key));
        uint256[] memory outputs = new uint256[](1);
        // Cache MISS, get from external store.
        if (exists == 0) {
            uint256 storeValue = state.store.get(state.namespace, key);

            // Push fetched value to memory to make subsequent lookups on the
            // same key find a cache HIT.
            state.stateKV = state.stateKV.set(MemoryKVKey.wrap(key), MemoryKVVal.wrap(storeValue));

            outputs[0] = storeValue;
        }
        // Cache HIT.
        else {
            outputs[0] = MemoryKVVal.unwrap(value);
        }

        return outputs;
    }
}
