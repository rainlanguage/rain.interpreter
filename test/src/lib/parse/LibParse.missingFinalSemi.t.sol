// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";

import {LibParse} from "src/lib/parse/LibParse.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";
import {MissingFinalSemi} from "src/error/ErrParse.sol";

/// @title LibParseMissingFinalSemiTest
/// @notice Tests that missing final semicolons are rejected. Every expression
/// MUST end with a semicolon as the EOF character.
contract LibParseMissingFinalSemiTest is Test {
    using LibParse for ParseState;

    /// A lone colon should revert as missing a semi.
    function testParseMissingFinalSemiRevertsLoneColon() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 1));
        LibMetaFixture.newState(":").parse();
    }

    /// A lone colon after an empty source should error as missing a semi.
    function testParseMissingFinalSemiRevertsEmptySource() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibMetaFixture.newState(":;:").parse();
    }

    /// An empty source with a trailing comma should error as missing a semi.
    function testParseMissingFinalSemiRevertsTrailingComma() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 2));
        LibMetaFixture.newState(":,").parse();
    }

    /// A single word without a trailing semi should error as missing a semi.
    function testParseMissingFinalSemiRevertsSingleWord() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 4));
        LibMetaFixture.newState(":a()").parse();
    }

    /// Some detached LHS items should error as missing a semi.
    function testParseMissingFinalSemiRevertsLHSItems() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibMetaFixture.newState("_ _").parse();
    }
}
