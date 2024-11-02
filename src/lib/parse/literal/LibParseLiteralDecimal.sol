// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParseDecimalFloat} from "rain.math.float/lib/parse/LibParseDecimalFloat.sol";

library LibParseLiteralDecimal {
    using LibParseError for ParseState;

    function parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256, uint256)
    {
        (bytes4 errorSelector, uint256 cursor, uint256 packedFloat) =
            LibParseDecimalFloat.parseDecimalFloatPacked(start, end);
        state.handleErrorSelector(errorSelector, cursor);
        return (cursor, packedFloat);
    }
}
