// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibParseLiteral} from "src/lib/parse/LibParseLiteral.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";

/// @title LibParseLiteralStringTest
/// Tests parsing strings with the LibParseLiteral library.
contract LibParseLiteralStringTest is Test {
    using LibBytes for bytes;

    /// Check that an empty string literal is parsed correctly.
    function testParseStringLiteralEmpty() external {
        bytes memory data = "";
        (uint256 value) = LibParseLiteral.parseLiteralString(
            data, Pointer.unwrap(data.dataPointer()), Pointer.unwrap(data.endDataPointer())
        );
    }

    /// The parser does not care about printable characters, or even ASCII. It
    /// will simply do exactly what the `IntOrAString` library does.
    function testParseStringLiteralAny(string memory data) external {
        uint256 expectedValue = IntOrAString.unwrap(LibIntOrAString.fromString(data));
        (uint256 value) = LibParseLiteral.parseLiteralString(
            bytes(data), Pointer.unwrap(bytes(data).dataPointer()), Pointer.unwrap(bytes(data).endDataPointer())
        );
        assertEq(value, expectedValue);
    }
}
