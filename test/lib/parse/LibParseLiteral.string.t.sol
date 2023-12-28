// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibParseLiteral} from "src/lib/parse/LibParseLiteral.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";

/// @title LibParseLiteralStringTest
/// Tests parsing strings with the LibParseLiteral library.
contract LibParseLiteralStringTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;

    /// Check that an empty string literal is parsed correctly.
    function testParseStringLiteralEmpty() external {
        ParseState memory state =
            LibParseState.newState("", "", "", LibAllStandardOpsNP.literalParserFunctionPointers());
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 value) =
            state.parseLiteralString(cursor, Pointer.unwrap(state.data.endDataPointer()));
        assertEq(value, 0);
        assertEq(cursorAfter, cursor);
    }

    /// The parser does not care about printable characters, or even ASCII. It
    /// will simply do exactly what the `IntOrAString` library does.
    function testParseStringLiteralAny(bytes memory data) external {
        ParseState memory state =
            LibParseState.newState(data, "", "", LibAllStandardOpsNP.literalParserFunctionPointers());

        uint256 expectedValue = IntOrAString.unwrap(LibIntOrAString.fromString(string(data)));
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 value) = state.parseLiteralString(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, expectedValue);
        assertEq(cursorAfter, cursor + data.length);
    }
}
