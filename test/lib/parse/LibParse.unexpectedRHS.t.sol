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
        uint256 shifted = 1 << uint8(unexpected);
        // Word heads are expected in this position.
        vm.assume(shifted & CMASK_RHS_WORD_HEAD == 0);
        // Right parens are NOT expected in this position but have a dedicated
        // error message.
        vm.assume(shifted & CMASK_RIGHT_PAREN == 0);
        // Whitespace is expected in this position.
        vm.assume(shifted & CMASK_WHITESPACE == 0);
        // EOL is expected in this position. Note that the implied string for
        // this test ":,;` is NOT valid.
        vm.assume(shifted & CMASK_EOL == 0);
        // EOS is also expected in this position. Note that the implied string
        // for this test ":;;` is NOT valid.
        vm.assume(shifted & CMASK_EOS == 0);

        string memory unexpectedString = string(abi.encodePacked(unexpected));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 1, unexpectedString));
        // Meta can be empty because we should revert before we even try to
        // lookup any words.
        LibParse.parse(bytes.concat(":", unexpected, ";"), "");
    }
}
