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
import {LibParseDecimal} from "rain.string/lib/parse/LibParseDecimal.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParse} from "../LibParse.sol";
import {LibDecimalFloatImplementation, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

library LibParseLiteralDecimal {
    using LibParseError for ParseState;
    using LibParseLiteralDecimal for ParseState;

    function parseDecimalFloatPacked(ParseState memory state) internal view returns (LibDecimalFloat.Data memory) {
        LibDecimalFloat.Data memory result;
        result = self.parseDecimalFloat();
        self.assertEnd();
        return result;
    }


}
