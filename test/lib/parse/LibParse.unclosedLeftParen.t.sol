// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/parse/LibMetaFixture.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseUnclosedLeftParenTest
/// Test that the parser errors when it encounters an unclosed left paren.
contract LibParseUnclosedLeftParenTest is Test {
    /// Check the parser reverts if it encounters an unclosed left paren.
    function testParseUnclosedLeftParen() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 4));
        LibParse.parse("_:a(;", LibMetaFixture.parseMeta());
    }

    /// Multiple unclosed left parens should be reported.
    function testParseUnclosedLeftParenNested() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 17));
        LibParse.parse("_:a(b(c<0 0>(d(e(;", LibMetaFixture.parseMeta());
    }

    /// The parser should track the paren depth as it encounters left parens
    /// and report if there are any unclosed parens.
    function testParseUnclosedLeftParenNested2() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 21));
        LibParse.parse("_:a(b(c<0 0>(d(e())));", LibMetaFixture.parseMeta());
    }

    /// If there are multiple RHS nestings, the parser should still report the
    /// unclosed left parens.
    function testParseUnclosedLeftParenNested3() external {
        // Second nesting is unclosed.
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 28));
        LibParse.parse("_:a(b(c<0 0>(d(e())))) e(a();", LibMetaFixture.parseMeta());

        // First nesting is unclosed.
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 23));
        LibParse.parse("_:a(b(c<0 0>(d(e()))) e(a());", LibMetaFixture.parseMeta());
    }
}
