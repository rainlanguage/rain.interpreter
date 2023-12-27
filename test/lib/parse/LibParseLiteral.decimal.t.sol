// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteral, ZeroLengthDecimal} from "src/lib/parse/LibParseLiteral.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseLiteralDecimalTest
/// Tests parsing decimal literal values with the LibParseLiteral library.
contract LibParseLiteralDecimalTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;

    /// Check that an empty string literal is an error.
    function testParseLiteralDecimalEmpty() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        (value);
    }

    /// Fuzz and round trip.
    function testParseLiteralDecimalRoundTrip(uint256 value) external {
        string memory valueString = Strings.toString(value);
        ParseState memory state =
            LibParseState.newState(bytes(valueString), "", "", LibParseLiteral.buildLiteralParsers());
        (uint256 parsedValue) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(parsedValue, value);
    }

    /// Check that a "0" parses to the correct value.
    function testParseLiteralDecimalSingleDigit0() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "0";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 0);
    }

    /// Check that a "1" parses to the correct value.
    function testParseLiteralDecimalSingleDigit1() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "1";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 1);
    }

    /// Check that a "2" parses to the correct value.
    function testParseLiteralDecimalSingleDigit2() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "2";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 2);
    }

    /// Check that a "3" parses to the correct value.
    function testParseLiteralDecimalSingleDigit3() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "3";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 3);
    }

    /// Check that a "4" parses to the correct value.
    function testParseLiteralDecimalSingleDigit4() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "4";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 4);
    }

    /// Check that a "5" parses to the correct value.
    function testParseLiteralDecimalSingleDigit5() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "5";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 5);
    }

    /// Check that a "6" parses to the correct value.
    function testParseLiteralDecimalSingleDigit6() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "6";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 6);
    }

    /// Check that a "7" parses to the correct value.
    function testParseLiteralDecimalSingleDigit7() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "7";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 7);
    }

    /// Check that a "8" parses to the correct value.
    function testParseLiteralDecimalSingleDigit8() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "8";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 8);
    }

    /// Check that a "9" parses to the correct value.
    function testParseLiteralDecimalSingleDigit9() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());
        state.data = "9";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 9);
    }

    /// Check that an "e" in 2nd position is processed as a 1 digit exponent.
    /// This tests Xe0 = X for X in [0,10].
    function testParseLiteralDecimalSingleDigitE0() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());

        state.data = "0e0";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 0);

        state.data = "1e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 1);

        state.data = "2e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 2);

        state.data = "3e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 3);

        state.data = "4e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 4);

        state.data = "5e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 5);

        state.data = "6e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 6);

        state.data = "7e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 7);

        state.data = "8e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 8);

        state.data = "9e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 9);

        state.data = "10e0";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 10);
    }

    /// Check that a "e" in 2nd position is processed as a 1 digit exponent.
    /// This tests Xe1 = X * 10 for X in [0,10].
    function testParseLiteralDecimalSingleDigitE1() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());

        state.data = "0e1";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 0);

        state.data = "1e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 10);

        state.data = "2e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 20);

        state.data = "3e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 30);

        state.data = "4e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 40);

        state.data = "5e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 50);

        state.data = "6e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 60);

        state.data = "7e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 70);

        state.data = "8e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 80);

        state.data = "9e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 90);

        state.data = "10e1";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 100);
    }

    /// Check that a "e" in 3rd position is processed as a 2 digit exponent.
    /// This tests Xe00 = X for X in [0,10].
    function testParseLiteralDecimalDoubleDigitE0() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());

        state.data = "0e00";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 0);

        state.data = "1e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 1);

        state.data = "2e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 2);

        state.data = "3e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 3);

        state.data = "4e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 4);

        state.data = "5e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 5);

        state.data = "6e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 6);

        state.data = "7e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 7);

        state.data = "8e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 8);

        state.data = "9e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 9);

        state.data = "10e00";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 10);
    }

    /// Check that a "e" in 3rd position is processed as a 2 digit exponent.
    /// This tests Xe01 = X * 10 for X in [0,10].
    function testParseLiteralDecimalDoubleDigitE1() external {
        ParseState memory state = LibParseState.newState("", "", "", LibParseLiteral.buildLiteralParsers());

        state.data = "0e01";
        (uint256 value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 0);

        state.data = "1e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 10);

        state.data = "2e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 20);

        state.data = "3e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 30);

        state.data = "4e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 40);

        state.data = "5e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 50);

        state.data = "6e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 60);

        state.data = "7e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 70);

        state.data = "8e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 80);

        state.data = "9e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 90);

        state.data = "10e01";
        (value) = state.parseLiteralDecimal(
            Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer())
        );
        assertEq(value, 100);
    }
}
