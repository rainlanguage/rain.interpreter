// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibParseLiteral} from "src/lib/parse/LibParseLiteral.sol";

/// @title LibParseSingleLHSNamedGasTest
/// Parse a single named LHS for many different sized LHS names just to include
/// the gas cost of the parsing in the gas snapshot.
contract LibParseSingleLHSNamedGasTest is Test {
    using LibParse for ParseState;

    function newState(string memory s) internal pure returns (ParseState memory) {
        return LibParseState.newState(
            bytes(s),
            "",
            // There's no operands on the LHS.
            "",
            // There's no literals on the LHS.
            0
        );
    }

    /// Test parsing "a" (1 char) a named LHS item.
    function testParseGasSingleLHSNamed00() external pure {
        newState("a:;").parse();
    }

    /// Test parsing "aa" (2 chars) a named LHS item.
    function testParseGasSingleLHSNamed01() external pure {
        newState("aa:;").parse();
    }

    /// Test parsing "aaa" (3 chars) a named LHS item.
    function testParseGasSingleLHSNamed02() external pure {
        newState("aaa:;").parse();
    }

    /// Test parsing "aaaa" (4 chars) a named LHS item.
    function testParseGasSingleLHSNamed03() external pure {
        newState("aaaa:;").parse();
    }

    /// Test parsing "aaaaa" (5 chars) a named LHS item.
    function testParseGasSingleLHSNamed04() external pure {
        newState("aaaaa:;").parse();
    }

    /// Test parsing "aaaaaa" (6 chars) a named LHS item.
    function testParseGasSingleLHSNamed05() external pure {
        newState("aaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaa" (7 chars) a named LHS item.
    function testParseGasSingleLHSNamed06() external pure {
        newState("aaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaa" (8 chars) a named LHS item.
    function testParseGasSingleLHSNamed07() external pure {
        newState("aaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaa" (9 chars) a named LHS item.
    function testParseGasSingleLHSNamed08() external pure {
        newState("aaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaa" (10 chars) a named LHS item.
    function testParseGasSingleLHSNamed09() external pure {
        newState("aaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaa" (11 chars) a named LHS item.
    function testParseGasSingleLHSNamed10() external pure {
        newState("aaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaa" (12 chars) a named LHS item.
    function testParseGasSingleLHSNamed11() external pure {
        newState("aaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaa" (13 chars) a named LHS item.
    function testParseGasSingleLHSNamed12() external pure {
        newState("aaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaa" (14 chars) a named LHS item.
    function testParseGasSingleLHSNamed13() external pure {
        newState("aaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaa" (15 chars) a named LHS item.
    function testParseGasSingleLHSNamed14() external pure {
        newState("aaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaa" (16 chars) a named LHS item.
    function testParseGasSingleLHSNamed15() external pure {
        newState("aaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaa" (17 chars) a named LHS item.
    function testParseGasSingleLHSNamed16() external pure {
        newState("aaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaa" (18 chars) a named LHS item.
    function testParseGasSingleLHSNamed17() external pure {
        newState("aaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaa" (19 chars) a named LHS item.
    function testParseGasSingleLHSNamed18() external pure {
        newState("aaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaa" (20 chars) a named LHS item.
    function testParseGasSingleLHSNamed19() external pure {
        newState("aaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaa" (21 chars) a named LHS item.
    function testParseGasSingleLHSNamed20() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaa" (22 chars) a named LHS item.
    function testParseGasSingleLHSNamed21() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaa" (23 chars) a named LHS item.
    function testParseGasSingleLHSNamed22() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaa" (24 chars) a named LHS item.
    function testParseGasSingleLHSNamed23() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaa" (25 chars) a named LHS item.
    function testParseGasSingleLHSNamed24() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaa" (26 chars) a named LHS item.
    function testParseGasSingleLHSNamed25() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaa" (27 chars) a named LHS item.
    function testParseGasSingleLHSNamed26() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaa" (28 chars) a named LHS item.
    function testParseGasSingleLHSNamed27() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (29 chars) a named LHS item.
    function testParseGasSingleLHSNamed28() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (30 chars) a named LHS item.
    function testParseGasSingleLHSNamed29() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (31 chars) a named LHS item.
    function testParseGasSingleLHSNamed30() external pure {
        newState("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }
}
