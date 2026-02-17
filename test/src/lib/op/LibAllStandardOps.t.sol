// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {LibAllStandardOps, ALL_STANDARD_OPS_LENGTH} from "src/lib/op/LibAllStandardOps.sol";
import {LITERAL_PARSERS_LENGTH} from "src/lib/parse/literal/LibParseLiteral.sol";

/// @title LibAllStandardOpsTest
/// Some basic guard rails around the `LibAllStandardOps` library. Most of the
/// logic can only be tested by deploying an interpreter and running it.
contract LibAllStandardOpsTest is Test {
    /// Test that the dynamic length of the function pointers is correct.
    function testIntegrityFunctionPointersLength() external pure {
        bytes memory integrityFunctionPointers = LibAllStandardOps.integrityFunctionPointers();
        assertEq(integrityFunctionPointers.length, ALL_STANDARD_OPS_LENGTH * 2);
    }

    /// Test that the dynamic length of the function pointers is correct.
    function testOpcodeFunctionPointersLength() external pure {
        bytes memory functionPointers = LibAllStandardOps.opcodeFunctionPointers();
        // Each function pointer is 2 bytes.
        assertEq(functionPointers.length, ALL_STANDARD_OPS_LENGTH * 2);
    }

    /// Test that the integrity function pointers length and opcode function
    /// pointers length are the same.
    function testIntegrityAndOpcodeFunctionPointersLength() external pure {
        bytes memory integrityFunctionPointers = LibAllStandardOps.integrityFunctionPointers();
        bytes memory functionPointers = LibAllStandardOps.opcodeFunctionPointers();

        bytes memory authoringMeta = LibAllStandardOps.authoringMetaV2();
        bytes32[] memory words = abi.decode(authoringMeta, (bytes32[]));

        assertEq(integrityFunctionPointers.length, functionPointers.length);
        assertEq(integrityFunctionPointers.length, words.length * 2);
    }

    /// Test that the literal parser function pointers length matches
    /// LITERAL_PARSERS_LENGTH.
    function testLiteralParserFunctionPointersLength() external pure {
        bytes memory pointers = LibAllStandardOps.literalParserFunctionPointers();
        assertEq(pointers.length, LITERAL_PARSERS_LENGTH * 2);
    }

    /// Test that the operand handler function pointers length matches
    /// ALL_STANDARD_OPS_LENGTH.
    function testOperandHandlerFunctionPointersLength() external pure {
        bytes memory pointers = LibAllStandardOps.operandHandlerFunctionPointers();
        assertEq(pointers.length, ALL_STANDARD_OPS_LENGTH * 2);
    }
}
