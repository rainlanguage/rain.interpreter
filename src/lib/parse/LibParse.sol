// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibMemCpy.sol";

import "./LibCtPop.sol";
import "./LibParseMeta.sol";
import "./LibParseCMask.sol";
import "./LibParseLiteral.sol";
import "./LibParseOperand.sol";
import "../../interface/IInterpreterV1.sol";
import "./LibParseStackName.sol";

/// The expression does not finish with a semicolon (EOF).
error MissingFinalSemi(uint256 offset);

/// Enountered an unexpected character on the LHS.
error UnexpectedLHSChar(uint256 offset);

/// Encountered an unexpected character on the RHS.
error UnexpectedRHSChar(uint256 offset);

/// More specific version of UnexpectedRHSChar where we specifically expected
/// a left paren but got some other char.
error ExpectedLeftParen(uint256 offset);

/// Encountered a right paren without a matching left paren.
error UnexpectedRightParen(uint256 offset);

/// Encountered an unclosed left paren.
error UnclosedLeftParen(uint256 offset);

/// Encountered a comment outside the interstitial space between lines.
error UnexpectedComment(uint256 offset);

/// Encountered a comment start sequence that is malformed.
error MalformedCommentStart(uint256 offset);

/// @dev Thrown when a stack name is duplicated. Shadowing in all forms is
/// disallowed in Rainlang.
error DuplicateLHSItem(uint256 errorOffset);

/// Encountered too many LHS items.
error ExcessLHSItems(uint256 offset);

/// Encountered inputs where they can't be handled.
error NotAcceptingInputs(uint256 offset);

/// Encountered too many RHS items.
error ExcessRHSItems(uint256 offset);

/// Encountered a word that is longer than 32 bytes.
error WordSize(string word);

/// Parsed a word that is not in the meta.
error UnknownWord(uint256 offset);

/// The parser exceeded the maximum number of sources that it can build.
error MaxSources();

/// The parser encountered a dangling source. This is a bug in the parser.
error DanglingSource();

/// The parser moved past the end of the data.
error ParserOutOfBounds();

/// The parser encountered a stack deeper than it can process in the memory
/// region allocated for stack names.
error StackOverflow();

/// The parser encountered a stack underflow.
error StackUnderflow();

/// The parser encountered a paren group deeper than it can process in the
/// memory region allocated for paren tracking.
error ParenOverflow();

uint256 constant NOT_LOW_16_BIT_MASK = ~uint256(0xFFFF);
uint256 constant ACTIVE_SOURCE_MASK = NOT_LOW_16_BIT_MASK;

uint256 constant FSM_RHS_MASK = 1;
uint256 constant FSM_YANG_MASK = 1 << 1;
uint256 constant FSM_WORD_END_MASK = 1 << 2;
uint256 constant FSM_ACCEPTING_INPUTS_MASK = 1 << 3;

/// @dev The space between lines where comments and whitespace is allowed.
/// The first LHS item breaks us out of the interstitial.
uint256 constant FSM_INTERSTITIAL_MASK = 1 << 4;

/// @dev If a source is active we cannot finish parsing without a semi to trigger
/// finalisation.
uint256 constant FSM_ACTIVE_SOURCE_MASK = 1 << 5;

/// @dev fsm default state is:
/// - LHS
/// - yin
/// - not word end
/// - accepting inputs
/// - interstitial
uint256 constant FSM_DEFAULT = FSM_ACCEPTING_INPUTS_MASK | FSM_INTERSTITIAL_MASK;

uint256 constant EMPTY_ACTIVE_SOURCE = 0x20;

/// @dev The opcode that will be used in the source to represent a stack copy
/// implied by named LHS stack items.
/// @dev @todo support the meta defining the opcode.
uint256 constant OPCODE_STACK = 0;

/// @dev The opcode that will be used in the source to read a constant.
/// @dev @todo support the meta defining the opcode.
uint256 constant OPCODE_CONSTANT = 1;

