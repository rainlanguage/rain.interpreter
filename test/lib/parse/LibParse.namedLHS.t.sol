// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseNamedLHSTest
contract LibParseNamedLHSTest is Test {
    /// A few simple examples that should create some empty sources.
    function testParseNamedLHSEmptySourceExamples() external {
        string[3] memory examples0 = ["a:;", "a b:;", "foo bar:;"];
        for (uint256 i = 0; i < examples0.length; i++) {
            (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse(bytes(examples0[i]), "");
            assertEq(sources0.length, 1);
            assertEq(sources0[0].length, 0);
            assertEq(constants0.length, 0);
        }

        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse("a:;b:;", "");
        assertEq(sources1.length, 2);
        assertEq(sources1[0].length, 0);
        assertEq(sources1[1].length, 0);
        assertEq(constants1.length, 0);
    }

    /// Exceeding the maximum length of a word should revert. Testing a 32 char
    /// is right at the limit.
    function testParseNamedError32() external {
        // Only the first 32 chars are visible in the error.
        vm.expectRevert(abi.encodeWithSelector(WordSize.selector, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        // 32 chars is too long.
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Exceeding the maximum length of a word should revert. Testing a 33 char
    /// word shows the difference between the actual source and the error.
    /// (The latter is truncated).
    function testParseNamedError33() external {
        // Only the first 32 chars are visible in the error.
        vm.expectRevert(abi.encodeWithSelector(WordSize.selector, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        // 33 chars is too long.
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }
}
