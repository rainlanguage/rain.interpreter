// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParseLiteralHex} from "src/lib/parse/literal/LibParseLiteralHex.sol";
import {HexLiteralOverflow, ZeroLengthHexLiteral, OddLengthHexLiteral} from "src/error/ErrParse.sol";

/// @title LibParseLiteralHexParseHexTest
/// Tests parsing hex literals with LibParseLiteralHex.
contract LibParseLiteralHexParseHexTest is Test {
    using LibParseLiteralHex for ParseState;
    using LibBytes for bytes;

    /// Fuzz and round trip.
    function testParseLiteralHexRoundTrip(bytes32 value) external pure {
        string memory hexString = Strings.toHexString(uint256(value));
        ParseState memory state = LibParseState.newState(bytes(hexString), "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, bytes32 parsedValue) = state.parseHex(
            // The hex parser wants only the hexadecimal digits without the
            // leading "0x".
            cursor,
            Pointer.unwrap(bytes(hexString).endDataPointer())
        );
        assertEq(parsedValue, value);
        assertEq(cursorAfter, cursor + bytes(hexString).length);
    }

    /// A hex literal with 65 hex digits (> 64 = 32 bytes) must revert with
    /// HexLiteralOverflow.
    function testParseHexOverflow() external {
        // 65 hex digits after "0x" — one more than the 64 (0x40) limit.
        bytes memory data = bytes("0x00000000000000000000000000000000000000000000000000000000000000000a");

        // Offset 2: the hex digits start after the "0x" prefix.
        vm.expectRevert(abi.encodeWithSelector(HexLiteralOverflow.selector, 2));
        this.externalParseHex(data);
    }

    /// "0x" with no hex digits must revert with ZeroLengthHexLiteral.
    function testParseHexZeroLength() external {
        bytes memory data = bytes("0x");

        // Offset 2: the (empty) hex body starts after the "0x" prefix.
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthHexLiteral.selector, 2));
        this.externalParseHex(data);
    }

    /// "0x" followed by an odd number of hex digits must revert with
    /// OddLengthHexLiteral.
    function testParseHexOddLength() external {
        bytes memory data = bytes("0xabc");

        // Offset 2: the hex body starts after the "0x" prefix.
        vm.expectRevert(abi.encodeWithSelector(OddLengthHexLiteral.selector, 2));
        this.externalParseHex(data);
    }

    /// External wrapper that constructs ParseState internally so memory
    /// pointers remain valid across the external call boundary.
    function externalParseHex(bytes memory data) external pure returns (uint256, bytes32) {
        ParseState memory state = LibParseState.newState(data, "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        return state.parseHex(cursor, Pointer.unwrap(data.endDataPointer()));
    }
}
