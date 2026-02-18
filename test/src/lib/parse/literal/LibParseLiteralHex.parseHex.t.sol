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

    /// "0x" followed by a non-hex byte must revert with ZeroLengthHexLiteral
    /// because boundHex stops at the non-hex character, giving hexLength == 0.
    function testParseHexZeroLength(uint8 trailingByte) external {
        // 256 - 22 valid hex chars = 234 non-hex values.
        trailingByte = uint8(bound(trailingByte, 0, 233));
        // Map to non-hex byte: skip 0-9 (0x30-0x39), A-F (0x41-0x46), a-f (0x61-0x66).
        if (trailingByte >= 0x30) trailingByte += 10; // skip 0-9
        if (trailingByte >= 0x41) trailingByte += 6; // skip A-F
        if (trailingByte >= 0x61) trailingByte += 6; // skip a-f

        bytes memory data = abi.encodePacked(bytes2("0x"), bytes1(trailingByte));

        vm.expectRevert(abi.encodeWithSelector(ZeroLengthHexLiteral.selector, 2));
        this.externalParseHex(data);
    }

    /// An odd number of hex digits (1 to 63) must revert with
    /// OddLengthHexLiteral.
    function testParseHexOddLength(uint8 halfLen) external {
        // oddLen in {1, 3, 5, ..., 63}
        halfLen = uint8(bound(halfLen, 0, 31));
        uint256 oddLen = uint256(halfLen) * 2 + 1;

        // Build "0x" followed by oddLen hex 'a' characters.
        bytes memory data = new bytes(oddLen + 2);
        data[0] = "0";
        data[1] = "x";
        for (uint256 i = 0; i < oddLen; i++) {
            data[i + 2] = "a";
        }

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
