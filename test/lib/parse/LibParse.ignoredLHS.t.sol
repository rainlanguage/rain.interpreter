// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "test/util/lib/io/LibIOFnPointers.sol";

/// @title LibParseIgnoredLHSTest
/// Tests parsing ignored LHS items. An ignored LHS item is one that starts with
/// an underscore and is cheaper than named LHS items as they don't need to be
/// tracked for potential use in the RHS.
contract LibParseIgnoredLHSTest is Test {
    bytes internal meta;

    /// Constructor just builds the shared meta.
    constructor() {
        bytes32[] memory words = new bytes32[](1);
        words[0] = bytes32("a");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// A lone underscore should parse to an empty source and constant.
    function testParseIgnoredLHSLoneUnderscore() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_:;", "");
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 0);
        assertEq(constants.length, 0);
    }

    /// Two underscores should parse to an empty source and constant.
    function testParseIgnoredLHSTwoUnderscores() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_ _:;", "");
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 0);
        assertEq(constants.length, 0);
    }

    /// An underscore that is NOT an input should parse to a non-empty source
    /// with no constants.
    function testParseIgnoredLHSUnderscoreNotInput() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(":,_:a();", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// An underscore followed by some alpha chars should parse to an empty
    /// source and constant.
    function testParseIgnoredLHSUnderscoreAlpha() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_a:;", "");
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 0);
        assertEq(constants.length, 0);
    }

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
