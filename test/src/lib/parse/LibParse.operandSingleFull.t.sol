// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {ExpectedOperand, UnclosedOperand, OperandOverflow, UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParse, ExpectedLeftParen} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

contract LibParseOperandSingleFullTest is Test {
    using LibParse for ParseState;

    /// Fallback is 0 for elided single full operand.
    function testOperandSingleFullElided() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 0 operand
            hex"03100000"
        );
        assertEq(constants.length, 0);
    }

    /// Empty operand is allowed.
    function testOperandSingleFullEmpty() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 0 operand
            hex"03100000"
        );
        assertEq(constants.length, 0);
    }

    /// Multiple operands are disallowed.
    function testOperandSingleFullMultiple() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0x00 0x01>();").parse();
        (bytecode);
        (constants);
    }

    /// Can provide decimal integer 0 as single full operand.
    function testOperandSingleFullZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 0 operand
            hex"03100000"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide hexadecimal 0x00 as a single full operand.
    function testOperandSingleFullHexZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0x00>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 0 operand
            hex"03100000"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide decimal 1 as single full operand.
    function testOperandSingleFullOne() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<1>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 1 operand
            hex"03100001"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide hexadecimal 0x01 as a single full operand.
    function testOperandSingleFullHexOne() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0x01>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 1 operand
            hex"03100001"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide decimal uint16 max as single full operand.
    function testOperandSingleFullUint16Max() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<65535>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 65535 operand
            hex"0310ffff"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide hexadecimal uint16 max as a single full operand.
    function testOperandSingleFullHexUint16Max() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0xffff>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 65535 operand
            hex"0310ffff"
        );
        assertEq(constants.length, 0);
    }

    /// Overflowing decimal uint16 max as single full operand reverts.
    function testOperandSingleFullUint16MaxOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<65536>();").parse();
        (bytecode);
        (constants);
    }

    /// Overflowing hexadecimal uint16 max as a single full operand reverts.
    function testOperandSingleFullHexUint16MaxOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0x010000>();").parse();
        (bytecode);
        (constants);
    }

    /// Opening angle bracket without closing angle bracket reverts.
    function testOperandSingleFullUnclosed() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedOperand.selector, 5));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<0;").parse();
        (bytecode);
        (constants);
    }

    /// Closing angle bracket without opening angle bracket reverts.
    function testOperandSingleFullUnopened() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedLeftParen.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b>0>;").parse();
        (bytecode);
        (constants);
    }

    /// Leading whitespace in the operand is supported.
    function testOperandSingleFullLeadingWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b< 5>();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 5 operand
            hex"03100005"
        );
        assertEq(constants.length, 0);
    }

    /// Trailing whitespace in the operand is supported.
    function testOperandSingleFullTrailingWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b<5 >();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 5 operand
            hex"03100005"
        );
        assertEq(constants.length, 0);
    }

    /// Leading and trailing whitespace in the operand is supported.
    function testOperandSingleFullLeadingAndTrailingWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:b< 0x05 >();").parse();
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 length
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 outputs
            hex"01"
            // b 5 operand
            hex"03100005"
        );
        assertEq(constants.length, 0);
    }
}
