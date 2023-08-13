// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/parse/LibMetaFixture.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseUnexpectedRightParenTest
/// Test that the parser errors when it encounters an unexpected right paren.
contract LibParseUnexpectedRightParenTest is Test {
    /// Check the parser reverts if it encounters an unexpected right paren.
    function testParseUnexpectedRightParen() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedRightParen.selector, 1));
        // Meta can be empty because we should revert before we even try to
        // lookup any words.
        LibParse.parse(":);", "");
    }

    /// The parser should track the paren depth as it encounters left parens.
    function testParseUnexpectedRightParenNested() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedRightParen.selector, 7));
        LibParse.parse(":a(b()));", LibMetaFixture.parseMeta());
    }
}
