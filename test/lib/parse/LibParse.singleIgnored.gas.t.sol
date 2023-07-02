// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseSingleLHSIgnoredGasTest
/// Parse a single ignored LHS for many different sized LHS names just to include
/// the gas cost of the parsing in the gas snapshot.
contract LibParseSingleLHSIgnoredGasTest is Test {

    /// Test parsing "_" (1 char) an ignored LHS item.
    function testParseGasSingleLHSIgnored00() external pure {
        LibParse.parse("_:;", "");
    }

    /// Test parsing "_a" (2 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored01() external pure {
        LibParse.parse("_a:;", "");
    }

    /// Test parsing "_ab" (3 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored02() external pure {
        LibParse.parse("_ab:;", "");
    }

    /// Test parsing "_abc" (4 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored03() external pure {
        LibParse.parse("_abc:;", "");
    }

    /// Test parsing "_abcd" (5 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored04() external pure {
        LibParse.parse("_abcd:;", "");
    }

    /// Test parsing "_abcde" (6 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored05() external pure {
        LibParse.parse("_abcde:;", "");
    }

    /// Test parsing "_abcdef" (7 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored06() external pure {
        LibParse.parse("_abcdef:;", "");
    }

    /// Test parsing "_abcdefg" (8 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored07() external pure {
        LibParse.parse("_abcdefg:;", "");
    }

    /// Test parsing "_abcdefgh" (9 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored08() external pure {
        LibParse.parse("_abcdefgh:;", "");
    }

    /// Test parsing "_abcdefghi" (10 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored09() external pure {
        LibParse.parse("_abcdefghi:;", "");
    }
}