// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, Operand} from "src/lib/parse/LibParseOperand.sol";
import {ExpectedOperand, UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";

contract LibParseOperandHandleOperandDoublePerByteNoDefaultTest is Test {
    // There must be exactly two values so zero values is an error.
    function testHandleOperandDoublePerByteNoDefaultNoValues() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        LibParseOperand.handleOperandDoublePerByteNoDefault(new uint256[](0));
    }

    // There must be exactly two values so one value is an error.
    function testHandleOperandDoublePerByteNoDefaultOneValue(uint256 value) external {
        value = bound(value, 0, type(uint16).max);
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        LibParseOperand.handleOperandDoublePerByteNoDefault(values);
    }

    // There must be exactly two values so three or more values is an error.
    function testHandleOperandDoublePerByteNoDefaultManyValues(uint256[] memory values) external {
        vm.assume(values.length > 2);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandDoublePerByteNoDefault(values);
    }

    // If the first value is greater than 1 byte, it is an error.
    function testHandleOperandDoublePerByteNoDefaultFirstValueTooLarge(uint256 a, uint256 b) external {
        a = bound(a, uint256(type(uint8).max) + 1, DECIMAL_MAX_SAFE_INT);
        b = bound(b, 0, type(uint8).max);

        // If a is a decimal, scale it above 256 as a decimal.
        if (a >= 1e18) {
            a = bound(a, 256e18, type(uint256).max);
            a = a - (a % 1e18);
        }

        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;

        vm.expectRevert(
            abi.encodeWithSelector(
                IntegerOverflow.selector, LibFixedPointDecimalScale.decimalOrIntToInt(a, DECIMAL_MAX_SAFE_INT), 255
            )
        );
        LibParseOperand.handleOperandDoublePerByteNoDefault(values);
    }

    // If the second value is greater than 1 byte, it is an error.
    function testHandleOperandDoublePerByteNoDefaultSecondValueTooLarge(uint256 a, uint256 b) external {
        a = bound(a, 0, type(uint8).max);
        b = bound(b, uint256(type(uint8).max) + 1, DECIMAL_MAX_SAFE_INT);

        // If b is a decimal, scale it above 256 as a decimal.
        if (b >= 1e18) {
            b = bound(b, 256e18, type(uint256).max);
            b = b - (b % 1e18);
        }

        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        vm.expectRevert(
            abi.encodeWithSelector(
                IntegerOverflow.selector, LibFixedPointDecimalScale.decimalOrIntToInt(b, DECIMAL_MAX_SAFE_INT), 255
            )
        );
        LibParseOperand.handleOperandDoublePerByteNoDefault(values);
    }

    // If both values are within 1 byte, it is not an error, the result is the
    // second value shifted left by 8 bits plus the first value. The rightmost
    // bits of the operand are the first value.
    function testHandleOperandDoublePerByteNoDefaultBothValuesWithinOneByte(uint256 a, uint256 b) external pure {
        a = bound(a, 0, type(uint8).max);
        b = bound(b, 0, type(uint8).max);
        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        assertEq(Operand.unwrap(LibParseOperand.handleOperandDoublePerByteNoDefault(values)), (b << 8) | a);
    }
}
