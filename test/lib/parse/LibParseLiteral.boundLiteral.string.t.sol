// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteral} from "src/lib/parse/LibParseLiteral.sol";
import {LibLiteralString} from "test/util/lib/literal/LibLiteralString.sol";
import {StringTooLong, UnclosedStringLiteral, ParserOutOfBounds} from "src/error/ErrParse.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseLiteralBoundLiteralStringTest
contract LibParseLiteralBoundLiteralStringTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;

    /// External parse function to allow us to assert reverts.
    function externalBoundLiteral(bytes memory data)
        external
        pure
        returns (uint256, uint256, uint256, uint256, uint256)
    {
        ParseState memory state = LibParseState.newState(data, "");
        state.literalParsers = LibParseLiteral.buildLiteralParsers();
        uint256 outerStart = Pointer.unwrap(bytes(data).dataPointer());
        uint256 cursor = outerStart;
        uint256 end = outerStart + bytes(data).length;
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parserFn,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor, end);
        uint256 parser;
        assembly ("memory-safe") {
            parser := parserFn
        }
        return (parser, outerStart, innerStart, innerEnd, outerEnd);
    }

    /// External parse function to allow us to assert reverts after forcing the
    /// string length. This can be used to force the parser out of bounds.
    function externalBoundLiteralForceLength(bytes memory data, uint256 length)
        external
        pure
        returns (uint256, uint256, uint256, uint256, uint256)
    {
        ParseState memory state = LibParseState.newState(data, "");
        state.literalParsers = LibParseLiteral.buildLiteralParsers();
        assembly ("memory-safe") {
            mstore(data, length)
        }
        uint256 outerStart = Pointer.unwrap(bytes(data).dataPointer());
        uint256 cursor = outerStart;
        uint256 end = outerStart + length;
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parserFn,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor, end);
        uint256 parser;
        assembly ("memory-safe") {
            parser := parserFn
        }
        return (parser, outerStart, innerStart, innerEnd, outerEnd);
    }

    function checkStringBounds(
        string memory str,
        uint256 expectedInnerStart,
        uint256 expectedInnerEnd,
        uint256 expectedOuterEnd
    ) internal {
        (uint256 actualParser, uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundLiteral(bytes(str));
        uint256 expectedParser;
        function(ParseState memory, uint256, uint256) pure returns (uint256) parseLiteralString =
            LibParseLiteral.parseLiteralString;
        assembly ("memory-safe") {
            expectedParser := parseLiteralString
        }
        assertEq(actualParser, expectedParser, "parser");
        assertEq(innerStart, outerStart + expectedInnerStart, "innerStart");
        assertEq(innerEnd, outerStart + expectedInnerEnd, "innerEnd");
        assertEq(outerEnd, outerStart + expectedOuterEnd, "outerEnd");
    }

    /// All valid strings should parse with the outer start and end either side
    /// of their quotes and the inner start and end at their data bounds.
    function testParseStringLiteralBounds(string memory str) external {
        vm.assume(bytes(str).length < 0x20);
        LibLiteralString.conformValidPrintableStringContent(str);

        checkStringBounds(string.concat("\"", str, "\""), 1, bytes(str).length + 1, bytes(str).length + 2);
    }

    /// Valid but too long strings should error.
    function testParseStringLiteralBoundsTooLong(string memory str) external {
        vm.assume(bytes(str).length >= 0x20);
        LibLiteralString.conformValidPrintableStringContent(str);

        vm.expectRevert(abi.encodeWithSelector(StringTooLong.selector, 0));
        (uint256 actualParser, uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundLiteral(bytes(string.concat("\"", str, "\"")));
        (actualParser, outerStart, innerStart, innerEnd, outerEnd);
    }

    /// Invalid chars in the first 31 bytes should error.
    function testParseStringLiteralBoundsInvalidCharBefore(string memory str, uint256 badIndex) external {
        vm.assume(bytes(str).length > 0);
        LibLiteralString.conformValidPrintableStringContent(str);
        badIndex = bound(badIndex, 0, (bytes(str).length > 0x1F ? 0x1F : bytes(str).length) - 1);
        LibLiteralString.corruptSingleChar(str, badIndex);

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, 0));
        (uint256 actualParser, uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundLiteral(bytes(string.concat("\"", str, "\"")));
        (actualParser, outerStart, innerStart, innerEnd, outerEnd);
    }

    /// Valid string data beyond the bounds of the parsed data should error as
    /// an unclosed string.
    function testParseStringLiteralBoundsParserOutOfBounds(string memory str, uint256 length) external {
        vm.assume(bytes(str).length < 0x20);
        LibLiteralString.conformValidPrintableStringContent(str);
        str = string.concat("\"", str, "\"");
        length = bound(length, 1, bytes(str).length - 1);

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, length));
        (uint256 actualParser, uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundLiteralForceLength(bytes(str), length);
        (actualParser, outerStart, innerStart, innerEnd, outerEnd);
    }
}
