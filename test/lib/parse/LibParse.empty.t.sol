// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseEmptyTest
/// Tests parsing empty sources and constants. All we want to check is that the
/// parser doesn't revert and the correct number of sources and constants are
/// returned.
contract LibParseEmptyTest is Test {
    /// Check truly empty input bytes. Should not revert and return length 0
    /// sources and constants.
    function testParseEmpty00() external {
        (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse("", "");
        assertEq(sources0.length, 0);
        assertEq(constants0.length, 0);
    }

    /// Check a single empty expression. Should not revert and return length 1
    /// sources and constants.
    function testParseEmpty01() external {
        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse(":;", "");
        assertEq(sources1.length, 1);
        assertEq(sources1[0].length, 0);
        assertEq(constants1.length, 0);
    }

    /// Check two empty expressions. Should not revert and return length 2
    /// sources and constants.
    function testParseEmpty02() external {
        (bytes[] memory sources2, uint256[] memory constants2) = LibParse.parse(":;:;", "");
        assertEq(sources2.length, 2);
        assertEq(sources2[0].length, 0);
        assertEq(sources2[1].length, 0);
        assertEq(constants2.length, 0);
    }
}
