// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./LibParseCMask.sol";
import "./LibParse.sol";

/// The parser tried to bound an unsupported literal that we have no type for.
error UnsupportedLiteralType(uint256 offset);

/// Encountered a literal that is larger than supported.
error HexLiteralOverflow(uint256 offset);

/// Encountered a zero length hex literal.
error ZeroLengthHexLiteral(uint256 offset);

/// Encountered an odd sized hex literal.
error OddLengthHexLiteral(uint256 offset);

/// Encountered a hex literal with an invalid character.
error MalformedHexLiteral(uint256 offset);

/// Encountered a decimal literal that is larger than supported.
error DecimalLiteralOverflow(uint256 offset);

/// Encountered a decimal literal with an exponent that has too many or no
/// digits.
error MalformedExponentDigits(uint256 offset);

/// @dev The type of a literal is both a unique value and a literal offset used
/// to index into the literal parser array as a uint256.
uint256 constant LITERAL_TYPE_INTEGER_HEX = 0;
/// @dev The type of a literal is both a unique value and a literal offset used
/// to index into the literal parser array as a uint256.
uint256 constant LITERAL_TYPE_INTEGER_DECIMAL = 0x10;

library LibParseLiteral {
    function buildLiteralParsers() internal pure returns (uint256 literalParsers) {
        // Register all the literal parsers in the parse state. Each is a 16 bit
        // function pointer so we can have up to 16 literal types. This needs to
        // be done at runtime because the library code doesn't know the bytecode
        // offsets of the literal parsers until it is compiled into a contract.
        {
            function(bytes memory, uint256, uint256) pure returns (uint256) literalParserHex =
                LibParseLiteral.parseLiteralHex;
            uint256 parseLiteralHexOffset = LITERAL_TYPE_INTEGER_HEX;
            function(bytes memory, uint256, uint256) pure returns (uint256) literalParserDecimal =
                LibParseLiteral.parseLiteralDecimal;
            uint256 parseLiteralDecimalOffset = LITERAL_TYPE_INTEGER_DECIMAL;

            assembly ("memory-safe") {
                literalParsers :=
                    or(shl(parseLiteralHexOffset, literalParserHex), shl(parseLiteralDecimalOffset, literalParserDecimal))
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
    /// @param cursor The start of the literal.
    /// @return The literal parser. This function can be called to convert the
    /// bounds into a uint256 value.
    /// @return The inner start.
    /// @return The inner end.
    /// @return The outer end.
    function boundLiteral(uint256 literalParsers, bytes memory data, uint256 cursor)
        internal
        pure
        returns (function(bytes memory, uint256, uint256) pure returns (uint256), uint256, uint256, uint256)
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

                // hexadecimal literal dispatch is 0x
                if ((head | dispatch) == CMASK_LITERAL_HEX_DISPATCH) {
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

                    function(bytes memory, uint256, uint256) pure returns (uint256) parser;
                    {
                        uint16 p = uint16(literalParsers >> LITERAL_TYPE_INTEGER_HEX);
                        assembly {
                            parser := p
                        }
                    }
                    return (parser, innerStart, innerEnd, innerEnd);
                }
                // decimal is the fallback as continuous numeric digits 0-9.
                else {
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
                        revert MalformedExponentDigits(LibParse.parseErrorOffset(data, ePosition));
                    }

                    function(bytes memory, uint256, uint256) pure returns (uint256) parser;
                    {
                        uint16 p = uint16(literalParsers >> LITERAL_TYPE_INTEGER_DECIMAL);
                        assembly {
                            parser := p
                        }
                    }
                    return (parser, innerStart, innerEnd, innerEnd);
                }
            }

            revert UnsupportedLiteralType(LibParse.parseErrorOffset(data, cursor));
        }
    }

    /// Algorithm for parsing hexadecimal literals:
    /// - start at the end of the literal
    /// - for each character:
    ///   - convert the character to a nybble
    ///   - shift the nybble into the total at the correct position
    ///     (4 bits per nybble)
    /// - return the total
    function parseLiteralHex(bytes memory data, uint256 start, uint256 end) internal pure returns (uint256 value) {
        unchecked {
            uint256 length = end - start;
            if (length > 0x40) {
                revert HexLiteralOverflow(LibParse.parseErrorOffset(data, start));
            } else if (length == 0) {
                revert ZeroLengthHexLiteral(LibParse.parseErrorOffset(data, start));
            } else if (length % 2 == 1) {
                revert OddLengthHexLiteral(LibParse.parseErrorOffset(data, start));
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
                        revert MalformedHexLiteral(LibParse.parseErrorOffset(data, cursor));
                    }

                    value |= nybble << valueOffset;
                    valueOffset += 4;
                    cursor--;
                }
            }
        }
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
    function parseLiteralDecimal(bytes memory data, uint256 start, uint256 end) internal pure returns (uint256 value) {
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
                assembly ("memory-safe") {
                    word := mload(sub(end, 3))
                    decimalCharByte := byte(0, word)
                }
                // If the last 3 bytes are e notation, then we need to parse
                // the exponent as a 2 digit number.
                //slither-disable-next-line incorrect-shift
                if (((1 << decimalCharByte) & CMASK_E_NOTATION) != 0) {
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
                    if (((1 << decimalCharByte) & CMASK_E_NOTATION) != 0) {
                        cursor = end - 3;
                        assembly ("memory-safe") {
                            exponent := sub(byte(2, word), digitOffset)
                        }
                    }
                    // Otherwise, we're not in e notation and we can start at the
                    // end of the literal with 0 starting exponent.
                    else {
                        cursor = end - 1;
                        exponent = 0;
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
                        revert DecimalLiteralOverflow(LibParse.parseErrorOffset(data, cursor));
                    } else {
                        uint256 scaled = digit * (10 ** exponent);
                        if (value + scaled < value) {
                            revert DecimalLiteralOverflow(LibParse.parseErrorOffset(data, cursor));
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
                            revert DecimalLiteralOverflow(LibParse.parseErrorOffset(data, cursor));
                        }
                        cursor--;
                    }
                }
            }
        }
    }
}
