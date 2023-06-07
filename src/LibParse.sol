// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// Error 1
error MissingFinalSemi(uint256 offset);

// Error 2
error UnexpectedLHSChar(uint256 offset, string char);

// Error 3
error UnexpectedRHSChar(uint256 offset, string char);

// Error 4
error WordTooLong(uint256 offset);

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

/// @dev -
uint128 constant CMASK_DASH = 0x200000000000;

/// @dev :
uint128 constant CMASK_COLON = 0x0400000000000000;

/// @dev ;
uint128 constant CMASK_SEMICOLON = 0x800000000000000;

/// @dev _
uint128 constant CMASK_UNDERSCORE = 0x800000000000000000000000;

/// @dev (
uint128 constant CMASK_LEFT_PAREN = 0x10000000000;

/// @dev )
uint128 constant CMASK_RIGHT_PAREN = 0x20000000000;

/// @dev LHS/RHS delimiter is :
uint128 constant CMASK_LHS_RHS_DELIMITER = 0x0400000000000000;
/// @dev lower alpha and underscore a-z _
uint128 constant CMASK_LHS_STACK_HEAD = 0xffffffe800000000000000000000000;

/// @dev lower alpha a-z
uint128 constant CMASK_IDENTIFIER_HEAD = 0xffffffe000000000000000000000000;
/// @dev lower alphanumeric kebab a-z 0-9 -
uint128 constant CMASK_IDENTIFIER_TAIL = 0xffffffe0000000003ff200000000000;
/// @dev NOT lower alphanumeric kebab
uint128 constant CMASK_NOT_IDENTIFIER_TAIL = 0xf0000001fffffffffc00dfffffffffff;

/// @dev stack item delimiter is space
uint128 constant CMASK_LHS_STACK_DELIMITER = 0x0100000000;

/// @dev whitespace is \n \r \t space
uint128 constant CMASK_WHITESPACE = 0x100002600;

