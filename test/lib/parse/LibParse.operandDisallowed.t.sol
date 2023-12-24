// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {ExpectedOperand, UnclosedOperand, UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibParse, ExpectedLeftParen} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";

contract LibParseOperandDisallowedTest is Test {
    /// Opening an operand is disallowed for words that don't support it.
    function testOperandDisallowed() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:a<;", LibMetaFixture.parseMetaV2());
        (bytecode);
        (constants);
    }

    /// Closing an operand is disallowed for words that don't support it.
    function testOperandDisallowed1() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedLeftParen.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:a>;", LibMetaFixture.parseMetaV2());
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand is disallowed for words that don't support
    /// it.
    function testOperandDisallowed2() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:a<>;", LibMetaFixture.parseMetaV2());
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand with a literal is disallowed for words
    /// that don't support it.
    function testOperandDisallowed3() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:a<1>;", LibMetaFixture.parseMetaV2());
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand with a literal and valid parens is
    /// disallowed for words that don't support it.
    function testOperandDisallowed4() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector, 3));
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:a<1>();", LibMetaFixture.parseMetaV2());
        (bytecode);
        (constants);
    }
}
