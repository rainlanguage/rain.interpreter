// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {AuthoringMetaV2} from "src/interface/IParserV1.sol";
import {LibParseMeta} from "src/lib/parse/LibParseMeta.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";

/// @title LibParseSingleRHSNamedGasTest
/// Parse a single RHS name for many different sized RHS names just to include
/// the gas cost of the name lookup in the gas snapshot.
contract LibParseSingleRHSNamedGasTest is Test {
    function parseMeta() internal pure returns (bytes memory) {
        AuthoringMetaV2[] memory authoringMeta = new AuthoringMetaV2[](32);
        authoringMeta[0] = AuthoringMetaV2("a", 0, "a");
        authoringMeta[1] = AuthoringMetaV2("aa", 0, "aa");
        authoringMeta[2] = AuthoringMetaV2("aaa", 0, "aaa");
        authoringMeta[3] = AuthoringMetaV2("aaaa", 0, "aaaa");
        authoringMeta[4] = AuthoringMetaV2("aaaaa", 0, "aaaaa");
        authoringMeta[5] = AuthoringMetaV2("aaaaaa", 0, "aaaaaa");
        authoringMeta[6] = AuthoringMetaV2("aaaaaaa", 0, "aaaaaaa");
        authoringMeta[7] = AuthoringMetaV2("aaaaaaaa", 0, "aaaaaaaa");
        authoringMeta[8] = AuthoringMetaV2("aaaaaaaaa", 0, "aaaaaaaaa");
        authoringMeta[9] = AuthoringMetaV2("aaaaaaaaaa", 0, "aaaaaaaaaa");
        authoringMeta[10] = AuthoringMetaV2("aaaaaaaaaaa", 0, "aaaaaaaaaaa");
        authoringMeta[11] = AuthoringMetaV2("aaaaaaaaaaaa", 0, "aaaaaaaaaaaa");
        authoringMeta[12] = AuthoringMetaV2("aaaaaaaaaaaaa", 0, "aaaaaaaaaaaaa");
        authoringMeta[13] = AuthoringMetaV2("aaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaa");
        authoringMeta[14] = AuthoringMetaV2("aaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaa");
        authoringMeta[15] = AuthoringMetaV2("aaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaa");
        authoringMeta[16] = AuthoringMetaV2("aaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaa");
        authoringMeta[17] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaa");
        authoringMeta[18] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaa");
        authoringMeta[19] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaa");
        authoringMeta[20] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[21] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[22] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[23] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[24] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[25] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[26] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[27] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[28] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[29] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[30] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        authoringMeta[31] = AuthoringMetaV2("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");

        return LibParseMeta.buildParseMetaV2(authoringMeta, 2);
    }

    /// Test parsing "a" (1 char) as the RHS.
    function testParseGasRHS00() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:a();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aa" (2 chars) as the RHS.
    function testParseGasRHS01() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaa" (3 chars) as the RHS.
    function testParseGasRHS02() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaa" (4 chars) as the RHS.
    function testParseGasRHS03() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaa" (5 chars) as the RHS.
    function testParseGasRHS04() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaa" (6 chars) as the RHS.
    function testParseGasRHS05() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaa" (7 chars) as the RHS.
    function testParseGasRHS06() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaa" (8 chars) as the RHS.
    function testParseGasRHS07() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaa" (9 chars) as the RHS.
    function testParseGasRHS08() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaa" (10 chars) as the RHS.
    function testParseGasRHS09() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaa" (11 chars) as the RHS.
    function testParseGasRHS10() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaa" (12 chars) as the RHS.
    function testParseGasRHS11() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaa" (13 chars) as the RHS.
    function testParseGasRHS12() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaa" (14 chars) as the RHS.
    function testParseGasRHS13() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaa" (15 chars) as the RHS.
    function testParseGasRHS14() external pure {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaa" (16 chars) as the RHS.
    function testParseGasRHS15() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaa" (17 chars) as the RHS.
    function testParseGasRHS16() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaa" (18 chars) as the RHS.
    function testParseGasRHS17() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaa" (19 chars) as the RHS.
    function testParseGasRHS18() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaa" (20 chars) as the RHS.
    function testParseGasRHS19() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaa" (21 chars) as the RHS.
    function testParseGasRHS20() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaa" (22 chars) as the RHS.
    function testParseGasRHS21() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaa" (23 chars) as the RHS.
    function testParseGasRHS22() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaa" (24 chars) as the RHS.
    function testParseGasRHS23() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaa" (25 chars) as the RHS.
    function testParseGasRHS24() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaa" (26 chars) as the RHS.
    function testParseGasRHS25() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaa" (27 chars) as the RHS.
    function testParseGasRHS26() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaa" (28 chars) as the RHS.
    function testParseGasRHS27() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (29 chars) as the RHS.
    function testParseGasRHS28() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (30 chars) as the RHS.
    function testParseGasRHS29() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (31 chars) as the RHS.
    function testParseGasRHS30() external pure {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), parseMeta());
        (bytecode);
        (constants);
    }
}
