// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, Operand} from "src/lib/parse/LibParseOperand.sol";
import {UnexpectedOperandValue, OperandOverflow, ExpectedOperand} from "src/error/ErrParse.sol";

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
        value = bound(value, uint256(type(uint16).max) + 1, type(uint256).max);
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperandSingleFullNoDefault(values);
    }

    // More than one value is disallowed.
    function testHandleOperandSingleFullNoDefaultManyValues(uint256[] memory values) external {
        vm.assume(values.length > 1);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandSingleFullNoDefault(values);
    }
}
