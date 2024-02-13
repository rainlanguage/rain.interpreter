// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {ExpectedOperand, UnclosedOperand, UnexpectedOperand, UnsupportedLiteralType} from "src/error/ErrParse.sol";
import {LibParse, ExpectedLeftParen} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

contract LibParseOperandDisallowedTest is Test {
    using LibParse for ParseState;

    /// Opening an operand is disallowed for words that don't support it.
    function testOperandDisallowed() external {
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, 4));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:a<;").parse();
        (bytecode);
        (constants);
    }

    /// Closing an operand is disallowed for words that don't support it.
    function testOperandDisallowed1() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedLeftParen.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:a>;").parse();
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand with a literal is disallowed for words
    /// that don't support it.
    function testOperandDisallowed3() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:a<1>;").parse();
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand with a literal and valid parens is
    /// disallowed for words that don't support it.
    function testOperandDisallowed4() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("_:a<1>();").parse();
        (bytecode);
        (constants);
    }
}
