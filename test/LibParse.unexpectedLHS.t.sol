// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseUnexpectedLHS(bytes1 unexpected) external {
        vm.assume(unexpected != bytes1("\t"));
        vm.assume(unexpected != bytes1("\n"));
        vm.assume(unexpected != bytes1("\r"));
        vm.assume(unexpected != bytes1(" "));
        vm.assume(unexpected != bytes1("_"));
        vm.assume(unexpected != bytes1(":"));

        string memory unexpectedString = string(abi.encodePacked(unexpected));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, unexpectedString));
        LibParse.parse(bytes.concat(unexpected, ":;"));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, unexpectedString));
        LibParse.parse(bytes.concat("_", unexpected, ":;"));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, unexpectedString));
        LibParse.parse(bytes.concat(unexpected, "_:;"));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0, unexpectedString));
        LibParse.parse(bytes.concat("_", unexpected, "_:;"));
    }
}
