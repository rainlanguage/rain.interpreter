// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "rain.solmem/lib/LibPointer.sol";
import "rain.solmem/lib/LibBytes.sol";
import "src/lib/parse/LibParseLiteral.sol";

/// @title LibParseLiteralBoundLiteralDecimalTest
/// Tests finding bounds for literal decimal values by parsing.
contract LibParseLiteralBoundLiteralDecimalTest is Test {
    using LibBytes for bytes;

    /// Check that an empty string is not treated as a literal.
    function testParseLiteralBoundLiteralDecimalEmpty() external {
        bytes memory data = "";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, 0));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit is bounded as a decimal literal.
    function testParseLiteralBoundLiteralDecimalZero() external {
        string[10] memory datas = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
        for (uint256 i = 0; i < datas.length; i++) {
            bytes memory data = bytes(datas[i]);
            uint256 outerStart = Pointer.unwrap(data.dataPointer());
            (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
                LibParseLiteral.boundLiteral(data, outerStart);
            assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
            assertEq(innerStart, outerStart);
            assertEq(innerEnd, outerStart + 1);
            assertEq(outerEnd, outerStart + 1);
        }
    }

    /// Check that "e" or "E" in isolation is not treated as a literal.
    function testParseLiteralBoundLiteralDecimalE() external {
        bytes memory data = "e";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, 0));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);

        data = "E";
        outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, 0));
        (literalType, innerStart, innerEnd, outerEnd) = LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroE() external {
        bytes memory data = "0e";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEUpper() external {
        bytes memory data = "0E";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e+" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlus() external {
        bytes memory data = "0e+";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E+" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusUpper() external {
        bytes memory data = "0E+";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e-" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinus() external {
        bytes memory data = "0e-";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E-" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusUpper() external {
        bytes memory data = "0E-";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e+1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusOne() external {
        bytes memory data = "0e+1";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E+1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusOneUpper() external {
        bytes memory data = "0E+1";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e-1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusOne() external {
        bytes memory data = "0e-1";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E-1" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusOneUpper() external {
        bytes memory data = "0E-1";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e+01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusZeroOne() external {
        bytes memory data = "0e+01";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E+01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusZeroOneUpper() external {
        bytes memory data = "0E+01";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "e-01" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEMinusZeroOne() external {
        bytes memory data = "0e-01";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a single digit followed by "E+10" is treated as malformed.
    function testParseLiteralBoundLiteralDecimalZeroEPlusTen() external {
        bytes memory data = "0E+10";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 1));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check a decimal with "e" followed by three digits is treated as
    /// malformed.
    function testParseLiteralBoundLiteralDecimalEPlusThreeDigits() external {
        bytes memory data = "01e123";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 2));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check a decimal with "E" followed by three digits is treated as
    /// malformed.
    function testParseLiteralBoundLiteralDecimalEPlusThreeDigitsUpper() external {
        bytes memory data = "01E123";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 2));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check a decimal with "e" followed by four digits is treated as malformed.
    function testParseLiteralBoundLiteralDecimalEPlusFourDigits() external {
        bytes memory data = "01e1234";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 2));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check a decimal with "E" followed by four digits is treated as malformed.
    function testParseLiteralBoundLiteralDecimalEPlusFourDigitsUpper() external {
        bytes memory data = "01E1234";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        vm.expectRevert(abi.encodeWithSelector(MalformedExponentDigits.selector, 2));
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        (literalType);
        (innerStart);
        (innerEnd);
        (outerEnd);
    }

    /// Check that a string with multiple e/E only bounds the first.
    function testParseLiteralBoundLiteralDecimalMultipleE() external {
        bytes memory data = "0e0e0";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
        assertEq(innerStart, outerStart);
        assertEq(innerEnd, outerStart + 3);
        assertEq(outerEnd, outerStart + 3);

        data = "0E0E0";
        outerStart = Pointer.unwrap(data.dataPointer());
        (literalType, innerStart, innerEnd, outerEnd) = LibParseLiteral.boundLiteral(data, outerStart);
        assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
        assertEq(innerStart, outerStart);
        assertEq(innerEnd, outerStart + 3);
        assertEq(outerEnd, outerStart + 3);
    }

    /// Check that a string with non digit characters after the first exponent
    /// digit is handled correctly (bounds up to the first exponent digit).
    function testParseLiteralBoundLiteralDecimalNonDigitAfterFirstExponent() external {
        bytes memory data = "0e0ze0";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
        assertEq(innerStart, outerStart);
        assertEq(innerEnd, outerStart + 3);
        assertEq(outerEnd, outerStart + 3);

        data = "0E0ZE0";
        outerStart = Pointer.unwrap(data.dataPointer());
        (literalType, innerStart, innerEnd, outerEnd) = LibParseLiteral.boundLiteral(data, outerStart);
        assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
        assertEq(innerStart, outerStart);
        assertEq(innerEnd, outerStart + 3);
        assertEq(outerEnd, outerStart + 3);
    }

    /// Check that a string with non digit characters after the second exponent
    /// digit is handled correctly (bounds up to the second exponent digit).
    function testParseLiteralBoundLiteralDecimalNonDigitAfterExponent() external {
        bytes memory data = "0e00ze0";
        uint256 outerStart = Pointer.unwrap(data.dataPointer());
        (uint256 literalType, uint256 innerStart, uint256 innerEnd, uint256 outerEnd) =
            LibParseLiteral.boundLiteral(data, outerStart);
        assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
        assertEq(innerStart, outerStart);
        assertEq(innerEnd, outerStart + 4);
        assertEq(outerEnd, outerStart + 4);

        data = "0E00ZE0";
        outerStart = Pointer.unwrap(data.dataPointer());
        (literalType, innerStart, innerEnd, outerEnd) = LibParseLiteral.boundLiteral(data, outerStart);
        assertEq(literalType, LITERAL_TYPE_INTEGER_DECIMAL);
        assertEq(innerStart, outerStart);
        assertEq(innerEnd, outerStart + 4);
        assertEq(outerEnd, outerStart + 4);
    }
}
