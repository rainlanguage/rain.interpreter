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

    /// Test parsing "__" (2 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored01() external pure {
        LibParse.parse("__:;", "");
    }

    /// Test parsing "___" (3 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored02() external pure {
        LibParse.parse("___:;", "");
    }

    /// Test parsing "____" (4 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored03() external pure {
        LibParse.parse("____:;", "");
    }

    /// Test parsing "_____" (5 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored04() external pure {
        LibParse.parse("_____:;", "");
    }

    /// Test parsing "______" (6 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored05() external pure {
        LibParse.parse("______:;", "");
    }

    /// Test parsing "_______" (7 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored06() external pure {
        LibParse.parse("_______:;", "");
    }

    /// Test parsing "________" (8 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored07() external pure {
        LibParse.parse("________:;", "");
    }

    /// Test parsing "_________" (9 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored08() external pure {
        LibParse.parse("_________:;", "");
    }

    /// Test parsing "__________" (10 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored09() external pure {
        LibParse.parse("__________:;", "");
    }
}