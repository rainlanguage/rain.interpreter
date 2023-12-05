// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {RainterpreterExternNPE2, OPCODE_FUNCTION_POINTERS, INTEGRITY_FUNCTION_POINTERS} from "src/concrete/RainterpreterExternNPE2.sol";

contract RainterpreterExternNPE2Test is Test {
    function testOpcodeFunctionPointers() external {
        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();
        bytes memory expected = extern.buildOpcodeFunctionPointers();
        bytes memory actual = OPCODE_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testIntegrityFunctionPointers() external {
        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();
        bytes memory expected = extern.buildIntegrityFunctionPointers();
        bytes memory actual = INTEGRITY_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
