// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {
    CMASK_E_NOTATION,
    CMASK_HEX,
    CMASK_LOWER_ALPHA_A_F,
    CMASK_NUMERIC_0_9,
    CMASK_STRING_LITERAL_HEAD,
    CMASK_UPPER_ALPHA_A_F,
    CMASK_LITERAL_HEX_DISPATCH,
    CMASK_NUMERIC_LITERAL_HEAD,
    CMASK_SUB_PARSEABLE_LITERAL_HEAD,
    CMASK_SUB_PARSEABLE_LITERAL_END,
    CMASK_WHITESPACE
} from "../LibParseCMask.sol";
import {LibParse} from "../LibParse.sol";

import {
    DecimalLiteralOverflow,
    HexLiteralOverflow,
    MalformedExponentDigits,
    MalformedHexLiteral,
    OddLengthHexLiteral,
    ZeroLengthDecimal,
    ZeroLengthHexLiteral,
    UnsupportedLiteralType,
    UnclosedSubParseableLiteral
} from "../../../error/ErrParse.sol";
import {ParseState} from "../LibParseState.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParseInterstitial} from "../LibParseInterstitial.sol";
import {LibSubParse} from "../LibSubParse.sol";

uint256 constant LITERAL_PARSERS_LENGTH = 3;

uint256 constant LITERAL_PARSER_INDEX_HEX = 0;
uint256 constant LITERAL_PARSER_INDEX_DECIMAL = 1;
uint256 constant LITERAL_PARSER_INDEX_STRING = 2;
uint256 constant LITERAL_PARSER_INDEX_SUB_PARSE = 3;

