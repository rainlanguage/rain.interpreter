// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "rain.lib.memkv/LibMemoryKV.sol";
import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";
import "rain.lib.typecast/LibConvert.sol";

import "../src/LibEval.sol";

contract LibEvalTest is Test {
    using LibMemoryKV for MemoryKV;
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;

    function opCount(InterpreterState memory state, Operand operand, Pointer pointer) internal pure returns (Pointer) {
        require(Pointer.unwrap(state.stackBottom) >= Pointer.unwrap(pointer));
        MemoryKVKey key = MemoryKVKey.wrap(0);
        (uint256 exists, MemoryKVVal value) = state.stateKV.get(key);
        if (exists > 0) {
            value = MemoryKVVal.wrap(MemoryKVVal.unwrap(value) + Operand.unwrap(operand));
        } else {
            value = MemoryKVVal.wrap(1);
        }
        state.stateKV.set(key, value);

        return pointer.unsafePush(MemoryKVVal.unwrap(value));
    }

    function opCountOrHash(InterpreterState memory state, Operand operand, Pointer pointer)
        internal
        pure
        returns (Pointer)
    {
        require(Pointer.unwrap(state.stackBottom) >= Pointer.unwrap(pointer));
        if (Pointer.unwrap(state.stackBottom) == Pointer.unwrap(pointer)) {
            return opCount(state, operand, pointer);
        } else if (Pointer.unwrap(state.stackBottom) == Pointer.unwrap(pointer.unsafeSubWord())) {
            Pointer location = state.stackBottom;
            uint256 value;
            assembly ("memory-safe") {
                mstore(0, mload(location))
                mstore(0, operand)
                value := keccak256(0, 0x40)
            }
            return pointer.unsafePush(value);
        } else {
            Pointer location = pointer.unsafeSubWords(2);
            uint256 value;
            assembly ("memory-safe") {
                let memoryPointer := mload(0x40)
                mstore(memoryPointer, mload(location))
                mstore(add(memoryPointer, 0x20), mload(add(location, 0x20)))
                mstore(add(memoryPointer, 0x40), operand)
                value := keccak256(0, 0x60)
            }
            return location.unsafePush(value);
        }
    }

    function opcodeFunctionPointers() internal pure returns (bytes memory) {
        function (InterpreterState memory, Operand, Pointer) internal pure returns (Pointer)[] memory fns =
            new function (InterpreterState memory, Operand, Pointer) internal pure returns (Pointer)[](2);
        fns[0] = opCount;
        fns[1] = opCountOrHash;
        uint256[] memory ufns;
        assembly ("memory-safe") {
            ufns := fns
        }
        return LibConvert.unsafeTo16BitBytes(ufns);
    }
}
