// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseUnexpectedRHSTest
/// The parser should revert if it encounters an unexpected character on the RHS.
contract LibParseUnexpectedRHSTest is Test {
    /// Check the parser reverts if it encounters an unexpected character as the
    /// first character on the RHS.
    function testParseUnexpectedRHS(bytes1 unexpected) external {
        vm.assume(unexpected != bytes1("\t"));
        vm.assume(unexpected != bytes1("\n"));
        vm.assume(unexpected != bytes1("\r"));
        vm.assume(unexpected != bytes1(" "));
        vm.assume(unexpected != bytes1(","));
        vm.assume(unexpected != bytes1(";"));

        string memory unexpectedString = string(abi.encodePacked(unexpected));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 1, unexpectedString));
        // Meta can be empty because we should revert before we even try to
        // lookup any words.
        LibParse.parse(bytes.concat(":", unexpected, ";"), "");
    }
}
