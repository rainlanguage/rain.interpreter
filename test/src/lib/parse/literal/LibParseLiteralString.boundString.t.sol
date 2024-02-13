// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteralString} from "src/lib/parse/literal/LibParseLiteralString.sol";
import {LibLiteralString} from "test/lib/literal/LibLiteralString.sol";
import {StringTooLong, UnclosedStringLiteral, ParserOutOfBounds} from "src/error/ErrParse.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";

/// @title LibParseLiteralStringBoundTest
contract LibParseLiteralStringBoundTest is Test {
    using LibBytes for bytes;
    using LibParseLiteralString for ParseState;

    /// External parse function to allow us to assert reverts.
    function externalBoundString(bytes memory data) external pure returns (uint256, uint256, uint256, uint256) {
        ParseState memory state = LibParseState.newState(data, "", "", "");
        uint256 cursor = Pointer.unwrap(bytes(data).dataPointer());
        uint256 end = cursor + bytes(data).length;
        (uint256 innerStart, uint256 innerEnd, uint256 outerEnd) = state.boundString(cursor, end);
        return (cursor, innerStart, innerEnd, outerEnd);
    }

    /// External parse function to allow us to assert reverts after forcing the
    /// string length. This can be used to force the parser out of bounds.
    function externalBoundLiteralForceLength(bytes memory data, uint256 length)
        external
        pure
        returns (uint256, uint256, uint256, uint256)
    {
        ParseState memory state = LibParseState.newState(data, "", "", "");
        state.literalParsers = LibAllStandardOpsNP.literalParserFunctionPointers();
        assembly ("memory-safe") {
            mstore(data, length)
        }
        uint256 outerStart = Pointer.unwrap(bytes(data).dataPointer());
        uint256 cursor = outerStart;
        uint256 end = outerStart + length;
        (uint256 innerStart, uint256 innerEnd, uint256 outerEnd) = state.boundString(cursor, end);
        return (outerStart, innerStart, innerEnd, outerEnd);
    }

    function checkStringBounds(
        string memory str,
        uint256 expectedInnerStart,
        uint256 expectedInnerEnd,
        uint256 expectedOuterEnd
    ) internal {
        (uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundString(bytes(str));
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
        checkStringBounds(string.concat("\"", str, "\""), 0, 0, 0);
    }

    /// Invalid chars in the first 31 bytes should error.
    function testParseStringLiteralBoundsInvalidCharBefore(string memory str, uint256 badIndex) external {
        vm.assume(bytes(str).length > 0);
        LibLiteralString.conformValidPrintableStringContent(str);
        badIndex = bound(badIndex, 0, (bytes(str).length > 0x1F ? 0x1F : bytes(str).length) - 1);
        LibLiteralString.corruptSingleChar(str, badIndex);

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, 1 + badIndex));
        checkStringBounds(string.concat("\"", str, "\""), 0, 0, 0);
    }

    /// Valid string data beyond the bounds of the parsed data should error as
    /// an unclosed string.
    function testParseStringLiteralBoundsParserOutOfBounds(string memory str, uint256 length) external {
        vm.assume(bytes(str).length < 0x20);
        LibLiteralString.conformValidPrintableStringContent(str);
        str = string.concat("\"", str, "\"");
        length = bound(length, 1, bytes(str).length - 1);

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, length));
        (uint256 outerStart, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            this.externalBoundLiteralForceLength(bytes(str), length);
        (outerStart, innerStart, innerEnd, outerEnd);
    }
}
