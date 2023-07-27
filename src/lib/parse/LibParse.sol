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

/// More specific version of UnexpectedRHSChar where we specifically expected
/// a left paren but got some other char.
error ExpectedLeftParen(uint256 offset, string char);

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
error UnknownWord(uint256 offset, bytes32 word);

/// The parser exceeded the maximum number of sources that it can build.
error MaxSources();

/// The parser encountered a dangling source. This is a bug in the parser.
error DanglingSource();

/// The parser moved past the end of the data.
error ParserOutOfBounds();

/// The parser encountered a stack deeper than it can process in the memory
/// region allocated for stack names.
error StackOverflow();

/// The parser encountered a paren group deeper than it can process in the
/// memory region allocated for paren tracking.
error ParenOverflow();

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
/// @param activeSourcePtr The pointer to the current source being built.
/// The active source being pointed to is:
/// - low 16 bits: bitwise offset into the source for the next word to be
///   written. Starts at 0x20. Once a source is no longer the active source, i.e.
///   it is full and a member of the LL tail, the offset is replaced with a
///   pointer to the next source (towards the head) to build a doubly linked
///   list.
/// - mid 16 bits: pointer to the previous active source (towards teh tail). This
///   is a linked list of sources that are built RTL and then reversed to LTR to
///   eval.
/// - high bits: 4 byte opcodes and operand pairs.
/// @param sourcesBuilder A builder for the sources array. This is a 256 bit
/// integer where each 16 bits is a literal memory pointer to a source.
/// @param fsm The finite state machine representation of the parser.
/// - bit 0: LHS/RHS => 0 = LHS, 1 = RHS
/// - bit 1: yang/yin => 0 = yin, 1 = yang
/// - bit 2: word end => 0 = not end, 1 = end
/// - bit 3: accepting inputs => 0 = not accepting, 1 = accepting
/// @param stack0 Memory region for stack word counters. The first byte is a
/// counter/offset into the region. The remaining 31 bytes are the stack words.
/// @param stack1 32 additional bytes of stack words.
/// @param parenTracker0 Memory region for tracking pointers to words in the
/// source, and counters for the number of words in each paren group. The first
/// byte is a counter/offset into the region. The second byte is a phantom
/// counter for the root level, the remaining 30 bytes are the paren group words.
/// @param parenTracker1 32 additional bytes of paren group words.
/// @param stackNames A linked list of stack names. As the parser encounters
/// named stack items it pushes them onto this linked list. The linked list is
/// in FILO order, so the first item on the stack is the last item in the list.
/// This makes it more efficient to reference more recent stack names on the RHS.
/// @param literalBloom A bloom filter of all the literals that have been
/// encountered so far. This is used to quickly dedupe literals.
/// @param constantsBuilder A builder for the constants array.
struct ParseState {
    /// @dev START things that are referenced directly in assembly by hardcoded
    /// offsets. E.g. `pushOpToSource` and `newSource`.
    uint256 activeSourcePtr;
    uint256 stack0;
    uint256 stack1;
    uint256 parenTracker0;
    uint256 parenTracker1;
    /// @dev END things that are referenced directly in assembly by hardcoded
    /// offsets.
    uint256 sourcesBuilder;
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

        uint256 emptyActiveSource = EMPTY_ACTIVE_SOURCE;
        uint256 activeSourcePtr;
        assembly ("memory-safe") {
            activeSourcePtr := mload(0x40)
            mstore(activeSourcePtr, emptyActiveSource)
            mstore(0x40, add(activeSourcePtr, 0x20))
        }

