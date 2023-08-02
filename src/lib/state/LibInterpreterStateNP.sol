// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";
import "rain.lib.memkv/lib/LibMemoryKV.sol";
import "../ns/LibNamespace.sol";

struct InterpreterStateNP {
    uint256[][] stacks;
    Pointer firstConstant;
    MemoryKV stateKV;
    FullyQualifiedNamespace namespace;
    IInterpreterStoreV1 store;
    uint256[][] context;
    bytes bytecode;
    bytes fs;
}
