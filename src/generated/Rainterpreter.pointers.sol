// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol

// This file is committed to the repository because there is a circular
// dependency between the contract and its pointers file. The contract
// needs the pointers file to exist so that it can compile, and the pointers
// file needs the contract to exist so that it can be compiled.

// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

/// @dev Hash of the known bytecode.
bytes32 constant BYTECODE_HASH = bytes32(0x3832e4c596e71b07980604239758fc15ee522ff100644dfc5819521439c1c9ee);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS =
    hex"07ea081c084009cc0a950aa70ab90ad20af60b2a0b3b0b4c0bee0c0d0ccb0d7b0dff0f4110740ccb116d121f12c11339134a135b135b136c13d71482149b14af14c814e1151a1545155e1577159e15b11613166116af16fd174b179917e718181826187418a518f31924197219c01ab6";
