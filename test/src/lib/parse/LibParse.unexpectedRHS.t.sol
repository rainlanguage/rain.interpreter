// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ParseTest} from "test/abstract/ParseTest.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {UnexpectedRHSChar} from "src/error/ErrParse.sol";
import {
    CMASK_RHS_WORD_HEAD,
    CMASK_LITERAL_HEAD,
    CMASK_RIGHT_PAREN,
    CMASK_WHITESPACE,
    CMASK_EOL,
    CMASK_EOS,
    CMASK_COMMENT_HEAD
} from "rain.string/lib/parse/LibParseCMask.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseUnexpectedRHSTest
/// @notice The parser should revert if it encounters an unexpected character on the RHS.
contract LibParseUnexpectedRHSTest is ParseTest {
    using LibParse for ParseState;

    /// Check the parser reverts if it encounters an unexpected character as the
    /// first character on the RHS.
    function testParseUnexpectedRHS(uint8 unexpected) external {
        //forge-lint: disable-next-line(incorrect-shift)
        uint256 shifted = 1 << unexpected;
        vm.assume(
            0
                == shifted
                    // Word heads are expected in this position.
                    & (CMASK_RHS_WORD_HEAD
                        // Literals are expected in this position.
                        | CMASK_LITERAL_HEAD
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
                        // Comments will give a more specialized error on the RHS.
                        | CMASK_COMMENT_HEAD)
        );
        string memory s = string(bytes.concat(":", bytes1(unexpected), ";"));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 1));
        (bytes memory bytecode, bytes32[] memory constants) = this.parseExternal(s);
        (bytecode, constants);
    }

    /// Check the parser reverts on a left paren as the first character on the
    /// RHS.
    function testParseUnexpectedRHSLeftParen() external {
        string memory s = ":();";

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 1));
        (bytes memory bytecode, bytes32[] memory constants) = this.parseExternal(s);
        (bytecode, constants);
    }
}
