// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {ExpectedOperand, UnclosedOperand, OperandOverflow, UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

contract LibParseOperandDoublePerByteNoDefaultTest is Test {
    using LibParse for ParseState;

    /// Defaults are not allowed for this operand parser. Tests no operand.
    function testOperandDoublePerByteNoDefaultElided() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c();").parse();
        (bytecode);
        (constants);
    }

    /// Defaults are not allowed for this operand parser. Tests empty operand.
    function testOperandDoublePerByteNoDefaultEmpty() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<>();").parse();
        (bytecode);
        (constants);
    }

    /// Defaults are not allowed for this operand parser. Tests first but not
    /// second operand.
    function testOperandDoublePerByteNoDefaultFirst() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<1>();").parse();
        (bytecode);
        (constants);
    }

    /// 2 literals are expected for this operand parser. Tests 1 2.
    function testOperandDoublePerByteNoDefaultSecond() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<1 2>();").parse();
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
            // c operand 1 2
            hex"04100201"
        );
        assertEq(constants.length, 0);
    }

    /// 2 literals are expected for this operand parser. Tests 0 0.
    function testOperandDoublePerByteNoDefaultSecondZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<0 0>();").parse();
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
            // c operand 0 0
            hex"04100000"
        );
        assertEq(constants.length, 0);
    }

    /// 2 literals are expected for this operand parser. Tests 255 0.
    function testOperandDoublePerByteNoDefaultSecondMaxZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<255 0>();").parse();
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
            // c operand 255 0
            hex"041000ff"
        );
        assertEq(constants.length, 0);
    }

    /// 2 literals are expected for this operand parser. Tests 0 255.
    function testOperandDoublePerByteNoDefaultSecondZeroMax() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<0 255>();").parse();
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
            // c operand 0 255
            hex"0410ff00"
        );
        assertEq(constants.length, 0);
    }

    /// 2 literals are expected for this operand parser. Tests 255 255.
    function testOperandDoublePerByteNoDefaultSecondMax() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<255 255>();").parse();
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
            // c operand 255 255
            hex"0410ffff"
        );
        assertEq(constants.length, 0);
    }

    /// 2 literals are expected for this operand parser. Tests 256 256.
    function testOperandDoublePerByteNoDefaultSecondOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<256 256>();").parse();
        (bytecode);
        (constants);
    }

    /// 2 literals are expected for this operand parser. Tests 256 255.
    function testOperandDoublePerByteNoDefaultSecondOverflowFirst() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<256 255>();").parse();
        (bytecode);
        (constants);
    }

    /// 3 literals is disallowed.
    function testOperandDoublePerByteNoDefaultThird() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<1 2 3>();").parse();
        (bytecode);
        (constants);
    }

    /// Unclosed operand is disallowed.
    function testOperandDoublePerByteNoDefaultUnclosed() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedOperand.selector, 7));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<1 2").parse();
        (bytecode);
        (constants);
    }

    /// Unopened operand is disallowed.
    function testOperandDoublePerByteNoDefaultUnopened() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c>1 2>").parse();
        (bytecode);
        (constants);
    }

    /// Prefix whitespace is allowed.
    function testOperandDoublePerByteNoDefaultPrefixWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c< 1 2>();").parse();
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
            // c operand 1 2
            hex"04100201"
        );
        assertEq(constants.length, 0);
    }

    /// Postfix whitespace is allowed.
    function testOperandDoublePerByteNoDefaultPostfixWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<1 2 >();").parse();
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
            // c operand 1 2
            hex"04100201"
        );
        assertEq(constants.length, 0);
    }

    /// Multiple sequential whitespace is allowed.
    function testOperandDoublePerByteNoDefaultMultipleWhitespace() external {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:c<  1   2   >();").parse();
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
            // c operand 1 2
            hex"04100201"
        );
        assertEq(constants.length, 0);
    }
}
