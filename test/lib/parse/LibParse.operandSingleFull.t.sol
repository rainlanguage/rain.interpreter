// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "test/util/lib/parse/LibMetaFixture.sol";

contract LibParseOperandSingleFullTest is Test {
    /// Fallback is 0 for elided single full operand.
    function testOperandSingleFullElided() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b();", LibMetaFixture.parseMeta());
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
            hex"03000000"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide decimal 0 as single full operand.
    function testOperandSingleFullZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b<0>();", LibMetaFixture.parseMeta());
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
            hex"03000000"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide hexadecimal 0x00 as a single full operand.
    function testOperandSingleFullHexZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b<0x00>();", LibMetaFixture.parseMeta());
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
            hex"03000000"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide decimal 1 as single full operand.
    function testOperandSingleFullOne() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b<1>();", LibMetaFixture.parseMeta());
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
            hex"03000001"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide hexadecimal 0x01 as a single full operand.
    function testOperandSingleFullHexOne() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b<0x01>();", LibMetaFixture.parseMeta());
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
            hex"03000001"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide decimal uint16 max as single full operand.
    function testOperandSingleFullUint16Max() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_:b<65535>();", LibMetaFixture.parseMeta());
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
            hex"0300ffff"
        );
        assertEq(constants.length, 0);
    }

    /// Can provide hexadecimal uint16 max as a single full operand.
    function testOperandSingleFullHexUint16Max() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_:b<0xffff>();", LibMetaFixture.parseMeta());
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
            hex"0300ffff"
        );
        assertEq(constants.length, 0);
    }

    /// Overflowing decimal uint16 max as single full operand reverts.
    function testOperandSingleFullUint16MaxOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector, 4));
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_:b<65536>();", LibMetaFixture.parseMeta());
        (bytecode);
        (constants);
    }

    /// Overflowing hexadecimal uint16 max as a single full operand reverts.
    function testOperandSingleFullHexUint16MaxOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector, 4));
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_:b<0x010000>();", LibMetaFixture.parseMeta());
        (bytecode);
        (constants);
    }

    /// Opening angle bracket without closing angle bracket reverts.
    function testOperandSingleFullUnclosed() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedOperand.selector, 5));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b<0;", LibMetaFixture.parseMeta());
        (bytecode);
        (constants);
    }

    /// Closing angle bracket without opening angle bracket reverts.
    function testOperandSingleFullUnopened() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedLeftParen.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b>0>;", LibMetaFixture.parseMeta());
        (bytecode);
        (constants);
    }

    /// Leading whitespace in the operand is supported.
    function testOperandSingleFullLeadingWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b< 5>();", LibMetaFixture.parseMeta());
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
            hex"03000005"
        );
        assertEq(constants.length, 0);
    }

    /// Trailing whitespace in the operand is supported.
    function testOperandSingleFullTrailingWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:b<5 >();", LibMetaFixture.parseMeta());
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
            hex"03000005"
        );
        assertEq(constants.length, 0);
    }

    /// Leading and trailing whitespace in the operand is supported.
    function testOperandSingleFullLeadingAndTrailingWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_:b< 0x05 >();", LibMetaFixture.parseMeta());
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
            hex"03000005"
        );
        assertEq(constants.length, 0);
    }
}
