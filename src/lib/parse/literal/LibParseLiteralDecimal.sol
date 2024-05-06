// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {
    DecimalLiteralOverflow,
    ZeroLengthDecimal,
    MalformedExponentDigits,
    MalformedDecimalPoint
} from "../../../error/ErrParse.sol";
import {CMASK_E_NOTATION, CMASK_NUMERIC_0_9, CMASK_DECIMAL_POINT, CMASK_NEGATIVE_SIGN} from "../LibParseCMask.sol";
import {LibParseError} from "../LibParseError.sol";

library LibParseLiteralDecimal {
    using LibParseError for ParseState;
    using LibParseLiteralDecimal for ParseState;

    function skipDigits(uint256 cursor, uint256 end) internal pure returns (uint256) {
        uint256 decimalCharMask = CMASK_NUMERIC_0_9;
        assembly ("memory-safe") {
            //slither-disable-next-line incorrect-shift
            for {} and(iszero(iszero(and(shl(byte(0, mload(cursor)), 1), decimalCharMask))), lt(cursor, end)) {} {
                cursor := add(cursor, 1)
            }
        }
        return cursor;
    }

    function unsafeStrToInt(ParseState memory state, uint256 start, uint256 end) internal pure returns (uint256) {
        // The ASCII byte can be translated to a numeric digit by subtracting
        // the digit offset.
        uint256 digitOffset = uint256(uint8(bytes1("0")));
        uint256 exponent = 0;
        uint256 cursor;
        unchecked {
            cursor = end - 1;
        }
        uint256 value = 0;

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

        return value;
    }

    /// Returns cursor after, value
    function parseDecimal(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        uint256 intValue;
        {
            uint256 start = cursor;
            cursor = skipDigits(cursor, end);
            if (cursor == start) {
                revert ZeroLengthDecimal(state.parseErrorOffset(cursor));
            }
            intValue = state.unsafeStrToInt(start, cursor);
        }

        uint256 isFrac = 0;
        uint256 fracValue = 0;
        uint256 fracOffset = 0;
        {
            uint256 dMask = CMASK_DECIMAL_POINT;
            assembly ("memory-safe") {
                isFrac := and(iszero(iszero(and(shl(byte(0, mload(cursor)), 1), dMask))), lt(cursor, end))
            }
            if (isFrac == 1) {
                cursor++;
                uint256 fracStart = cursor;
                cursor = skipDigits(cursor, end);
                if (cursor == fracStart) {
                    revert MalformedDecimalPoint(state.parseErrorOffset(cursor));
                }
                fracValue = state.unsafeStrToInt(fracStart, cursor);
                fracOffset = cursor - fracStart;
            }
        }

        uint256 eValue = 0;
        uint256 eNeg = 0;
        {
            uint256 isE = 0;
            {
                uint256 eMask = CMASK_E_NOTATION;
                assembly ("memory-safe") {
                    isE := and(iszero(iszero(and(shl(byte(0, mload(cursor)), 1), eMask))), lt(cursor, end))
                }
            }

            if (isE == 1) {
                cursor++;
                {
                    uint256 negativeMask = CMASK_NEGATIVE_SIGN;
                    assembly ("memory-safe") {
                        eNeg := and(iszero(iszero(and(shl(byte(0, mload(cursor)), 1), negativeMask))), lt(cursor, end))
                    }
                    if (eNeg == 1) {
                        cursor++;
                    }
                }

                uint256 eStart = cursor;
                cursor = skipDigits(cursor, end);
                if (cursor == eStart) {
                    revert MalformedExponentDigits(state.parseErrorOffset(cursor));
                }
                eValue = state.unsafeStrToInt(eStart, cursor);
            }
        }

        uint256 scale;
        unchecked {
            uint256 fracScale = isFrac * 18;
            // If this is a fractional number, then we need to scale it up to
            // 1e18 being "one". Otherwise we treat as an integer.
            if (eNeg > 0) {
                scale = fracScale - eValue;
            } else {
                scale = fracScale + eValue;
            }
        }

        return (cursor, intValue * (10 ** scale) + fracValue * (10 ** (scale - fracOffset)));
    }
}
