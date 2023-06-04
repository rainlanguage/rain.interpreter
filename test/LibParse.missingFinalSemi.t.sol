// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseMissingFinalSemi() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 1));
        LibParse.parse(":");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibParse.parse(":;:");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 2));
        LibParse.parse("::");
    }
}
