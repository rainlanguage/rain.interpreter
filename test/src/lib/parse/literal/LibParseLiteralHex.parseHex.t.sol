// SPDX-License-Identifier: CAL
pragma solidity =0.8.26;

import {Test} from "forge-std/Test.sol";

import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibParseLiteralHex} from "src/lib/parse/literal/LibParseLiteralHex.sol";

/// @title LibParseLiteralHexTest
/// Tests parsing hex literals with LibParseLiteralHex.
contract LibParseLiteralHexBoundHexTest is Test {
    using LibParseLiteralHex for ParseState;
    using LibBytes for bytes;

    /// Fuzz and round trip.
    function testParseLiteralHexRoundTrip(uint256 value) external {
        string memory hexString = Strings.toHexString(value);
        ParseState memory state = LibParseState.newState(bytes(hexString), "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 parsedValue) = state.parseHex(
            // The hex parser wants only the hexadecimal digits without the
            // leading "0x".
            cursor,
            Pointer.unwrap(bytes(hexString).endDataPointer())
        );
        assertEq(parsedValue, value);
        assertEq(cursorAfter, cursor + bytes(hexString).length);
    }
}
