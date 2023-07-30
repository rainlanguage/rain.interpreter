// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseUnexpectedRightParenTest
/// Test that the parser errors when it encounters an unexpected right paren.
contract LibParseUnexpectedRightParenTest is Test {
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
        LibParse.parse(":a(b()));", meta);
    }
}
