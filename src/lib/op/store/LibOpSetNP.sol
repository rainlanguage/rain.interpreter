// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {MemoryKV, MemoryKVKey, MemoryKVVal, LibMemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpSetNP
/// @notice Opcode for recording k/v state changes to be set in storage.
library LibOpSetNP {
    using LibMemoryKV for MemoryKV;

    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // Always 2 inputs. The key and the value. `hash()` is recommended to
        // build compound keys.
        return (2, 0);
    }

    function run(InterpreterStateNP memory state, Operand, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            uint256 key;
            uint256 value;
            assembly ("memory-safe") {
                key := mload(stackTop)
                value := mload(add(stackTop, 0x20))
                stackTop := add(stackTop, 0x40)
            }

            state.stateKV = state.stateKV.set(MemoryKVKey.wrap(key), MemoryKVVal.wrap(value));
            return stackTop;
        }
    }

    function referenceFn(InterpreterStateNP memory state, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256 key = inputs[0];
        uint256 value = inputs[1];
        state.stateKV = state.stateKV.set(MemoryKVKey.wrap(key), MemoryKVVal.wrap(value));
        return new uint256[](0);
    }
}
