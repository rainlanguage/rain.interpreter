// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

contract LibParseTest is Test {
    function testParseUnexpectedRHS(bytes1 unexpected) external {
        vm.assume(unexpected != bytes1("\t"));
        vm.assume(unexpected != bytes1("\n"));
        vm.assume(unexpected != bytes1("\r"));
        vm.assume(unexpected != bytes1(" "));
        vm.assume(unexpected != bytes1(","));
        vm.assume(unexpected != bytes1(";"));

        string memory unexpectedString = string(abi.encodePacked(unexpected));

        vm.expectRevert(abi.encodeWithSelector(UnexpectedRHSChar.selector, 1, unexpectedString));
        LibParse.parse(bytes.concat(":", unexpected, ";"));
    }
}