type StackTracker is uint256;

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
/// @param topLevel1 32 additional bytes of stack words, allowing for 63 top
/// level stack items total per source.
/// @param parenTracker0 Memory region for tracking pointers to words in the
/// source, and counters for the number of words in each paren group. The first
/// byte is a counter/offset into the region. The second byte is a phantom
/// counter for the root level, the remaining 30 bytes are the paren group words.
/// @param parenTracker1 32 additional bytes of paren group words.
/// @param lineTracker A 32 byte memory region for tracking the current line.
/// Will be partially reset for each line when `balanceLine` is called. Fully
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
    StackTracker stackTracker;
}

library LibStackTracker {
    using LibStackTracker for StackTracker;

    /// Pushing inputs requires special handling as the inputs need to be tallied
    /// separately and in addition to the regular stack pushes.
    function pushInputs(StackTracker tracker, uint256 n) internal pure returns (StackTracker) {
        unchecked {
            tracker = tracker.push(n);
            uint256 inputs = (StackTracker.unwrap(tracker) >> 8) & 0xFF;
            inputs += n;
            return StackTracker.wrap((StackTracker.unwrap(tracker) & ~uint256(0xFF00)) | (inputs << 8));
        }
    }

    function push(StackTracker tracker, uint256 n) internal pure returns (StackTracker) {
        unchecked {
            uint256 current = StackTracker.unwrap(tracker) & 0xFF;
            uint256 inputs = (StackTracker.unwrap(tracker) >> 8) & 0xFF;
            uint256 max = StackTracker.unwrap(tracker) >> 0x10;
            current += n;
            if (current > max) {
                max = current;
            }
            return StackTracker.wrap(current | (inputs << 8) | (max << 0x10));
        }
    }

    function pop(StackTracker tracker, uint256 n) internal pure returns (StackTracker) {
        unchecked {
            uint256 current = StackTracker.unwrap(tracker) & 0xFF;
            if (current < n) {
                revert StackUnderflow();
            }
            return StackTracker.wrap(StackTracker.unwrap(tracker) - n);
        }
    }
}

