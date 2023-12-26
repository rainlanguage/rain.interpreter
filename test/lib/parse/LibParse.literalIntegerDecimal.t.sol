// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";

import {DecimalLiteralOverflow} from "src/lib/parse/LibParseLiteral.sol";
import {LibParse, UnexpectedRHSChar, UnexpectedRightParen} from "src/lib/parse/LibParse.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

/// @title LibParseLiteralIntegerDecimalTest
/// Tests parsing integer literal decimal values.
contract LibParseLiteralIntegerDecimalTest is Test {
    using LibParse for ParseState;

    /// Check a single decimal literal. Should not revert and return length 1
    /// sources and constants.
    function testParseIntegerLiteralDecimal00() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_: 1;").parse();
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // constant 0
            hex"01000000"
        );

        assertEq(constants.length, 1);
        assertEq(constants[0], 1);
    }

    /// Check 2 decimal literals. Should not revert and return one source and
    /// length 2 constants.
    function testParseIntegerLiteralDecimal01() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_ _: 10 25;").parse();
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 2);

        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 2 ops
            hex"02"
            // 2 stack allocation
            hex"02"
            // 0 inputs
            hex"00"
            // 2 outputs
            hex"02"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
        );

        assertEq(constants.length, 2);
        assertEq(constants[0], 10);
        assertEq(constants[1], 25);
    }

    /// Check 3 decimal literals with 2 dupes. Should dedupe and respect ordering.
    function testParseIntegerLiteralDecimal02() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_ _ _: 11 233 11;").parse();
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 3);

        // Sources represents all 3 literals, but the dupe is deduped so that the
        // operands only reference the first instance of the duped constant.
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 3 ops
            hex"03"
            // 3 stack allocation
            hex"03"
            // 0 inputs
            hex"00"
            // 3 outputs
            hex"03"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
            // constant 0
            hex"01000000"
        );
        assertEq(constants.length, 2);
        assertEq(constants[0], 11);
        assertEq(constants[1], 233);
    }

    /// Check that we can parse uint256 max int in decimal form.
    function testParseIntegerLiteralDecimalUint256Max() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState(
            "_: 115792089237316195423570985008687907853269984665640564039457584007913129639935;"
        ).parse();
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // constant 0
            hex"01000000"
        );

        assertEq(constants.length, 1);
        assertEq(constants[0], type(uint256).max);
    }

    /// Check that we can parse uint256 max int in decimal form with leading
    /// zeros.
    function testParseIntegerLiteralDecimalUint256MaxLeadingZeros() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState(
            "_: 000115792089237316195423570985008687907853269984665640564039457584007913129639935;"
        ).parse();
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // constant 0
            hex"01000000"
        );
        assertEq(constants.length, 1);
        assertEq(constants[0], type(uint256).max);
    }

    /// Check that decimal literals will revert if they overflow uint256.
    function testParseIntegerLiteralDecimalUint256Overflow() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState(
            "_: 115792089237316195423570985008687907853269984665640564039457584007913129639936;"
        ).parse();
        (bytecode);
        (constants);
    }

    /// Check that decimal literals will revert if they overflow uint256 with
    /// leading zeros.
    function testParseIntegerLiteralDecimalUint256OverflowLeadingZeros() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 5));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState(
            "_: 00115792089237316195423570985008687907853269984665640564039457584007913129639936;"
        ).parse();
        (bytecode);
        (constants);
    }

    // Check that decimal literals will revert if they overflow uint256 with
    // a non-one leading digit.
    function testParseIntegerLiteralDecimalUint256OverflowLeadingDigit() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState(
            "_: 215792089237316195423570985008687907853269984665640564039457584007913129639935;"
        ).parse();
        (bytecode);
        (constants);
    }

    /// Check that decimal literals will revert if they overflow uint256 with
    /// a non-one leading digit and leading zeros.
    function testParseIntegerLiteralDecimalUint256OverflowLeadingDigitLeadingZeros() external {
        vm.expectRevert(abi.encodeWithSelector(DecimalLiteralOverflow.selector, 5));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState(
            "_: 00215792089237316195423570985008687907853269984665640564039457584007913129639935;"
        ).parse();
        (bytecode);
        (constants);
    }

    /// Check that e notation works.
    function testParseIntegerLiteralDecimalENotation() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibMetaFixture.newState("_ _ _ _ _: 1e2 10e2 1e30 1e18 1001e15;").parse();
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 5);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 5);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 5);

        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 5 ops
            hex"05"
            // 5 stack allocation
            hex"05"
            // 0 inputs
            hex"00"
            // 5 outputs
            hex"05"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
            // constant 2
            hex"01000002"
            // constant 3
            hex"01000003"
            // constant 4
            hex"01000004"
        );

        assertEq(constants.length, 5);
        assertEq(constants[0], 1e2);
        assertEq(constants[1], 10e2);
        assertEq(constants[2], 1e30);
        assertEq(constants[3], 1e18);
        assertEq(constants[4], 1001e15);
    }

    /// Check that decimals cause yang.
    function testParseIntegerLiteralDecimalYang() external {
        // The second e will happily be parsed up to by the internal bounds logic
        // but the parser will be in a state of yang, unable to receive the next
        // non-yin char.
        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 5));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:1e0e;").parse();
        (bytecode);
        (constants);
    }

    /// Check that decimals cannot be used with parens as they are literals not
    /// words. This tests left paren.
    function testParseIntegerLiteralDecimalParensLeft() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:1(;").parse();
        (bytecode);
        (constants);
    }

    /// Check that decimals cannot be used with parens as they are literals not
    /// words. This tests right paren.
    function testParseIntegerLiteralDecimalParensRight() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedRightParen.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:1);").parse();
        (bytecode);
        (constants);
    }

    /// Check that decimals cannot be used with parens as they are literals not
    /// words. This tests both parens.
    function testParseIntegerLiteralDecimalParensBoth() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:1();").parse();
        (bytecode);
        (constants);
    }
}
