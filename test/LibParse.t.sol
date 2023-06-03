// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testCharBuilder() external pure {
        bytes memory char = ";";
        assembly {
            let x := shl(and(mload(add(char, 1)), 0xFF), 1)
            // let x := or(or(0x100000000000, 0x0400000000000000), 0x0800000000000000)
            let y := mload(x)
        }
    }

    function testParseEmpty() external {
        (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse("");
        assertEq(sources0.length, 0);
        assertEq(constants0.length, 0);

        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse(":;");
        assertEq(sources1.length, 1);
        assertEq(constants1.length, 0);

        (bytes[] memory sources2, uint256[] memory constants2) = LibParse.parse(":;:;");
        assertEq(sources2.length, 2);
        assertEq(constants2.length, 0);
    }

    function testParseMissingFinalSemi() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector));
        LibParse.parse(":");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector));
        LibParse.parse(":;:");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector));
        LibParse.parse("::");
    }
}
