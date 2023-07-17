// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../lib/forge-std/src/Test.sol";

import "../../../src/lib/parse/LibParse.sol";

/// @title LibParseUnexpectedRHSTest
/// The parser should revert if it encounters an unexpected character on the RHS.
contract LibParseUnexpectedRHSTest is Test {
    /// Check the parser reverts if it encounters an unexpected character as the
    /// first character on the RHS.
    function testParseUnexpectedRHS(bytes1 unexpected) external {
        uint256 shifted = 1 << uint8(unexpected);
        vm.assume(
            0
                == shifted
                // Word heads are expected in this position.
                & (
                    CMASK_RHS_WORD_HEAD
                    // Right parens are NOT expected in this position but have a dedicated
                    // error message.
                    | CMASK_RIGHT_PAREN
                    // Whitespace is expected in this position.
                    | CMASK_WHITESPACE
                    // EOL is expected in this position. Note that the implied string for
                    // this test ":,;` is NOT valid.
                    | CMASK_EOL
                    // EOS is also expected in this position. Note that the implied string
                    // for this test ":;;` is NOT valid.
                    | CMASK_EOS
                )
        );

        string memory unexpectedString = string(abi.encodePacked(unexpected));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 1, unexpectedString));
        // Meta can be empty because we should revert before we even try to
        // lookup any words.
        LibParse.parse(bytes.concat(":", unexpected, ";"), "");
    }
}