library LibParse {
    function stringToChar(string memory s) external pure returns (uint256 char) {
        return 1 << uint256(uint8(bytes1(bytes(s))));
    }

    function parse(bytes memory data) internal pure returns (bytes[] memory, uint256[] memory) {
        if (data.length > 0) {
            uint256 char;
            uint256 errorCode;
            uint256 state;
            assembly ("memory-safe") {
                function buildErrorCode(data_, cursor_, byteCode_) -> errorCode_ {
                    errorCode_ :=
                        or(shl(16, sub(cursor_, add(data_, 1))), or(shl(8, byteCode_), and(mload(cursor_), 0xFF)))
                }

                // Notable excerpts from ASCII as shifted chars
                // mask for structure , : ;
                // 0x0C00100000000000
                //
                // mask for a-z
                // 0xffffffe000000000000000000000000
                //
                // mask for 0-9
                // 0x3ff000000000000
                //
                // mask for lower alphanumeric kebab case a-z 0-9 -
                // 0xffffffe0000000003ff200000000000
                //
                // mask for lower alpha kebab case a-z -
                // 0xffffffe000000000000200000000000
                //
                // mask for lower alpha and underscore a-z _
                // 0xffffffe800000000000000000000000
                let outputCursor := mload(0x40)

                // Layout of state is
                // EXTREME care must be taken if the layout changes to ensure ALL
                // reads and writes are updated to match.
                // 0 => lhs/rhs and yin/yang flags
                // 0x20 => stackIndex
                // 0x40 => pointer to sources
                // 0x60 => named stack linked list head
                // 0x80 => current source linked list head
                state := outputCursor
                outputCursor := add(outputCursor, 0xA0)

                // start with lhs = 1 and yin/yang = 0
                mstore(state, 1)

                // start with empty stack
                mstore(add(state, 0x20), 0)

                // start with empty sources
                mstore(add(state, 0x40), 0x60)

                // base of stack linked list is 0
                mstore(add(state, 0x60), 0)

                // base of source linked list is 0
                // low 32 bits are the pointer to the next item
                // high bits are bytecode of the source
                mstore(add(state, 0x80), 0)

                // Additionally we are using the scratch space to build source
                // 0x0 => for tracking length of the current source, sources and
                // pointers to all sources (max 14)
                // low 16 bits = length of source (# of ops NOT bytes/bits)
                // high 16 bits = length of sources
                // big endian middle bits = 16 bit pointers to sources
                mstore(0, 0)

                let cursor := add(data, 1)
                let end := add(cursor, mload(data))
                for {} lt(cursor, end) { cursor := add(cursor, 1) } {
                    // Cursor must be incremented by the inner logic.
                    char := shl(and(mload(cursor), 0xFF), 1)

                    switch and(mload(state), 1)
                    // Process LHS (stack items).
                    case 1 {
                        // stack items
                        // first char is lower alpha a-z _
                        // tail chars will be lower alphanumeric kebab a-z 0-9 -
                        if and(char, 0xffffffe800000000000000000000000) {
                            // if yang we can't start a new stack item
                            if and(mload(state), 2) {
                                errorCode := buildErrorCode(data, cursor, 2)
                                break
                            }

                            let word := mload(add(cursor, 0x20))

                            // loop over the word
                            let i := 0
                            for {} and(
                                lt(i, 0x20),
                                // not not a tail char
                                iszero(and(shl(byte(i, word), 1), 0xf0000001fffffffffc00dfffffffffff))
                            ) { i := add(i, 1) } {}
                            if lt(i, 0x20) {
                                // If the stack item is named, save its stack
                                // position in a FILO linked list structure.
                                if and(char, 0xffffffe000000000000000000000000) {
                                    let name := shr(sub(256, mul(add(i, 1), 8)), mload(add(cursor, 0x1F)))
                                    mstore(outputCursor, name)
                                    name := keccak256(outputCursor, 0x20)

                                    // Prepend name to linked list.
                                    mstore(outputCursor, mload(add(state, 0x60)))
                                    mstore(
                                        add(state, 0x60),
                                        or(
                                            // make room in the name for pointers
                                            shl(0x20, name),
                                            // pointers
                                            or(
                                                // current stack height, assume
                                                // it can't exceed 16 bits.
                                                shl(0x10, mload(add(state, 0x20))),
                                                // pointer to old head, assume
                                                // it can't exceed 16 bits of
                                                // memory (64Kb)
                                                outputCursor
                                            )
                                        )
                                    )
                                    outputCursor := add(outputCursor, 0x20)
                                }

                                // Update state ready for next char.
                                {
                                    // increment stack height
                                    let stateStackOffset := add(state, 0x20)
                                    mstore(stateStackOffset, add(mload(stateStackOffset), 1))

                                    // lhs/rhs = 1, yin/yang = 1
                                    mstore(state, 3)
                                }

                                cursor := add(cursor, i)
                                continue
                            }
                            errorCode := buildErrorCode(data, cursor, 4)
                            break
                        }

                        // whitespace
                        if and(char, 0x100002600) {
                            // lhs/rhs = 1, yin/yang = 0
                            mstore(state, 1)
                            continue
                        }

                        // end of lhs
                        // char equals :
                        if eq(char, 0x0400000000000000) {
                            // lhs/rhs = 0, yin/yang = 0
                            mstore(state, 0)
                            continue
                        }
                        errorCode := buildErrorCode(data, cursor, 2)
                        break
                    }
                    // Process RHS (opcodes).
                    case 0 {
                        // words
                        // first char is lower a-z
                        if and(char, 0xffffffe000000000000000000000000) {
                            // if yang we can't start a new word
                            if and(mload(state), 2) {
                                errorCode := buildErrorCode(data, cursor, 2)
                                break
                            }

                            let word := mload(add(cursor, 0x20))

                            // loop over the word
                            let i := 0
                            for {} and(
                                lt(i, 0x20),
                                // not not a tail char
                                iszero(and(shl(byte(i, word), 1), 0xf0000001fffffffffc00dfffffffffff))
                            ) { i := add(i, 1) } {}

                            // RHS words MUST be appended by a left paren (
                            // literal byte check here, NOT a char shifted mask
                            // for efficiency
                            if eq(byte(i, word), 0x28) {
                                let op := shr(sub(256, mul(add(i, 1), 8)), mload(add(cursor, 0x1F)))
                                mstore(outputCursor, op)
                                // @todo this is fake, the hash bytes are mimic
                                // for the opcode and the operand is left as 0
                                op := shl(0x10, and(keccak256(outputCursor, 0x20), 0xFFFF))

                                // Prepend op to source linked list
                                let sourceLength := and(mload(0), 0xFFFF)
                                let offset := mul(add(mod(sourceLength, 0x07), 1), 0x20)

                                mstore(add(state, 0x80), or(mload(add(state, 0x80)), shl(offset, op)))
                                // inc source length
                                mstore(
                                    0,
                                    or(
                                        add(sourceLength, 1),
                                        and(
                                            mload(0), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
                                        )
                                    )
                                )

                                if eq(offset, 0xe0) {
                                    mstore(outputCursor, mload(add(state, 0x80)))
                                    mstore(
                                        add(state, 0x80),
                                        // assume output cursor can't exceed 16
                                        // bits.
                                        outputCursor
                                    )
                                    outputCursor := add(outputCursor, 0x20)
                                }

                                cursor := add(cursor, add(i, 1))
                                continue
                            }

                            if eq(i, 0x20) {
                                errorCode := buildErrorCode(data, cursor, 4)
                                break
                            }

                            errorCode := buildErrorCode(data, add(cursor, i), 3)
                            break
                        }

                        // closing paren
                        // char equals )
                        if eq(char, 0x20000000000) {
                            // rhs = 0, yin = 0
                            mstore(state, 0)

                            // @todo track nested inputs
                            continue
                        }

                        // whitespace
                        if and(char, 0x100002600) {
                            // rhs = 0, yin = 0
                            mstore(state, 0)
                            continue
                        }

                        // end of rhs
                        // char equals ,
                        if eq(char, 0x100000000000) {
                            // lhs/rhs = 1, yin/yang = 0
                            mstore(state, 1)
                            continue
                        }

                        // end of source
                        // implies end of rhs
                        // char equals ;
                        if eq(char, 0x0800000000000000) {
                            // lhs/rhs = 1, yin/yang = 0
                            mstore(state, 1)

                            // Update sources
                            {
                                let sourcesLength := byte(1, mload(0))
                                mstore8(1, add(sourcesLength, 1))
                                mstore(0, or(mload(0), shl(sub(0xe0, mul(sourcesLength, 0x10)), outputCursor)))
                            }

                            // Build solidity compatible `bytes` out of source
                            // linked list
                            let sourceLength := and(mload(0), 0xFFFF)
                            // Reset source length in memory.
                            mstore(0, and(mload(0), not(0xFFFF)))

                            mstore(outputCursor, mul(sourceLength, 0x04))
                            outputCursor := add(outputCursor, 0x20)

                            let sourceHead := mload(add(state, 0x80))
                            // Write the head opcodes into the bytes
                            mstore(
                                outputCursor,
                                // shift the ops up to start at the outputCursor
                                shl(
                                    // it's not possible to have a full item in
                                    // the head position, as full items are
                                    // always bumped to the tail, so we always
                                    // shift at least one slot to the left
                                    mul(sub(0x07, mod(sourceLength, 0x07)), 0x20),
                                    // mask out the pointer to the next list item
                                    and(sourceHead, not(0xFFFF))
                                )
                            )
                            outputCursor := add(outputCursor, mul(mod(sourceLength, 0x07), 0x04))

                            // Loop over the tail
                            for { let tailPointer := and(sourceHead, 0xFFFF) } iszero(iszero(tailPointer)) {} {
                                tailPointer := and(mload(tailPointer), 0xFFFF)
                                mstore(outputCursor, and(mload(tailPointer), not(0xFFFF)))
                                outputCursor := add(outputCursor, 0x1c)
                            }

                            // Reset the linked list
                            mstore(add(state, 0x80), 0)
                            // Realign outputCursor with 32 byte memory
                            {
                                let unaligned := mod(outputCursor, 0x20)
                                outputCursor := add(sub(outputCursor, unaligned), and(add(unaligned, 0x1F), not(0x1F)))
                            }

                            continue
                        }

                        errorCode := buildErrorCode(data, cursor, 3)
                        break
                    }
                    // unreachable, implies broken lhs flag.
                    default { revert(0, 0) }
                }

                // Build real sources
                {
                    let sourcesScratch := mload(0)
                    let sourcesLength := byte(1, sourcesScratch)
                    mstore(add(state, 0x40), outputCursor)
                    mstore(outputCursor, sourcesLength)
                    outputCursor := add(outputCursor, 0x20)
                    for {
                        let offset := 0xe0
                        let sourcesEnd := sub(offset, mul(sourcesLength, 0x10))
                    } gt(offset, sourcesEnd) {
                        offset := sub(offset, 0x10)
                        outputCursor := add(outputCursor, 0x20)
                    } { mstore(outputCursor, and(shr(offset, sourcesScratch), 0xFFFF)) }
                }

                // Sync free memory pointer with final output cursor
                mstore(0x40, outputCursor)

                // missing final semi
                if and(iszero(errorCode), iszero(eq(char, 0x0800000000000000))) {
                    errorCode := buildErrorCode(data, cursor, 1)
                }
            }

            bytes[] memory sources;
            uint256[] memory constants;
            assembly ("memory-safe") {
                sources := mload(add(state, 0x40))
            }

            if (errorCode > 0) {
                string memory s = string(abi.encodePacked(uint8(errorCode)));
                uint256 code = errorCode >> 8 & 0xFF;
                uint256 offset = errorCode >> 16;
                if (code == 1) {
                    revert MissingFinalSemi(offset);
                } else if (code == 2) {
                    revert UnexpectedLHSChar(offset, s);
                } else if (code == 3) {
                    revert UnexpectedRHSChar(offset, s);
                } else if (code == 4) {
                    revert WordTooLong(offset);
                }
            }

            return (sources, constants);
        } else {
            return (new bytes[](0), new uint256[](0));
        }
    }
}

