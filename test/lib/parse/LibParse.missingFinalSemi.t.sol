// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseMissingFinalSemiTest
/// @notice Tests that missing final semicolons are rejected. Every expression
/// MUST end with a semicolon as the EOF character.
contract LibParseMissingFinalSemiTest is Test {
    /// A few simple examples that should revert due to the missing final
    /// semicolon.
    function testParseMissingFinalSemiReverts() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 1));
        LibParse.parse(":", "");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibParse.parse(":;:", "");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 2));
        LibParse.parse("::", "");
    }
}
