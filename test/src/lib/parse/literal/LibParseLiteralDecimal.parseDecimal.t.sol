// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteral, ZeroLengthDecimal} from "src/lib/parse/literal/LibParseLiteral.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibParseLiteralDecimal} from "src/lib/parse/literal/LibParseLiteralDecimal.sol";
import {MalformedExponentDigits} from "src/error/ErrParse.sol";
import {console2} from "forge-std/console2.sol";

/// @title LibParseLiteralDecimalTest
/// Tests parsing decimal literal values with the LibParseLiteral library.
contract LibParseLiteralDecimalTest is Test {
    using LibBytes for bytes;
    using LibParseLiteral for ParseState;
    using LibParseLiteralDecimal for ParseState;

    function checkParseDecimal(string memory data, uint256 expectedValue, uint256 expectedCursorAfter) internal {
        ParseState memory state = LibParseState.newState(bytes(data), "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        (uint256 cursorAfter, uint256 value) = state.parseDecimal(cursor, Pointer.unwrap(state.data.endDataPointer()));
        assertEq(cursorAfter - cursor, expectedCursorAfter);
        assertEq(value, expectedValue);
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
    function testParseLiteralDecimalRoundTrip(uint256 value) external {
        string memory valueStr = Strings.toString(value);
        checkParseDecimal(valueStr, value, bytes(valueStr).length);
    }

    /// Check some specific examples.
    function testParseLiteralDecimalSpecific() external {
        checkParseDecimal("0", 0, 1);
        checkParseDecimal("1", 1, 1);
        checkParseDecimal("2", 2, 1);
        checkParseDecimal("3", 3, 1);
        checkParseDecimal("4", 4, 1);
        checkParseDecimal("5", 5, 1);
        checkParseDecimal("6", 6, 1);
        checkParseDecimal("7", 7, 1);
        checkParseDecimal("8", 8, 1);
        checkParseDecimal("9", 9, 1);
        checkParseDecimal("10", 10, 2);
    }

    /// Check some examples of decimals.
    function testParseLiteralDecimalDecimals() external {
        checkParseDecimal("0.0", 0, 3);
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
    function testParseLiteralDecimalExponents() external {
        checkParseDecimal("0e0", 0, 3);
        checkParseDecimal("1e0", 1, 3);
        checkParseDecimal("2e0", 2, 3);
        checkParseDecimal("3e0", 3, 3);
        checkParseDecimal("4e0", 4, 3);
        checkParseDecimal("5e0", 5, 3);
        checkParseDecimal("6e0", 6, 3);
        checkParseDecimal("7e0", 7, 3);
        checkParseDecimal("8e0", 8, 3);
        checkParseDecimal("9e0", 9, 3);
        checkParseDecimal("10e0", 10, 4);

        checkParseDecimal("0e1", 0, 3);
        checkParseDecimal("1e1", 10, 3);
        checkParseDecimal("2e1", 20, 3);
        checkParseDecimal("3e1", 30, 3);
        checkParseDecimal("4e1", 40, 3);
        checkParseDecimal("5e1", 50, 3);
        checkParseDecimal("6e1", 60, 3);
        checkParseDecimal("7e1", 70, 3);
        checkParseDecimal("8e1", 80, 3);
        checkParseDecimal("9e1", 90, 3);
        checkParseDecimal("10e1", 100, 4);

        checkParseDecimal("0e2", 0, 3);
        checkParseDecimal("1e2", 100, 3);
        checkParseDecimal("2e2", 200, 3);
        checkParseDecimal("3e2", 300, 3);
        checkParseDecimal("4e2", 400, 3);
        checkParseDecimal("5e2", 500, 3);
        checkParseDecimal("6e2", 600, 3);
        checkParseDecimal("7e2", 700, 3);
        checkParseDecimal("8e2", 800, 3);
        checkParseDecimal("9e2", 900, 3);
        checkParseDecimal("10e2", 1000, 4);
    }

    /// Check some examples of exponents.
    /// Checks e in the 3rd position.
    function testParseLiteralDecimalExponents2() external {
        checkParseDecimal("0e00", 0, 4);
        checkParseDecimal("1e00", 1, 4);
        checkParseDecimal("2e00", 2, 4);
        checkParseDecimal("3e00", 3, 4);
        checkParseDecimal("4e00", 4, 4);
        checkParseDecimal("5e00", 5, 4);
        checkParseDecimal("6e00", 6, 4);
        checkParseDecimal("7e00", 7, 4);
        checkParseDecimal("8e00", 8, 4);
        checkParseDecimal("9e00", 9, 4);
        checkParseDecimal("10e00", 10, 5);

        checkParseDecimal("0e01", 0, 4);
        checkParseDecimal("1e01", 10, 4);
        checkParseDecimal("2e01", 20, 4);
        checkParseDecimal("3e01", 30, 4);
        checkParseDecimal("4e01", 40, 4);
        checkParseDecimal("5e01", 50, 4);
        checkParseDecimal("6e01", 60, 4);
        checkParseDecimal("7e01", 70, 4);
        checkParseDecimal("8e01", 80, 4);
        checkParseDecimal("9e01", 90, 4);
        checkParseDecimal("10e01", 100, 5);

        checkParseDecimal("0e02", 0, 4);
        checkParseDecimal("1e02", 100, 4);
        checkParseDecimal("2e02", 200, 4);
        checkParseDecimal("3e02", 300, 4);
        checkParseDecimal("4e02", 400, 4);
        checkParseDecimal("5e02", 500, 4);
        checkParseDecimal("6e02", 600, 4);
        checkParseDecimal("7e02", 700, 4);
        checkParseDecimal("8e02", 800, 4);
        checkParseDecimal("9e02", 900, 4);
        checkParseDecimal("10e02", 1000, 5);

        checkParseDecimal("0e10", 0, 4);
        checkParseDecimal("1e10", 1e10, 4);
        checkParseDecimal("2e10", 2e10, 4);
        checkParseDecimal("3e10", 3e10, 4);
        checkParseDecimal("4e10", 4e10, 4);
        checkParseDecimal("5e10", 5e10, 4);
        checkParseDecimal("6e10", 6e10, 4);
        checkParseDecimal("7e10", 7e10, 4);
        checkParseDecimal("8e10", 8e10, 4);
        checkParseDecimal("9e10", 9e10, 4);
        checkParseDecimal("10e10", 10e10, 5);
    }

    // e without a digit is an error.
    function testParseLiteralDecimalExponentsError() external {
        ParseState memory state = LibParseState.newState("e", "", "", "");
        vm.expectRevert(abi.encodeWithSelector(ZeroLengthDecimal.selector, 0));
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }

    // // e with more than 2 digits is an error.
    // function testParseLiteralDecimalExponentsError2() external {
    //     ParseState memory state = LibParseState.newState("1e000", "", "", "");
    //     vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
    //     (uint256 cursorAfter, uint256 value) =
    //         state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
    //     (cursorAfter, value);
    // }

    // e with a left digit but not a right digit is an error.
    function testParseLiteralDecimalExponentsError3() external {
        ParseState memory state = LibParseState.newState("1e", "", "", "");
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }

    // e with a right digit but not a left digit is an error.
    // This should never happen in practise as it would be parsed as a word not
    // a literal.
    // Tests e in the 2nd place.
    function testParseLiteralDecimalExponentsError4() external {
        ParseState memory state = LibParseState.newState("e0", "", "", "");
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 0));
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }

    // e with a right digit but not a left digit is an error.
    // This should never happen in practise as it would be parsed as a word not
    // a literal.
    // Tests e in the 3rd place.
    function testParseLiteralDecimalExponentsError5() external {
        ParseState memory state = LibParseState.newState("e00", "", "", "");
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 0));
        (uint256 cursorAfter, uint256 value) =
            state.parseDecimal(Pointer.unwrap(state.data.dataPointer()), Pointer.unwrap(state.data.endDataPointer()));
        (cursorAfter, value);
    }
}
