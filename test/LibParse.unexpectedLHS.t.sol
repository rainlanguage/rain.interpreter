// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseUnexpectedLHS(bytes1 memory unexpected) external {

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, string(bytes(unexpected))));
        LibParse.parse(bytes.concat(unexpected, ":;"));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("_0:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("0_:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, "0"));
        LibParse.parse("_0_:;");
    }
}
