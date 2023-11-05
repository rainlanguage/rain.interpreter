// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {FullyQualifiedNamespace, IInterpreterStoreV1} from "src/interface/IInterpreterStoreV1.sol";

struct InterpreterStateNP {
    Pointer[] stackBottoms;
    uint256[] constants;
    uint256 sourceIndex;
    MemoryKV stateKV;
    FullyQualifiedNamespace namespace;
    IInterpreterStoreV1 store;
    uint256[][] context;
    bytes bytecode;
    bytes fs;
}

library LibInterpreterStateNP {
    function fingerprint(InterpreterStateNP memory state) internal pure returns (bytes32) {
        return keccak256(abi.encode(state));
    }

    function stackBottoms(uint256[][] memory stacks) internal pure returns (Pointer[] memory) {
        Pointer[] memory bottoms = new Pointer[](stacks.length);
        assembly ("memory-safe") {
            for {
                let cursor := add(stacks, 0x20)
                let end := add(cursor, mul(mload(stacks), 0x20))
                let bottomsCursor := add(bottoms, 0x20)
            } lt(cursor, end) {
                cursor := add(cursor, 0x20)
                bottomsCursor := add(bottomsCursor, 0x20)
            } {
                let stack := mload(cursor)
                let stackBottom := add(stack, mul(0x20, add(mload(stack), 1)))
                mstore(bottomsCursor, stackBottom)
            }
        }
        return bottoms;
    }
}
