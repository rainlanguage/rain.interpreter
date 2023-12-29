// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ParseLiteralTest} from "test/util/abstract/ParseLiteralTest.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {
    LibParseLiteral, UnsupportedLiteralType, MalformedExponentDigits
} from "src/lib/parse/literal/LibParseLiteral.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";

/// @title LibParseLiteralBoundLiteralDecimalTest
/// Tests finding bounds for literal decimal values by parsing.
contract LibParseLiteralBoundLiteralDecimalTest is ParseLiteralTest {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;

    // function checkDecimalBounds(
    //     bytes memory data,
    //     uint256 expectedInnerStart,
    //     uint256 expectedInnerEnd,
    //     uint256 expectedOuterEnd
    // ) internal {
    //     uint256 decimalParser;
    //     function (ParseState memory, uint256, uint256) pure returns (uint256) parseLiteralDecimal =
    //         LibParseLiteral.parseLiteralDecimal;
    //     assembly ("memory-safe") {
    //         decimalParser := parseLiteralDecimal
    //     }
    //     checkLiteralBounds(data, expectedInnerStart, expectedInnerEnd, expectedOuterEnd, decimalParser);
    // }

    function checkMalformedExponentDigits(bytes memory data, uint256 offset) internal {
        ParseState memory state =
            LibParseState.newState(data, "", "", LibAllStandardOpsNP.literalParserFunctionPointers());
        state.literalParsers = LibAllStandardOpsNP.literalParserFunctionPointers();
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        uint256 cursor = outerStart;
        uint256 end = outerStart + data.length;
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, offset));
        uint256 value;
        (cursor, value) = state.parseLiteral(cursor, end);
        (cursor, value);
    }

    // /// Check that a single digit is bounded as a decimal literal. Tests "0".
    // function testParseLiteralBoundLiteralDecimal0() external {
    //     checkDecimalBounds("0", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "1".
    // function testParseLiteralBoundLiteralDecimal1() external {
    //     checkDecimalBounds("1", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "2".
    // function testParseLiteralBoundLiteralDecimal2() external {
    //     checkDecimalBounds("2", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "3".
    // function testParseLiteralBoundLiteralDecimal3() external {
    //     checkDecimalBounds("3", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "4".
    // function testParseLiteralBoundLiteralDecimal4() external {
    //     checkDecimalBounds("4", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "5".
    // function testParseLiteralBoundLiteralDecimal5() external {
    //     checkDecimalBounds("5", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "6".
    // function testParseLiteralBoundLiteralDecimal6() external {
    //     checkDecimalBounds("6", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "7".
    // function testParseLiteralBoundLiteralDecimal7() external {
    //     checkDecimalBounds("7", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "8".
    // function testParseLiteralBoundLiteralDecimal8() external {
    //     checkDecimalBounds("8", 0, 1, 1);
    // }

    // /// Check that a single digit is bounded as a decimal literal. Tests "9".
    // function testParseLiteralBoundLiteralDecimal9() external {
    //     checkDecimalBounds("9", 0, 1, 1);
    // }

    /// Check that "e" or "E" in isolation is not treated as a literal.
    function testParseLiteralBoundLiteralDecimalE() external {
        checkUnsupportedLiteralType("e", 0);
        checkUnsupportedLiteralType("E", 0);
    }

    /// Check that a single digit followed by "e" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroE() external {
        checkMalformedExponentDigits("0e", 1);
    }

    /// Check that a single digit followed by "E" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEUpper() external {
        checkMalformedExponentDigits("0E", 1);
    }

    /// Check that a single digit followed by "e+" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlus() external {
        checkMalformedExponentDigits("0e+", 1);
    }

    /// Check that a single digit followed by "E+" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusUpper() external {
        checkMalformedExponentDigits("0E+", 1);
    }

    /// Check that a single digit followed by "e-" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinus() external {
        checkMalformedExponentDigits("0e-", 1);
    }

    /// Check that a single digit followed by "E-" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusUpper() external {
        checkMalformedExponentDigits("0E-", 1);
    }

    /// Check that a single digit followed by "e+1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusOne() external {
        checkMalformedExponentDigits("0e+1", 1);
    }

    /// Check that a single digit followed by "E+1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusOneUpper() external {
        checkMalformedExponentDigits("0E+1", 1);
    }

    /// Check that a single digit followed by "e-1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusOne() external {
        checkMalformedExponentDigits("0e-1", 1);
    }

    /// Check that a single digit followed by "E-1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusOneUpper() external {
        checkMalformedExponentDigits("0E-1", 1);
    }

    /// Check that a single digit followed by "e+01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusZeroOne() external {
        checkMalformedExponentDigits("0e+01", 1);
    }

    /// Check that a single digit followed by "E+01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusZeroOneUpper() external {
        checkMalformedExponentDigits("0E+01", 1);
    }

    /// Check that a single digit followed by "e-01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusZeroOne() external {
        checkMalformedExponentDigits("0e-01", 1);
    }

    /// Check that a single digit followed by "E+10" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusTen() external {
        checkMalformedExponentDigits("0e+10", 1);
    }

    /// Check a decimal with "e" followed by three digits is treated as
    /// malformed.
    function testParseLiteralBoundLiteralDecimalEPlusThreeDigits() external {
        checkMalformedExponentDigits("01e123", 2);
    }

    /// Check a decimal with "E" followed by three digits is treated as
    /// malformed.
    function testParseLiteralBoundLiteralDecimalEPlusThreeDigitsUpper() external {
        checkMalformedExponentDigits("01E123", 2);
    }

    /// Check a decimal with "e" followed by four digits is treated as malformed.
    function testParseLiteralBoundLiteralDecimalEPlusFourDigits() external {
        checkMalformedExponentDigits("01e1234", 2);
    }

    /// Check a decimal with "E" followed by four digits is treated as malformed.
    function testParseLiteralBoundLiteralDecimalEPlusFourDigitsUpper() external {
        checkMalformedExponentDigits("01E1234", 2);
    }

    // /// Check that a string with multiple e/E only bounds the first.
    // function testParseLiteralBoundLiteralDecimalMultipleE() external {
    //     checkDecimalBounds("0e0e0", 0, 3, 3);
    //     checkDecimalBounds("0E0E0", 0, 3, 3);
    // }

    // /// Check that a string with non digit characters after the first exponent
    // /// digit is handled correctly (bounds up to the first exponent digit).
    // function testParseLiteralBoundLiteralDecimalNonDigitAfterFirstExponent() external {
    //     checkDecimalBounds("0e0ze0", 0, 3, 3);
    //     checkDecimalBounds("0E0ZE0", 0, 3, 3);
    // }

    // /// Check that a string with non digit characters after the second exponent
    // /// digit is handled correctly (bounds up to the second exponent digit).
    // function testParseLiteralBoundLiteralDecimalNonDigitAfterExponent() external {
    //     checkDecimalBounds("0e00ze0", 0, 4, 4);
    //     checkDecimalBounds("0E00ZE0", 0, 4, 4);
    // }
}
