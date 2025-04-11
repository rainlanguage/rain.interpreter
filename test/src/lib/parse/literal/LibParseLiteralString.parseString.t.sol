// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseLiteralString} from "src/lib/parse/literal/LibParseLiteralString.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/lib/LibIntOrAString.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOps} from "src/lib/op/LibAllStandardOps.sol";
import {CMASK_STRING_LITERAL_TAIL} from "rain.string/lib/parse/LibParseCMask.sol";
import {LibConformString} from "rain.string/lib/mut/LibConformString.sol";
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
        (uint256 cursorAfter, bytes32 value) = state.parseString(cursor, Pointer.unwrap(state.data.endDataPointer()));
        // Empty string is represented by 0 with the highest bit set to make it
        // a truthy value.
        assertEq(value, bytes32(uint256(1 << 0xFF)));
        assertEq(cursorAfter, cursor + 2);
    }

    /// The parser will only accept strings that are valid according to the mask.
    function testParseStringLiteralAny(bytes memory data) external pure {
        LibConformString.conformStringToMask(string(data), CMASK_STRING_LITERAL_TAIL, 0x80);
        vm.assume(data.length < 32);
        ParseState memory state = LibParseState.newState(bytes(string.concat("\"", string(data), "\"")), "", "", "");

        uint256 expectedValue = IntOrAString.unwrap(LibIntOrAString.fromString2(string(data)));
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, bytes32 value) =
            state.parseString(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        assertEq(value, bytes32(expectedValue));
        assertEq(cursorAfter, cursor + data.length + 2);
    }

    /// If any character in the string is not in the mask, the parser will error.
    function testParseStringLiteralCorrupt(bytes memory data, uint256 corruptIndex) external {
        vm.assume(data.length > 0);
        LibConformString.conformStringToMask(string(data), CMASK_STRING_LITERAL_TAIL, 0x80);
        vm.assume(data.length < 32);
        corruptIndex = bound(corruptIndex, 0, data.length - 1);
        LibConformString.corruptSingleChar(string(data), corruptIndex);

        ParseState memory state = LibParseState.newState(bytes(string.concat("\"", string(data), "\"")), "", "", "");

        vm.expectRevert(abi.encodeWithSelector(UnclosedStringLiteral.selector, 1 + corruptIndex));
        (uint256 cursorAfter, bytes32 value) =
            state.parseString(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }
}
