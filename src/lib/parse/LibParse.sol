// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";
import "./LibCtPop.sol";
import "./LibParseMeta.sol";
import "./LibParseCMask.sol";
import "./LibParseLiteral.sol";
import "../../interface/IInterpreterV1.sol";
import "./LibParseStackName.sol";

/// The expression does not finish with a semicolon (EOF).
error MissingFinalSemi(uint256 offset);

/// Enountered an unexpected character on the LHS.
error UnexpectedLHSChar(uint256 offset, string char);

/// Encountered an unexpected character on the RHS.
error UnexpectedRHSChar(uint256 offset, string char);

/// Encountered a right paren without a matching left paren.
error UnexpectedRightParen(uint256 offset);

/// Encountered an unclosed left paren.
error UnclosedLeftParen(uint256 offset);

/// @dev Thrown when a stack name is duplicated. Shadowing in all forms is
/// disallowed in Rainlang.
error DuplicateLHSItem(uint256 errorOffset, string errorCharString);

/// Encountered too many LHS items.
error ExcessLHSItems(uint256 offset);

/// Encountered too many RHS items.
error ExcessRHSItems(uint256 offset);

/// Encountered a word that is longer than 32 bytes.
error WordSize(string word);

/// Parsed a word that is not in the meta.
error UnknownWord(bytes32 word);

/// The parser exceeded the maximum number of sources that it can build.
error MaxSources();

/// The parser encountered a dangling source. This is a bug in the parser.
error DanglingSource();

/// The parser moved past the end of the data.
error ParserOutOfBounds();

error StackOverflow();

uint256 constant NOT_LOW_16_BIT_MASK = ~uint256(0xFFFF);
uint256 constant ACTIVE_SOURCE_MASK = NOT_LOW_16_BIT_MASK;

uint256 constant FSM_RHS_MASK = 1;
uint256 constant FSM_YANG_MASK = 1 << 1;
uint256 constant FSM_WORD_END_MASK = 1 << 2;
uint256 constant FSM_ACCEPTING_INPUTS_MASK = 1 << 3;

uint256 constant EMPTY_ACTIVE_SOURCE = 0x20;

/// @dev The opcode that will be used in the source to represent a stack copy
/// implied by named LHS stack items.
/// @dev @todo support the meta defining the opcode.
uint256 constant OPCODE_STACK = 0;

/// @dev The opcode that will be used in the source to represent a literal after
/// it has been parsed into a constant.
/// @dev @todo support the meta defining the opcode.
uint256 constant OPCODE_LITERAL = 1;

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
/// - bit 3: accepting inputs => 0 = not accepting, 1 = accepting
/// @param stackOffset The current stack offset in bytes. This is where the
/// current stack word counter is.
/// @param stack0 Memory region for stack word counters.
/// @param stack1 Memory region for stack word counters.
/// @param stackNames A linked list of stack names. As the parser encounters
/// named stack items it pushes them onto this linked list. The linked list is
/// in FILO order, so the first item on the stack is the last item in the list.
/// This makes it more efficient to reference more recent stack names on the RHS.
/// @param literalBloom A bloom filter of all the literals that have been
/// encountered so far. This is used to quickly dedupe literals.
/// @param constantsBuilder A builder for the constants array.
struct ParseState {
    /// @dev WARNING: Referenced directly in assembly. If the order of these
    /// fields changes, the assembly must be updated. Specifically, activeSource
    /// is referenced as a pointer in `pushOpToSource` and `newSource`.
    uint256 activeSource;
    /// @dev These stack tracking items are all accessed as hardcoded offsets in
    /// assembly.
    uint256 stackRHSOffset;
    uint256 stack0;
    uint256 stack1;
    uint256 sourcesBuilder;
    uint256 parenDepth;
    uint256 fsm;
    uint256 stackLHSIndex;
    uint256 stackNames;
    uint256 stackNameBloom;
    uint256 literalBloom;
    uint256 constantsBuilder;
    uint256 literalParsers;
}

