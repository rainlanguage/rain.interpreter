// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {
    CMASK_COMMENT_HEAD,
    CMASK_EOS,
    CMASK_EOL,
    CMASK_LITERAL_HEAD,
    CMASK_WHITESPACE,
    CMASK_RIGHT_PAREN,
    CMASK_LEFT_PAREN,
    CMASK_RHS_WORD_TAIL,
    CMASK_RHS_WORD_HEAD,
    CMASK_LHS_RHS_DELIMITER,
    CMASK_LHS_STACK_TAIL,
    CMASK_LHS_STACK_HEAD,
    COMMENT_START_SEQUENCE,
    COMMENT_END_SEQUENCE,
    CMASK_IDENTIFIER_HEAD
} from "./LibParseCMask.sol";
import {LibCtPop} from "../bitwise/LibCtPop.sol";
import {LibParseMeta} from "./LibParseMeta.sol";
import {LibParseLiteral} from "./LibParseLiteral.sol";
import {LibParseOperand} from "./LibParseOperand.sol";
import {Operand, OPCODE_STACK} from "../../interface/unstable/IInterpreterV2.sol";
import {LibParseStackName} from "./LibParseStackName.sol";
import {
    ExcessLHSItems,
    ExcessRHSItems,
    NotAcceptingInputs,
    ParseStackUnderflow,
    ParseStackOverflow,
    UnexpectedRHSChar,
    UnexpectedRightParen,
    WordSize,
    DuplicateLHSItem,
    ParserOutOfBounds,
    ExpectedLeftParen,
    UnexpectedLHSChar,
    DanglingSource,
    MaxSources,
    UnclosedLeftParen,
    MissingFinalSemi,
    UnexpectedComment,
    ParenOverflow,
    UnknownWord,
    MalformedCommentStart
} from "../../error/ErrParse.sol";
import {
    LibParseState,
    ParseState,
    FSM_YANG_MASK,
    FSM_DEFAULT,
    FSM_ACTIVE_SOURCE_MASK,
    FSM_WORD_END_MASK
} from "./LibParseState.sol";
import {LibParsePragma} from "./LibParsePragma.sol";
import {LibParseInterstitial} from "./LibParseInterstitial.sol";
import {LibParseError} from "./LibParseError.sol";

uint256 constant NOT_LOW_16_BIT_MASK = ~uint256(0xFFFF);
uint256 constant ACTIVE_SOURCE_MASK = NOT_LOW_16_BIT_MASK;