library LibParseState {
    using LibParseState for ParseState;
    using LibStackTracker for StackTracker;

    function resetSource(ParseState memory state) internal pure {
        uint256 activeSourcePtr;
        uint256 emptyActiveSource = EMPTY_ACTIVE_SOURCE;
        assembly ("memory-safe") {
            activeSourcePtr := mload(0x40)
            mstore(activeSourcePtr, emptyActiveSource)
            mstore(0x40, add(activeSourcePtr, 0x20))
        }
        state.activeSourcePtr = activeSourcePtr;
        state.topLevel0 = 0;
        state.topLevel1 = 0;
        state.lineTracker = 0;
        state.stackTracker = StackTracker.wrap(0);
    }

    function newState() internal pure returns (ParseState memory) {
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
            StackTracker.wrap(0)
        );
        state.resetSource();
        return state;
    }

    // Find the pointer to the first opcode in the source LL. Put it in the line
    // tracker at the appropriate offset.
    function snapshotSourceHeadToLineTracker(ParseState memory state) internal pure {
        assembly ("memory-safe") {
            let topLevel0Pointer := add(state, 0x20)
            let totalRHSTopLevel := byte(0, mload(topLevel0Pointer))
            // Only do stuff if the current word counter is zero.
            if iszero(byte(0, mload(add(topLevel0Pointer, add(totalRHSTopLevel, 1))))) {
                let sourceHead := mload(state)
                let byteOffset := div(and(mload(sourceHead), 0xFFFF), 8)
                sourceHead := add(sourceHead, sub(0x20, byteOffset))

                let lineTracker := mload(add(state, 0xa0))
                let lineRHSTopLevel := sub(totalRHSTopLevel, byte(30, lineTracker))
                let offset := mul(0x10, add(lineRHSTopLevel, 1))
                lineTracker := or(lineTracker, shl(offset, sourceHead))
                mstore(add(state, 0xa0), lineTracker)
            }
        }
    }

    function endLine(ParseState memory state, bytes memory data, uint256 cursor) internal pure {
        unchecked {
            {
                uint256 parenOffset;
                assembly ("memory-safe") {
                    parenOffset := byte(0, mload(add(state, 0x60)))
                }
                if (parenOffset > 0) {
                    revert UnclosedLeftParen(LibParse.parseErrorOffset(data, cursor));
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
                    revert NotAcceptingInputs(LibParse.parseErrorOffset(data, cursor));
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
                    revert ExcessRHSItems(LibParse.parseErrorOffset(data, cursor));
                } else if (lineLHSItems > lineRHSTopLevel) {
                    revert ExcessLHSItems(LibParse.parseErrorOffset(data, cursor));
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
                        // tail to keep going.
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
                revert StackOverflow();
            }
        }
    }

    function pushLiteral(ParseState memory state, bytes memory data, uint256 cursor) internal pure returns (uint256) {
        unchecked {
            (
                function(bytes memory, uint256, uint256) pure returns (uint256) parser,
                uint256 innerStart,
                uint256 innerEnd,
                uint256 outerEnd
            ) = LibParseLiteral.boundLiteral(state.literalParsers, data, cursor);
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
                    // the pointer to the next item in the linked list.
                    uint256 tailKey = state.constantsBuilder >> 0x10 | fingerprint;
                    assembly ("memory-safe") {
                        mstore(ptr, tailKey)
                    }
                }
                // Second word is the value.
                {
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
            assembly ("memory-safe") {
                let activeSourcePointer := mload(state)
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

    function endSource(ParseState memory state) internal pure {
        state.fsm &= ~FSM_ACTIVE_SOURCE_MASK;

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
            StackTracker stackTracker = state.stackTracker;
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
            assembly ("memory-safe") {
                activeSource := mload(mload(state))
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

library LibParse {
    using LibPointer for Pointer;
    using LibParseState for ParseState;
    using LibParseStackName for ParseState;

    function parseErrorOffset(bytes memory data, uint256 cursor) internal pure returns (uint256 offset) {
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 0x20))
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

    /// Skip an unlimited number of chars until we find one that is not in the
    /// mask. This MAY REVERT if the cursor is OOB.
    function skipMask(uint256 cursor, uint256 mask) internal pure returns (uint256) {
        uint256 i;
        assembly ("memory-safe") {
            let done := 0
            for {} iszero(done) {} {
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

    /// The cursor currently points at the head of a comment. We need to skip
    /// over all data until we find the end of the comment. This MAY REVERT if
    /// the comment is malformed, e.g. if the comment doesn't start with `/*`.
    /// @param data The source data.
    /// @param cursor The current cursor position.
    /// @return The new cursor position.
    function skipComment(bytes memory data, uint256 cursor) internal pure returns (uint256) {
        // First check the comment opening sequence is not malformed.
        uint256 startSequence;
        assembly ("memory-safe") {
            startSequence := shr(0xf0, mload(cursor))
        }
        if (startSequence != COMMENT_START_SEQUENCE) {
            revert MalformedCommentStart(parseErrorOffset(data, cursor));
        }
        uint256 commentEndSequenceStart = COMMENT_END_SEQUENCE >> 8;
        uint256 commentEndSequenceEnd = COMMENT_END_SEQUENCE & 0xFF;
        uint256 max;
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

    //slither-disable-next-line cyclomatic-complexity
    function parse(bytes memory data, bytes memory meta)
        internal
        pure
        returns (bytes memory bytecode, uint256[] memory)
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
                                revert UnexpectedLHSChar(parseErrorOffset(data, cursor));
                            }

                            // Named stack item.
                            if (char & CMASK_IDENTIFIER_HEAD > 0) {
                                (cursor, word) = parseWord(cursor, CMASK_LHS_STACK_TAIL);
                                (bool exists, uint256 index) = state.pushStackName(word);
                                (index);
                                // If the stack name already exists, then we
                                // revert as shadowing is not allowed.
                                if (exists) {
                                    revert DuplicateLHSItem(parseErrorOffset(data, cursor));
                                }
                            }
                            // Anon stack item.
                            else {
                                cursor = skipMask(cursor + 1, CMASK_LHS_STACK_TAIL);
                            }
                            // Bump the index regardless of whether the stack
                            // item is named or not.
                            state.lineTracker++;

                            // Set yang as we are now building a stack item.
                            // We are also no longer interstitial
                            state.fsm = (state.fsm | FSM_YANG_MASK | FSM_ACTIVE_SOURCE_MASK) & ~FSM_INTERSTITIAL_MASK;
                        } else if (char & CMASK_WHITESPACE != 0) {
                            cursor = skipMask(cursor + 1, CMASK_WHITESPACE);
                            // Set ying as we now open to possibilities.
                            state.fsm &= ~FSM_YANG_MASK;
                        } else if (char & CMASK_LHS_RHS_DELIMITER != 0) {
                            // Set RHS and yin. Move out of the interstitial if
                            // we haven't already.
                            state.fsm = (state.fsm | FSM_RHS_MASK | FSM_ACTIVE_SOURCE_MASK)
                                & ~(FSM_YANG_MASK | FSM_INTERSTITIAL_MASK);
                            cursor++;
                        } else if (char & CMASK_COMMENT_HEAD != 0) {
                            if (state.fsm & FSM_INTERSTITIAL_MASK == 0) {
                                revert UnexpectedComment(parseErrorOffset(data, cursor));
                            }
                            cursor = skipComment(data, cursor);
                            // Set yang for comments to force a little breathing
                            // room between comments and the next item.
                            state.fsm |= FSM_YANG_MASK;
                        } else {
                            revert UnexpectedLHSChar(parseErrorOffset(data, cursor));
                        }
                    }
                    // RHS
                    else {
                        if (char & CMASK_RHS_WORD_HEAD > 0) {
                            // If yang we can't start a new word.
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                revert UnexpectedRHSChar(parseErrorOffset(data, cursor));
                            }

                            (cursor, word) = parseWord(cursor, CMASK_RHS_WORD_TAIL);

                            // First check if this word is in meta.
                            (
                                bool exists,
                                uint256 opcodeIndex,
                                function(uint256, bytes memory, uint256) pure returns (uint256, Operand) operandParser
                            ) = LibParseMeta.lookupWord(meta, state.operandParsers, word);
                            if (exists) {
                                Operand operand;
                                (cursor, operand) = operandParser(state.literalParsers, data, cursor);
                                state.pushOpToSource(opcodeIndex, operand);
                                // This is a real word so we expect to see parens
                                // after it.
                                state.fsm |= FSM_WORD_END_MASK;
                            }
                            // Fallback to LHS items.
                            else {
                                (exists, opcodeIndex) = LibParseStackName.stackNameIndex(state, word);
                                if (exists) {
                                    state.pushOpToSource(OPCODE_STACK, Operand.wrap(opcodeIndex));
                                    // Need to process highwater here because we
                                    // don't have any parens to open or close.
                                    state.highwater();
                                } else {
                                    revert UnknownWord(parseErrorOffset(data, cursor));
                                }
                            }

                            state.fsm |= FSM_YANG_MASK;
                        }
                        // If this is the end of a word we MUST start a paren.
                        else if (state.fsm & FSM_WORD_END_MASK > 0) {
                            if (char & CMASK_LEFT_PAREN == 0) {
                                revert ExpectedLeftParen(parseErrorOffset(data, cursor));
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
                                revert UnexpectedRightParen(parseErrorOffset(data, cursor));
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
                            cursor = skipMask(cursor + 1, CMASK_WHITESPACE);
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
                            state.endLine(data, cursor);
                            cursor++;
                        }
                        // End of source.
                        else if (char & CMASK_EOS > 0) {
                            state.endLine(data, cursor);
                            state.endSource();
                            cursor++;

                            state.fsm = FSM_DEFAULT;
                        }
                        // Comments aren't allowed in the RHS but we can give a
                        // nicer error message than the default.
                        else if (char & CMASK_COMMENT_HEAD != 0) {
                            revert UnexpectedComment(parseErrorOffset(data, cursor));
                        } else {
                            revert UnexpectedRHSChar(parseErrorOffset(data, cursor));
                        }
                    }
                }
                if (cursor != end) {
                    revert ParserOutOfBounds();
                }
                if (state.fsm & FSM_ACTIVE_SOURCE_MASK != 0) {
                    revert MissingFinalSemi(parseErrorOffset(data, cursor));
                }
            }
            return (state.buildBytecode(), state.buildConstants());
        }
    }
}
