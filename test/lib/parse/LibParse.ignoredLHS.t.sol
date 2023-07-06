// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseIgnoredLHSTest
/// Tests parsing ignored LHS items. An ignored LHS item is one that starts with
/// an underscore and is cheaper than named LHS items as they don't need to be
/// tracked for potential use in the RHS.
contract LibParseIgnoredLHSTest is Test {
    /// Test a few simple ignored LHS items. All of these should parse to empty
    /// sources and constants.
    function testParseIgnoredLHSSimple() external {
        string[3] memory examples0 = ["_a:;", "_a _b:;", "_foo _bar:;"];
        for (uint256 i = 0; i < examples0.length; i++) {
            (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse(bytes(examples0[i]), "");
            assertEq(sources0.length, 1);
            assertEq(sources0[0].length, 0);
            assertEq(constants0.length, 0);
        }

        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse("_a:;_b:;", "");
        assertEq(sources1.length, 2);
        assertEq(sources1[0].length, 0);
        assertEq(sources1[1].length, 0);
        assertEq(constants1.length, 0);
    }

    /// Ignored words have no size limit. We can parse a 32 char ignored word.
    /// Normally words are limited to 31 chars.
    function testParseIgnoredWordTooLong() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 0);
        assertEq(constants.length, 0);
    }
}