// // The second char is not a word char so do nothing.
// if iszero(and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000)) { continue }

// // inline the first 16 word chars for gas efficiency.
// // It is usual for named stack items to be more than
// // one char long, so we can do better than looping in
// // terms of gas.
// if and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000) {
//     if and(shl(byte(0x01, word), 1), 0xffffffe0000000003ff200000000000) {
//         if and(shl(byte(0x02, word), 1), 0xffffffe0000000003ff200000000000) {
//             if and(shl(byte(0x03, word), 1), 0xffffffe0000000003ff200000000000) {
//                 if and(shl(byte(0x04, word), 1), 0xffffffe0000000003ff200000000000) {
//                     if and(shl(byte(0x05, word), 1), 0xffffffe0000000003ff200000000000) {
//                         if and(shl(byte(0x06, word), 1), 0xffffffe0000000003ff200000000000)
//                         {
//                             if and(
//                                 shl(byte(0x07, word), 1), 0xffffffe0000000003ff200000000000
//                             ) {
//                                 if and(
//                                     shl(byte(0x08, word), 1),
//                                     0xffffffe0000000003ff200000000000
//                                 ) {
//                                     if and(
//                                         shl(byte(0x09, word), 1),
//                                         0xffffffe0000000003ff200000000000
//                                     ) {
//                                         if and(
//                                             shl(byte(0x0A, word), 1),
//                                             0xffffffe0000000003ff200000000000
//                                         ) {
//                                             if and(
//                                                 shl(byte(0x0B, word), 1),
//                                                 0xffffffe0000000003ff200000000000
//                                             ) {
//                                                 if and(
//                                                     shl(byte(0x0C, word), 1),
//                                                     0xffffffe0000000003ff200000000000
//                                                 ) {
//                                                     if and(
//                                                         shl(byte(0x0D, word), 1),
//                                                         0xffffffe0000000003ff200000000000
//                                                     ) {
//                                                         if and(
//                                                             shl(byte(0x0E, word), 1),
//                                                             0xffffffe0000000003ff200000000000
//                                                         ) {
//                                                             if and(
//                                                                 shl(byte(0x0F, word), 1),
//                                                                 0xffffffe0000000003ff200000000000
//                                                             ) {
//                                                                 // loop for the remainder for 16+ char words.
//                                                                 let i := 0x10
//                                                                 for {} and(
//                                                                     lt(i, 0x20),
//                                                                     iszero(
//                                                                         iszero(
//                                                                             and(
//                                                                                 shl(
//                                                                                     byte(
//                                                                                         i,
//                                                                                         word
//                                                                                     ),
//                                                                                     1
//                                                                                 ),
//                                                                                 0xffffffe0000000003ff200000000000
//                                                                             )
//                                                                         )
//                                                                     )
//                                                                 ) { i := add(i, 1) } {}
//                                                                 if lt(i, 0x20) {
//                                                                     cursor := add(cursor, i)
//                                                                     continue
//                                                                 }
//                                                                 errorCode :=
//                                                                     buildErrorCode(
//                                                                         data, cursor, 4
//                                                                     )
//                                                                 break
//                                                             }
//                                                             cursor := add(cursor, 0x0F)
//                                                             continue
//                                                         }
//                                                         cursor := add(cursor, 0x0E)
//                                                         continue
//                                                     }
//                                                     cursor := add(cursor, 0x0D)
//                                                     continue
//                                                 }
//                                                 cursor := add(cursor, 0x0C)
//                                                 continue
//                                             }
//                                             cursor := add(cursor, 0x0B)
//                                             continue
//                                         }
//                                         cursor := add(cursor, 0x0A)
//                                         continue
//                                     }
//                                     cursor := add(cursor, 0x09)
//                                     continue
//                                 }
//                                 cursor := add(cursor, 0x08)
//                                 continue
//                             }
//                             cursor := add(cursor, 0x07)
//                             continue
//                         }
//                         cursor := add(cursor, 0x06)
//                         continue
//                     }
//                     cursor := add(cursor, 0x05)
//                     continue
//                 }
//                 cursor := add(cursor, 0x04)
//                 continue
//             }
//             cursor := add(cursor, 0x03)
//             continue
//         }
//         cursor := add(cursor, 0x02)
//         continue
//     }
//     cursor := add(cursor, 0x01)
//     continue
// }
