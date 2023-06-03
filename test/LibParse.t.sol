// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testCharBuilder() external view {
        bytes memory char = "_";
        uint256 x;
        assembly {
            x := shl(and(mload(add(char, 1)), 0xFF), 1)
            // let x := or(or(0x100000000000, 0x0400000000000000), 0x0800000000000000)
        }
        console.log(x);
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

    function testParseGasEmpty0() external {
        LibParse.parse("");
    }

    function testParseGasEmpty1() external {
        LibParse.parse(":;");
    }

    function testParseGasEmpty2() external {
        LibParse.parse(":;:;");
    }

    function testParseMissingFinalSemi() external {
        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 1));
        LibParse.parse(":");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 3));
        LibParse.parse(":;:");

        vm.expectRevert(abi.encodeWithSelector(MissingFinalSemi.selector, 2));
        LibParse.parse("::");
    }

    function testParseInputsOnly() external {
        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse("_:;");
        assertEq(sources1.length, 1);
        assertEq(constants1.length, 0);
    }

    function testParseGasInputsOnly0() external {
        LibParse.parse("_:;");
    }

    function testParseUnexpectedLHS() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0));
        LibParse.parse("0:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0));
        LibParse.parse("_0:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0));
        LibParse.parse("0_:;");

        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 0));
        LibParse.parse("_0_:;");
    }
}
