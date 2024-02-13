// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseSingleLHSIgnoredGasTest
/// Parse a single ignored LHS for many different sized LHS names just to include
/// the gas cost of the parsing in the gas snapshot.
contract LibParseSingleLHSIgnoredGasTest is Test {
    using LibParse for ParseState;

    function newState(string memory s) internal pure returns (ParseState memory) {
        return LibParseState.newState(
            bytes(s),
            "",
            // There's no operands on the LHS.
            "",
            // There's no literals on the LHS.
            ""
        );
    }

    /// Test parsing "_" (1 char) an ignored LHS item.
    function testParseGasSingleLHSIgnored00() external pure {
        newState("_:;").parse();
    }

    /// Test parsing "_a" (2 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored01() external pure {
        newState("_a:;").parse();
    }

    /// Test parsing "_ab" (3 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored02() external pure {
        newState("_ab:;").parse();
    }

    /// Test parsing "_abc" (4 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored03() external pure {
        newState("_abc:;").parse();
    }

    /// Test parsing "_abcd" (5 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored04() external pure {
        newState("_abcd:;").parse();
    }

    /// Test parsing "_abcde" (6 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored05() external pure {
        newState("_abcde:;").parse();
    }

    /// Test parsing "_abcdef" (7 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored06() external pure {
        newState("_abcdef:;").parse();
    }

    /// Test parsing "_abcdefg" (8 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored07() external pure {
        newState("_abcdefg:;").parse();
    }

    /// Test parsing "_abcdefgh" (9 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored08() external pure {
        newState("_abcdefgh:;").parse();
    }

    /// Test parsing "_abcdefghi" (10 chars) an ignored LHS item.
    function testParseGasSingleLHSIgnored09() external pure {
        newState("_abcdefghi:;").parse();
    }
}
