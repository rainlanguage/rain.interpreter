// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseSingleLHSNamedGasTest
/// Parse a single named LHS for many different sized LHS names just to include
/// the gas cost of the parsing in the gas snapshot.
contract LibParseSingleLHSNamedGasTest is Test {
    /// Test parsing "a" (1 char) a named LHS item.
    function testParseGasSingleLHSNamed00() external pure {
        LibParse.parse("a:;", "");
    }

    /// Test parsing "aa" (2 chars) a named LHS item.
    function testParseGasSingleLHSNamed01() external pure {
        LibParse.parse("aa:;", "");
    }

    /// Test parsing "aaa" (3 chars) a named LHS item.
    function testParseGasSingleLHSNamed02() external pure {
        LibParse.parse("aaa:;", "");
    }

    /// Test parsing "aaaa" (4 chars) a named LHS item.
    function testParseGasSingleLHSNamed03() external pure {
        LibParse.parse("aaaa:;", "");
    }

    /// Test parsing "aaaaa" (5 chars) a named LHS item.
    function testParseGasSingleLHSNamed04() external pure {
        LibParse.parse("aaaaa:;", "");
    }

    /// Test parsing "aaaaaa" (6 chars) a named LHS item.
    function testParseGasSingleLHSNamed05() external pure {
        LibParse.parse("aaaaaa:;", "");
    }

    /// Test parsing "aaaaaaa" (7 chars) a named LHS item.
    function testParseGasSingleLHSNamed06() external pure {
        LibParse.parse("aaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaa" (8 chars) a named LHS item.
    function testParseGasSingleLHSNamed07() external pure {
        LibParse.parse("aaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaa" (9 chars) a named LHS item.
    function testParseGasSingleLHSNamed08() external pure {
        LibParse.parse("aaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaa" (10 chars) a named LHS item.
    function testParseGasSingleLHSNamed09() external pure {
        LibParse.parse("aaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaa" (11 chars) a named LHS item.
    function testParseGasSingleLHSNamed10() external pure {
        LibParse.parse("aaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaa" (12 chars) a named LHS item.
    function testParseGasSingleLHSNamed11() external pure {
        LibParse.parse("aaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaa" (13 chars) a named LHS item.
    function testParseGasSingleLHSNamed12() external pure {
        LibParse.parse("aaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaa" (14 chars) a named LHS item.
    function testParseGasSingleLHSNamed13() external pure {
        LibParse.parse("aaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaa" (15 chars) a named LHS item.
    function testParseGasSingleLHSNamed14() external pure {
        LibParse.parse("aaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaa" (16 chars) a named LHS item.
    function testParseGasSingleLHSNamed15() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaa" (17 chars) a named LHS item.
    function testParseGasSingleLHSNamed16() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaa" (18 chars) a named LHS item.
    function testParseGasSingleLHSNamed17() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaa" (19 chars) a named LHS item.
    function testParseGasSingleLHSNamed18() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaa" (20 chars) a named LHS item.
    function testParseGasSingleLHSNamed19() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaa" (21 chars) a named LHS item.
    function testParseGasSingleLHSNamed20() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaa" (22 chars) a named LHS item.
    function testParseGasSingleLHSNamed21() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaa" (23 chars) a named LHS item.
    function testParseGasSingleLHSNamed22() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaa" (24 chars) a named LHS item.
    function testParseGasSingleLHSNamed23() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaa" (25 chars) a named LHS item.
    function testParseGasSingleLHSNamed24() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaa" (26 chars) a named LHS item.
    function testParseGasSingleLHSNamed25() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaa" (27 chars) a named LHS item.
    function testParseGasSingleLHSNamed26() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaa" (28 chars) a named LHS item.
    function testParseGasSingleLHSNamed27() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (29 chars) a named LHS item.
    function testParseGasSingleLHSNamed28() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (30 chars) a named LHS item.
    function testParseGasSingleLHSNamed29() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (31 chars) a named LHS item.
    function testParseGasSingleLHSNamed30() external pure {
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }
}
