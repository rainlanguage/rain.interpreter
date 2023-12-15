// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {
    CMASK_E_NOTATION,
    CMASK_HEX,
    CMASK_LOWER_ALPHA_A_F,
    CMASK_NUMERIC_0_9,
    CMASK_STRING_LITERAL_HEAD,
    CMASK_STRING_LITERAL_TAIL,
    CMASK_UPPER_ALPHA_A_F,
    CMASK_LITERAL_HEX_DISPATCH,
    CMASK_NUMERIC_LITERAL_HEAD,
    CMASK_STRING_LITERAL_END
} from "./LibParseCMask.sol";
import {LibParse} from "./LibParse.sol";

import {IntOrAString, LibIntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";

import {
    DecimalLiteralOverflow,
    HexLiteralOverflow,
    MalformedExponentDigits,
    MalformedHexLiteral,
    OddLengthHexLiteral,
    StringTooLong,
    UnsupportedLiteralType,
    ZeroLengthDecimal,
    ZeroLengthHexLiteral,
    UnclosedStringLiteral,
    ParserOutOfBounds
} from "../../error/ErrParse.sol";
import {ParseState} from "./LibParseState.sol";
import {LibParseError} from "./LibParseError.sol";

/// @dev The type of a literal is both a unique value and a literal offset used
/// to index into the literal parser array as a uint256.
uint256 constant LITERAL_TYPE_INTEGER_HEX = 0;

/// @dev The type of a literal is both a unique value and a literal offset used
/// to index into the literal parser array as a uint256.
uint256 constant LITERAL_TYPE_INTEGER_DECIMAL = 0x10;

/// @dev The type of a literal is both a unique value and a literal offset used
/// to index into the literal parser array as a uint256.
uint256 constant LITERAL_TYPE_STRING = 0x20;

library LibParseLiteral {
    using LibParseLiteral for ParseState;
    using LibParseError for ParseState;

    function buildLiteralParsers() internal pure returns (uint256 literalParsers) {
        // Register all the literal parsers in the parse state. Each is a 16 bit
        // function pointer so we can have up to 16 literal types. This needs to
        // be done at runtime because the library code doesn't know the bytecode
        // offsets of the literal parsers until it is compiled into a contract.
        {
            function(ParseState memory, uint256, uint256) pure returns (uint256) literalParserHex =
                LibParseLiteral.parseLiteralHex;
            uint256 parseLiteralHexOffset = LITERAL_TYPE_INTEGER_HEX;
            function(ParseState memory, uint256, uint256) pure returns (uint256) literalParserDecimal =
                LibParseLiteral.parseLiteralDecimal;
            uint256 parseLiteralDecimalOffset = LITERAL_TYPE_INTEGER_DECIMAL;
            function(ParseState memory, uint256, uint256) pure returns (uint256) literalParserString =
                LibParseLiteral.parseLiteralString;
            uint256 parseLiteralStringOffset = LITERAL_TYPE_STRING;

            assembly ("memory-safe") {
                literalParsers :=
                    or(
                        shl(parseLiteralStringOffset, literalParserString),
                        or(
                            shl(parseLiteralHexOffset, literalParserHex),
                            shl(parseLiteralDecimalOffset, literalParserDecimal)
                        )
                    )
            }
        }
    }

    /// Find the bounds for some literal at the cursor. The caller is responsible
    /// for checking that the cursor is at the start of a literal. As each
    /// literal type has a different format, this function returns the bounds
    /// for the literal and the type of the literal. The bounds are:
    /// - innerStart: the start of the literal, e.g. after the 0x in 0x1234
    /// - innerEnd: the end of the literal, e.g. after the 1234 in 0x1234
    /// - outerEnd: the end of the literal including any suffixes, MAY be the
    ///   same as innerEnd if there is no suffix.
    /// The outerStart is the cursor, so it is not returned.
    /// @param state The parser state.
    /// @param cursor The start of the literal.
    /// @return The literal parser. This function can be called to convert the
    /// bounds into a uint256 value.
    /// @return The inner start.
    /// @return The inner end.
    /// @return The outer end.
    function boundLiteral(ParseState memory state, uint256 cursor)
        internal
        pure
        returns (function(ParseState memory, uint256, uint256) pure returns (uint256), uint256, uint256, uint256)
    {
        unchecked {
            uint256 word;
            uint256 head;
            assembly ("memory-safe") {
                word := mload(cursor)
                //slither-disable-next-line incorrect-shift
                head := shl(byte(0, word), 1)
            }

            // numeric literal head is 0-9
            if (head & CMASK_NUMERIC_LITERAL_HEAD != 0) {
                uint256 dispatch;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    dispatch := shl(byte(1, word), 1)
                }

                // Hexadecimal literal dispatch is 0x. We can't accidentally
                // match x0 because we already checked that the head is 0-9.
                if ((head | dispatch) == CMASK_LITERAL_HEX_DISPATCH) {
                    //slither-disable-next-line unused-return
                    return state.boundLiteralHex(cursor);
                }
                // decimal is the fallback as continuous numeric digits 0-9.
                else {
                    //slither-disable-next-line unused-return
                    return state.boundLiteralDecimal(cursor);
                }
            } else if (head & CMASK_STRING_LITERAL_HEAD != 0) {
                //slither-disable-next-line unused-return
                return state.boundLiteralString(cursor);
            }

            uint256 endUnknown;
            bytes memory data = state.data;
            assembly ("memory-safe") {
                endUnknown := add(data, add(mload(data), 0x20))
            }
            if (cursor >= endUnknown) {
                revert ParserOutOfBounds();
            } else {
                revert UnsupportedLiteralType(state.parseErrorOffset(cursor));
            }
        }
    }

    /// Find the bounds for some string literal at the cursor. The caller is
    /// responsible for checking that the cursor is at the start of a string
    /// literal. Bounds are as per `boundLiteral`.
    function boundLiteralString(ParseState memory state, uint256 cursor)
        internal
        pure
        returns (function(ParseState memory, uint256, uint256) pure returns (uint256), uint256, uint256, uint256)
    {
        unchecked {
            uint256 innerStart = cursor + 1;
            uint256 innerEnd;
            uint256 outerEnd;
            {
                uint256 stringCharMask = CMASK_STRING_LITERAL_TAIL;
                uint256 stringData;
                uint256 i = 0;
                assembly ("memory-safe") {
                    // Only up to 31 bytes of string data can be stored in a
                    // single word, so strings can't be longer than 31 bytes.
                    // The 32nd byte is the length of the string.
                    stringData := mload(innerStart)
                    //slither-disable-next-line incorrect-shift
                    for {} and(lt(i, 0x20), iszero(iszero(and(shl(byte(i, stringData), 1), stringCharMask)))) {} {
                        i := add(i, 1)
                    }
                }
                if (i == 0x20) {
                    revert StringTooLong(state.parseErrorOffset(cursor));
                }
                innerEnd = innerStart + i;
                uint256 finalChar;
                assembly ("memory-safe") {
                    finalChar := byte(0, mload(innerEnd))
                }
                //slither-disable-next-line incorrect-shift
                if (1 << finalChar & CMASK_STRING_LITERAL_END == 0) {
                    revert UnclosedStringLiteral(state.parseErrorOffset(cursor));
                }
                // Outer end is after the final `"`.
                outerEnd = innerEnd + 1;
            }

            function(ParseState memory, uint256, uint256) pure returns (uint256) parser;
            {
                uint256 p = (state.literalParsers >> LITERAL_TYPE_STRING) & 0xFFFF;
                assembly ("memory-safe") {
                    parser := p
                }
            }
            // Check the parser hasn't moved outside the bounds of the data.
            {
                uint256 endString;
                bytes memory data = state.data;
                assembly ("memory-safe") {
                    endString := add(data, add(mload(data), 0x20))
                }
                if (outerEnd > endString) {
                    revert ParserOutOfBounds();
                }
            }
            return (parser, innerStart, innerEnd, outerEnd);
        }
    }

    /// Algorithm for parsing string literals:
    /// - Get the inner length of the string
    /// - Mutate memory in place to add a length prefix, record the original data
    /// - Use this solidity string to build an `IntOrAString`
    /// - Restore the original data that the length prefix overwrote
    /// - Return the `IntOrAString`
    function parseLiteralString(ParseState memory, uint256 start, uint256 end) internal pure returns (uint256) {
        IntOrAString intOrAString;
        uint256 before;
        string memory str;
        assembly ("memory-safe") {
            let length := sub(end, start)
            str := sub(start, 0x20)
            before := mload(str)
            mstore(str, length)
        }
        intOrAString = LibIntOrAString.fromString(str);
        assembly ("memory-safe") {
            mstore(str, before)
        }
        return IntOrAString.unwrap(intOrAString);
    }

    function boundLiteralHex(ParseState memory state, uint256 cursor)
        internal
        pure
        returns (function(ParseState memory, uint256, uint256) pure returns (uint256), uint256, uint256, uint256)
    {
        uint256 innerStart = cursor + 2;
        uint256 innerEnd = innerStart;
        {
            uint256 hexCharMask = CMASK_HEX;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                for {} iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), hexCharMask))) {
                    innerEnd := add(innerEnd, 1)
                } {}
            }
        }

        function(ParseState memory, uint256, uint256) pure returns (uint256) parser;
        {
            uint256 p = (state.literalParsers >> LITERAL_TYPE_INTEGER_HEX) & 0xFFFF;
            assembly ("memory-safe") {
                parser := p
            }
        }
        {
            uint256 endHex;
            bytes memory data = state.data;
            assembly ("memory-safe") {
                endHex := add(data, add(mload(data), 0x20))
            }
            if (innerEnd > endHex) {
                revert ParserOutOfBounds();
            }
        }
        return (parser, innerStart, innerEnd, innerEnd);
    }

    /// Algorithm for parsing hexadecimal literals:
    /// - start at the end of the literal
    /// - for each character:
    ///   - convert the character to a nybble
    ///   - shift the nybble into the total at the correct position
    ///     (4 bits per nybble)
    /// - return the total
    function parseLiteralHex(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256 value)
    {
        unchecked {
            uint256 length = end - start;
            if (length > 0x40) {
                revert HexLiteralOverflow(state.parseErrorOffset(start));
            } else if (length == 0) {
                revert ZeroLengthHexLiteral(state.parseErrorOffset(start));
            } else if (length % 2 == 1) {
                revert OddLengthHexLiteral(state.parseErrorOffset(start));
            } else {
                uint256 cursor = end - 1;
                uint256 valueOffset = 0;
                while (cursor >= start) {
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
        }
    }

    function boundLiteralDecimal(ParseState memory state, uint256 cursor)
        internal
        pure
        returns (function(ParseState memory, uint256, uint256) pure returns (uint256), uint256, uint256, uint256)
    {
        uint256 innerStart = cursor;
        // We know the head is a numeric so we can move past it.
        uint256 innerEnd = innerStart + 1;
        uint256 ePosition = 0;

        {
            uint256 decimalCharMask = CMASK_NUMERIC_0_9;
            uint256 eMask = CMASK_E_NOTATION;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                for {} iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), decimalCharMask))) {
                    innerEnd := add(innerEnd, 1)
                } {}

                // If we're now pointing at an e notation, then we need
                // to move past it. Negative exponents are not supported.
                //slither-disable-next-line incorrect-shift
                if iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), eMask))) {
                    ePosition := innerEnd
                    innerEnd := add(innerEnd, 1)

                    // Move past the exponent digits.
                    //slither-disable-next-line incorrect-shift
                    for {} iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), decimalCharMask))) {
                        innerEnd := add(innerEnd, 1)
                    } {}
                }
            }
        }
        if (ePosition != 0 && (innerEnd > ePosition + 3 || innerEnd == ePosition + 1)) {
            revert MalformedExponentDigits(state.parseErrorOffset(ePosition));
        }

        function(ParseState memory, uint256, uint256) pure returns (uint256) parser;
        {
            uint256 p = (state.literalParsers >> LITERAL_TYPE_INTEGER_DECIMAL) & 0xFFFF;
            assembly ("memory-safe") {
                parser := p
            }
        }
        {
            uint256 endDecimal;
            bytes memory data = state.data;
            assembly ("memory-safe") {
                endDecimal := add(data, add(mload(data), 0x20))
            }
            if (innerEnd > endDecimal) {
                revert ParserOutOfBounds();
            }
        }
        return (parser, innerStart, innerEnd, innerEnd);
    }

    /// Algorithm for parsing decimal literals:
    /// - start at the end of the literal
    /// - for each digit:
    ///   - multiply the digit by 10^digit position
    ///   - add the result to the total
    /// - return the total
    ///
    /// This algorithm is ONLY safe if the caller has already checked that the
    /// start/end span a non-zero length of valid decimal chars. The caller
    /// can most easily do this by using the `boundLiteral` function.
    ///
    /// Unsafe behavior is undefined and can easily result in out of bounds
    /// reads as there are no checks that start/end are within `data`.
    function parseLiteralDecimal(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256 value)
    {
        unchecked {
            // Tracks which digit we're on.
            uint256 cursor;
            // The ASCII byte can be translated to a numeric digit by subtracting
            // the digit offset.
            uint256 digitOffset = uint256(uint8(bytes1("0")));
            // Tracks the exponent of the current digit. Can start above 0 if
            // the literal is in e notation.
            uint256 exponent;
            {
                uint256 word;
                //slither-disable-next-line similar-names
                uint256 decimalCharByte;
                uint256 length = end - start;
                assembly ("memory-safe") {
                    word := mload(sub(end, 3))
                    decimalCharByte := byte(0, word)
                }
                // If the last 3 bytes are e notation, then we need to parse
                // the exponent as a 2 digit number.
                //slither-disable-next-line incorrect-shift
                if (length > 3 && ((1 << decimalCharByte) & CMASK_E_NOTATION) != 0) {
                    cursor = end - 4;
                    assembly ("memory-safe") {
                        exponent := add(sub(byte(2, word), digitOffset), mul(sub(byte(1, word), digitOffset), 10))
                    }
                } else {
                    assembly ("memory-safe") {
                        decimalCharByte := byte(1, word)
                    }
                    // If the last 2 bytes are e notation, then we need to parse
                    // the exponent as a 1 digit number.
                    //slither-disable-next-line incorrect-shift
                    if (length > 2 && ((1 << decimalCharByte) & CMASK_E_NOTATION) != 0) {
                        cursor = end - 3;
                        assembly ("memory-safe") {
                            exponent := sub(byte(2, word), digitOffset)
                        }
                    }
                    // Otherwise, we're not in e notation and we can start at the
                    // end of the literal with 0 starting exponent.
                    else if (length > 0) {
                        cursor = end - 1;
                        exponent = 0;
                    } else {
                        revert ZeroLengthDecimal(state.parseErrorOffset(start));
                    }
                }
            }

            // Anything under 10^77 is safe to raise to its power of 10 without
            // overflowing a uint256.
            while (cursor >= start && exponent < 77) {
                // We don't need to check the bounds of the byte because
                // we know it is a decimal literal as long as the bounds
                // are correct (calculated in `boundLiteral`).
                assembly ("memory-safe") {
                    value := add(value, mul(sub(byte(0, mload(cursor)), digitOffset), exp(10, exponent)))
                }
                exponent++;
                cursor--;
            }

            // If we didn't consume the entire literal, then we have
            // to check if the remaining digit is safe to multiply
            // by 10 without overflowing a uint256.
            if (cursor >= start) {
                {
                    uint256 digit;
                    assembly ("memory-safe") {
                        digit := sub(byte(0, mload(cursor)), digitOffset)
                    }
                    // If the digit is greater than 1, then we know that
                    // multiplying it by 10^77 will overflow a uint256.
                    if (digit > 1) {
                        revert DecimalLiteralOverflow(state.parseErrorOffset(cursor));
                    } else {
                        uint256 scaled = digit * (10 ** exponent);
                        if (value + scaled < value) {
                            revert DecimalLiteralOverflow(state.parseErrorOffset(cursor));
                        }
                        value += scaled;
                    }
                    cursor--;
                }

                {
                    // If we didn't consume the entire literal, then only
                    // leading zeros are allowed.
                    while (cursor >= start) {
                        //slither-disable-next-line similar-names
                        uint256 decimalCharByte;
                        assembly ("memory-safe") {
                            decimalCharByte := byte(0, mload(cursor))
                        }
                        if (decimalCharByte != uint256(uint8(bytes1("0")))) {
                            revert DecimalLiteralOverflow(state.parseErrorOffset(cursor));
                        }
                        cursor--;
                    }
                }
            }
        }
    }
}
