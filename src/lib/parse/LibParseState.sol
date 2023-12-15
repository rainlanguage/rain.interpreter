// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand, OPCODE_CONSTANT} from "../../interface/unstable/IInterpreterV2.sol";
import {LibParseStackTracker, ParseStackTracker} from "./LibParseStackTracker.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {
    DanglingSource,
    MaxSources,
    ParseStackOverflow,
    UnclosedLeftParen,
    ExcessRHSItems,
    ExcessLHSItems,
    NotAcceptingInputs
} from "../../error/ErrParse.sol";
import {LibParseLiteral} from "./LibParseLiteral.sol";
import {LibParse} from "./LibParse.sol";
import {LibParseOperand} from "./LibParseOperand.sol";
import {LibParseError} from "./LibParseError.sol";

/// @dev Initial state of an active source is just the starting offset which is
/// 0x20.
uint256 constant EMPTY_ACTIVE_SOURCE = 0x20;

uint256 constant FSM_YANG_MASK = 1;
uint256 constant FSM_WORD_END_MASK = 1 << 1;
uint256 constant FSM_ACCEPTING_INPUTS_MASK = 1 << 2;

/// @dev If a source is active we cannot finish parsing without a semi to trigger
/// finalisation.
uint256 constant FSM_ACTIVE_SOURCE_MASK = 1 << 3;

/// @dev fsm default state is:
/// - yin
/// - not word end
/// - accepting inputs
uint256 constant FSM_DEFAULT = FSM_ACCEPTING_INPUTS_MASK;

/// The parser is stateful. This struct keeps track of the entire state.
/// @param activeSourcePtr The pointer to the current source being built.
/// The active source being pointed to is:
/// - low 16 bits: bitwise offset into the source for the next word to be
///   written. Starts at 0x20. Once a source is no longer the active source, i.e.
///   it is full and a member of the LL tail, the offset is replaced with a
///   pointer to the next source (towards the head) to build a doubly linked
///   list.
/// - mid 16 bits: pointer to the previous active source (towards the tail). This
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
/// - bit 4: interstitial => 0 = not interstitial, 1 = interstitial
/// @param topLevel0 Memory region for stack word counters. The first byte is a
/// counter/offset into the region, which increments for every top level item
/// parsed on the RHS. The remaining 31 bytes are the word counters for each
/// stack item, which are incremented for every op pushed to the source. This is
/// reset to 0 for every new source.
/// @param topLevel1 31 additional bytes of stack words, allowing for 62 top
/// level stack items total per source. The final byte is used to count the
/// stack height according to the LHS for the current source. This is reset to 0
/// for every new source.
/// @param parenTracker0 Memory region for tracking pointers to words in the
/// source, and counters for the number of words in each paren group. The first
/// byte is a counter/offset into the region. The second byte is a phantom
/// counter for the root level, the remaining 30 bytes are the paren group words.
/// @param parenTracker1 32 additional bytes of paren group words.
/// @param lineTracker A 32 byte memory region for tracking the current line.
/// Will be partially reset for each line when `endLine` is called. Fully
/// reset when a new source is started.
/// Bytes from low to high:
/// - byte 0: Lowest byte is the number of LHS items parsed. This is the low
/// byte so that a simple ++ is a valid operation on the line tracker while
/// parsing the LHS. This is reset to 0 for each new line.
/// - byte 1: A snapshot of the first high byte of `topLevel0`, i.e. the offset
/// of top level items as at the beginning of the line. This is reset to the high
/// byte of `topLevel0` on each new line.
/// - bytes 2+: A sequence of 2 byte pointers to before the start of each top
/// level item, which is implictly after the end of the previous top level item.
/// Allows us to quickly find the start of the RHS source for each top level
/// item.
/// @param stackNames A linked list of stack names. As the parser encounters
/// named stack items it pushes them onto this linked list. The linked list is
/// in FILO order, so the first item on the stack is the last item in the list.
/// This makes it more efficient to reference more recent stack names on the RHS.
/// @param literalBloom A bloom filter of all the literals that have been
/// encountered so far. This is used to quickly dedupe literals.
/// @param constantsBuilder A builder for the constants array.
/// @param literalParsers A 256 bit integer where each 16 bits is a function
/// pointer to a literal parser.
struct ParseState {
    /// @dev START things that are referenced directly in assembly by hardcoded
    /// offsets. E.g.
    /// - `pushOpToSource`
    /// - `snapshotSourceHeadToLineTracker`
    /// - `newSource`
    uint256 activeSourcePtr;
    uint256 topLevel0;
    uint256 topLevel1;
    uint256 parenTracker0;
    uint256 parenTracker1;
    uint256 lineTracker;
    /// @dev END things that are referenced directly in assembly by hardcoded
    /// offsets.
    uint256 sourcesBuilder;
    uint256 fsm;
    uint256 stackNames;
    uint256 stackNameBloom;
    uint256 literalBloom;
    uint256 constantsBuilder;
    uint256 literalParsers;
    uint256 operandParsers;
    ParseStackTracker stackTracker;
    bytes data;
    bytes meta;
}

