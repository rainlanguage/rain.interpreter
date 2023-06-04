// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/console2.sol";

// Error 1
error MissingFinalSemi(uint256 offset);

// Error 2
error UnexpectedLHSChar(uint256 offset, string char);

// Error 3
error UnexpectedRHSChar(uint256 offset, string char);

// Error 4
error WordTooLong(uint256 offset);

library LibParse {
    function testCharBuilder(string memory s) external view {
        uint256 char = 1 << uint256(uint8(bytes1(bytes(s))));
        console2.log(char);
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
                // 0x09 = \t = 0x200
                // 0x0a = \n = 0x400
                // 0x0d = \r = 0x2000
                // 0x20 = space = 0x0100000000
                // 0x2C = , = 0x100000000000
                // 0x2D = - = 0x200000000000
                // 0x3A = : = 0x0400000000000000
                // 0x3B = ; = 0x0800000000000000
                // 0x5F = _ = 0x800000000000000000000000
                //
                // mask for structure , : ;
                // 0x0C00100000000000
                //
                // mask for whitespace space \n \r \t
                // 0x100002600
                //
                // mask for a-z
                // 0xffffffe000000000000000000000000
                //
                // mask for 0-9
                // 0x3ff000000000000
                //
                // mask for kebab case a-z 0-9 -
                // 0xffffffe0000000003ff200000000000
                let outputCursor := mload(0x40)

                // Layout of state is
                // 0 => lhs/rhs
                // 0x20 => stackIndex
                // 0x40 => pointer to sources
                state := outputCursor
                outputCursor := add(outputCursor, 0x60)

                // start with lhs = 1
                mstore(state, 1)

                // start with empty stack
                mstore(add(state, 0x20), 0)

                // start with empty sources
                mstore(add(state, 0x40), 0x60)

                let source := outputCursor
                mstore(source, 0)
                outputCursor := add(outputCursor, 0x20)

                let cursor := add(data, 1)
                let end := add(cursor, mload(data))
                for {} lt(cursor, end) { cursor := add(cursor, 1) } {
                    // Cursor must be incremented by the inner logic.
                    char := shl(and(mload(cursor), 0xFF), 1)

                    switch mload(state)
                    case 1 {
                        // ignored stack items
                        // first char equals _
                        if eq(char, 0x800000000000000000000000) {
                            {
                                let stackIndex := mload(add(state, 0x20))
                                stackIndex := add(stackIndex, 1)
                                mstore(add(state, 0x20), stackIndex)
                            }
                            let word := mload(add(cursor, 0x20))

                            // The second char is not a word char so do nothing.
                            if iszero(and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000)) { continue }

                            // inline the first 16 word chars for gas efficiency.
                            if and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000) {
                                if and(shl(byte(0x01, word), 1), 0xffffffe0000000003ff200000000000) {
                                    if and(shl(byte(0x02, word), 1), 0xffffffe0000000003ff200000000000) {
                                        if and(shl(byte(0x03, word), 1), 0xffffffe0000000003ff200000000000) {
                                            if and(shl(byte(0x04, word), 1), 0xffffffe0000000003ff200000000000) {
                                                if and(shl(byte(0x05, word), 1), 0xffffffe0000000003ff200000000000) {
                                                    if and(shl(byte(0x06, word), 1), 0xffffffe0000000003ff200000000000)
                                                    {
                                                        if and(
                                                            shl(byte(0x07, word), 1), 0xffffffe0000000003ff200000000000
                                                        ) {
                                                            if and(
                                                                shl(byte(0x08, word), 1),
                                                                0xffffffe0000000003ff200000000000
                                                            ) {
                                                                if and(
                                                                    shl(byte(0x09, word), 1),
                                                                    0xffffffe0000000003ff200000000000
                                                                ) {
                                                                    if and(
                                                                        shl(byte(0x0A, word), 1),
                                                                        0xffffffe0000000003ff200000000000
                                                                    ) {
                                                                        if and(
                                                                            shl(byte(0x0B, word), 1),
                                                                            0xffffffe0000000003ff200000000000
                                                                        ) {
                                                                            if and(
                                                                                shl(byte(0x0C, word), 1),
                                                                                0xffffffe0000000003ff200000000000
                                                                            ) {
                                                                                if and(
                                                                                    shl(byte(0x0D, word), 1),
                                                                                    0xffffffe0000000003ff200000000000
                                                                                ) {
                                                                                    if and(
                                                                                        shl(byte(0x0E, word), 1),
                                                                                        0xffffffe0000000003ff200000000000
                                                                                    ) {
                                                                                        if and(
                                                                                            shl(byte(0x0F, word), 1),
                                                                                            0xffffffe0000000003ff200000000000
                                                                                        ) {
                                                                                            // loop for the remainder for 16+ char words.
                                                                                            let i := 0x10
                                                                                            for {} and(
                                                                                                lt(i, 0x20),
                                                                                                iszero(
                                                                                                    iszero(
                                                                                                        and(
                                                                                                            shl(
                                                                                                                byte(
                                                                                                                    i,
                                                                                                                    word
                                                                                                                ),
                                                                                                                1
                                                                                                            ),
                                                                                                            0xffffffe0000000003ff200000000000
                                                                                                        )
                                                                                                    )
                                                                                                )
                                                                                            ) { i := add(i, 1) } {}
                                                                                            if lt(i, 0x20) {
                                                                                                cursor := add(cursor, i)
                                                                                                continue
                                                                                            }
                                                                                            errorCode :=
                                                                                                buildErrorCode(
                                                                                                    data, cursor, 4
                                                                                                )
                                                                                            break
                                                                                        }
                                                                                        cursor := add(cursor, 0x0F)
                                                                                        continue
                                                                                    }
                                                                                    cursor := add(cursor, 0x0E)
                                                                                    continue
                                                                                }
                                                                                cursor := add(cursor, 0x0D)
                                                                                continue
                                                                            }
                                                                            cursor := add(cursor, 0x0C)
                                                                            continue
                                                                        }
                                                                        cursor := add(cursor, 0x0B)
                                                                        continue
                                                                    }
                                                                    cursor := add(cursor, 0x0A)
                                                                    continue
                                                                }
                                                                cursor := add(cursor, 0x09)
                                                                continue
                                                            }
                                                            cursor := add(cursor, 0x08)
                                                            continue
                                                        }
                                                        cursor := add(cursor, 0x07)
                                                        continue
                                                    }
                                                    cursor := add(cursor, 0x06)
                                                    continue
                                                }
                                                cursor := add(cursor, 0x05)
                                                continue
                                            }
                                            cursor := add(cursor, 0x04)
                                            continue
                                        }
                                        cursor := add(cursor, 0x03)
                                        continue
                                    }
                                    cursor := add(cursor, 0x02)
                                    continue
                                }
                                cursor := add(cursor, 0x01)
                                continue
                            }
                        }

                        // only space is allowed whitespace on LHS
                        if eq(char, 0x0100000000) { continue }

                        // end of lhs
                        // char equals :
                        if eq(char, 0x0400000000000000) {
                            mstore(state, 0)
                            continue
                        }
                        errorCode := buildErrorCode(data, cursor, 2)
                        break
                    }
                    case 0 {
                        // end of rhs
                        // char equals ,
                        if eq(char, 0x100000000000) {
                            mstore(state, 1)
                            continue
                        }

                        // end of source
                        // implies end of rhs
                        // char equals ;
                        if eq(char, 0x0800000000000000) {
                            mstore(state, 1)

                            // Brute force a new list of references every time we
                            // encounter a new source. We assume that most parsed
                            // data will have a low number of sources, ~5 or less.
                            let sourcesCursor := mload(add(state, 0x40))
                            let oldSourcesLength := mload(sourcesCursor)
                            sourcesCursor := add(sourcesCursor, 0x20)
                            mstore(add(state, 0x40), outputCursor)

                            mstore(outputCursor, add(oldSourcesLength, 1))
                            outputCursor := add(outputCursor, 0x20)

                            let sourcesEnd := add(sourcesCursor, mul(oldSourcesLength, 0x20))
                            for {} lt(sourcesCursor, sourcesEnd) {
                                sourcesCursor := add(sourcesCursor, 0x20)
                                outputCursor := add(outputCursor, 0x20)
                            } { mstore(outputCursor, mload(sourcesCursor)) }
                            mstore(outputCursor, source)
                            outputCursor := add(outputCursor, 0x20)
                            source := outputCursor
                            mstore(source, 0)
                            outputCursor := add(outputCursor, 0x20)

                            continue
                        }

                        errorCode := buildErrorCode(data, cursor, 3)
                        break
                    }
                    // unreachable, implies broken lhs flag.
                    default { revert(0, 0) }
                }
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
        }
    }
}