library LibParseState {
    using LibParseState for ParseState;

    function newState() internal pure returns (ParseState memory) {
        // Register all the literal parsers in the parse state. Each is a 16 bit
        // function pointer so we can have up to 16 literal types. This needs to
        // be done at runtime because the library code doesn't know the bytecode
        // offsets of the literal parsers until it is compiled into a contract.
        uint256 literalParsers;
        {
            function(bytes memory, uint256, uint256) pure returns (uint256) parseLiteralHex =
                LibParseLiteral.parseLiteralHex;
            uint256 parseLiteralHexOffset = LITERAL_TYPE_INTEGER_HEX;
            function(bytes memory, uint256, uint256) pure returns (uint256) parseLiteralDecimal =
                LibParseLiteral.parseLiteralDecimal;
            uint256 parseLiteralDecimalOffset = LITERAL_TYPE_INTEGER_DECIMAL;

            assembly ("memory-safe") {
                literalParsers :=
                    or(shl(parseLiteralHexOffset, parseLiteralHex), shl(parseLiteralDecimalOffset, parseLiteralDecimal))
            }
        }

        return ParseState(
            // activeSource
            EMPTY_ACTIVE_SOURCE,
            // stackRHSOffset
            0,
            // stack0
            0,
            // stack1
            0,
            // sourcesBuilder
            0,
            // parenDepth
            0,
            // fsm initially is the LHS and accepting inputs.
            FSM_ACCEPTING_INPUTS_MASK,
            // stackLHSIndex
            0,
            // stackNames
            0,
            // stackNameBloom
            0,
            // literalBloom
            0,
            // constantsBuilder
            0,
            // literalParsers
            literalParsers
        );
    }

    function balance(ParseState memory state, bytes memory data, uint256 cursor) internal pure {
        if (state.parenDepth > 0) {
            (uint256 offset, string memory char) = LibParse.parseErrorContext(data, cursor);
            (char);
            revert UnclosedLeftParen(offset);
        }

        // Nested conditionals to make the happy path more efficient at the
        // expense of the unhappy path.
        if (state.stackLHSIndex != state.stackRHSOffset) {
            (uint256 offset, string memory char) = LibParse.parseErrorContext(data, cursor);
            (char);
            if (state.stackLHSIndex > state.stackRHSOffset) {
                if (state.fsm & FSM_ACCEPTING_INPUTS_MASK == 0) {
                    revert ExcessLHSItems(offset);
                } else {
                    // Move the RHS offset to cover inputs to the source. This
                    // gives a zero length of words for each input.
                    state.stackRHSOffset = state.stackLHSIndex;
                }
            } else {
                revert ExcessRHSItems(offset);
            }
        }
    }

    /// We potentially just closed out some group of arbitrarily nested parens
    /// OR a lone literal value at the top level. IF we are at the top level we
    /// move the immutable stack highwater mark forward 1 item, which moves the
    /// RHS offset forward 1 byte to start a new word counter.
    function highwater(ParseState memory state) internal pure {
        if (state.parenDepth == 0) {
            state.stackRHSOffset++;
            if (state.stackRHSOffset == 0x40) {
                revert StackOverflow();
            }
        }
    }

    function pushLiteral(ParseState memory state, bytes memory data, uint256 cursor) internal pure returns (uint256) {
        unchecked {
            (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
                LibParseLiteral.boundLiteral(data, cursor);
            uint256 fingerprint;
            uint256 fingerprintBloom;
            assembly ("memory-safe") {
                fingerprint := and(keccak256(cursor, sub(outerEnd, cursor)), not(0xFFFF))
                //slither-disable-next-line incorrect-shift
                fingerprintBloom := shl(byte(0, fingerprint), 1)
            }

            // Whether the literal is a duplicate.
            bool exists = false;

            // The index of the literal in the linked list of literals. This is
            // starting from the top of the linked list, so the final index is
            // the height of the linked list minus this value.
            uint256 t = 1;

            // If the literal is in the bloom filter, then it MAY be a duplicate.
            // Try to find the literal in the linked list of literals using the
            // full fingerprint for better collision resistance than the bloom.
            //
            // If the literal is NOT in the bloom filter, then it is definitely
            // NOT a duplicate, so avoid traversing the linked list.
            //
            // Worst case is a false positive in the bloom filter, which means
            // we traverse the linked list and find no match. This is O(1) for
            // the bloom filter and O(n) for the linked list traversal, then
            // O(m) for the per-char literal parsing. The bloom filter is
            // 256 bits, so the chance of there being at least one false positive
            // over 10 literals is ~15% due to the birthday paradox.
            if (state.literalBloom & fingerprintBloom != 0) {
                uint256 tailPtr = state.constantsBuilder >> 0x10;
                while (tailPtr != 0) {
                    uint256 tailKey;
                    assembly ("memory-safe") {
                        tailKey := mload(tailPtr)
                    }
                    // If the fingerprint  matches, then the literal IS a duplicate,
                    // with 240 bits of collision resistance. The value sits alongside
                    // the key in memory.
                    if (fingerprint == (tailKey & ~uint256(0xFFFF))) {
                        exists = true;
                        break;
                    }

                    assembly ("memory-safe") {
                        // Tail pointer is the low 16 bits of the key.
                        tailPtr := and(mload(tailPtr), 0xFFFF)
                    }
                    t++;
                }
            }

            // Push the literal opcode to the source.
            // The index is either the height of the constants, if the literal
            // is NOT a duplicate, or the height minus the index of the
            // duplicate. This is because the final constants array is built
            // 0 indexed from the bottom of the linked list to the top.
            {
                uint256 constantsHeight = state.constantsBuilder & 0xFFFF;
                state.pushOpToSource(OPCODE_LITERAL, Operand.wrap(exists ? constantsHeight - t : constantsHeight));
            }

            // If the literal is not a duplicate, then we need to add it to the
            // linked list of literals so that `t` can point to it, and we can
            // build the constants array from the values in the linked list
            // later.
            if (!exists) {
                uint256 ptr;
                assembly ("memory-safe") {
                    // Allocate two words.
                    ptr := mload(0x40)
                    mstore(0x40, add(ptr, 0x40))
                }
                // First word is the key.
                {
                    // tail key is the fingerprint with the low 16 bits set to
                    // the pointer to the next item in the linked list.
                    uint256 tailKey = state.constantsBuilder >> 0x10 | fingerprint;
                    assembly ("memory-safe") {
                        mstore(ptr, tailKey)
                    }
                }
                // Second word is the value.
                {
                    function(bytes memory, uint256, uint256) pure returns (uint256) parser;
                    uint256 parsers = state.literalParsers;
                    // `boundLiteral` MUST return a literal type that is
                    // supported by the parser OR revert.
                    assembly ("memory-safe") {
                        parser := and(shr(literalType, parsers), 0xFFFF)
                    }
                    uint256 tailValue = parser(data, innerStart, innerEnd);

                    assembly ("memory-safe") {
                        // Second word is the value
                        mstore(add(ptr, 0x20), tailValue)
                    }
                }

                state.constantsBuilder = ((state.constantsBuilder & 0xFFFF) + 1) | (ptr << 0x10);
                state.literalBloom |= fingerprintBloom;
            }

            return outerEnd;
        }
    }

    function pushOpToSource(ParseState memory state, uint256 opcode, Operand operand) internal pure {
        // Increment the stack counter.
        {
            uint256 stackRHSOffset = state.stackRHSOffset;
            assembly ("memory-safe") {
                let counter := and(mload(add(state, add(0x21, stackRHSOffset))), 0xFF)
                mstore8(add(state, add(0x40, stackRHSOffset)), add(counter, 1))
            }
        }

        uint256 activeSource = state.activeSource;
        // The low 16 bits of the active source is the current offset.
        uint256 offset = uint16(activeSource);

        // We write sources RTL so they can run LTR.
        activeSource =
        // increment offset. We have 16 bits allocated to the offset and stop
        // processing at 0x100 so this never overflows into the actual source
        // data.
        activeSource + 0x20
        // include the operand. The operand is assumed to be 16 bits, so we shift
        // it into the correct position.
        | Operand.unwrap(operand) << offset
        // include new op. The opcode is assumed to be 16 bits, so we shift it
        // into the correct position, beyond the operand.
        | opcode << (offset + 0x10);

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

    function pushWordToSource(ParseState memory state, bytes memory meta, bytes32 word) internal pure {
        unchecked {
            // Convert the word to an offset that can be used to compile function
            // pointers later.
            (bool exists, uint256 opcode) = LibParseMeta.lookupIndexFromMeta(meta, word);
            // The lookup failed so the entire parsing process failed.
            if (!exists) {
                revert UnknownWord(word);
            }

            // @todo support operands.
            state.pushOpToSource(opcode, Operand.wrap(0));
        }
    }

    function newSource(ParseState memory state) internal pure {
        uint256 sourcesBuilder = state.sourcesBuilder;
        uint256 offset = sourcesBuilder >> 0xf0;
        uint256 end = state.stackRHSOffset;

        if (offset == 0xf0) {
            revert MaxSources();
        }
        // Follow the word counters to build the source with the correct
        // combination of LTR and RTL words. The stack needs to be built
        // LTR at the top level, so that as the evaluation proceeds LTR it
        // can reference previous items in subsequent items. However, the
        // stack is built RTL within each item, so that nested parens are
        // evaluated correctly similar to reverse polish notation.
        else {
            uint256 source;
            assembly ("memory-safe") {
                // find the end of the LL tail.
                let cursor := state

                let tailPointer := and(shr(0x10, mload(cursor)), 0xFFFF)
                for {} iszero(iszero(tailPointer)) {} {
                    cursor := tailPointer
                    tailPointer := and(shr(0x10, mload(cursor)), 0xFFFF)
                }

                // Move cursor to the end of the end of the LL tail item.
                // This is 4 bytes from the end of the EVM word, to compensate
                // for the offset and pointer positions.
                tailPointer := cursor
                cursor := add(cursor, 0x1C)
                let length := 0
                source := mload(0x40)
                let writeCursor := add(source, 0x20)

                let counterCursor := add(state, 0x21)
                for {
                    let i := 0
                    let wordsTotal := and(mload(counterCursor), 0xFF)
                    let wordsRemaining := wordsTotal
                } lt(i, end) {
                    i := add(i, 1)
                    counterCursor := add(counterCursor, 1)
                    wordsTotal := and(mload(counterCursor), 0xFF)
                    wordsRemaining := wordsTotal
                } {
                    length := add(length, mul(wordsTotal, 4))
                    {
                        // 4 bytes per source word.
                        let tailItemWordsRemaining := div(sub(cursor, tailPointer), 4)
                        // loop to the tail item that contains the start of the words
                        // that we need to copy.
                        for {} gt(wordsRemaining, tailItemWordsRemaining) {} {
                            wordsRemaining := sub(wordsRemaining, tailItemWordsRemaining)
                            tailPointer := and(mload(tailPointer), 0xFFFF)
                            tailItemWordsRemaining := 7
                            cursor := add(tailPointer, 0x1C)
                        }
                    }

                    // Now the words remaining is lte the words remaining in the
                    // tail item. Move the cursor back to the start of the words
                    // and copy the passed over bytes to the write cursor.
                    {
                        let forwardTailPointer := tailPointer
                        let size := mul(wordsRemaining, 4)
                        cursor := sub(cursor, size)
                        mstore(writeCursor, mload(cursor))
                        writeCursor := add(writeCursor, size)

                        // Redefine wordsRemaining to be the number of words
                        // left to copy.
                        wordsRemaining := sub(wordsTotal, wordsRemaining)
                        // Move over whole tail items.
                        for {} gt(wordsRemaining, 7) {} {
                            wordsRemaining := sub(wordsRemaining, 7)
                            // Follow the forward tail pointer.
                            forwardTailPointer := and(shr(0x10, mload(forwardTailPointer)), 0xFFFF)
                            mstore(writeCursor, mload(forwardTailPointer))
                            writeCursor := add(writeCursor, 0x1c)
                        }
                        // Move over the remaining words in the tail item.
                        if gt(wordsRemaining, 0) {
                            forwardTailPointer := and(shr(0x10, mload(forwardTailPointer)), 0xFFFF)
                            mstore(writeCursor, mload(forwardTailPointer))
                            writeCursor := add(writeCursor, mul(wordsRemaining, 4))
                        }
                    }
                }
                mstore(source, length)
                // Round up to the nearest 32 bytes to realign memory.
                mstore(0x40, and(add(writeCursor, 0x1f), not(0x1f)))
            }

            // Reset state for next source.
            state.stackRHSOffset = 0;
            state.stack0 = 0;
            state.stack1 = 0;
            state.activeSource = 0x20;
            //slither-disable-next-line incorrect-shift
            state.sourcesBuilder =
                ((offset + 0x10) << 0xf0) | (source << offset) | (sourcesBuilder & ((1 << offset) - 1));
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

    function buildConstants(ParseState memory state) internal pure returns (uint256[] memory constants) {
        uint256 constantsHeight = state.constantsBuilder & 0xFFFF;
        uint256 tailPtr = state.constantsBuilder >> 0x10;

        assembly ("memory-safe") {
            let cursor := mload(0x40)
            constants := cursor
            mstore(cursor, constantsHeight)
            let end := cursor
            // Move the cursor to the end of the array. Write in reverse order
            // of the linked list traversal so that the constants are built
            // according to the stable indexes in the source from the linked
            // list base.
            cursor := add(cursor, mul(constantsHeight, 0x20))
            // Allocate one word past the cursor. This will be just after the
            // length if the constants array is empty. Otherwise it will be
            // just after the last constant.
            mstore(0x40, add(cursor, 0x20))
            // It MUST be equivalent to say that the cursor is above the end,
            // and that we are following tail pointers until they point to 0,
            // and that the cursor is moving as far as the constants height.
            // This is ensured by the fact that the constants height is only
            // incremented when a new constant is added to the linked list.
            for {} gt(cursor, end) {
                // Next item in the linked list.
                cursor := sub(cursor, 0x20)
                // tail pointer in tail keys is the low 16 bits under the
                // fingerprint, which is different from the tail pointer in
                // the constants builder, where it sits above the constants
                // height.
                tailPtr := and(mload(tailPtr), 0xFFFF)
            } {
                // Store the values not the keys.
                mstore(cursor, mload(add(tailPtr, 0x20)))
            }
        }
    }
}

library LibParse {
    using LibPointer for Pointer;
    using LibParseState for ParseState;
    using LibParseStackName for ParseState;

    function stringToChar(string memory s) external pure returns (uint256 char) {
        return 1 << uint256(uint8(bytes1(bytes(s))));
    }

    function parseErrorContext(bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256 offset, string memory char)
    {
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 0x20))
            char := mload(0x40)
            mstore(char, 1)
            mstore8(add(char, 0x20), byte(0, mload(cursor)))
            // Allocate two full words to keep memory aligned.
            mstore(0x40, add(char, 0x40))
        }
    }

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

    function skipWord(uint256 cursor, uint256 mask) internal pure returns (uint256) {
        uint256 i;
        assembly ("memory-safe") {
            let done := 0
            // process the tail
            for {} iszero(done) {} {
                // we already know the head is to be ignored so move past it.
                cursor := add(cursor, 1)
                i := 0
                //slither-disable-next-line incorrect-shift
                for { let word := mload(cursor) } and(lt(i, 0x20), iszero(iszero(and(shl(byte(i, word), 1), mask)))) {}
                {
                    i := add(i, 1)
                }
                if lt(i, 0x20) {
                    cursor := add(cursor, i)
                    done := 1
                }
            }
        }
        return cursor;
    }

    //slither-disable-next-line cyclomatic-complexity
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
                    cursor := add(data, 0x20)
                    end := add(cursor, mload(data))
                }
                while (cursor < end) {
                    assembly ("memory-safe") {
                        //slither-disable-next-line incorrect-shift
                        char := shl(byte(0, mload(cursor)), 1)
                    }

                    // LHS
                    if (state.fsm & FSM_RHS_MASK == 0) {
                        if (char & CMASK_LHS_STACK_HEAD > 0) {
                            // if yang we can't start new stack item
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                //slither-disable-next-line similar-names
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedLHSChar(offset, charString);
                            }

                            // Named stack item.
                            if (char & CMASK_IDENTIFIER_HEAD > 0) {
                                (cursor, word) = parseWord(cursor, CMASK_LHS_STACK_TAIL);
                                (uint256 exists, uint256 index) = state.pushStackName(word);

                                // If the stack name already exists, then we
                                // revert as shadowing is not allowed.
                                if (exists != 0) {
                                    //slither-disable-next-line similar-names
                                    (uint256 errorOffset, string memory errorCharString) = parseErrorContext(data, cursor);
                                    revert DuplicateLHSItem(errorOffset, errorCharString);
                                }

                                state.stackLHSIndex = index;
                            }
                            // Anon stack item.
                            else {
                                cursor = skipWord(cursor, CMASK_LHS_STACK_TAIL);
                                // Bump the index without pushing a name.
                                state.stackLHSIndex++;
                            }

                            // Set yang as we are now building a stack item.
                            state.fsm |= FSM_YANG_MASK;
                        } else if (char & CMASK_WHITESPACE > 0) {
                            cursor = skipWord(cursor, CMASK_WHITESPACE);
                            // Set ying as we now open to possibilities.
                            state.fsm &= ~FSM_YANG_MASK;
                        } else if (char & CMASK_LHS_RHS_DELIMITER > 0) {
                            // Set RHS and yin.
                            state.fsm = (state.fsm | FSM_RHS_MASK) & ~FSM_YANG_MASK;
                            cursor++;
                        } else {
                            //slither-disable-next-line similar-names
                            (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                            revert UnexpectedLHSChar(offset, charString);
                        }
                    }
                    // RHS
                    else {
                        if (char & CMASK_RHS_WORD_HEAD > 0) {
                            // If yang we can't start a new word.
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                //slither-disable-next-line similar-names
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedRHSChar(offset, charString);
                            }

                            (cursor, word) = parseWord(cursor, CMASK_RHS_WORD_TAIL);
                            state.pushWordToSource(meta, word);

                            state.fsm |= FSM_YANG_MASK | FSM_WORD_END_MASK;
                        }
                        // If this is the end of a word we MUST start a paren.
                        // @todo support operands and constants.
                        else if (state.fsm & FSM_WORD_END_MASK > 0) {
                            if (char & CMASK_LEFT_PAREN == 0) {
                                //slither-disable-next-line similar-names
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedRHSChar(offset, charString);
                            }
                            state.parenDepth++;
                            cursor++;

                            // We've moved past the paren, so we are no longer at
                            // the end of a word and are yin.
                            state.fsm &= ~(FSM_WORD_END_MASK | FSM_YANG_MASK);
                        } else if (char & CMASK_RIGHT_PAREN > 0) {
                            // @todo input handling.
                            if (state.parenDepth == 0) {
                                //slither-disable-next-line similar-names
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                (charString);
                                revert UnexpectedRightParen(offset);
                            }
                            state.parenDepth--;
                            state.highwater();
                            cursor++;
                        } else if (char & CMASK_WHITESPACE > 0) {
                            cursor = skipWord(cursor, CMASK_WHITESPACE);
                            // Set yin as we now open to possibilities.
                            state.fsm &= ~FSM_YANG_MASK;
                        }
                        // Handle all literals.
                        else if (char & CMASK_LITERAL_HEAD > 0) {
                            cursor = state.pushLiteral(data, cursor);
                            state.highwater();
                            // We are yang now. Need the next char to release to
                            // yin.
                            state.fsm |= FSM_YANG_MASK;
                        } else if (char & CMASK_EOL > 0) {
                            state.balance(data, cursor);
                            cursor++;
                            state.fsm = 0;
                        }
                        // End of source.
                        else if (char & CMASK_EOS > 0) {
                            state.balance(data, cursor);
                            state.newSource();
                            cursor++;
                            state.fsm = FSM_ACCEPTING_INPUTS_MASK;
                        } else {
                            //slither-disable-next-line similar-names
                            (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                            revert UnexpectedRHSChar(offset, charString);
                        }
                    }
                }
                if (cursor != end) {
                    revert ParserOutOfBounds();
                }
                if (char & CMASK_EOS == 0) {
                    //slither-disable-next-line similar-names
                    (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                    (charString);
                    revert MissingFinalSemi(offset);
                }
            }
            return (state.buildSources(), state.buildConstants());
        }
    }
}
