// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseSingleRHSNamedGasTest
/// Parse a single RHS name for many different sized RHS names just to include
/// the gas cost of the name lookup in the gas snapshot.
contract LibParseSingleRHSNamedGasTest is Test {
    /// We build a shared meta for all the tests to simplify the implementation
    /// of each. It also makes it easier to compare the expected bytes across
    /// tests.
    bytes internal meta;

    /// Constructor just builds the shared meta.
    constructor() {
        bytes32[] memory words = new bytes32[](32);
        words[0] = bytes32("a");
        words[1] = bytes32("aa");
        words[2] = bytes32("aaa");
        words[3] = bytes32("aaaa");
        words[4] = bytes32("aaaaa");
        words[5] = bytes32("aaaaaa");
        words[6] = bytes32("aaaaaaa");
        words[7] = bytes32("aaaaaaaa");
        words[8] = bytes32("aaaaaaaaa");
        words[9] = bytes32("aaaaaaaaaa");
        words[10] = bytes32("aaaaaaaaaaa");
        words[11] = bytes32("aaaaaaaaaaaa");
        words[12] = bytes32("aaaaaaaaaaaaa");
        words[13] = bytes32("aaaaaaaaaaaaaa");
        words[14] = bytes32("aaaaaaaaaaaaaaa");
        words[15] = bytes32("aaaaaaaaaaaaaaaa");
        words[16] = bytes32("aaaaaaaaaaaaaaaaa");
        words[17] = bytes32("aaaaaaaaaaaaaaaaaa");
        words[18] = bytes32("aaaaaaaaaaaaaaaaaaa");
        words[19] = bytes32("aaaaaaaaaaaaaaaaaaaa");
        words[20] = bytes32("aaaaaaaaaaaaaaaaaaaaa");
        words[21] = bytes32("aaaaaaaaaaaaaaaaaaaaaa");
        words[22] = bytes32("aaaaaaaaaaaaaaaaaaaaaaa");
        words[23] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaa");
        words[24] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaa");
        words[25] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaa");
        words[26] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaaa");
        words[27] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        words[28] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        words[29] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        words[30] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
        words[31] = bytes32("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");

        meta = LibParseMeta.buildMetaExpander(words, 2);
    }

    /// Test parsing "a" (1 char) as the RHS.
    function testParseGasRHS00() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:a();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aa" (2 chars) as the RHS.
    function testParseGasRHS01() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaa" (3 chars) as the RHS.
    function testParseGasRHS02() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaa" (4 chars) as the RHS.
    function testParseGasRHS03() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaa" (5 chars) as the RHS.
    function testParseGasRHS04() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaa" (6 chars) as the RHS.
    function testParseGasRHS05() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaa" (7 chars) as the RHS.
    function testParseGasRHS06() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaa" (8 chars) as the RHS.
    function testParseGasRHS07() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaa" (9 chars) as the RHS.
    function testParseGasRHS08() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaa" (10 chars) as the RHS.
    function testParseGasRHS09() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaa" (11 chars) as the RHS.
    function testParseGasRHS10() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaa" (12 chars) as the RHS.
    function testParseGasRHS11() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaa" (13 chars) as the RHS.
    function testParseGasRHS12() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaa" (14 chars) as the RHS.
    function testParseGasRHS13() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaa" (15 chars) as the RHS.
    function testParseGasRHS14() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaa" (16 chars) as the RHS.
    function testParseGasRHS15() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaa" (17 chars) as the RHS.
    function testParseGasRHS16() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaa" (18 chars) as the RHS.
    function testParseGasRHS17() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaa" (19 chars) as the RHS.
    function testParseGasRHS18() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaa" (20 chars) as the RHS.
    function testParseGasRHS19() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaa" (21 chars) as the RHS.
    function testParseGasRHS20() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaa" (22 chars) as the RHS.
    function testParseGasRHS21() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaa" (23 chars) as the RHS.
    function testParseGasRHS22() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaa" (24 chars) as the RHS.
    function testParseGasRHS23() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaa" (25 chars) as the RHS.
    function testParseGasRHS24() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaa" (26 chars) as the RHS.
    function testParseGasRHS25() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaa" (27 chars) as the RHS.
    function testParseGasRHS26() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaa" (28 chars) as the RHS.
    function testParseGasRHS27() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (29 chars) as the RHS.
    function testParseGasRHS28() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (30 chars) as the RHS.
    function testParseGasRHS29() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (31 chars) as the RHS.
    function testParseGasRHS30() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (32 chars) as the RHS.
    function testParseGasRHS31() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }

    /// Test parsing "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (33 chars) as the RHS.
    function testParseGasRHS32() external view {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes("_:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa();"), meta);
        (sources);
        (constants);
    }
}