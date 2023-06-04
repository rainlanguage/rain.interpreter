// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseUnexpectedLHS() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("0:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("_0:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("0_:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("_0_:;");
    }
}