library LibParse {
    using LibPointer for Pointer;
    using LibParseStackName for ParseState;
    using LibParseState for ParseState;
    using LibParseInterstitial for ParseState;
    using LibParseError for ParseState;
    using LibParseMeta for ParseState;
    using LibParsePragma for ParseState;
    using LibParse for ParseState;

    function parseWord(uint256 cursor, uint256 mask) internal pure returns (uint256, bytes32) {
        bytes32 word;
        uint256 i = 1;
        assembly ("memory-safe") {
            // word is head + tail
            word := mload(cursor)
            // loop over the tail
            //slither-disable-next-line incorrect-shift
            for {} and(lt(i, 0x20), iszero(and(shl(byte(i, word), 1), not(mask)))) { i := add(i, 1) } {}
            let scrub := mul(sub(0x20, i), 8)
            word := shl(scrub, shr(scrub, word))
            cursor := add(cursor, i)
        }
        if (i == 0x20) {
            revert WordSize(string(abi.encodePacked(word)));
        }
        return (cursor, word);
    }

    /// Skip an unlimited number of chars until we find one that is not in the
    /// mask.
    function skipMask(uint256 cursor, uint256 end, uint256 mask) internal pure returns (uint256) {
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            for {} and(lt(cursor, end), gt(and(shl(byte(0, mload(cursor)), 1), mask), 0)) { cursor := add(cursor, 1) } {}
        }
        return cursor;
    }

    function parseLHS(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        while (cursor < end) {
            bytes32 word;
            uint256 char;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                char := shl(byte(0, mload(cursor)), 1)
            }

            if (char & CMASK_LHS_STACK_HEAD > 0) {
                // if yang we can't start new stack item
                if (state.fsm & FSM_YANG_MASK > 0) {
                    revert UnexpectedLHSChar(state.parseErrorOffset(cursor));
                }

                // Named stack item.
                if (char & CMASK_IDENTIFIER_HEAD > 0) {
                    (cursor, word) = parseWord(cursor, CMASK_LHS_STACK_TAIL);
                    (bool exists, uint256 index) = state.pushStackName(word);
                    (index);
                    // If the stack name already exists, then we
                    // revert as shadowing is not allowed.
                    if (exists) {
                        revert DuplicateLHSItem(state.parseErrorOffset(cursor));
                    }
                }
                // Anon stack item.
                else {
                    cursor = skipMask(cursor + 1, end, CMASK_LHS_STACK_TAIL);
                }
                // Bump the index regardless of whether the stack
                // item is named or not.
                state.topLevel1++;
                state.lineTracker++;

                // Set yang as we are now building a stack item.
                state.fsm |= FSM_YANG_MASK | FSM_ACTIVE_SOURCE_MASK;
            } else if (char & CMASK_WHITESPACE != 0) {
                cursor = skipMask(cursor + 1, end, CMASK_WHITESPACE);
                // Set ying as we now open to possibilities.
                state.fsm &= ~FSM_YANG_MASK;
            } else if (char & CMASK_LHS_RHS_DELIMITER != 0) {
                // Set RHS and yin.
                state.fsm = (state.fsm | FSM_ACTIVE_SOURCE_MASK) & ~FSM_YANG_MASK;
                cursor++;
                break;
            } else {
                if (char & CMASK_COMMENT_HEAD != 0) {
                    revert UnexpectedComment(state.parseErrorOffset(cursor));
                } else {
                    revert UnexpectedLHSChar(state.parseErrorOffset(cursor));
                }
            }
        }
        return cursor;
    }

    function parseRHS(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        while (cursor < end) {
            bytes32 word;
            uint256 char;
            assembly ("memory-safe") {
                char := shl(byte(0, mload(cursor)), 1)
            }

            if (char & CMASK_RHS_WORD_HEAD > 0) {
                // If yang we can't start a new word.
                if (state.fsm & FSM_YANG_MASK > 0) {
                    revert UnexpectedRHSChar(state.parseErrorOffset(cursor));
                }

                (cursor, word) = parseWord(cursor, CMASK_RHS_WORD_TAIL);

                // First check if this word is in meta.
                (
                    bool exists,
                    uint256 opcodeIndex,
                    function(ParseState memory, uint256) pure returns (uint256, Operand) operandParser
                ) = state.lookupWord(word);
                if (exists) {
                    Operand operand;
                    (cursor, operand) = operandParser(state, cursor);
                    state.pushOpToSource(opcodeIndex, operand);
                    // This is a real word so we expect to see parens
                    // after it.
                    state.fsm |= FSM_WORD_END_MASK;
                }
                // Fallback to LHS items.
                else {
                    (exists, opcodeIndex) = state.stackNameIndex(word);
                    if (exists) {
                        state.pushOpToSource(OPCODE_STACK, Operand.wrap(opcodeIndex));
                        // Need to process highwater here because we
                        // don't have any parens to open or close.
                        state.highwater();
                    } else {
                        revert UnknownWord(state.parseErrorOffset(cursor));
                    }
                }

                state.fsm |= FSM_YANG_MASK;
            }
            // If this is the end of a word we MUST start a paren.
            else if (state.fsm & FSM_WORD_END_MASK > 0) {
                if (char & CMASK_LEFT_PAREN == 0) {
                    revert ExpectedLeftParen(state.parseErrorOffset(cursor));
                }
                // Increase the paren depth by 1.
                // i.e. move the byte offset by 3
                // There MAY be garbage at this new offset due to
                // a previous paren group being deallocated. The
                // deallocation process writes the input counter
                // to zero but leaves a garbage word in place, with
                // the expectation that it will be overwritten by
                // the next paren group.
                uint256 newParenOffset;
                assembly ("memory-safe") {
                    newParenOffset := add(byte(0, mload(add(state, 0x60))), 3)
                    mstore8(add(state, 0x60), newParenOffset)
                }
                // first 2 bytes are reserved, then remaining 62
                // bytes are for paren groups, so the offset MUST NOT
                // imply writing to the 63rd byte.
                if (newParenOffset > 59) {
                    revert ParenOverflow();
                }
                cursor++;

                // We've moved past the paren, so we are no longer at
                // the end of a word and are yin.
                state.fsm &= ~(FSM_WORD_END_MASK | FSM_YANG_MASK);
            } else if (char & CMASK_RIGHT_PAREN > 0) {
                uint256 parenOffset;
                assembly ("memory-safe") {
                    parenOffset := byte(0, mload(add(state, 0x60)))
                }
                if (parenOffset == 0) {
                    revert UnexpectedRightParen(state.parseErrorOffset(cursor));
                }
                // Decrease the paren depth by 1.
                // i.e. move the byte offset by -3.
                // This effectively deallocates the paren group, so
                // write the input counter out to the operand pointed
                // to by the pointer we deallocated.
                assembly ("memory-safe") {
                    // State field offset.
                    let stateOffset := add(state, 0x60)
                    parenOffset := sub(parenOffset, 3)
                    mstore8(stateOffset, parenOffset)
                    mstore8(
                        // Add 2 for the reserved bytes to the offset
                        // then read top 16 bits from the pointer.
                        // Add 1 to sandwitch the inputs byte between
                        // the opcode index byte and the operand low
                        // bytes.
                        add(1, shr(0xf0, mload(add(add(stateOffset, 2), parenOffset)))),
                        // Store the input counter, which is 2 bytes
                        // after the operand write pointer.
                        byte(0, mload(add(add(stateOffset, 4), parenOffset)))
                    )
                }
                state.highwater();
                cursor++;
            } else if (char & CMASK_WHITESPACE > 0) {
                cursor = skipMask(cursor + 1, end, CMASK_WHITESPACE);
                // Set yin as we now open to possibilities.
                state.fsm &= ~FSM_YANG_MASK;
            }
            // Handle all literals.
            else if (char & CMASK_LITERAL_HEAD > 0) {
                cursor = state.pushLiteral(cursor);
                state.highwater();
                // We are yang now. Need the next char to release to
                // yin.
                state.fsm |= FSM_YANG_MASK;
            } else if (char & CMASK_EOL > 0) {
                state.endLine(cursor);
                cursor++;
                break;
            }
            // End of source.
            else if (char & CMASK_EOS > 0) {
                state.endLine(cursor);
                state.endSource();
                cursor++;

                state.fsm = FSM_DEFAULT;
                break;
            }
            // Comments aren't allowed in the RHS but we can give a
            // nicer error message than the default.
            else if (char & CMASK_COMMENT_HEAD != 0) {
                revert UnexpectedComment(state.parseErrorOffset(cursor));
            } else {
                revert UnexpectedRHSChar(state.parseErrorOffset(cursor));
            }
        }
        return cursor;
    }

    function parse(bytes memory data, bytes memory meta)
        internal
        pure
        returns (bytes memory bytecode, uint256[] memory)
    {
        unchecked {
            ParseState memory state = LibParseState.newState(data, meta);
            if (data.length > 0) {
                uint256 cursor;
                uint256 end;
                assembly ("memory-safe") {
                    cursor := add(data, 0x20)
                    end := add(cursor, mload(data))
                }
                cursor = state.parseInterstitial(cursor, end);
                cursor = state.parsePragma(cursor, end);
                while (cursor < end) {
                    cursor = state.parseInterstitial(cursor, end);
                    cursor = state.parseLHS(cursor, end);
                    cursor = state.parseRHS(cursor, end);
                }
                if (cursor != end) {
                    revert ParserOutOfBounds();
                }
                if (state.fsm & FSM_ACTIVE_SOURCE_MASK != 0) {
                    revert MissingFinalSemi(state.parseErrorOffset(cursor));
                }
            }
            return (state.buildBytecode(), state.buildConstants());
        }
    }
}
