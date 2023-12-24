// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/parse/LibMetaFixture.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseMissingFinalSemiTest
/// @notice Tests that missing final semicolons are rejected. Every expression
/// MUST end with a semicolon as the EOF character.
contract LibParseMissingFinalSemiTest is Test {
    /// A lone colon should revert as missing a semi.
    function testParseMissingFinalSemiRevertsLoneColon() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 1));
        LibParse.parse(":", "");
    }

    /// A lone colon after an empty source should error as missing a semi.
    function testParseMissingFinalSemiRevertsEmptySource() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibParse.parse(":;:", "");
    }

    /// An empty source with a trailing comma should error as missing a semi.
    function testParseMissingFinalSemiRevertsTrailingComma() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 2));
        LibParse.parse(":,", "");
    }

    /// A single word without a trailing semi should error as missing a semi.
    function testParseMissingFinalSemiRevertsSingleWord() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 4));
        LibParse.parse(":a()", LibMetaFixture.parseMetaV2());
    }

    /// Some detached LHS items should error as missing a semi.
    function testParseMissingFinalSemiRevertsLHSItems() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibParse.parse("_ _", LibMetaFixture.parseMetaV2());
    }
}
