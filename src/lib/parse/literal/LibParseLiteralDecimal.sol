// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParseDecimalFloat, Float} from "rain.math.float/lib/parse/LibParseDecimalFloat.sol";
import {LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

library LibParseLiteralDecimal {
    using LibParseError for ParseState;

    /// Parses a decimal float literal from the source and returns it as a
    /// losslessly packed float in bytes32 form.
    function parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256, bytes32)
    {
        (bytes4 errorSelector, uint256 cursor, int256 signedCoefficient, int256 exponent) =
            LibParseDecimalFloat.parseDecimalFloatInline(start, end);
        state.handleErrorSelector(cursor, errorSelector);
        return (cursor, Float.unwrap(LibDecimalFloat.packLossless(signedCoefficient, exponent)));
    }
}
