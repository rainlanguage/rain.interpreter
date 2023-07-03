// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "sol.lib.memory/LibPointer.sol";
import "./LibCtPop.sol";
import "./LibParseMeta.sol";

/// The expression does not finish with a semicolon (EOF).
error MissingFinalSemi(uint256 offset);

/// Enountered an unexpected character on the LHS.
error UnexpectedLHSChar(uint256 offset, string char);

/// Encountered an unexpected character on the RHS.
error UnexpectedRHSChar(uint256 offset, string char);

/// Encountered a right paren without a matching left paren.
error UnexpectedRightParen(uint256 offset);

/// Enountered a word that is longer than 32 bytes.
error WordSize(string word);

/// Parsed a word that is not in the meta.
error UnknownWord(bytes32 word);

/// The parser exceeded the maximum number of sources that it can build.
error MaxSources();

/// The parser encountered a dangling source. This is a bug in the parser.
error DanglingSource();

/// @dev \t
uint128 constant CMASK_TAB = 0x200;

/// @dev \n
uint128 constant CMASK_LINE_FEED = 0x400;

/// @dev \r
uint128 constant CMASK_CARRIAGE_RETURN = 0x2000;

/// @dev space
uint128 constant CMASK_SPACE = 0x0100000000;

/// @dev ,
uint128 constant CMASK_COMMA = 0x100000000000;
uint128 constant CMASK_EOL = CMASK_COMMA;

/// @dev -
uint128 constant CMASK_DASH = 0x200000000000;

/// @dev :
uint128 constant CMASK_COLON = 0x0400000000000000;
/// @dev LHS/RHS delimiter is :
uint128 constant CMASK_LHS_RHS_DELIMITER = CMASK_COLON;

/// @dev ;
uint128 constant CMASK_SEMICOLON = 0x800000000000000;
uint128 constant CMASK_EOS = CMASK_SEMICOLON;

/// @dev _
uint128 constant CMASK_UNDERSCORE = 0x800000000000000000000000;

/// @dev (
uint128 constant CMASK_LEFT_PAREN = 0x10000000000;

/// @dev )
uint128 constant CMASK_RIGHT_PAREN = 0x20000000000;

/// @dev lower alpha and underscore a-z _
uint128 constant CMASK_LHS_STACK_HEAD = 0xffffffe800000000000000000000000;

/// @dev lower alpha a-z
uint128 constant CMASK_IDENTIFIER_HEAD = 0xffffffe000000000000000000000000;
uint128 constant CMASK_RHS_WORD_HEAD = CMASK_IDENTIFIER_HEAD;

/// @dev lower alphanumeric kebab a-z 0-9 -
uint128 constant CMASK_IDENTIFIER_TAIL = 0xffffffe0000000003ff200000000000;
uint128 constant CMASK_LHS_STACK_TAIL = CMASK_IDENTIFIER_TAIL;
uint128 constant CMASK_RHS_WORD_TAIL = CMASK_IDENTIFIER_TAIL;

/// @dev NOT lower alphanumeric kebab
uint128 constant CMASK_NOT_IDENTIFIER_TAIL = 0xf0000001fffffffffc00dfffffffffff;

/// @dev whitespace is \n \r \t space
uint128 constant CMASK_WHITESPACE = 0x100002600;

/// @dev stack item delimiter is whitespace
uint128 constant CMASK_LHS_STACK_DELIMITER = CMASK_WHITESPACE;

uint256 constant NOT_LOW_16_BIT_MASK = ~uint256(0xFFFF);
uint256 constant ACTIVE_SOURCE_MASK = NOT_LOW_16_BIT_MASK;

uint256 constant FSM_LHS_MASK = 1;
uint256 constant FSM_YANG_MASK = 1 << 1;
uint256 constant FSM_WORD_END_MASK = 1 << 2;

uint256 constant EMPTY_ACTIVE_SOURCE = 0x20;