library LibParseState {
    using LibParseState for ParseState;
    using LibParseStackTracker for ParseStackTracker;
    using LibParseError for ParseState;
    using LibParseLiteral for ParseState;

    function newActiveSourcePointer(uint256 oldActiveSourcePointer) internal pure returns (uint256) {
        uint256 activeSourcePtr;
        uint256 emptyActiveSource = EMPTY_ACTIVE_SOURCE;
        assembly ("memory-safe") {
            // The active source pointer MUST be aligned to 32 bytes because we
            // rely on alignment to know when we have filled a source and need
            // to create a new one, or need to jump through the linked list.
            activeSourcePtr := and(add(mload(0x40), 0x1F), not(0x1F))
            mstore(activeSourcePtr, or(emptyActiveSource, shl(0x10, oldActiveSourcePointer)))
            mstore(0x40, add(activeSourcePtr, 0x20))

            // The old tail head must now point back to the new tail head.
            mstore(oldActiveSourcePointer, or(and(mload(oldActiveSourcePointer), not(0xFFFF)), activeSourcePtr))
        }
        return activeSourcePtr;
    }

    function resetSource(ParseState memory state) internal pure {
        state.activeSourcePtr = newActiveSourcePointer(0);
        state.topLevel0 = 0;
        state.topLevel1 = 0;
        state.parenTracker0 = 0;
        state.parenTracker1 = 0;
        state.lineTracker = 0;
        state.stackNames = 0;
        state.stackNameBloom = 0;
        state.stackTracker = ParseStackTracker.wrap(0);
    }

    function newState(bytes memory data, bytes memory meta) internal pure returns (ParseState memory) {
        ParseState memory state = ParseState(
            // activeSource
            // (will be built in `newActiveSource`)
            0,
            // topLevel0
            0,
            // topLevel1
            0,
            // parenTracker0
            0,
            // parenTracker1
            0,
            // lineTracker
            // (will be built in `newActiveSource`)
            0,
            // sourcesBuilder
            0,
            // fsm
            FSM_DEFAULT,
            // stackNames
            0,
            // stackNameBloom
            0,
            // literalBloom
            0,
            // constantsBuilder
            0,
            // literalParsers
            LibParseLiteral.buildLiteralParsers(),
            // operandParsers
            LibParseOperand.buildOperandParsers(),
            // stackTracker
            ParseStackTracker.wrap(0),
            data,
            meta
        );
        state.resetSource();
        return state;
    }

    // Find the pointer to the first opcode in the source LL. Put it in the line
    // tracker at the appropriate offset.
    function snapshotSourceHeadToLineTracker(ParseState memory state) internal pure {
        uint256 activeSourcePtr = state.activeSourcePtr;
        assembly ("memory-safe") {
            let topLevel0Pointer := add(state, 0x20)
            let totalRHSTopLevel := byte(0, mload(topLevel0Pointer))
            // Only do stuff if the current word counter is zero.
            if iszero(byte(0, mload(add(topLevel0Pointer, add(totalRHSTopLevel, 1))))) {
                let byteOffset := div(and(mload(activeSourcePtr), 0xFFFF), 8)
                let sourceHead := add(activeSourcePtr, sub(0x20, byteOffset))

                let lineTracker := mload(add(state, 0xa0))
                let lineRHSTopLevel := sub(totalRHSTopLevel, byte(30, lineTracker))
                let offset := mul(0x10, add(lineRHSTopLevel, 1))
                lineTracker := or(lineTracker, shl(offset, sourceHead))
                mstore(add(state, 0xa0), lineTracker)
            }
        }
    }

    function endLine(ParseState memory state, uint256 cursor) internal pure {
        unchecked {
            {
                uint256 parenOffset;
                assembly ("memory-safe") {
                    parenOffset := byte(0, mload(add(state, 0x60)))
                }
                if (parenOffset > 0) {
                    revert UnclosedLeftParen(state.parseErrorOffset(cursor));
                }
            }

            // This will snapshot the current head of the source, which will be
            // the start of where we want to read for the final line RHS item,
            // if it exists.
            state.snapshotSourceHeadToLineTracker();

            // Preserve the accepting inputs flag but set
            // everything else back to defaults. Also set that
            // there is an active source.
            state.fsm = (FSM_DEFAULT & ~FSM_ACCEPTING_INPUTS_MASK) | (state.fsm & FSM_ACCEPTING_INPUTS_MASK)
                | FSM_ACTIVE_SOURCE_MASK;

            uint256 lineLHSItems = state.lineTracker & 0xFF;
            // Total number of RHS at top level is the top byte of topLevel0.
            uint256 totalRHSTopLevel = state.topLevel0 >> 0xf8;
            // Snapshot for RHS from start of line is second low byte of
            // lineTracker.
            uint256 lineRHSTopLevel = totalRHSTopLevel - ((state.lineTracker >> 8) & 0xFF);

            // If:
            // - we are accepting inputs
            // - the RHS on this line is empty
            // Then we treat the LHS items as inputs to the source. This means that
            // we need to move the RHS offset to the end of the LHS items. There MAY
            // be 0 LHS items, e.g. if the entire source is empty. This can only
            // happen at the start of the source, as any RHS item immediately flips
            // the FSM to not accepting inputs.
            if (lineRHSTopLevel == 0) {
                if (state.fsm & FSM_ACCEPTING_INPUTS_MASK == 0) {
                    revert NotAcceptingInputs(state.parseErrorOffset(cursor));
                } else {
                    // As there are no RHS opcodes yet we can simply set topLevel0 directly.
                    // This is the only case where we defer to the LHS to tell
                    // us how many top level items there are.
                    totalRHSTopLevel += lineLHSItems;
                    state.topLevel0 = totalRHSTopLevel << 0xf8;

                    // Push the inputs onto the stack tracker.
                    state.stackTracker = state.stackTracker.pushInputs(lineLHSItems);
                }
            }
            // If:
            // - there are multiple RHS items on this line
            // Then there must be the same number of LHS items. Multi or zero output
            // RHS top level items are NOT supported unless they are the only RHS
            // item on that line.
            else if (lineRHSTopLevel > 1) {
                if (lineLHSItems < lineRHSTopLevel) {
                    revert ExcessRHSItems(state.parseErrorOffset(cursor));
                } else if (lineLHSItems > lineRHSTopLevel) {
                    revert ExcessLHSItems(state.parseErrorOffset(cursor));
                }
            }

            // Follow pointers to the start of the RHS item.
            uint256 topLevelOffset = 1 + totalRHSTopLevel - lineRHSTopLevel;
            uint256 end = (0x10 * lineRHSTopLevel) + 0x20;
            for (uint256 offset = 0x20; offset < end; offset += 0x10) {
                uint256 itemSourceHead = (state.lineTracker >> offset) & 0xFFFF;
                uint256 opsDepth;
                assembly ("memory-safe") {
                    opsDepth := byte(0, mload(add(state, add(0x20, topLevelOffset))))
                }
                for (uint256 i = 1; i <= opsDepth; i++) {
                    {
                        // We've hit the end of a LL item so have to jump towards the
                        // tail to keep going. This makes the assumption that
                        // the relevant pointers are aligned to 32 bytes, which
                        // is handled on allocation in `newActiveSourcePointer`.
                        if (itemSourceHead % 0x20 == 0x1c) {
                            assembly ("memory-safe") {
                                itemSourceHead := shr(0xf0, mload(itemSourceHead))
                            }
                        }
                        uint256 opInputs;
                        assembly ("memory-safe") {
                            opInputs := byte(1, mload(itemSourceHead))
                        }
                        state.stackTracker = state.stackTracker.pop(opInputs);
                        // Nested multi or zero output RHS items are NOT
                        // supported. If the top level RHS item is the ONLY RHS
                        // item on the line then it MAY have multiple or zero
                        // outputs. In this case we defer to the LHS to tell us
                        // how many outputs there are. If the LHS is wrong then
                        // later integrity checks will need to flag it.
                        state.stackTracker =
                            state.stackTracker.push(i == opsDepth && lineRHSTopLevel == 1 ? lineLHSItems : 1);
                    }
                    itemSourceHead += 4;
                }
                topLevelOffset++;
            }

            state.lineTracker = totalRHSTopLevel << 8;
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
                revert ParseStackOverflow();
            }
        }
    }

    function pushLiteral(ParseState memory state, uint256 cursor) internal pure returns (uint256) {
        unchecked {
            (
                function(ParseState memory, uint256, uint256) pure returns (uint256) parser,
                uint256 innerStart,
                uint256 innerEnd,
                uint256 outerEnd
            ) = state.boundLiteral(cursor);
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
                state.pushOpToSource(OPCODE_CONSTANT, Operand.wrap(exists ? constantsHeight - t : constantsHeight));
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
                    // the pointer to the next item in the linked list. If there
                    // is no next item then the pointer is 0.
                    uint256 tailKey = state.constantsBuilder >> 0x10 | fingerprint;
                    assembly ("memory-safe") {
                        mstore(ptr, tailKey)
                    }
                }
                // Second word is the value.
                {
                    uint256 tailValue = parser(state, innerStart, innerEnd);

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
            // This might be a top level item so try to snapshot its pointer to
            // the line tracker before writing the stack counter.
            state.snapshotSourceHeadToLineTracker();

            // As soon as we push an op to source we can no longer accept inputs.
            state.fsm &= ~FSM_ACCEPTING_INPUTS_MASK;
            // We also have an active source;
            state.fsm |= FSM_ACTIVE_SOURCE_MASK;

            // Increment the top level stack counter for the current top level
            // word. MAY be setting 0 to 1 if this is the top level.
            assembly ("memory-safe") {
                // Hardcoded offset into the state struct.
                let counterOffset := add(state, 0x20)
                let counterPointer := add(counterOffset, add(byte(0, mload(counterOffset)), 1))
                // Increment the counter.
                mstore8(counterPointer, add(byte(0, mload(counterPointer)), 1))
            }

            uint256 activeSource;
            uint256 offset;
            uint256 activeSourcePointer = state.activeSourcePtr;
            assembly ("memory-safe") {
                activeSource := mload(activeSourcePointer)
                // The low 16 bits of the active source is the current offset.
                offset := and(activeSource, 0xFFFF)

                // The offset is in bits so for a byte pointer we need to divide
                // by 8, then add 4 to move to the operand low byte.
                let inputsBytePointer := sub(add(activeSourcePointer, 0x20), add(div(offset, 8), 4))

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
                mstore(parenTrackerPointer, or(and(mload(parenTrackerPointer), not(0xFFFF)), inputsBytePointer))
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
            // include new op. The opcode is assumed to be 8 bits, so we shift it
            // into the correct position, beyond the operand.
            | opcode << (offset + 0x18);
            assembly ("memory-safe") {
                mstore(activeSourcePointer, activeSource)
            }

            // We have filled the current source slot. Need to create a new active
            // source and fulfill the doubly linked list.
            if (offset == 0xe0) {
                state.activeSourcePtr = newActiveSourcePointer(activeSourcePointer);
            }
        }
    }

    function endSource(ParseState memory state) internal pure {
        uint256 sourcesBuilder = state.sourcesBuilder;
        uint256 offset = sourcesBuilder >> 0xf0;

        // End is the number of top level words in the source, which is the
        // byte offset index + 1.
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
            ParseStackTracker stackTracker = state.stackTracker;
            uint256 cursor = state.activeSourcePtr;
            assembly ("memory-safe") {
                // find the end of the LL tail.
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
                // leave space for the source prefix in the bytecode output.
                let length := 4
                source := mload(0x40)
                // Move over the source 32 byte length and the 4 byte prefix.
                let writeCursor := add(source, 0x20)
                writeCursor := add(writeCursor, 4)

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
                // Store the bytes length in the source.
                mstore(source, length)
                // Store the opcodes length and stack tracker in the source
                // prefix.
                let prefixWritePointer := add(source, 4)
                mstore(
                    prefixWritePointer,
                    or(
                        and(mload(prefixWritePointer), not(0xFFFFFFFF)),
                        or(shl(0x18, sub(div(length, 4), 1)), stackTracker)
                    )
                )

                // Round up to the nearest 32 bytes to realign memory.
                mstore(0x40, and(add(writeCursor, 0x1f), not(0x1f)))
            }

            //slither-disable-next-line incorrect-shift
            state.sourcesBuilder =
                ((offset + 0x10) << 0xf0) | (source << offset) | (sourcesBuilder & ((1 << offset) - 1));

            // Reset source as we're done with this one.
            state.fsm &= ~FSM_ACTIVE_SOURCE_MASK;
            state.resetSource();
        }
    }

    function buildBytecode(ParseState memory state) internal pure returns (bytes memory bytecode) {
        unchecked {
            uint256 sourcesBuilder = state.sourcesBuilder;
            uint256 offsetEnd = (sourcesBuilder >> 0xf0);

            // Somehow the parser state for the active source was not reset
            // correctly, or the finalised offset is dangling. This implies that
            // we are building the overall sources array while still trying to
            // build one of the individual sources. This is a bug in the parser.
            uint256 activeSource;
            {
                uint256 activeSourcePointer = state.activeSourcePtr;
                assembly ("memory-safe") {
                    activeSource := mload(activeSourcePointer)
                }
            }

            if (activeSource != EMPTY_ACTIVE_SOURCE) {
                revert DanglingSource();
            }

            uint256 cursor;
            uint256 sourcesCount;
            uint256 sourcesStart;
            assembly ("memory-safe") {
                cursor := mload(0x40)
                bytecode := cursor
                // Move past the bytecode length, we will write this at the end.
                cursor := add(cursor, 0x20)

                // First byte is the number of sources.
                sourcesCount := div(offsetEnd, 0x10)
                mstore8(cursor, sourcesCount)
                cursor := add(cursor, 1)

                let pointersCursor := cursor

                // Skip past the pointer space. We'll back fill it.
                // Divide offsetEnd to convert from a bit to a byte shift.
                cursor := add(cursor, div(offsetEnd, 8))
                sourcesStart := cursor

                // Write total bytes length into bytecode. We do ths and handle
                // the allocation in this same assembly block for memory safety
                // for the compiler optimiser.
                let sourcesLength := 0
                let sourcePointers := 0
                for { let offset := 0 } lt(offset, offsetEnd) { offset := add(offset, 0x10) } {
                    let currentSourcePointer := and(shr(offset, sourcesBuilder), 0xFFFF)
                    // add 4 byte prefix to the length of the sources, all as
                    // bytes.
                    sourcePointers := or(sourcePointers, shl(sub(0xf0, offset), sourcesLength))
                    let currentSourceLength := mload(currentSourcePointer)

                    // Put the reference source pointer and length into the
                    // prefix so that we can use them to copy the actual data
                    // into the bytecode.
                    let tmpPrefix := shl(0xe0, or(shl(0x10, currentSourcePointer), currentSourceLength))
                    mstore(add(sourcesStart, sourcesLength), tmpPrefix)
                    sourcesLength := add(sourcesLength, currentSourceLength)
                }
                mstore(pointersCursor, or(mload(pointersCursor), sourcePointers))
                mstore(bytecode, add(sourcesLength, sub(sub(sourcesStart, 0x20), bytecode)))

                // Round up to the nearest 32 bytes past cursor to realign and
                // allocate memory.
                mstore(0x40, and(add(add(add(0x20, mload(bytecode)), bytecode), 0x1f), not(0x1f)))
            }

            // Loop over the sources and write them into the bytecode. Perhaps
            // there is a more efficient way to do this in the future that won't
            // cause each source to be written twice in memory.
            for (uint256 i = 0; i < sourcesCount; i++) {
                Pointer sourcePointer;
                uint256 length;
                Pointer targetPointer;
                assembly ("memory-safe") {
                    let relativePointer := and(mload(add(bytecode, add(3, mul(i, 2)))), 0xFFFF)
                    targetPointer := add(sourcesStart, relativePointer)
                    let tmpPrefix := mload(targetPointer)
                    sourcePointer := add(0x20, shr(0xf0, tmpPrefix))
                    length := and(shr(0xe0, tmpPrefix), 0xFFFF)
                }
                LibMemCpy.unsafeCopyBytesTo(sourcePointer, targetPointer, length);
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
