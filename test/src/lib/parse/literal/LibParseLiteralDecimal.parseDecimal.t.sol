// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteral, ZeroLengthDecimal} from "src/lib/parse/literal/LibParseLiteral.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibParseLiteralDecimal} from "src/lib/parse/literal/LibParseLiteralDecimal.sol";
import {
    MalformedExponentDigits,
    MalformedDecimalPoint,
    DecimalLiteralOverflow,
    DecimalLiteralPrecisionLoss
} from "src/error/ErrParse.sol";

/// @title LibParseLiteralDecimalTest
/// Tests parsing decimal literal values with the LibParseLiteral library.
contract LibParseLiteralDecimalTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;
    using LibParseLiteralDecimal for ParseState;

    function checkParseDecimal(string memory data, uint256 expectedValue, uint256 expectedCursorAfter) internal pure {
        ParseState memory state = LibParseState.newState(bytes(data), "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 value) = state.parseDecimal(cursor, Pointer.unwrap(state.data.endDataPointer()));
        assertEq(cursorAfter - cursor, expectedCursorAfter);
        assertEq(value, expectedValue);
    }

    function checkParseDecimalRevert(string memory data, bytes memory err) internal {
        ParseState memory state = LibParseState.newState(bytes(data), "", "", "");
        vm.expectRevert(err);
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }

    /// Check that an empty string literal is an error.
    function testParseLiteralDecimalEmpty() external {
        ParseState memory state = LibParseState.newState("", "", "", "");
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }

    /// A non decimal literal is an error.
    function testParseLiteralDecimalNonDecimal() external {
        ParseState memory state = LibParseState.newState("hello", "", "", "");
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }

    /// Fuzz and round trip.
    function testParseLiteralDecimalRoundTrip(uint256 value) external pure {
        value = bound(value, 0, type(uint256).max / 1e18);
        string memory valueStr = Strings.toString(value);
        checkParseDecimal(valueStr, value * 1e18, bytes(valueStr).length);
    }

    /// Check some specific examples.
    function testParseLiteralDecimalSpecific() external pure {
        checkParseDecimal("0", 0e18, 1);
        checkParseDecimal("1", 1e18, 1);
        checkParseDecimal("2", 2e18, 1);
        checkParseDecimal("3", 3e18, 1);
        checkParseDecimal("4", 4e18, 1);
        checkParseDecimal("5", 5e18, 1);
        checkParseDecimal("6", 6e18, 1);
        checkParseDecimal("7", 7e18, 1);
        checkParseDecimal("8", 8e18, 1);
        checkParseDecimal("9", 9e18, 1);
        checkParseDecimal("10", 10e18, 2);
    }

    /// Check some examples of decimals.
    function testParseLiteralDecimalDecimals() external pure {
        checkParseDecimal("0.0", 0e18, 3);
        checkParseDecimal("1.0", 1e18, 3);
        checkParseDecimal("2.0", 2e18, 3);
        checkParseDecimal("3.0", 3e18, 3);
        checkParseDecimal("4.0", 4e18, 3);
        checkParseDecimal("5.0", 5e18, 3);
        checkParseDecimal("6.0", 6e18, 3);
        checkParseDecimal("7.0", 7e18, 3);
        checkParseDecimal("8.0", 8e18, 3);
        checkParseDecimal("9.0", 9e18, 3);
        checkParseDecimal("10.0", 10e18, 4);

        checkParseDecimal("0.1", 0.1e18, 3);
        checkParseDecimal("1.1", 1.1e18, 3);
        checkParseDecimal("2.1", 2.1e18, 3);
        checkParseDecimal("3.1", 3.1e18, 3);
        checkParseDecimal("4.1", 4.1e18, 3);
        checkParseDecimal("5.1", 5.1e18, 3);
        checkParseDecimal("6.1", 6.1e18, 3);
        checkParseDecimal("7.1", 7.1e18, 3);
        checkParseDecimal("8.1", 8.1e18, 3);
        checkParseDecimal("9.1", 9.1e18, 3);
        checkParseDecimal("10.1", 10.1e18, 4);

        checkParseDecimal("0.01", 0.01e18, 4);
        checkParseDecimal("1.01", 1.01e18, 4);
        checkParseDecimal("2.01", 2.01e18, 4);
        checkParseDecimal("3.01", 3.01e18, 4);
        checkParseDecimal("4.01", 4.01e18, 4);
        checkParseDecimal("5.01", 5.01e18, 4);
        checkParseDecimal("6.01", 6.01e18, 4);
        checkParseDecimal("7.01", 7.01e18, 4);
        checkParseDecimal("8.01", 8.01e18, 4);
        checkParseDecimal("9.01", 9.01e18, 4);
        checkParseDecimal("10.01", 10.01e18, 5);
    }

    /// Check some examples of exponents.
    /// Checks e in the 2nd position.
    function testParseLiteralDecimalExponents() external pure {
        checkParseDecimal("0e0", 0e18, 3);
        checkParseDecimal("1e0", 1e18, 3);
        checkParseDecimal("2e0", 2e18, 3);
        checkParseDecimal("3e0", 3e18, 3);
        checkParseDecimal("4e0", 4e18, 3);
        checkParseDecimal("5e0", 5e18, 3);
        checkParseDecimal("6e0", 6e18, 3);
        checkParseDecimal("7e0", 7e18, 3);
        checkParseDecimal("8e0", 8e18, 3);
        checkParseDecimal("9e0", 9e18, 3);
        checkParseDecimal("10e0", 10e18, 4);

        checkParseDecimal("0e1", 0e18, 3);
        checkParseDecimal("1e1", 10e18, 3);
        checkParseDecimal("2e1", 20e18, 3);
        checkParseDecimal("3e1", 30e18, 3);
        checkParseDecimal("4e1", 40e18, 3);
        checkParseDecimal("5e1", 50e18, 3);
        checkParseDecimal("6e1", 60e18, 3);
        checkParseDecimal("7e1", 70e18, 3);
        checkParseDecimal("8e1", 80e18, 3);
        checkParseDecimal("9e1", 90e18, 3);
        checkParseDecimal("10e1", 100e18, 4);

        checkParseDecimal("0e2", 0e18, 3);
        checkParseDecimal("1e2", 100e18, 3);
        checkParseDecimal("2e2", 200e18, 3);
        checkParseDecimal("3e2", 300e18, 3);
        checkParseDecimal("4e2", 400e18, 3);
        checkParseDecimal("5e2", 500e18, 3);
        checkParseDecimal("6e2", 600e18, 3);
        checkParseDecimal("7e2", 700e18, 3);
        checkParseDecimal("8e2", 800e18, 3);
        checkParseDecimal("9e2", 900e18, 3);
        checkParseDecimal("10e2", 1000e18, 4);
    }

    /// Check some examples of exponents.
    /// Checks e in the 3rd position.
    function testParseLiteralDecimalExponents2() external pure {
        checkParseDecimal("0e00", 0e18, 4);
        checkParseDecimal("1e00", 1e18, 4);
        checkParseDecimal("2e00", 2e18, 4);
        checkParseDecimal("3e00", 3e18, 4);
        checkParseDecimal("4e00", 4e18, 4);
        checkParseDecimal("5e00", 5e18, 4);
        checkParseDecimal("6e00", 6e18, 4);
        checkParseDecimal("7e00", 7e18, 4);
        checkParseDecimal("8e00", 8e18, 4);
        checkParseDecimal("9e00", 9e18, 4);
        checkParseDecimal("10e00", 10e18, 5);

        checkParseDecimal("0e01", 0e18, 4);
        checkParseDecimal("1e01", 10e18, 4);
        checkParseDecimal("2e01", 20e18, 4);
        checkParseDecimal("3e01", 30e18, 4);
        checkParseDecimal("4e01", 40e18, 4);
        checkParseDecimal("5e01", 50e18, 4);
        checkParseDecimal("6e01", 60e18, 4);
        checkParseDecimal("7e01", 70e18, 4);
        checkParseDecimal("8e01", 80e18, 4);
        checkParseDecimal("9e01", 90e18, 4);
        checkParseDecimal("10e01", 100e18, 5);

        checkParseDecimal("0e02", 0e18, 4);
        checkParseDecimal("1e02", 100e18, 4);
        checkParseDecimal("2e02", 200e18, 4);
        checkParseDecimal("3e02", 300e18, 4);
        checkParseDecimal("4e02", 400e18, 4);
        checkParseDecimal("5e02", 500e18, 4);
        checkParseDecimal("6e02", 600e18, 4);
        checkParseDecimal("7e02", 700e18, 4);
        checkParseDecimal("8e02", 800e18, 4);
        checkParseDecimal("9e02", 900e18, 4);
        checkParseDecimal("10e02", 1000e18, 5);

        checkParseDecimal("0e10", 0e18, 4);
        checkParseDecimal("1e10", 1e28, 4);
        checkParseDecimal("2e10", 2e28, 4);
        checkParseDecimal("3e10", 3e28, 4);
        checkParseDecimal("4e10", 4e28, 4);
        checkParseDecimal("5e10", 5e28, 4);
        checkParseDecimal("6e10", 6e28, 4);
        checkParseDecimal("7e10", 7e28, 4);
        checkParseDecimal("8e10", 8e28, 4);
        checkParseDecimal("9e10", 9e28, 4);
        checkParseDecimal("10e10", 10e28, 5);
    }

    // Test integer with capital E
    function testParseLiteralDecimalExponents2Capital() external pure {
        checkParseDecimal("0E00", 0e18, 4);
        checkParseDecimal("1E00", 1e18, 4);
        checkParseDecimal("2E00", 2e18, 4);
        checkParseDecimal("3E00", 3e18, 4);
        checkParseDecimal("4E00", 4e18, 4);
        checkParseDecimal("5E00", 5e18, 4);
        checkParseDecimal("6E00", 6e18, 4);
        checkParseDecimal("7E00", 7e18, 4);
        checkParseDecimal("8E00", 8e18, 4);
        checkParseDecimal("9E00", 9e18, 4);
        checkParseDecimal("10E00", 10e18, 5);

        checkParseDecimal("0E01", 0e18, 4);
        checkParseDecimal("1E01", 10e18, 4);
        checkParseDecimal("2E01", 20e18, 4);
        checkParseDecimal("3E01", 30e18, 4);
        checkParseDecimal("4E01", 40e18, 4);
        checkParseDecimal("5E01", 50e18, 4);
        checkParseDecimal("6E01", 60e18, 4);
        checkParseDecimal("7E01", 70e18, 4);
        checkParseDecimal("8E01", 80e18, 4);
        checkParseDecimal("9E01", 90e18, 4);
        checkParseDecimal("10E01", 100e18, 5);

        checkParseDecimal("0E02", 0e18, 4);
        checkParseDecimal("1E02", 100e18, 4);
        checkParseDecimal("2E02", 200e18, 4);
        checkParseDecimal("3E02", 300e18, 4);
        checkParseDecimal("4E02", 400e18, 4);
        checkParseDecimal("5E02", 500e18, 4);
        checkParseDecimal("6E02", 600e18, 4);
        checkParseDecimal("7E02", 700e18, 4);
        checkParseDecimal("8E02", 800e18, 4);
        checkParseDecimal("9E02", 900e18, 4);
    }

    // Test decimals with exponents.
    function testParseLiteralDecimalExponents3() external pure {
        checkParseDecimal("0.0e0", 0, 5);
        checkParseDecimal("1.0e0", 1e18, 5);
        checkParseDecimal("2.0e0", 2e18, 5);
        checkParseDecimal("3.0e0", 3e18, 5);
        checkParseDecimal("4.0e0", 4e18, 5);
        checkParseDecimal("5.0e0", 5e18, 5);
        checkParseDecimal("6.0e0", 6e18, 5);
        checkParseDecimal("7.0e0", 7e18, 5);
        checkParseDecimal("8.0e0", 8e18, 5);
        checkParseDecimal("9.0e0", 9e18, 5);
        checkParseDecimal("10.0e0", 10e18, 6);

        checkParseDecimal("0.1e0", 0.1e18, 5);
        checkParseDecimal("1.1e0", 1.1e18, 5);
        checkParseDecimal("2.1e0", 2.1e18, 5);
        checkParseDecimal("3.1e0", 3.1e18, 5);
        checkParseDecimal("4.1e0", 4.1e18, 5);
        checkParseDecimal("5.1e0", 5.1e18, 5);
        checkParseDecimal("6.1e0", 6.1e18, 5);
        checkParseDecimal("7.1e0", 7.1e18, 5);
        checkParseDecimal("8.1e0", 8.1e18, 5);
        checkParseDecimal("9.1e0", 9.1e18, 5);
        checkParseDecimal("10.1e0", 10.1e18, 6);

        checkParseDecimal("0.01e000", 0.01e18, 8);

        checkParseDecimal("0.01e0", 0.01e18, 6);
        checkParseDecimal("1.01e0", 1.01e18, 6);
        checkParseDecimal("2.01e0", 2.01e18, 6);
        checkParseDecimal("3.01e0", 3.01e18, 6);

        checkParseDecimal("0.0e1", 0.0e19, 5);
        checkParseDecimal("1.0e1", 1.0e19, 5);
        checkParseDecimal("2.0e1", 2.0e19, 5);
        checkParseDecimal("3.0e1", 3.0e19, 5);
        checkParseDecimal("4.0e1", 4.0e19, 5);
        checkParseDecimal("5.0e1", 5.0e19, 5);

        checkParseDecimal("0.0e001", 0.0e20, 7);

        checkParseDecimal("0.0e2", 0.0e20, 5);
        checkParseDecimal("1.0e2", 1.0e20, 5);
        checkParseDecimal("2.0e2", 2.0e20, 5);
        checkParseDecimal("3.0e2", 3.0e20, 5);
        checkParseDecimal("4.0e2", 4.0e20, 5);
        checkParseDecimal("5.0e2", 5.0e20, 5);

        checkParseDecimal("0.0101e10", 0.0101e28, 9);
        checkParseDecimal("1.0101e10", 1.0101e28, 9);
        checkParseDecimal("2.0101e10", 2.0101e28, 9);
        checkParseDecimal("3.0101e10", 3.0101e28, 9);
    }

    /// Test capital E
    function testParseLiteralDecimalExponents4() external pure {
        checkParseDecimal("0.0E0", 0, 5);
        checkParseDecimal("1.0E0", 1e18, 5);
        checkParseDecimal("2.0E0", 2e18, 5);
        checkParseDecimal("3.0E0", 3e18, 5);
        checkParseDecimal("4.0E0", 4e18, 5);
        checkParseDecimal("5.0E0", 5e18, 5);
        checkParseDecimal("6.0E0", 6e18, 5);
        checkParseDecimal("7.0E0", 7e18, 5);
        checkParseDecimal("8.0E0", 8e18, 5);
        checkParseDecimal("9.0E0", 9e18, 5);
        checkParseDecimal("10.0E0", 10e18, 6);

        checkParseDecimal("0.1E0", 0.1e18, 5);
        checkParseDecimal("1.1E0", 1.1e18, 5);
        checkParseDecimal("2.1E0", 2.1e18, 5);
        checkParseDecimal("3.1E0", 3.1e18, 5);
        checkParseDecimal("4.1E0", 4.1e18, 5);
        checkParseDecimal("5.1E0", 5.1e18, 5);
        checkParseDecimal("6.1E0", 6.1e18, 5);
        checkParseDecimal("7.1E0", 7.1e18, 5);
        checkParseDecimal("8.1E0", 8.1e18, 5);
        checkParseDecimal("9.1E0", 9.1e18, 5);
        checkParseDecimal("10.1E0", 10.1e18, 6);

        checkParseDecimal("0.01E000", 0.01e18, 8);

        checkParseDecimal("0.01E0", 0.01e18, 6);
    }

    /// Test some negative exponents.
    function testParseLiteralDecimalNegativeExponents() external pure {
        checkParseDecimal("0.0e-0", 0, 6);
        checkParseDecimal("1.0e-0", 1e18, 6);
        checkParseDecimal("2.0e-0", 2e18, 6);
        checkParseDecimal("3.0e-0", 3e18, 6);
        checkParseDecimal("4.0e-0", 4e18, 6);
        checkParseDecimal("5.0e-0", 5e18, 6);
        checkParseDecimal("6.0e-0", 6e18, 6);
        checkParseDecimal("7.0e-0", 7e18, 6);
        checkParseDecimal("8.0e-0", 8e18, 6);
        checkParseDecimal("9.0e-0", 9e18, 6);
        checkParseDecimal("10.0e-0", 10e18, 7);

        checkParseDecimal("0.1e-0", 0.1e18, 6);
        checkParseDecimal("1.1e-0", 1.1e18, 6);
        checkParseDecimal("2.1e-0", 2.1e18, 6);
        checkParseDecimal("3.1e-0", 3.1e18, 6);
        checkParseDecimal("4.1e-0", 4.1e18, 6);
        checkParseDecimal("5.1e-0", 5.1e18, 6);
        checkParseDecimal("6.1e-0", 6.1e18, 6);
        checkParseDecimal("7.1e-0", 7.1e18, 6);
        checkParseDecimal("8.1e-0", 8.1e18, 6);
        checkParseDecimal("9.1e-0", 9.1e18, 6);
        checkParseDecimal("10.1e-0", 10.1e18, 7);

        checkParseDecimal("0.01e-0", 0.01e18, 7);

        checkParseDecimal("0.0e-1", 0.0e17, 6);
        checkParseDecimal("1.0e-1", 1.0e17, 6);
        checkParseDecimal("2.0e-1", 2.0e17, 6);
        checkParseDecimal("3.0e-1", 3.0e17, 6);
        checkParseDecimal("4.0e-1", 4.0e17, 6);

        checkParseDecimal("0.0e-2", 0.0e16, 6);
        checkParseDecimal("1.0e-2", 1.0e16, 6);
        checkParseDecimal("2.0e-2", 2.0e16, 6);
        checkParseDecimal("3.0e-2", 3.0e16, 6);

        checkParseDecimal("0.0101e-10", 0.0101e8, 10);
        checkParseDecimal("1.0101e-10", 1.0101e8, 10);
        checkParseDecimal("2.0101e-10", 2.0101e8, 10);

        checkParseDecimal("0.0e-18", 0, 7);
        checkParseDecimal("1.0e-18", 1, 7);
        checkParseDecimal("2.0e-18", 2, 7);
    }

    /// Test trailing zeros.
    function testParseLiteralDecimalTrailingZeros() external pure {
        checkParseDecimal("0.000000000000000000", 0, 20);
        checkParseDecimal("1.000000000000000000", 1e18, 20);
        checkParseDecimal("2.000000000000000000", 2e18, 20);
        checkParseDecimal("3.000000000000000000", 3e18, 20);
        checkParseDecimal("4.000000000000000000", 4e18, 20);
        checkParseDecimal("5.000000000000000000", 5e18, 20);
        checkParseDecimal("6.000000000000000000", 6e18, 20);
        checkParseDecimal("7.000000000000000000", 7e18, 20);
        checkParseDecimal("8.000000000000000000", 8e18, 20);
        checkParseDecimal("9.000000000000000000", 9e18, 20);
        checkParseDecimal("10.000000000000000000", 10e18, 21);

        checkParseDecimal("0.100000000000000000", 0.1e18, 20);
        checkParseDecimal("1.100000000000000000", 1.1e18, 20);
        checkParseDecimal("2.100000000000000000", 2.1e18, 20);
        checkParseDecimal("3.100000000000000000", 3.1e18, 20);
        checkParseDecimal("4.100000000000000000", 4.1e18, 20);
        checkParseDecimal("5.100000000000000000", 5.1e18, 20);
        checkParseDecimal("6.100000000000000000", 6.1e18, 20);
        checkParseDecimal("7.100000000000000000", 7.1e18, 20);
        checkParseDecimal("8.100000000000000000", 8.1e18, 20);
        checkParseDecimal("9.100000000000000000", 9.1e18, 20);

        checkParseDecimal("0.010000000000000000e5", 0.01e23, 22);
        checkParseDecimal("1.010000000000000000e-5", 1.01e13, 23);
        checkParseDecimal("2.000000000000000000e-18", 2, 24);
    }

    // Test some unrelated data after the decimal.
    function testParseLiteralDecimalUnrelated() external pure {
        checkParseDecimal("0.0hello", 0, 3);
        checkParseDecimal("1.0hello", 1e18, 3);
        checkParseDecimal("2.0hello", 2e18, 3);
        checkParseDecimal("3.0hello", 3e18, 3);

        checkParseDecimal("0.0e0e10", 0, 5);
        checkParseDecimal("1.0e0e10", 1e18, 5);
        checkParseDecimal("2.0e0e10", 2e18, 5);

        checkParseDecimal("0.0e0.5", 0, 5);
        checkParseDecimal("1.0e0.5", 1e18, 5);
        checkParseDecimal("2.0e0.5", 2e18, 5);

        checkParseDecimal("0.0e1.5", 0, 5);
        checkParseDecimal("1.0e1.5", 1e19, 5);
        checkParseDecimal("2.0e1.5", 2e19, 5);
    }

    // e without a digit is an error.
    function testParseLiteralDecimalExponentsError() external {
        checkParseDecimalRevert("e", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    // e with a left digit but not a right digit is an error.
    function testParseLiteralDecimalExponentsError3() external {
        checkParseDecimalRevert("1e", abi.encodeWithSelector(MalformedExponentDigits.selector, 2));
    }

    // e with a right digit but not a left digit is an error.
    // This should never happen in practise as it would be parsed as a word not
    // a literal.
    // Tests e in the 2nd place.
    function testParseLiteralDecimalExponentsError4() external {
        checkParseDecimalRevert("e0", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    // e with a right digit but not a left digit is an error.
    // This should never happen in practise as it would be parsed as a word not
    // a literal.
    // Tests e in the 3rd place.
    function testParseLiteralDecimalExponentsError5() external {
        checkParseDecimalRevert("e00", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    /// Dot without digits is an error.
    function testParseLiteralDecimalDotError() external {
        checkParseDecimalRevert(".", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    /// Dot without leading digits is an error.
    function testParseLiteralDecimalDotError2() external {
        checkParseDecimalRevert(".0", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    /// Dot without trailing digits is an error.
    function testParseLiteralDecimalDotError3() external {
        checkParseDecimalRevert("0.", abi.encodeWithSelector(MalformedDecimalPoint.selector, 2));
    }

    /// Dot e is an error.
    function testParseLiteralDecimalDotError4() external {
        checkParseDecimalRevert(".e", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    /// Dot e0 is an error.
    function testParseLiteralDecimalDotError5() external {
        checkParseDecimalRevert(".e0", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    /// e Dot is an error.
    function testParseLiteralDecimalDotError6() external {
        checkParseDecimalRevert("e.", abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
    }

    /// Negative e with no digits is an error.
    function testParseLiteralDecimalNegativeExponentsError() external {
        checkParseDecimalRevert("0.0e-", abi.encodeWithSelector(MalformedExponentDigits.selector, 5));
    }

    /// Large e will cause overflow.
    function testParseLiteralDecimalOverflow() external {
        checkParseDecimalRevert("1.0e100", abi.encodeWithSelector(DecimalLiteralOverflow.selector, 7));
    }

    /// Integer precision loss will revert.
    function testParseLiteralDecimalPrecisionLossInteger() external {
        checkParseDecimalRevert("1.0e-19", abi.encodeWithSelector(DecimalLiteralPrecisionLoss.selector, 7));
    }

    /// Decimal precision loss will revert.
    function testParseLiteralDecimalPrecisionLossDecimal() external {
        checkParseDecimalRevert("1.5e-18", abi.encodeWithSelector(DecimalLiteralPrecisionLoss.selector, 7));
    }

    /// Decimal precision loss will revert. Max zeros.
    function testParseLiteralDecimalPrecisionLossDecimalMax() external {
        checkParseDecimalRevert(
            "1.000000000000000001e-1", abi.encodeWithSelector(DecimalLiteralPrecisionLoss.selector, 23)
        );
    }

    /// Decimal precision loss will revert. No e, just too small.
    function testParseLiteralDecimalPrecisionLossDecimalSmall() external {
        checkParseDecimalRevert(
            "0.0000000000000000001", abi.encodeWithSelector(DecimalLiteralPrecisionLoss.selector, 21)
        );
    }
}