/// The parser is stateful. This struct keeps track of the entire state.
/// @param activeSource The current source being built.
/// - low 16 bits: bitwise offset into the source for the next word to be
///   written. Starts at 0x20. Once a source is no longer the active source, i.e.
///   it is full and a member of the LL tail, the offset is replaced with a
///   pointer to the next source to build a doubly linked list.
/// - mid 16 bits: pointer to the previous active source. This is a linked list
///   of sources that are built RTL and then reversed to LTR to eval.
/// - high bits: 4 byte opcodes and operand pairs.
/// @param sourcesBuilder A builder for the sources array. This is a 256 bit
/// integer where each 16 bits is a literal memory pointer to a source.
/// @param parenDepth The current paren depth. Each left paren increments this
/// value and each right paren decrements it. The parser fails if this value
/// ever goes negative.
/// @param fsm The finite state machine representation of the parser.
/// - bit 0: LHS/RHS => 0 = LHS, 1 = RHS
/// - bit 1: yang/yin => 0 = yin, 1 = yang
/// - bit 2: word end => 0 = not end, 1 = end
/// @param stackIndex The current stack index. This is equal to the number of
/// items on the LHS.
/// @param stackNames A linked list of stack names. As the parser encounters
/// named stack items it pushes them onto this linked list. The linked list is
/// in FILO order, so the first item on the stack is the last item in the list.
/// This makes it more efficient to reference more recent stack names on the RHS.
/// @param constantsBuilder A builder for the constants array.
struct ParseState {
    /// @dev WARNING: Referenced directly in assembly. If the order of these
    /// fields changes, the assembly must be updated. Specifically, activeSource
    /// is referenced as a pointer in pushWordToSource.
    uint256 activeSource;
    uint256 sourcesBuilder;
    uint256 parenDepth;
    uint256 fsm;
    uint256 stackIndex;
    uint256 stackNames;
    uint256 constantsBuilder;
}

