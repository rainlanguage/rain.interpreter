// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {
    LibParseLiteral,
    UnsupportedLiteralType,
    MalformedExponentDigits,
    ParserOutOfBounds
} from "src/lib/parse/LibParseLiteral.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseLiteralBoundLiteralDecimalTest
/// Tests finding bounds for literal decimal values by parsing.
contract LibParseLiteralBoundLiteralDecimalTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;

    function checkUnsupportedLiteralType(bytes memory data, uint256 offset) internal {
        ParseState memory state = LibParseState.newState(data, "");
        state.literalParsers = LibParseLiteral.buildLiteralParsers();
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        uint256 cursor = outerStart;
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, offset));
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor);
        (parser);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    function checkDecimalBounds(
        bytes memory data,
        uint256 expectedInnerStart,
        uint256 expectedInnerEnd,
        uint256 expectedOuterEnd
    ) internal {
        ParseState memory state = LibParseState.newState(data, "");
        state.literalParsers = LibParseLiteral.buildLiteralParsers();
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        uint256 cursor = outerStart;
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor);
        uint256 expectedParser;
        function(ParseState memory, uint256, uint256) pure returns (uint256) parseLiteralDecimal =
            LibParseLiteral.parseLiteralDecimal;
        assembly ("memory-safe") {
            expectedParser := parseLiteralDecimal
        }
        uint256 actualParser;
        assembly ("memory-safe") {
            actualParser := parser
        }
        assertEq(actualParser, expectedParser, "parser");
        assertEq(innerStart, outerStart + expectedInnerStart, "innerStart");
        assertEq(innerEnd, outerStart + expectedInnerEnd, "innerEnd");
        assertEq(outerEnd, outerStart + expectedOuterEnd, "outerEnd");
    }

    function checkMalformedExponentDigits(bytes memory data, uint256 offset) internal {
        ParseState memory state = LibParseState.newState(data, "");
        state.literalParsers = LibParseLiteral.buildLiteralParsers();
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        uint256 cursor = outerStart;
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, offset));
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor);
        (parser);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    function checkParserOutOfBounds(bytes memory data) internal {
        ParseState memory state = LibParseState.newState(data, "");
        state.literalParsers = LibParseLiteral.buildLiteralParsers();
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        uint256 cursor = outerStart;
        vm.expectRevert(abi.encodeWithSelector(ParserOutOfBounds.selector));
        (
            function(ParseState memory, uint256, uint256) pure returns (uint256) parser,
            uint256 innerStart,
            uint256 innerEnd,
            uint256 outerEnd
        ) = state.boundLiteral(cursor);
        (parser);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that an empty string is not treated as a literal.
    function testParseLiteralBoundLiteralDecimalEmpty() external {
        checkParserOutOfBounds("");
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "0".
    function testParseLiteralBoundLiteralDecimal0() external {
        checkDecimalBounds("0", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "1".
    function testParseLiteralBoundLiteralDecimal1() external {
        checkDecimalBounds("1", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "2".
    function testParseLiteralBoundLiteralDecimal2() external {
        checkDecimalBounds("2", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "3".
    function testParseLiteralBoundLiteralDecimal3() external {
        checkDecimalBounds("3", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "4".
    function testParseLiteralBoundLiteralDecimal4() external {
        checkDecimalBounds("4", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "5".
    function testParseLiteralBoundLiteralDecimal5() external {
        checkDecimalBounds("5", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "6".
    function testParseLiteralBoundLiteralDecimal6() external {
        checkDecimalBounds("6", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "7".
    function testParseLiteralBoundLiteralDecimal7() external {
        checkDecimalBounds("7", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "8".
    function testParseLiteralBoundLiteralDecimal8() external {
        checkDecimalBounds("8", 0, 1, 1);
    }

    /// Check that a single digit is bounded as a decimal literal. Tests "9".
    function testParseLiteralBoundLiteralDecimal9() external {
        checkDecimalBounds("9", 0, 1, 1);
    }

    /// Check that "e" or "E" in isolation is not treated as a literal.
    function testParseLiteralBoundLiteralDecimalE() external {
        checkUnsupportedLiteralType("e", 0);
        checkUnsupportedLiteralType("E", 0);
    }

    /// Check that a single digit followed by "e" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroE() external {
        checkMalformedExponentDigits("0e", 1);
    }

    /// Check that a single digit followed by "E" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEUpper() external {
        checkMalformedExponentDigits("0E", 1);
    }

    /// Check that a single digit followed by "e+" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlus() external {
        checkMalformedExponentDigits("0e+", 1);
    }

    /// Check that a single digit followed by "E+" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusUpper() external {
        checkMalformedExponentDigits("0E+", 1);
    }

    /// Check that a single digit followed by "e-" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinus() external {
        checkMalformedExponentDigits("0e-", 1);
    }

    /// Check that a single digit followed by "E-" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusUpper() external {
        checkMalformedExponentDigits("0E-", 1);
    }

    /// Check that a single digit followed by "e+1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusOne() external {
        checkMalformedExponentDigits("0e+1", 1);
    }

    /// Check that a single digit followed by "E+1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusOneUpper() external {
        checkMalformedExponentDigits("0E+1", 1);
    }

    /// Check that a single digit followed by "e-1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusOne() external {
        checkMalformedExponentDigits("0e-1", 1);
    }

    /// Check that a single digit followed by "E-1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusOneUpper() external {
        checkMalformedExponentDigits("0E-1", 1);
    }

    /// Check that a single digit followed by "e+01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusZeroOne() external {
        checkMalformedExponentDigits("0e+01", 1);
    }

    /// Check that a single digit followed by "E+01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusZeroOneUpper() external {
        checkMalformedExponentDigits("0E+01", 1);
    }

    /// Check that a single digit followed by "e-01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusZeroOne() external {
        checkMalformedExponentDigits("0e-01", 1);
    }

    /// Check that a single digit followed by "E+10" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusTen() external {
        checkMalformedExponentDigits("0e+10", 1);
    }

    /// Check a decimal with "e" followed by three digits is treated as
    /// malformed.
    function testParseLiteralBoundLiteralDecimalEPlusThreeDigits() external {
        checkMalformedExponentDigits("01e123", 2);
    }

    /// Check a decimal with "E" followed by three digits is treated as
    /// malformed.
    function testParseLiteralBoundLiteralDecimalEPlusThreeDigitsUpper() external {
        checkMalformedExponentDigits("01E123", 2);
    }

    /// Check a decimal with "e" followed by four digits is treated as malformed.
    function testParseLiteralBoundLiteralDecimalEPlusFourDigits() external {
        checkMalformedExponentDigits("01e1234", 2);
    }

    /// Check a decimal with "E" followed by four digits is treated as malformed.
    function testParseLiteralBoundLiteralDecimalEPlusFourDigitsUpper() external {
        checkMalformedExponentDigits("01E1234", 2);
    }

    /// Check that a string with multiple e/E only bounds the first.
    function testParseLiteralBoundLiteralDecimalMultipleE() external {
        checkDecimalBounds("0e0e0", 0, 3, 3);
        checkDecimalBounds("0E0E0", 0, 3, 3);
    }

    /// Check that a string with non digit characters after the first exponent
    /// digit is handled correctly (bounds up to the first exponent digit).
    function testParseLiteralBoundLiteralDecimalNonDigitAfterFirstExponent() external {
        checkDecimalBounds("0e0ze0", 0, 3, 3);
        checkDecimalBounds("0E0ZE0", 0, 3, 3);
    }

    /// Check that a string with non digit characters after the second exponent
    /// digit is handled correctly (bounds up to the second exponent digit).
    function testParseLiteralBoundLiteralDecimalNonDigitAfterExponent() external {
        checkDecimalBounds("0e00ze0", 0, 4, 4);
        checkDecimalBounds("0E00ZE0", 0, 4, 4);
    }
}
