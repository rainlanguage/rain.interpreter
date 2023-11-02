// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {OperandOverflow, UnclosedOperand} from "src/lib/parse/LibParseOperand.sol";
import {ParserOutOfBounds, LibParse, ExpectedLeftParen} from "src/lib/parse/LibParse.sol";
import {OperandTest} from "test/util/abstract/OperandTest.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";

contract LibParseOperandM1M1Test is OperandTest {
    /// Default is zero for this operand parser. Tests no operand.
    function testOperandM1M1Elided() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d();", LibMetaFixture.parseMeta());
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
            // d operand 0 0
            hex"05000000"
        );
        assertEq(constants.length, 0);
    }

    /// Default is zero for this operand parser. Tests empty operand.
    function testOperandM1M1Empty() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<>();", LibMetaFixture.parseMeta());
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
            // d operand 0 0
            hex"05000000"
        );
        assertEq(constants.length, 0);
    }

    /// Default is zero for this operand parser. Tests first but not second operand.
    function testOperandM1M1First() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<1>();", LibMetaFixture.parseMeta());
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
            // d operand 1 0
            hex"05000001"
        );
        assertEq(constants.length, 0);
    }

    /// Default is zero for this operand parser. Tests first overflow.
    function testOperandM1M1FirstOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector, 4));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<2>();", LibMetaFixture.parseMeta());
        (bytecode);
        (constants);
    }

    /// Default is zero for this operand parser. Tests 0 1.
    function testOperandM1M1Second() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<0 1>();", LibMetaFixture.parseMeta());
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
            // d operand 0 1
            hex"05000002"
        );
        assertEq(constants.length, 0);
    }

    /// Default is zero for this operand parser. Tests 0 0.
    function testOperandM1M1SecondZero() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<0 0>();", LibMetaFixture.parseMeta());
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
            // d operand 0 0
            hex"05000000"
        );
        assertEq(constants.length, 0);
    }

    /// Default is zero for this operand parser. Tests 0 2.
    function testOperandM1M1SecondOverflow() external {
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector, 6));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<0 2>();", LibMetaFixture.parseMeta());
        (bytecode);
        (constants);
    }

    /// Default is zero for this operand parser. Tests 1 1.
    function testOperandM1M1Both() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:d<1 1>();", LibMetaFixture.parseMeta());
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
            // d operand 1 1
            hex"05000003"
        );
        assertEq(constants.length, 0);
    }

    /// Default is zero for this operand parser. Tests 1 1 0.
    function testOperandM1M1BothZero() external {
        checkParseError("_:d<1 1 0>();", abi.encodeWithSelector(UnclosedOperand.selector, 8));
    }

    /// Unclosed operand is disallowed.
    function testOperandM1M1Unclosed() external {
        checkParseError("_:d<1 1();", abi.encodeWithSelector(UnclosedOperand.selector, 7));
        checkParseError("_:d<1 0()", abi.encodeWithSelector(UnclosedOperand.selector, 7));
        checkParseError("_:d<1 ", abi.encodeWithSelector(ParserOutOfBounds.selector));
        checkParseError("_:d<1", abi.encodeWithSelector(ParserOutOfBounds.selector));
        checkParseError("_:d<1 1", abi.encodeWithSelector(UnclosedOperand.selector, 7));
    }

    /// Unopened operand is disallowed.
    function testOperandM1M1Unopened() external {
        checkParseError("_:d>1 1>();", abi.encodeWithSelector(ExpectedLeftParen.selector, 3));
    }
}
