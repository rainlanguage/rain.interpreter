// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, Operand} from "src/lib/parse/LibParseOperand.sol";
import {UnexpectedOperandValue, ExpectedOperand} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {IntegerOverflow} from "rain.math.fixedpoint/error/ErrScale.sol";
import {LibFixedPointDecimalScale, DECIMAL_MAX_SAFE_INT} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

contract LibParseOperandHandleOperandSingleFullTest is Test {
    // No values errors.
    function testHandleOperandSingleFullNoDefaultNoValues() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        Operand.unwrap(LibParseOperand.handleOperandSingleFullNoDefault(new uint256[](0)));
    }

    // A single value of up to 2 bytes is allowed.
    function testHandleOperandSingleFullNoDefaultSingleValue(uint256 value) external {
        value = bound(value, 0, type(uint16).max);
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        assertEq(Operand.unwrap(LibParseOperand.handleOperandSingleFullNoDefault(values)), value);
    }

    // Single values outside 2 bytes are disallowed.
    function testHandleOperandSingleFullSingleValueNoDefaultDisallowed(uint256 value) external {
        value = bound(value, uint256(type(uint16).max) + 1, DECIMAL_MAX_SAFE_INT);
        value = value * 1e18;

        // If value is a decimal, scale it above 256 as a decimal.
        if (value >= 1e18) {
            value = bound(value, 256e18, type(uint256).max);
            value = value - (value % 1e18);
        }

        uint256[] memory values = new uint256[](1);
        values[0] = value;
        vm.expectRevert(
            abi.encodeWithSelector(
                IntegerOverflow.selector,
                LibFixedPointDecimalScale.decimalOrIntToInt(value, DECIMAL_MAX_SAFE_INT),
                0xFFFF
            )
        );
        LibParseOperand.handleOperandSingleFullNoDefault(values);
    }

    // More than one value is disallowed.
    function testHandleOperandSingleFullNoDefaultManyValues(uint256[] memory values) external {
        vm.assume(values.length > 1);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandSingleFullNoDefault(values);
    }
}
