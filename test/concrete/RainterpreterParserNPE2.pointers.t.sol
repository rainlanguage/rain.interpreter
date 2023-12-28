// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterParserNPE2,
    OPERAND_HANDLER_FUNCTION_POINTERS,
    LITERAL_PARSER_FUNCTION_POINTERS
} from "src/concrete/RainterpreterParserNPE2.sol";

contract RainterpreterParserNPE2PointersTest is Test {
    function testOperandHandlerFunctionPointers() external {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        bytes memory expected = parser.buildOperandHandlerFunctionPointers();
        bytes memory actual = OPERAND_HANDLER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testLiteralParserFunctionPointers() external {
        RainterpreterParserNPE2 parser = new RainterpreterParserNPE2();
        bytes memory expected = parser.buildLiteralParserFunctionPointers();
        bytes memory actual = LITERAL_PARSER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
