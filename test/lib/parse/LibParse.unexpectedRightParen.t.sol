// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";

import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {UnexpectedRightParen} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/LibParseLiteral.sol";

/// @title LibParseUnexpectedRightParenTest
/// Test that the parser errors when it encounters an unexpected right paren.
contract LibParseUnexpectedRightParenTest is Test {
    using LibParse for ParseState;

    /// Check the parser reverts if it encounters an unexpected right paren.
    function testParseUnexpectedRightParen() external {
        string memory str = ":)";
        ParseState memory state = LibParseState.newState(
            bytes(str),
            LibMetaFixture.parseMetaV2(),
            LibMetaFixture.operandHandlerFunctionPointers(),
            LibParseLiteral.buildLiteralParsers()
        );

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRightParen.selector, 1));
        (bytes memory bytecode, uint256[] memory constants) = state.parse();
        (bytecode, constants);
    }

    /// The parser should track the paren depth as it encounters left parens.
    function testParseUnexpectedRightParenNested() external {
        string memory str = ":a(b()));";
        ParseState memory state = LibParseState.newState(
            bytes(str),
            LibMetaFixture.parseMetaV2(),
            LibMetaFixture.operandHandlerFunctionPointers(),
            LibParseLiteral.buildLiteralParsers()
        );

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRightParen.selector, 7));
        (bytes memory bytecode, uint256[] memory constants) = state.parse();
        (bytecode, constants);
    }
}
