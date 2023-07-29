// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "test/util/lib/io/LibIOFnPointers.sol";

/// @title LibParseIntegerLiteralHexTest
/// Tests parsing integer literal hex values.
contract LibParseIntegerLiteralHexTest is Test {
    bytes internal meta;

    constructor() {
        bytes32[] memory words = new bytes32[](7);
        words[0] = bytes32("stack");
        words[1] = bytes32("constant");
        words[2] = bytes32("a");
        words[3] = bytes32("b");
        words[4] = bytes32("c");
        words[5] = bytes32("d");
        words[6] = bytes32("e");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// Check a single hex literal. Should not revert and return length 1
    /// sources and constants.
    function testParseIntegerLiteralHex00() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 0xa2;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"00010000");
        assertEq(constants.length, 1);
        assertEq(constants[0], 0xa2);
    }

    /// Check 2 hex literals. Should not revert and return one source and
    /// length 2 constants.
    function testParseIntegerLiteralHex01() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_ _: 0xa2 0x03;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"0001000000010001");
        assertEq(constants.length, 2);
        assertEq(constants[0], 0xa2);
        assertEq(constants[1], 0x03);
    }

    /// Check 3 hex literals with 2 dupes. Should dedupe and respect ordering.
    function testParseIntegerLiteralHex02() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_ _ _: 0xa2 0x03 0xa2;", meta);
        assertEq(sources.length, 1);
        // Sources represents all 3 literals, but the dupe is deduped so that the
        // operands only reference the first instance of the duped constant.
        assertEq(sources[0], hex"000100000001000100010000");
        assertEq(constants.length, 2);
        assertEq(constants[0], 0xa2);
        assertEq(constants[1], 0x03);
    }

    /// Check that we can parse uint256 max int in hex form.
    function testParseIntegerLiteralHexUint256Max() external {
        (bytes[] memory sources, uint256[] memory constants) =
            LibParse.parse("_: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"00010000");
        assertEq(constants.length, 1);
        assertEq(constants[0], type(uint256).max);
    }
}
