// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, Operand} from "src/lib/parse/LibParseOperand.sol";
import {UnexpectedOperandValue, IntegerOverflow} from "src/error/ErrParse.sol";

contract LibParseOperandHandleOperandSingleFullTest is Test {
    // No values falls back to zero.
    function testHandleOperandSingleFullNoValues() external {
        assertEq(Operand.unwrap(LibParseOperand.handleOperandSingleFull(new uint256[](0))), 0);
    }

    // A single value of up to 2 bytes is allowed.
    function testHandleOperandSingleFullSingleValue(uint256 value) external {
        value = bound(value, 0, type(uint16).max);
        uint256 valueScaled = value * 1e18;
        uint256[] memory values = new uint256[](1);
        values[0] = valueScaled;
        assertEq(Operand.unwrap(LibParseOperand.handleOperandSingleFull(values)), value);
    }

    // Single values outside 2 bytes are disallowed.
    function testHandleOperandSingleFullSingleValueDisallowed(uint256 value) external {
        value = bound(value, uint256(type(uint16).max) + 1, type(uint256).max / 1e18);
        value *= 1e18;
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        vm.expectRevert(abi.encodeWithSelector(IntegerOverflow.selector));
        LibParseOperand.handleOperandSingleFull(values);
    }

    // More than one value is disallowed.
    function testHandleOperandSingleFullManyValues(uint256[] memory values) external {
        vm.assume(values.length > 1);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandSingleFull(values);
    }
}
