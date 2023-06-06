// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseUnexpectedLHSEOL() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, ","));
        LibParse.parse(",");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 1, ","));
        LibParse.parse(" ,");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 1, ","));
        LibParse.parse("_,");
    }

    function testParseUnexpectedLHSEOF() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, ";"));
        LibParse.parse(";");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 1, ";"));
        LibParse.parse(" ;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 1, ";"));
        LibParse.parse("_;");
    }

    function testParseUnexpectedLHSSingleChar(bytes1 a) external {
        vm.assume(
            1 << uint256(uint8(a)) & (CMASK_LHS_RHS_DELIMITER | CMASK_LHS_STACK_HEAD | CMASK_LHS_STACK_DELIMITER) == 0
        );

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, string(abi.encodePacked(a))));
        LibParse.parse(bytes.concat(a, ":;"));
    }

    function testParseUnexpectedLHSIgnoredTail(bytes1 a) external {
        vm.assume(
            1 << uint256(uint8(a)) & (CMASK_LHS_RHS_DELIMITER | CMASK_IDENTIFIER_TAIL | CMASK_LHS_STACK_DELIMITER) == 0
        );

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 1, string(abi.encodePacked(a))));
        LibParse.parse(bytes.concat("_", a, ":;"));
    }

    function testParseUnexpectedLHSBadTail(uint8 a, bytes memory b) external {
        // a-z
        a = uint8(bound(a, 0x61, 0x7A));

        bool hasInvalidChar = false;
        uint256 i = 0;
        for (; i < b.length; i++) {
            bytes1 c = b[i];
            vm.assume(1 << uint256(uint8(c)) & (CMASK_LHS_STACK_DELIMITER | CMASK_LHS_RHS_DELIMITER) == 0);
            hasInvalidChar = 1 << uint256(uint8(c)) & CMASK_IDENTIFIER_TAIL == 0;
            if (hasInvalidChar) break;
        }
        vm.assume(hasInvalidChar);

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, i + 1, string(abi.encodePacked(b[i]))));
        LibParse.parse(bytes.concat(bytes1(a), b, ":;"));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, i + 1, string(abi.encodePacked(b[i]))));
        LibParse.parse(bytes.concat("_", b, ":;"));
    }
}
