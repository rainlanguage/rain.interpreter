// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {
    DecimalLiteralOverflow,
    ZeroLengthDecimal,
    MalformedExponentDigits,
    MalformedDecimalPoint,
    DecimalLiteralPrecisionLoss
} from "../../../error/ErrParse.sol";
import {
    CMASK_E_NOTATION,
    CMASK_NUMERIC_0_9,
    CMASK_DECIMAL_POINT,
    CMASK_NEGATIVE_SIGN,
    CMASK_ZERO
} from "rain.string/lib/parse/LibParseCMask.sol";
import {LibParseChar} from "rain.string/lib/parse/LibParseChar.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParse} from "../LibParse.sol";
import {LibDecimalFloatImplementation, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @dev The default is 18 decimal places for a fractional number.
uint256 constant DECIMAL_SCALE = 18;

library LibParseLiteralDecimal {
    using LibParseError for ParseState;
    using LibParseLiteralDecimal for ParseState;

    function unsafeStrToSignedInt(ParseState memory state, uint256 start, uint256 end) internal pure returns (int256) {
        unchecked {
            uint256 cursor = start;
            uint256 isNeg = LibParseChar.isMask(cursor, end, CMASK_NEGATIVE_SIGN);
            cursor += isNeg;

            uint256 value = state.unsafeStrToInt(cursor, end);

            if (isNeg != 0) {
                if (value > uint256(type(int256).max) + 1) {
                    revert DecimalLiteralOverflow(state.parseErrorOffset(start));
                }
                return -int256(value);
            } else {
                if (value > uint256(type(int256).max)) {
                    revert DecimalLiteralOverflow(state.parseErrorOffset(start));
                }
                return int256(value);
            }
        }
    }

    function parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256 cursor, uint256 packedFloat)
    {
        int256 signedCoefficient;
        int256 exponent;
        (cursor, signedCoefficient, exponent) = parseDecimalFloat(state, start, end);

        // Prenormalize signed coefficients that are smaller than their
        // normalized form at parse time, as this can save runtime gas that would
        // be needed to normalize the value at runtime.
        // We only do normalization that will scale up, to avoid causing
        // unneccessary precision loss.
        if (-1e37 < signedCoefficient && signedCoefficient < 1e37) {
            (signedCoefficient, exponent) = LibDecimalFloatImplementation.normalize(signedCoefficient, exponent);
        }

        packedFloat = LibDecimalFloat.pack(signedCoefficient, exponent);

        (int256 unpackedSignedCoefficient, int256 unpackedExponent) = LibDecimalFloat.unpack(packedFloat);
        if (unpackedSignedCoefficient != signedCoefficient || unpackedExponent != exponent) {
            revert DecimalLiteralPrecisionLoss(state.parseErrorOffset(start));
        }
    }

    function parseDecimalFloat(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256 cursor, int256 signedCoefficient, int256 exponent)
    {
        unchecked {
            cursor = start;
            cursor = LibParseChar.skipMask(cursor, end, CMASK_NEGATIVE_SIGN);
            {
                uint256 intStart = cursor;
                cursor = LibParseChar.skipMask(cursor, end, CMASK_NUMERIC_0_9);
                if (cursor == intStart) {
                    revert ZeroLengthDecimal(state.parseErrorOffset(start));
                }
            }
            signedCoefficient = state.unsafeStrToSignedInt(start, cursor);

            int256 fracValue = int256(LibParseChar.isMask(cursor, end, CMASK_DECIMAL_POINT));
            if (fracValue != 0) {
                cursor++;
                uint256 fracStart = cursor;
                cursor = LibParseChar.skipMask(cursor, end, CMASK_NUMERIC_0_9);
                if (cursor == fracStart) {
                    revert MalformedDecimalPoint(state.parseErrorOffset(fracStart));
                }
                // Trailing zeros are allowed in fractional literals but should
                // not be counted in the precision.
                uint256 nonZeroCursor = cursor;
                while (LibParseChar.isMask(nonZeroCursor - 1, end, CMASK_ZERO) == 1) {
                    nonZeroCursor--;
                }

                fracValue = unsafeStrToSignedInt(state, fracStart, nonZeroCursor);
                // Frac value inherits its sign from the coefficient.
                if (fracValue < 0) {
                    revert MalformedDecimalPoint(state.parseErrorOffset(fracStart));
                }
                if (signedCoefficient < 0) {
                    fracValue = -fracValue;
                }

                // We want to _decrease_ the exponent by the number of digits in the
                // fractional part.
                exponent = int256(fracStart) - int256(nonZeroCursor);
                uint256 scale = uint256(-exponent);
                if (scale >= 77 && signedCoefficient != 0) {
                    revert DecimalLiteralPrecisionLoss(state.parseErrorOffset(start));
                }
                scale = 10 ** scale;
                int256 rescaledIntValue = signedCoefficient * int256(scale);
                if (rescaledIntValue / int256(scale) != signedCoefficient) {
                    revert DecimalLiteralPrecisionLoss(state.parseErrorOffset(start));
                }
                signedCoefficient = rescaledIntValue + fracValue;
            }

            int256 eValue = int256(LibParseChar.isMask(cursor, end, CMASK_E_NOTATION));
            if (eValue != 0) {
                cursor++;
                uint256 eStart = cursor;
                cursor = LibParseChar.skipMask(cursor, end, CMASK_NEGATIVE_SIGN);
                {
                    uint256 digitsStart = cursor;
                    cursor = LibParseChar.skipMask(cursor, end, CMASK_NUMERIC_0_9);
                    if (cursor == digitsStart) {
                        revert MalformedExponentDigits(state.parseErrorOffset(digitsStart));
                    }
                }

                eValue = state.unsafeStrToSignedInt(eStart, cursor);
                exponent += eValue;
            }
        }
    }
}
