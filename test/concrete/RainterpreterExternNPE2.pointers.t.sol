// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterReferenceExternNPE2,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS
} from "src/concrete/RainterpreterReferenceExternNPE2.sol";

contract RainterpreterReferenceExternNPE2Test is Test {
    function testOpcodeFunctionPointers() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        bytes memory expected = extern.buildOpcodeFunctionPointers();
        bytes memory actual = OPCODE_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testIntegrityFunctionPointers() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        bytes memory expected = extern.buildIntegrityFunctionPointers();
        bytes memory actual = INTEGRITY_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
