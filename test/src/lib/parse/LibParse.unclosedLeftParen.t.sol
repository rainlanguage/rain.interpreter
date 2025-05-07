// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {UnclosedLeftParen} from "src/error/ErrParse.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseUnclosedLeftParenTest
/// Test that the parser errors when it encounters an unclosed left paren.
contract LibParseUnclosedLeftParenTest is Test {
    using LibParse for ParseState;

    /// Check the parser reverts if it encounters an unclosed left paren.
    function testParseUnclosedLeftParen() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 4));
        LibMetaFixture.newState("_:a(;").parse();
    }

    /// Multiple unclosed left parens should be reported.
    function testParseUnclosedLeftParenNested() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 20));
        LibMetaFixture.newState("_:a(b(c<0 0>(d(e<0>(;").parse();
    }

    /// The parser should track the paren depth as it encounters left parens
    /// and report if there are any unclosed parens.
    function testParseUnclosedLeftParenNested2() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 24));
        LibMetaFixture.newState("_:a(b(c<0 0>(d(e<0>())));").parse();
    }

    /// If there are multiple RHS nestings, the parser should still report the
    /// unclosed left parens.
    function testParseUnclosedLeftParenNested3() external {
        // Second nesting is unclosed.
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 34));
        LibMetaFixture.newState("_:a(b(c<0 0>(d(e<0>())))) e<0>(a();").parse();

        // First nesting is unclosed.
        vm.expectRevert(abi.encodeWithSelector(UnclosedLeftParen.selector, 23));
        LibMetaFixture.newState("_:a(b(c<0 0>(d(e<0>()))) e<0>(a());").parse();
    }
}
