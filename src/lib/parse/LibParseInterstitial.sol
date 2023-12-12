// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {FSM_YANG_MASK, ParseState} from "./LibParseState.sol";
import {CMASK_COMMENT_HEAD, CMASK_WHITESPACE, COMMENT_END_SEQUENCE, COMMENT_START_SEQUENCE} from "./LibParseCMask.sol";
import {ParserOutOfBounds, MalformedCommentStart} from "../../error/ErrParse.sol";
import {LibParseError} from "./LibParseError.sol";
import {LibParse} from "./LibParse.sol";

library LibParseInterstitial {
    using LibParse for ParseState;
    using LibParseError for ParseState;
    using LibParseInterstitial for ParseState;

    /// The cursor currently points at the head of a comment. We need to skip
    /// over all data until we find the end of the comment. This MAY REVERT if
    /// the comment is malformed, e.g. if the comment doesn't start with `/*`.
    /// @param state The parser state.
    /// @param cursor The current cursor position.
    /// @return The new cursor position.
    function skipComment(ParseState memory state, uint256 cursor) internal pure returns (uint256) {
        // Set yang for comments to force a little breathing room between
        // comments and the next item.
        state.fsm |= FSM_YANG_MASK;

        // First check the comment opening sequence is not malformed.
        uint256 startSequence;
        assembly ("memory-safe") {
            startSequence := shr(0xf0, mload(cursor))
        }
        if (startSequence != COMMENT_START_SEQUENCE) {
            revert MalformedCommentStart(state.parseErrorOffset(cursor));
        }
        uint256 commentEndSequenceStart = COMMENT_END_SEQUENCE >> 8;
        uint256 commentEndSequenceEnd = COMMENT_END_SEQUENCE & 0xFF;
        uint256 max;
        bytes memory data = state.data;
        assembly ("memory-safe") {
            // Move past the start sequence.
            cursor := add(cursor, 2)
            max := add(data, add(mload(data), 0x20))

            // Loop until we find the end sequence.
            let done := 0
            for {} iszero(done) {} {
                for {} and(iszero(eq(byte(0, mload(cursor)), commentEndSequenceStart)), lt(cursor, max)) {} {
                    cursor := add(cursor, 1)
                }
                // We have found the start of the end sequence. Now check the
                // end sequence is correct.
                cursor := add(cursor, 1)
                // Only exit the loop if the end sequence is correct. We don't
                // move the cursor forward unless we haven exact match on the
                // end byte. E.g. consider the sequence `/** comment **/`.
                if or(eq(byte(0, mload(cursor)), commentEndSequenceEnd), iszero(lt(cursor, max))) {
                    done := 1
                    cursor := add(cursor, 1)
                }
            }
        }
        // If the cursor is past the max we either never even started an end
        // sequence, or we started parsing an end sequence but couldn't complete
        // it. Either way, the comment is malformed, and the parser is OOB.
        if (cursor > max) {
            revert ParserOutOfBounds();
        }
        return cursor;
    }

    function skipWhitespace(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        unchecked {
            // Set ying as we now open to possibilities.
            state.fsm &= ~FSM_YANG_MASK;
            return LibParse.skipMask(cursor + 1, end, CMASK_WHITESPACE);
        }
    }

    function parseInterstitial(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        while (cursor < end) {
            uint256 char;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }
            if (char & CMASK_WHITESPACE > 0) {
                cursor = state.skipWhitespace(cursor, end);
            } else if (char & CMASK_COMMENT_HEAD > 0) {
                cursor = state.skipComment(cursor);
            } else {
                break;
            }
        }
        return cursor;
    }
}
