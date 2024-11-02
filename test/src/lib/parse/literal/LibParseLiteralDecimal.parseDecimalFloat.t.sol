// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteralDecimal} from "src/lib/parse/literal/LibParseLiteralDecimal.sol";
import {LibParseLiteral, ZeroLengthDecimal} from "src/lib/parse/literal/LibParseLiteral.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {ParseEmptyDecimalString} from "rain.string/error/ErrParse.sol";
import {ParseDecimalPrecisionLoss, MalformedExponentDigits, MalformedDecimalPoint} from "rain.math.float/error/ErrParse.sol";

/// @title LibParseLiteralDecimalParseDecimalFloatTest
contract LibParseLiteralDecimalParseDecimalFloatTest is Test {
    using LibParseLiteralDecimal for ParseState;
    using LibBytes for bytes;
    using Strings for uint256;

    function checkParseDecimalRevert(string memory data, bytes memory err) internal {
        ParseState memory state = LibParseState.newState(bytes(data), "", "", "");
        vm.expectRevert(err);
        state.parseDecimalFloat(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
    }

    /// An empty string should revert.
    function testParseLiteralDecimalFloatEmpty() external {
        checkParseDecimalRevert("", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// A non decimal string should revert.
    function testParseLiteralDecimalFloatNonDecimal() external {
        checkParseDecimalRevert("hello", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// e without a number should revert.
    function testParseLiteralDecimalFloatExponentRevert() external {
        checkParseDecimalRevert("e", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// e with a left digit but not right should revert.
    function testParseLiteralDecimalFloatExponentRevert2() external {
        checkParseDecimalRevert("1e", abi.encodeWithSelector(MalformedExponentDigits.selector, 2));
    }

    /// e with a left digit but not right should revert. Add a negative sign.
    function testParseLiteralDecimalFloatExponentRevert3() external {
        checkParseDecimalRevert("1e-", abi.encodeWithSelector(MalformedExponentDigits.selector, 3));
    }

    /// e with a right digit but not left should revert.
    function testParseLiteralDecimalFloatExponentRevert4() external {
        checkParseDecimalRevert("e1", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// e with a right digit but not left should revert.
    /// two digits.
    function testParseLiteralDecimalFloatExponentRevert5() external {
        checkParseDecimalRevert("e10", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// e with a right digit but not left should revert.
    /// two digits with negative sign.
    function testParseLiteralDecimalFloatExponentRevert6() external {
        checkParseDecimalRevert("e-10", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// Dot without digits should revert.
    function testParseLiteralDecimalFloatDotRevert() external {
        checkParseDecimalRevert(".", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// Dot without leading digits should revert.
    function testParseLiteralDecimalFloatDotRevert2() external {
        checkParseDecimalRevert(".1", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// Dot without trailing digits should revert.
    function testParseLiteralDecimalFloatDotRevert3() external {
        checkParseDecimalRevert("1.", abi.encodeWithSelector(MalformedDecimalPoint.selector, 2));
    }

    /// Dot e is an error.
    function testParseLiteralDecimalFloatDotE() external {
        checkParseDecimalRevert(".e", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// Dot e0 is an error.
    function testParseLiteralDecimalFloatDotE0() external {
        checkParseDecimalRevert(".e0", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// e dot is an error.
    function testParseLiteralDecimalFloatEDot() external {
        checkParseDecimalRevert("e.", abi.encodeWithSelector(ParseEmptyDecimalString.selector, 0));
    }

    /// Negative e with no digits is an error.
    function testParseLiteralDecimalFloatNegativeE() external {
        checkParseDecimalRevert("0.0e-", abi.encodeWithSelector(MalformedExponentDigits.selector, 5));
    }

    /// Negative frac is an error.
    function testParseLiteralDecimalFloatNegativeFrac() external {
        checkParseDecimalRevert("0.-1", abi.encodeWithSelector(MalformedDecimalPoint.selector, 2));
    }

    /// Can't have more than max total precision. Add decimals after the max int.
    function testParseLiteralDecimalFloatPrecisionRevert0() external {
        checkParseDecimalRevert(
            "57896044618658097711785492504343953926634992332820282019728792003956564819967.1",
            abi.encodeWithSelector(ParseDecimalPrecisionLoss.selector, 79)
        );
    }

    /// Can't have more than max total precision. Have an int that makes it
    /// impossible to fit the max decimals.
    function testParseLiteralDecimalFloatPrecisionRevert1() external {
        checkParseDecimalRevert(
            "1.57896044618658097711785492504343953926634992332820282019728792003956564819967",
            abi.encodeWithSelector(ParseDecimalPrecisionLoss.selector, 79)
        );
    }
}
