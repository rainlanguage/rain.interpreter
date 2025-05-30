// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {ExpectedOperand, UnclosedOperand, UnexpectedOperand, UnsupportedLiteralType} from "src/error/ErrParse.sol";
import {LibParse, ExpectedLeftParen} from "src/lib/parse/LibParse.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";

contract LibParseOperandDisallowedTest is Test {
    using LibParse for ParseState;

    function parseExternal(string memory s) external view returns (bytes memory bytecode, bytes32[] memory constants) {
        return LibMetaFixture.newState(s).parse();
    }

    /// Opening an operand is disallowed for words that don't support it.
    function testOperandDisallowed() external {
        vm.expectRevert(abi.encodeWithSelector(UnsupportedLiteralType.selector, 4));
        (bytes memory bytecode, bytes32[] memory constants) = this.parseExternal("_:a<;");
        (bytecode);
        (constants);
    }

    /// Closing an operand is disallowed for words that don't support it.
    function testOperandDisallowed1() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedLeftParen.selector, 3));
        (bytes memory bytecode, bytes32[] memory constants) = this.parseExternal("_:a>;");
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand with a literal is disallowed for words
    /// that don't support it.
    function testOperandDisallowed3() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, bytes32[] memory constants) = this.parseExternal("_:a<1>;");
        (bytecode);
        (constants);
    }

    /// Opening and closing an operand with a literal and valid parens is
    /// disallowed for words that don't support it.
    function testOperandDisallowed4() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        (bytes memory bytecode, bytes32[] memory constants) = this.parseExternal("_:a<1>();");
        (bytecode);
        (constants);
    }
}