library LibParseState {
    function newState() internal pure returns (ParseState memory) {
        return ParseState(EMPTY_ACTIVE_SOURCE, 0, 0, FSM_LHS_MASK, 0, 0, 0);
    }

    function pushStackName(ParseState memory state, bytes32 word) internal pure {
        uint256 fingerprint;
        uint256 ptr;
        uint256 oldStackNames = state.stackNames;
        assembly ("memory-safe") {
            ptr := mload(0x40)
            mstore(ptr, word)
            fingerprint := and(keccak256(ptr, 0x20), not(0xFFFFFFFF))
            mstore(ptr, oldStackNames)
            mstore(0x40, add(ptr, 0x20))
        }
        state.stackNames = fingerprint | (state.stackIndex << 0x10) | ptr;
    }

    function pushWordToSource(ParseState memory state, bytes memory meta, bytes32 word) internal pure {
        unchecked {
            // Convert the word to an offset that can be used to compile function
            // pointers later.
            (bool exists, uint256 i) = LibParseMeta.lookupIndexMetaExpander(meta, word);

            uint256 activeSource = state.activeSource;
            // The low 16 bits of the active source is the current offset.
            uint256 offset = uint16(activeSource);

            // We write sources RTL so they can run LTR.
            activeSource =
            // increment offset. We have 16 bits allocated to the offset and stop
            // processing at 0x100 so this never overflows into the actual source
            // data.
            activeSource + 0x20
            // include new op
            | i << (offset + 0x10);

            // Maintenance branches.
            // The lookup failed so the entire parsing process failed.
            if (!exists) {
                revert UnknownWord(word);
            }
            // We have filled the current source slot. Need to to shift it off
            // to a newly allocated region of memory and reset the current active
            // source. Both slots reference each other as a doubly linked list.
            if (offset == 0xe0) {
                // Pointer to what was the active source but is now being
                // shifted off to the LL tail.
                uint256 newTailPtr;
                // Pointer to the old head of the LL tail.
                uint256 oldTailPtr = (activeSource >> 0x10) & 0xFFFF;
                assembly ("memory-safe") {
                    newTailPtr := mload(0x40)
                    // Replace the offset of the active source to the pointer
                    // back to new active source.
                    // WARNING: state is being used as a pointer here, so if
                    // the struct changes, this must be updated.
                    activeSource := or(and(activeSource, not(0xFFFF)), state)
                    // Build the new tail head.
                    mstore(newTailPtr, activeSource)
                    mstore(0x40, add(newTailPtr, 0x20))
                    // The old tail head must now point back to the new tail
                    // head.
                    mstore(oldTailPtr, or(and(mload(oldTailPtr), not(0xFFFF)), newTailPtr))
                }

                // The new active source has a fresh offset and points forward to
                // the new tail head.
                activeSource = EMPTY_ACTIVE_SOURCE | (newTailPtr << 0x10);
            }

            state.activeSource = activeSource;
        }
    }

    function newSource(ParseState memory state) internal pure {
        uint256 sourcesBuilder = state.sourcesBuilder;
        uint256 offset = sourcesBuilder >> 0xf0;
        uint256 activeSource = state.activeSource;

        if (offset == 0xf0) {
            revert MaxSources();
        } else {
            // close out the LL to fixed solidity compatible bytes.
            uint256 source;
            assembly ("memory-safe") {
                source := mload(0x40)
                let cursor := add(source, 0x20)

                // handle the head first
                let activeSourceOffset := and(activeSource, 0xFFFF)
                mstore(cursor, shl(sub(0x100, activeSourceOffset), and(activeSource, not(0xFFFF))))
                let length := div(sub(activeSourceOffset, 0x20), 8)
                cursor := add(cursor, length)

                // loop the tail
                for { let tailPointer := and(shr(0x10, activeSource), 0xFFFF) } iszero(iszero(tailPointer)) {} {
                    tailPointer := and(shr(0x10, mload(tailPointer)), 0xFFFF)
                    mstore(cursor, and(mload(tailPointer), not(0xFFFFFFFF)))
                    cursor := add(cursor, 0xe0)
                    length := add(length, 0xe0)
                }
                mstore(source, length)
                mstore(0x40, and(add(cursor, 0x1f), not(0x1f)))
            }
            state.activeSource = 0x20;
            state.sourcesBuilder = (offset + 0x10) << 0xf0 | source << offset | (sourcesBuilder & ((1 << offset) - 1));
        }
    }

    function buildSources(ParseState memory state) internal pure returns (bytes[] memory sources) {
        unchecked {
            uint256 sourcesBuilder = state.sourcesBuilder;
            uint256 offsetEnd = (sourcesBuilder >> 0xf0);

            // Somehow the parser state for the active source was not reset
            // correctly, or the finalised offset is dangling. This implies that
            // we are building the overall sources array while still trying to
            // build one of the individual sources. This is a bug in the parser.
            if (state.activeSource != EMPTY_ACTIVE_SOURCE) {
                revert DanglingSource();
            }

            uint256 cursor;
            assembly ("memory-safe") {
                cursor := mload(0x40)
                sources := cursor
                mstore(cursor, div(offsetEnd, 0x10))
                cursor := add(cursor, 0x20)
                // Expect underflow on the break condition.
                for { let offset := 0 } lt(offset, offsetEnd) {
                    offset := add(offset, 0x10)
                    cursor := add(cursor, 0x20)
                } { mstore(cursor, and(shr(offset, sourcesBuilder), 0xFFFF)) }
                mstore(0x40, cursor)
            }
        }
    }

    function buildConstants(ParseState memory) internal pure returns (uint256[] memory) {
        return new uint256[](0);
    }
}

