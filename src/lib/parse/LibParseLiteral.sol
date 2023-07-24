// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./LibParseCMask.sol";
import "./LibParse.sol";

/// Encountered a literal that is larger than supported.
error HexLiteralOverflow(uint256 maxLength, string literal);

/// Encountered a zero length hex literal.
error ZeroLengthHexLiteral(uint256 offset);

/// Encountered an odd sized hex literal.
error OddLengthHexLiteral(uint256 offset);

/// Encountered a hex literal with an invalid character.
error MalformedHexLiteral(uint256 offset, string char);

/// Encountered a decimal literal that is larger than supported.
error DecimalLiteralOverflow(uint256 maxLength, string literal);

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
    /// @return The type of the literal. This is used to determine how to parse
    /// the literal once the bounds are known.
    /// @return The inner start.
    /// @return The inner end.
    /// @return The outer end.
    function boundLiteral(bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256, uint256, uint256, uint256)
    {
        unchecked {
            uint256 errorOffset;
            string memory errorChar;
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
                    uint256 hexCharMask = CMASK_HEX;
                    assembly ("memory-safe") {
                        //slither-disable-next-line incorrect-shift
                        for {} iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), hexCharMask))) {
                            innerEnd := add(innerEnd, 1)
                        } {}
                    }
                    return (LITERAL_TYPE_INTEGER_HEX, innerStart, innerEnd, innerEnd);
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
                        (errorOffset, errorChar) = LibParse.parseErrorContext(data, ePosition);
                        revert MalformedExponentDigits(errorOffset);
                    }

                    return (LITERAL_TYPE_INTEGER_DECIMAL, innerStart, innerEnd, innerEnd);
                }
            }

            (errorOffset, errorChar) = LibParse.parseErrorContext(data, cursor);
            revert UnsupportedLiteralType(errorOffset);
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
                revert HexLiteralOverflow(0x40, string(abi.encodePacked(start, end)));
            } else if (length == 0) {
                //slither-disable-next-line similar-names
                (uint256 offset, string memory errorChar) = LibParse.parseErrorContext(data, start);
                (errorChar);
                revert ZeroLengthHexLiteral(offset);
            } else if (length % 2 == 1) {
                //slither-disable-next-line similar-names
                (uint256 offset, string memory errorChar) = LibParse.parseErrorContext(data, end);
                (errorChar);
                revert OddLengthHexLiteral(offset);
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
                        (uint256 offset, string memory errorChar) = LibParse.parseErrorContext(data, cursor);
                        (errorChar);
                        revert MalformedHexLiteral(offset, errorChar);
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
                        //slither-disable-next-line similar-names
                        (uint256 errorOffset, string memory errorChar) = LibParse.parseErrorContext(data, cursor);
                        revert DecimalLiteralOverflow(errorOffset, errorChar);
                    } else {
                        uint256 scaled = digit * (10 ** exponent);
                        if (value + scaled < value) {
                            //slither-disable-next-line similar-names
                            (uint256 errorOffset, string memory errorChar) = LibParse.parseErrorContext(data, cursor);
                            revert DecimalLiteralOverflow(errorOffset, errorChar);
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
                            //slither-disable-next-line similar-names
                            (uint256 errorOffset, string memory errorChar) = LibParse.parseErrorContext(data, cursor);
                            revert DecimalLiteralOverflow(errorOffset, errorChar);
                        }
                        cursor--;
                    }
                }
            }
        }
    }
}
