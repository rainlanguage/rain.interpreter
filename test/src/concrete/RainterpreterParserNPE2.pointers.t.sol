// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterParserNPE2,
    OPERAND_HANDLER_FUNCTION_POINTERS,
    LITERAL_PARSER_FUNCTION_POINTERS,
    PARSE_META
} from "src/concrete/RainterpreterParserNPE2.sol";
import {LibAllStandardOpsNP, AuthoringMetaV2} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibParseMeta} from "src/lib/parse/LibParseMeta.sol";

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

    function testParserParseMeta() external {
        bytes memory authoringMetaBytes = LibAllStandardOpsNP.authoringMetaV2();
        AuthoringMetaV2[] memory authoringMeta = abi.decode(authoringMetaBytes, (AuthoringMetaV2[]));
        bytes memory expected = LibParseMeta.buildParseMetaV2(authoringMeta, 2);
        bytes memory actual = PARSE_META;
        assertEq(actual, expected);
    }
}
