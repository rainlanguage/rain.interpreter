// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseIntegerLiteralHexTest
/// Tests parsing integer literal hex values.
contract LibParseIntegerLiteralHexTest is Test {

    bytes internal meta;

    constructor() {
        bytes32[] memory words = new bytes32[](6);
        words[0] = bytes32("constant");
        words[1] = bytes32("a");
        words[2] = bytes32("b");
        words[3] = bytes32("c");
        words[4] = bytes32("d");
        words[5] = bytes32("e");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// Check a single hex literal. Should not revert and return length 1
    /// sources and constants.
    function testParseIntegerLiteralHex00() external {
        (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse("_: 0x00;", meta);
        assertEq(sources0.length, 1);
        assertEq(sources0[0], hex"00000000");
        assertEq(constants0.length, 1);
        assertEq(constants0[0], 0x00);
    }

    // /// Check a single hex literal. Should not revert and return length 1
    // /// sources and constants.
    // function testParseIntegerLiteralHex01() external {
    //     (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse("0x1", "");
    //     assertEq(sources1.length, 1);
    //     assertEq(sources1[0].length, 0);
    //     assertEq(constants1.length, 1);
    //     assertEq(constants1[0], 1);
    // }

    // /// Check a single hex literal. Should not revert and return length 1
    // /// sources and constants.
    // function testParseIntegerLiteralHex02() external {
    //     (bytes[] memory sources2, uint256[] memory constants2) = LibParse.parse("0x2", "");
    //     assertEq(sources2.length, 1);
    //     assertEq(sources2[0].length, 0);
    //     assertEq(constants2.length, 1);
    //     assertEq(constants2[0], 2);
    // }

    // /// Check a single hex literal. Should not revert and return length 1
    // /// sources and constants.
    // function testParseIntegerLiteralHex03() external {
    //     (bytes[] memory sources3, uint256[] memory constants3) = LibParse.parse("0x3", "");
    //     assertEq(sources3.length, 1);
    //     assertEq(sources3[0].length, 0);
    //     assertEq(constants3.length, 1);
    //     assertEq(constants3[0], 3);
    // }
}