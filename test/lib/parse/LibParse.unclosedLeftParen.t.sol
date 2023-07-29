// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

import "test/util/lib/io/LibIOFnPointers.sol";

/// @title LibParseUnclosedLeftParenTest
/// Test that the parser errors when it encounters an unclosed left paren.
contract LibParseUnclosedLeftParenTest is Test {
    /// Build a shared meta for all the tests to simplify the implementation
    /// of each. It also makes it easier to compare the expected bytes across
    /// tests.
    bytes internal meta;

    /// Constructor just builds the shared meta.
    constructor() {
        bytes32[] memory words = new bytes32[](5);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        words[2] = bytes32("c");
        words[3] = bytes32("d");
        words[4] = bytes32("e");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// Check the parser reverts if it encounters an unclosed left paren.
    function testParseUnclosedLeftParen() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 4));
        LibParse.parse("_:a(;", meta);
    }

    /// Multiple unclosed left parens should be reported.
    function testParseUnclosedLeftParenNested() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 12));
        LibParse.parse("_:a(b(c(d(e(;", meta);
    }

    /// The parser should track the paren depth as it encounters left parens
    /// and report if there are any unclosed parens.
    function testParseUnclosedLeftParenNested2() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 16));
        LibParse.parse("_:a(b(c(d(e())));", meta);
    }

    /// If there are multiple RHS nestings, the parser should still report the
    /// unclosed left parens.
    function testParseUnclosedLeftParenNested3() external {
        // Second nesting is unclosed.
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 23));
        LibParse.parse("_:a(b(c(d(e())))) e(a();", meta);

        // First nesting is unclosed.
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 23));
        LibParse.parse("_:a(b(c(d(e()))) e(a());", meta);
    }
}
