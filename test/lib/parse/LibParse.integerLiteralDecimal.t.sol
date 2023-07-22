// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseIntegerLiteralDecimalTest
/// Tests parsing integer literal decimal values.
contract LibParseIntegerLiteralDecimalTest is Test {
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

    /// Check a single decimal literal. Should not revert and return length 1
    /// sources and constants.
    function testParseIntegerLiteralDecimal00() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 1;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 1);
        assertEq(constants[0], 1);
    }

    /// Check 2 decimal literals. Should not revert and return one source and
    /// length 2 constants.
    function testParseIntegerLiteralDecimal01() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_ _: 10 25;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"0000000000000001");
        assertEq(constants.length, 2);
        assertEq(constants[0], 10);
        assertEq(constants[1], 25);
    }

    /// Check 3 decimal literals with 2 dupes. Should dedupe and respect ordering.
    function testParseIntegerLiteralDecimal02() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_ _ _: 11 233 11;", meta);
        assertEq(sources.length, 1);
        // Sources represents all 3 literals, but the dupe is deduped so that the
        // operands only reference the first instance of the duped constant.
        assertEq(sources[0], hex"000000000000000100000000");
        assertEq(constants.length, 2);
        assertEq(constants[0], 11);
        assertEq(constants[1], 233);
    }

    /// Check that we can parse uint256 max int in decimal form.
    function testParseIntegerLiteralDecimalUint256Max() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 115792089237316195423570985008687907853269984665640564039457584007913129639935;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 1);
        assertEq(constants[0], type(uint256).max);
    }

    /// Check that we can parse uint256 max int in decimal form with leading
    /// zeros.
    function testParseIntegerLiteralDecimalUint256MaxLeadingZeros() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 000115792089237316195423570985008687907853269984665640564039457584007913129639935;", meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 1);
        assertEq(constants[0], type(uint256).max);
    }

    /// Check that decimal literals will revert if they overflow uint256.
    function testParseIntegerLiteralDecimalUint256Overflow() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 3, "1"));
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 115792089237316195423570985008687907853269984665640564039457584007913129639936;", meta);
        (sources);
        (constants);
    }

    /// Check that decimal literals will revert if they overflow uint256 with
    /// leading zeros.
    function testParseIntegerLiteralDecimalUint256OverflowLeadingZeros() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 5, "1"));
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 00115792089237316195423570985008687907853269984665640564039457584007913129639936;", meta);
        (sources);
        (constants);
    }

    // Check that decimal literals will revert if they overflow uint256 with
    // a non-one leading digit.
    function testParseIntegerLiteralDecimalUint256OverflowLeadingDigit() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 3, "2"));
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 215792089237316195423570985008687907853269984665640564039457584007913129639935;", meta);
        (sources);
        (constants);
    }

    /// Check that decimal literals will revert if they overflow uint256 with
    /// a non-one leading digit and leading zeros.
    function testParseIntegerLiteralDecimalUint256OverflowLeadingDigitLeadingZeros() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 5, "2"));
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_: 00215792089237316195423570985008687907853269984665640564039457584007913129639935;", meta);
        (sources);
        (constants);
    }
}
