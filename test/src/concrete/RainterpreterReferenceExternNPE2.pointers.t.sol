// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterReferenceExternNPE2,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    SUB_PARSER_WORD_PARSERS,
    AuthoringMetaV2,
    SUB_PARSER_PARSE_META,
    LibRainterpreterReferenceExternNPE2,
    SUB_PARSER_LITERAL_PARSERS,
    OPERAND_HANDLER_FUNCTION_POINTERS
} from "src/concrete/extern/RainterpreterReferenceExternNPE2.sol";
import {LibParseMeta} from "src/lib/parse/LibParseMeta.sol";

contract RainterpreterReferenceExternNPE2PointersTest is Test {
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

    function testSubParserParseMeta() external {
        bytes memory authoringMetaBytes = LibRainterpreterReferenceExternNPE2.authoringMetaV2();
        AuthoringMetaV2[] memory authoringMeta = abi.decode(authoringMetaBytes, (AuthoringMetaV2[]));
        bytes memory expected = LibParseMeta.buildParseMetaV2(authoringMeta, 2);
        bytes memory actual = SUB_PARSER_PARSE_META;
        assertEq(actual, expected);
    }

    function testSubParserLiteralParsers() external {
        RainterpreterReferenceExternNPE2 subParser = new RainterpreterReferenceExternNPE2();
        bytes memory expected = subParser.buildSubParserLiteralParsers();
        bytes memory actual = SUB_PARSER_LITERAL_PARSERS;
        assertEq(actual, expected);
    }

    function testSubParserFunctionPointers() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        bytes memory expected = extern.buildSubParserWordParsers();
        bytes memory actual = SUB_PARSER_WORD_PARSERS;
        assertEq(actual, expected);
    }

    function testSubParserOperandParsers() external {
        RainterpreterReferenceExternNPE2 extern = new RainterpreterReferenceExternNPE2();
        bytes memory expected = extern.buildOperandHandlerFunctionPointers();
        bytes memory actual = OPERAND_HANDLER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