library LibParse {
    using LibPointer for Pointer;
    using LibParseState for ParseState;

    function stringToChar(string memory s) external pure returns (uint256 char) {
        return 1 << uint256(uint8(bytes1(bytes(s))));
    }

    function parseErrorContext(bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256 offset, string memory char)
    {
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 1))
            char := mload(0x40)
            mstore(char, 1)
            mstore8(add(char, 0x20), and(mload(cursor), 0xFF))
            mstore(0x40, add(char, 0x21))
        }
    }

    function parseWord(uint256 cursor, uint256 mask) internal pure returns (uint256, bytes32) {
        bytes32 word;
        uint256 i = 1;
        assembly ("memory-safe") {
            // word is head + tail
            word := mload(add(cursor, 0x1f))
            // loop over the tail
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

    function skipWord(uint256 cursor, uint256 mask) internal pure returns (uint256) {
        uint256 i;
        assembly ("memory-safe") {
            let done := 0
            // process the tail
            for {} iszero(done) {} {
                cursor := add(cursor, 0x20)
                i := 0
                for { let word := mload(cursor) } and(lt(i, 0x20), iszero(iszero(and(shl(byte(i, word), 1), mask)))) {}
                {
                    i := add(i, 1)
                }
                if lt(i, 0x20) {
                    cursor := sub(cursor, sub(0x20, i))
                    done := 1
                }
            }
            // compensate for the head
            cursor := add(cursor, 1)
        }
        return cursor;
    }

    function parse(bytes memory data, bytes memory meta)
        internal
        pure
        returns (bytes[] memory sources, uint256[] memory)
    {
        unchecked {
            ParseState memory state = LibParseState.newState();
            if (data.length > 0) {
                bytes32 word;
                uint256 cursor;
                uint256 end;
                uint256 char;
                assembly ("memory-safe") {
                    cursor := add(data, 1)
                    end := add(cursor, mload(data))
                }
                while (cursor < end) {
                    assembly ("memory-safe") {
                        char := shl(and(mload(cursor), 0xFF), 1)
                    }

                    // LHS
                    if (state.fsm & FSM_LHS_MASK > 0) {
                        if (char & CMASK_LHS_STACK_HEAD > 0) {
                            // if yang we can't start new stack item
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedLHSChar(offset, charString);
                            }

                            // Named stack item.
                            if (char & CMASK_IDENTIFIER_HEAD > 0) {
                                (cursor, word) = parseWord(cursor, CMASK_LHS_STACK_TAIL);
                                state.pushStackName(word);
                            }
                            // Anon stack item.
                            else {
                                cursor = skipWord(cursor, CMASK_LHS_STACK_TAIL);
                            }

                            state.stackIndex++;
                            state.fsm = FSM_LHS_MASK | FSM_YANG_MASK;
                        } else if (char & CMASK_WHITESPACE > 0) {
                            cursor = skipWord(cursor, CMASK_WHITESPACE);
                            state.fsm = FSM_LHS_MASK;
                        } else if (char & CMASK_LHS_RHS_DELIMITER > 0) {
                            state.fsm = 0;
                            cursor++;
                        } else {
                            (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                            revert UnexpectedLHSChar(offset, charString);
                        }
                    }
                    // RHS
                    else {
                        if (char & CMASK_RHS_WORD_HEAD > 0) {
                            // If yang we can't start a new word.
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedRHSChar(offset, charString);
                            }

                            (cursor, word) = parseWord(cursor, CMASK_RHS_WORD_TAIL);
                            state.pushWordToSource(meta, word);

                            state.fsm = FSM_YANG_MASK | FSM_WORD_END_MASK;
                        }
                        // If this is the end of a word we MUST start a paren.
                        // @todo support operands and constants.
                        else if (state.fsm & FSM_WORD_END_MASK > 0) {
                            if (char & CMASK_LEFT_PAREN == 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedRHSChar(offset, charString);
                            }
                            state.fsm = 0;
                            state.parenDepth++;
                            cursor++;
                        } else if (char & CMASK_RIGHT_PAREN > 0) {
                            // @todo input handling.
                            state.fsm = 0;
                            if (state.parenDepth == 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                (charString);
                                revert UnexpectedRightParen(offset);
                            }
                            state.parenDepth--;
                            cursor++;
                        } else if (char & CMASK_WHITESPACE > 0) {
                            state.fsm = 0;
                            cursor = skipWord(cursor, CMASK_WHITESPACE);
                        } else if (char & CMASK_EOL > 0) {
                            state.fsm = FSM_LHS_MASK;
                            cursor++;
                        }
                        // End of source.
                        else if (char & CMASK_EOS > 0) {
                            state.fsm = FSM_LHS_MASK;
                            state.newSource();
                            cursor++;
                        } else {
                            (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                            revert UnexpectedRHSChar(offset, charString);
                        }
                    }
                }
                if (char & CMASK_EOS == 0) {
                    (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                    (charString);
                    revert MissingFinalSemi(offset);
                }
            }
            return (state.buildSources(), state.buildConstants());
        }
    }
}
