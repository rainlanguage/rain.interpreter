// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {LibParse} from "../LibParse.sol";
import {UnclosedSubParseableLiteral} from "../../../error/ErrParse.sol";
import {
    CMASK_WHITESPACE, CMASK_SUB_PARSEABLE_LITERAL_HEAD, CMASK_SUB_PARSEABLE_LITERAL_END
} from "../LibParseCMask.sol";
import {LibParseInterstitial} from "../LibParseInterstitial.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibSubParse} from "../LibSubParse.sol";

library LibParseLiteralSubParseable {
    using LibParse for ParseState;
    using LibParseInterstitial for ParseState;
    using LibParseError for ParseState;
    using LibSubParse for ParseState;

    function parseSubParseable(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        unchecked {
            // Move cursor past opening bracket.
            // Caller is responsible for checking that the cursor is pointing
            // at a sub parseable literal.
            ++cursor;

            uint256 dispatchStart = cursor;

            // Skip all non-whitespace and non-bracket characters.
            cursor = LibParse.skipMask(cursor, end, ~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_HEAD));
            uint256 dispatchEnd = cursor;

            // Skip any whitespace.
            cursor = state.skipWhitespace(cursor, end);

            uint256 bodyStart = cursor;

            // Skip all chars til the close.
            cursor = LibParse.skipMask(cursor, end, ~CMASK_SUB_PARSEABLE_LITERAL_END);
            uint256 bodyEnd = cursor;

            {
                uint256 finalChar;
                assembly ("memory-safe") {
                    finalChar := shl(byte(0, mload(cursor)), 1)
                }
                if ((finalChar & CMASK_SUB_PARSEABLE_LITERAL_END) == 0) {
                    revert UnclosedSubParseableLiteral(state.parseErrorOffset(cursor));
                }
            }

            // Move cursor past closing bracket.
            ++cursor;

            return (cursor, state.subParseLiteral(dispatchStart, dispatchEnd, bodyStart, bodyEnd));
        }
    }
}