        return ParseState(
            // activeSource
            activeSourcePtr,
            // stack0
            0,
            // stack1
            0,
            // parenTracker0
            0,
            // parenTracker1
            0,
            // sourcesBuilder
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
        uint256 parenOffset;
        assembly ("memory-safe") {
            parenOffset := byte(0, mload(add(state, 0x60)))
        }
        if (parenOffset > 0) {
            (uint256 offset, string memory char) = LibParse.parseErrorContext(data, cursor);
            (char);
            revert UnclosedLeftParen(offset);
        }

        // Nested conditionals to make the happy path more efficient at the
        // expense of the unhappy path.
        uint256 stackLHSIndex = state.stackLHSIndex;
        uint256 stackRHSOffset;
        assembly ("memory-safe") {
            stackRHSOffset := byte(0, mload(add(state, 0x20)))
        }
        if (stackLHSIndex != stackRHSOffset) {
            (uint256 offset, string memory char) = LibParse.parseErrorContext(data, cursor);
            (char);
            if (stackLHSIndex > stackRHSOffset) {
                if (state.fsm & FSM_ACCEPTING_INPUTS_MASK == 0) {
                    revert ExcessLHSItems(offset);
                } else {
                    // Move the RHS offset to cover inputs to the source. This
                    // gives a zero length of words for each input.
                    assembly ("memory-safe") {
                        mstore8(add(state, 0x20), stackLHSIndex)
                    }
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
        uint256 parenOffset;
        assembly ("memory-safe") {
            parenOffset := byte(0, mload(add(state, 0x60)))
        }
        if (parenOffset == 0) {
            uint256 newStackRHSOffset;
            assembly ("memory-safe") {
                let stackRHSOffsetPtr := add(state, 0x20)
                newStackRHSOffset := add(byte(0, mload(stackRHSOffsetPtr)), 1)
                mstore8(stackRHSOffsetPtr, newStackRHSOffset)
            }
            if (newStackRHSOffset == 0x3f) {
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
        unchecked {
            // Increment the stack counter.
            assembly ("memory-safe") {
                // Hardcoded offset into the state struct.
                let counterPos := add(state, 0x20)
                counterPos := add(add(counterPos, byte(0, mload(counterPos))), 1)
                // Increment the counter.
                mstore8(counterPos, add(byte(0, mload(counterPos)), 1))
            }

            uint256 activeSource;
            uint256 offset;
            assembly ("memory-safe") {
                let activeSourcePointer := mload(state)
                activeSource := mload(activeSourcePointer)
                // The low 16 bits of the active source is the current offset.
                offset := and(activeSource, 0xFFFF)

                // The offset is in bits so for a byte pointer we need to divide
                // by 8, then add 1 to move to the operand low byte.
                let operandLowBytePointer := sub(add(activeSourcePointer, 0x20), add(div(offset, 8), 1))

                // Increment the paren input counter. The input counter is for the paren
                // group that is currently being built. This means the counter is for
                // the paren group that is one level above the current paren offset.
                // Assumes that every word has exactly 1 output, therefore the input
                // counter always increases by 1.
                // Hardcoded offset into the state struct.
                let inputCounterPos := add(state, 0x60)
                inputCounterPos :=
                    add(
                        add(
                            inputCounterPos,
                            // the offset
                            byte(0, mload(inputCounterPos))
                        ),
                        // +2 for the reserved bytes -1 to move back to the counter
                        // for the previous paren group.
                        1
                    )
                // Increment the parent counter.
                mstore8(inputCounterPos, add(byte(0, mload(inputCounterPos)), 1))
                // Zero out the current counter.
                mstore8(add(inputCounterPos, 3), 0)

                // Write the operand low byte pointer into the paren tracker.
                // Move 3 bytes after the input counter pos, then shift down 32
                // bytes to accomodate the full mload.
                let parenTrackerPointer := sub(inputCounterPos, 29)
                mstore(parenTrackerPointer, or(and(mload(parenTrackerPointer), not(0xFFFF)), operandLowBytePointer))
            }

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
            assembly ("memory-safe") {
                mstore(mload(state), activeSource)
            }

            // We have filled the current source slot. Need to create a new active
            // source and fulfill the doubly linked list.
            if (offset == 0xe0) {
                // Pointer to a newly allocated active source.
                uint256 newTailPtr;
                // Pointer to the old head of the LL tail.
                uint256 oldTailPtr;
                uint256 emptyActiveSource = EMPTY_ACTIVE_SOURCE;
                assembly ("memory-safe") {
                    oldTailPtr := mload(state)

                    // Build the new tail head.
                    newTailPtr := mload(0x40)
                    mstore(state, newTailPtr)
                    mstore(newTailPtr, or(emptyActiveSource, shl(0x10, oldTailPtr)))
                    mstore(0x40, add(newTailPtr, 0x20))

                    // The old tail head must now point back to the new tail head.
                    mstore(oldTailPtr, or(and(mload(oldTailPtr), not(0xFFFF)), newTailPtr))
                }
            }
        }
    }

    function newSource(ParseState memory state) internal pure {
        uint256 sourcesBuilder = state.sourcesBuilder;
        uint256 offset = sourcesBuilder >> 0xf0;

        // End is the number of top level words in the source.
        uint256 end;
        assembly ("memory-safe") {
            end := add(byte(0, mload(add(state, 0x20))), 1)
        }

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
                let cursor := mload(state)

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
                    let wordsTotal := byte(0, mload(counterCursor))
                    let wordsRemaining := wordsTotal
                } lt(i, end) {
                    i := add(i, 1)
                    counterCursor := add(counterCursor, 1)
                    wordsTotal := byte(0, mload(counterCursor))
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
            uint256 emptyActiveSource = EMPTY_ACTIVE_SOURCE;
            assembly ("memory-safe") {
                let ptr := mload(0x40)
                mstore(ptr, emptyActiveSource)
                mstore(0x40, add(ptr, 0x20))
                mstore(state, ptr)
            }
            state.stack0 = 0;
            state.stack1 = 0;

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
            uint256 activeSource;
            assembly ("memory-safe") {
                activeSource := mload(mload(state))
            }
            if (activeSource != EMPTY_ACTIVE_SOURCE) {
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
                                (bool exists, uint256 index) = state.pushStackName(word);

                                // If the stack name already exists, then we
                                // revert as shadowing is not allowed.
                                if (exists) {
                                    //slither-disable-next-line similar-names
                                    (uint256 errorOffset, string memory errorCharString) =
                                        parseErrorContext(data, cursor);
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

                            // First check if this word is in meta.
                            (bool exists, uint256 index) = LibParseMeta.lookupIndexFromMeta(meta, word);
                            if (exists) {
                                state.pushOpToSource(index, Operand.wrap(0));
                                // This is a real word so we expect to see parens
                                // after it.
                                state.fsm |= FSM_WORD_END_MASK;
                            }
                            // Fallback to LHS items.
                            else {
                                (exists, index) = LibParseStackName.stackNameIndex(state, word);
                                if (exists) {
                                    state.pushOpToSource(OPCODE_STACK, Operand.wrap(index));
                                    // Need to process highwater here because we
                                    // don't have any parens to open or close.
                                    state.highwater();
                                } else {
                                    //slither-disable-next-line similar-names
                                    (uint256 errorOffset, string memory errorCharString) =
                                        parseErrorContext(data, cursor);
                                    (errorCharString);
                                    revert UnknownWord(errorOffset, word);
                                }
                            }

                            state.fsm |= FSM_YANG_MASK;
                        }
                        // If this is the end of a word we MUST start a paren.
                        // @todo support operands and constants.
                        else if (state.fsm & FSM_WORD_END_MASK > 0) {
                            if (char & CMASK_LEFT_PAREN == 0) {
                                //slither-disable-next-line similar-names
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert ExpectedLeftParen(offset, charString);
                            }
                            // Increase the paren depth by 1.
                            // i.e. move the byte offset by 3
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
                                //slither-disable-next-line similar-names
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                (charString);
                                revert UnexpectedRightParen(offset);
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
                                    shr(0xf0, mload(add(add(stateOffset, 2), parenOffset))),
                                    // Store the input counter, which is 2 bytes
                                    // after the operand write pointer.
                                    byte(0, mload(add(add(stateOffset, 4), parenOffset)))
                                )
                            }
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
