// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {DecimalLiteralOverflow, ZeroLengthDecimal, MalformedExponentDigits} from "../../../error/ErrParse.sol";
import {CMASK_E_NOTATION, CMASK_NUMERIC_0_9} from "../LibParseCMask.sol";
import {LibParseError} from "../LibParseError.sol";

library LibParseLiteralDecimal {
    using LibParseError for ParseState;
    using LibParseLiteralDecimal for ParseState;

    function boundDecimal(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256, uint256)
    {
        uint256 innerStart = cursor;
        uint256 innerEnd = innerStart;
        uint256 ePosition = 0;
        uint256 eExists = 0;

        {
            uint256 decimalCharMask = CMASK_NUMERIC_0_9;
            uint256 eMask = CMASK_E_NOTATION;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                for {} and(iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), decimalCharMask))), lt(innerEnd, end)) {}
                {
                    innerEnd := add(innerEnd, 1)
                }

                // If we're now pointing at an e notation, then we need
                // to move past it. Negative exponents are not supported.
                //slither-disable-next-line incorrect-shift
                if and(iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), eMask))), lt(innerEnd, end)) {
                    ePosition := innerEnd
                    innerEnd := add(innerEnd, 1)
                    eExists := 1

                    // Move past the exponent digits.
                    //slither-disable-next-line incorrect-shift
                    for {} and(
                        iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), decimalCharMask))), lt(innerEnd, end)
                    ) {} { innerEnd := add(innerEnd, 1) }
                }
            }
        }
        if (
            (ePosition != 0 && (innerEnd > ePosition + 3 || innerEnd == ePosition + 1))
            // if e is found at the start of the literal, with no digits before
            // it that is malformed.
            || (ePosition == innerStart && eExists == 1)
        ) {
            revert MalformedExponentDigits(state.parseErrorOffset(ePosition));
        }

        return (innerStart, innerEnd, innerEnd);
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
    function parseDecimal(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        unchecked {
            uint256 value;
            // The ASCII byte can be translated to a numeric digit by subtracting
            // the digit offset.
            uint256 digitOffset = uint256(uint8(bytes1("0")));
            // Tracks the exponent of the current digit. Can start above 0 if
            // the literal is in e notation.
            uint256 exponent;
            (uint256 decimalStart, uint256 decimalEnd, uint256 outerEnd) = state.boundDecimal(cursor, end);
            {
                uint256 word;
                //slither-disable-next-line similar-names
                uint256 decimalCharByte;
                uint256 decimalLength = decimalEnd - decimalStart;
                assembly ("memory-safe") {
                    word := mload(sub(decimalEnd, 3))
                    decimalCharByte := byte(0, word)
                }
                // If the last 3 bytes are e notation, then we need to parse
                // the exponent as a 2 digit number.
                //slither-disable-next-line incorrect-shift
                if (decimalLength > 3 && ((1 << decimalCharByte) & CMASK_E_NOTATION) != 0) {
                    cursor = decimalEnd - 4;
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
                    if (decimalLength > 2 && ((1 << decimalCharByte) & CMASK_E_NOTATION) != 0) {
                        cursor = decimalEnd - 3;
                        assembly ("memory-safe") {
                            exponent := sub(byte(2, word), digitOffset)
                        }
                    }
                    // Otherwise, we're not in e notation and we can start at the
                    // decimalEnd of the literal with 0 starting exponent.
                    else if (decimalLength > 0) {
                        cursor = decimalEnd - 1;
                        exponent = 0;
                    } else {
                        revert ZeroLengthDecimal(state.parseErrorOffset(decimalStart));
                    }
                }
            }

            // Anything under 10^77 is safe to raise to its power of 10 without
            // overflowing a uint256.
            while (cursor >= decimalStart && exponent < 77) {
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
            if (cursor >= decimalStart) {
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
                    while (cursor >= decimalStart) {
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
            return (outerEnd, value);
        }
    }
}
