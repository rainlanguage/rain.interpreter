// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, OperandV2} from "src/lib/parse/LibParseOperand.sol";
import {UnexpectedOperandValue, ExpectedOperand} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";

contract LibParseOperandHandleOperandSingleFullTest is Test {
    // No values errors.
    function testHandleOperandSingleFullNoDefaultNoValues() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        OperandV2.unwrap(LibParseOperand.handleOperandSingleFullNoDefault(new bytes32[](0)));
    }

    // A single value of up to 2 bytes is allowed.
    function testHandleOperandSingleFullNoDefaultSingleValue(uint256 value) external pure {
        value = bound(value, 0, type(uint16).max);
        bytes32[] memory values = new bytes32[](1);
        values[0] = bytes32(value);
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandSingleFullNoDefault(values)), bytes32(value));
    }

    // Single values outside 2 bytes are disallowed.
    function testHandleOperandSingleFullSingleValueNoDefaultDisallowed(uint256 value) external {
        value = bound(value, uint256(type(uint16).max) + 1, uint256(int256(type(int128).max)));

        bytes32[] memory values = new bytes32[](1);
        values[0] = bytes32(value);
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperandSingleFullNoDefault(values);
    }

    // More than one value is disallowed.
    function testHandleOperandSingleFullNoDefaultManyValues(bytes32[] memory values) external {
        vm.assume(values.length > 1);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandSingleFullNoDefault(values);
    }
}