library LibParseLiteral {
    using LibParseLiteral for ParseState;
    using LibParseError for ParseState;
    using LibParseLiteral for ParseState;
    using LibParseInterstitial for ParseState;
    using LibSubParse for ParseState;

    function selectLiteralParserByIndex(ParseState memory state, uint256 index)
        internal
        pure
        returns (function(ParseState memory, uint256, uint256) pure returns (uint256, uint256))
    {
        bytes memory literalParsers = state.literalParsers;
        function(ParseState memory, uint256, uint256) pure returns (uint256, uint256) parser;
        // This is NOT bounds checked because the indexes are all expected to
        // be provided by the parser itself and not user input.
        assembly ("memory-safe") {
            parser := and(mload(add(literalParsers, add(2, mul(index, 2)))), 0xFFFF)
        }
        return parser;
    }

    function parseLiteral(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        (bool success, uint256 newCursor, uint256 value) = tryParseLiteral(state, cursor, end);
        if (success) {
            return (newCursor, value);
        } else {
            revert UnsupportedLiteralType(state.parseErrorOffset(cursor));
        }
    }

    function tryParseLiteral(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (bool, uint256, uint256)
    {
        uint256 index;
        {
            uint256 word;
            uint256 head;
            assembly ("memory-safe") {
                word := mload(cursor)
                //slither-disable-next-line incorrect-shift
                head := shl(byte(0, word), 1)
            }

            // Figure out the literal type and dispatch to the correct parser.
            // Probably a numeric, most things are.
            if ((head & CMASK_NUMERIC_LITERAL_HEAD) != 0) {
                uint256 disambiguate;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    disambiguate := shl(byte(1, word), 1)
                }
                // Hexadecimal literal dispatch is 0x. We can't accidentally
                // match x0 because we already checked that the head is 0-9.
                if ((head | disambiguate) == CMASK_LITERAL_HEX_DISPATCH) {
                    index = LITERAL_PARSER_INDEX_HEX;
                } else {
                    index = LITERAL_PARSER_INDEX_DECIMAL;
                }
            }
            // Could be a lil' string.
            else if ((head & CMASK_STRING_LITERAL_HEAD) != 0) {
                index = LITERAL_PARSER_INDEX_STRING;
            }
            // Or a sub parseable something.
            else if ((head & CMASK_SUB_PARSEABLE_LITERAL_HEAD) != 0) {
                index = LITERAL_PARSER_INDEX_SUB_PARSE;
            }
            // We don't know what this is.
            else {
                return (false, cursor, 0);
            }
        }
        uint256 value;
        (cursor, value) = state.selectLiteralParserByIndex(index)(state, cursor, end);
        return (true, cursor, value);
    }

    function boundLiteralHex(ParseState memory, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256, uint256)
    {
        uint256 innerStart = cursor + 2;
        uint256 innerEnd = innerStart;
        {
            uint256 hexCharMask = CMASK_HEX;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                for {} and(iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), hexCharMask))), lt(innerEnd, end)) {} {
                    innerEnd := add(innerEnd, 1)
                }
            }
        }

        return (innerStart, innerEnd, innerEnd);
    }

    /// Algorithm for parsing hexadecimal literals:
    /// - start at the end of the literal
    /// - for each character:
    ///   - convert the character to a nybble
    ///   - shift the nybble into the total at the correct position
    ///     (4 bits per nybble)
    /// - return the total
    function parseLiteralHex(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        unchecked {
            uint256 value;
            uint256 hexStart;
            uint256 hexEnd;
            (hexStart, hexEnd, cursor) = state.boundLiteralHex(cursor, end);

            uint256 hexLength = hexEnd - hexStart;
            if (hexLength > 0x40) {
                revert HexLiteralOverflow(state.parseErrorOffset(hexStart));
            } else if (hexLength == 0) {
                revert ZeroLengthHexLiteral(state.parseErrorOffset(hexStart));
            } else if (hexLength % 2 == 1) {
                revert OddLengthHexLiteral(state.parseErrorOffset(hexStart));
            } else {
                // Loop the cursor backwards over the hex string, we'll return
                // the hex end instead.
                cursor = hexEnd - 1;
                uint256 valueOffset = 0;
                while (cursor >= hexStart) {
                    uint256 hexCharByte;
                    assembly ("memory-safe") {
                        hexCharByte := byte(0, mload(cursor))
                    }
                    //slither-disable-next-line incorrect-shift
                    uint256 hexChar = 1 << hexCharByte;

                    uint256 nybble;
                    // 0-9
                    if (hexChar & CMASK_NUMERIC_0_9 != 0) {
                        nybble = hexCharByte - uint256(uint8(bytes1("0")));
                    }
                    // a-f
                    else if (hexChar & CMASK_LOWER_ALPHA_A_F != 0) {
                        nybble = hexCharByte - uint256(uint8(bytes1("a"))) + 10;
                    }
                    // A-F
                    else if (hexChar & CMASK_UPPER_ALPHA_A_F != 0) {
                        nybble = hexCharByte - uint256(uint8(bytes1("A"))) + 10;
                    } else {
                        revert MalformedHexLiteral(state.parseErrorOffset(cursor));
                    }

                    value |= nybble << valueOffset;
                    valueOffset += 4;
                    cursor--;
                }
            }

            return (hexEnd, value);
        }
    }

    function parseLiteralSubParseable(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        unchecked {
            // Move cursor past opening bracket.
            // Caller is responsible for checking that the cursor is pointing
            // at a sub parseable literal.
            ++cursor;

            // Skip any whitespace.
            cursor = state.skipWhitespace(cursor, end);

            uint256 dispatchStart = cursor;

            // Skip all non-whitespace and non-bracket characters.
            cursor = LibParse.skipMask(cursor, end, ~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_HEAD));
            uint256 dispatchEnd = cursor;

            // Skip any whitespace.
            cursor = state.skipWhitespace(cursor, end);

            uint256 bodyStart = cursor;

            // Skip all non-whitespace and non-bracket characters.
            cursor = LibParse.skipMask(cursor, end, ~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_HEAD));
            uint256 bodyEnd = cursor;

            // Skip any whitespace.
            cursor = state.skipWhitespace(cursor, end);

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
