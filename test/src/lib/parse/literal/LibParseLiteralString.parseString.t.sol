// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseLiteralString} from "src/lib/parse/literal/LibParseLiteralString.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/lib/LibIntOrAString.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {CMASK_STRING_LITERAL_TAIL} from "src/lib/parse/LibParseCMask.sol";
import {LibLiteralString} from "test/lib/literal/LibLiteralString.sol";
import {UnclosedStringLiteral} from "src/error/ErrParse.sol";

/// @title LibParseLiteralStringTest
/// Tests parsing strings with the LibParseLiteral library.
contract LibParseLiteralStringTest is Test {
    using LibBytes for bytes;
    using LibParseLiteralString for ParseState;

    /// Check that an empty string literal is parsed correctly.
    function testParseStringLiteralEmpty() external pure {
        ParseState memory state = LibParseState.newState("\"\"", "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 value) = state.parseString(cursor, Pointer.unwrap(state.data.endDataPointer()));
        // Empty string is represented by 0 with the highest bit set to make it
        // a truthy value.
        assertEq(value, 1 << 0xFF);
        assertEq(cursorAfter, cursor + 2);
    }

    /// The parser will only accept strings that are valid according to the mask.
    function testParseStringLiteralAny(bytes memory data) external pure {
        LibLiteralString.conformStringToMask(string(data), CMASK_STRING_LITERAL_TAIL, 0x80);
        vm.assume(data.length < 32);
        ParseState memory state = LibParseState.newState(bytes(string.concat("\"", string(data), "\"")), "", "", "");

        uint256 expectedValue = IntOrAString.unwrap(LibIntOrAString.fromString2(string(data)));
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 value) =
            state.parseString(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        assertEq(value, expectedValue);
        assertEq(cursorAfter, cursor + data.length + 2);
    }

    /// If any character in the string is not in the mask, the parser will error.
    function testParseStringLiteralCorrupt(bytes memory data, uint256 corruptIndex) external {
        vm.assume(data.length > 0);
        LibLiteralString.conformStringToMask(string(data), CMASK_STRING_LITERAL_TAIL, 0x80);
        vm.assume(data.length < 32);
        corruptIndex = bound(corruptIndex, 0, data.length - 1);
        LibLiteralString.corruptSingleChar(string(data), corruptIndex);

        ParseState memory state = LibParseState.newState(bytes(string.concat("\"", string(data), "\"")), "", "", "");

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, 1 + corruptIndex));
        (uint256 cursorAfter, uint256 value) =
            state.parseString(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }
}
