// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseEmptyTest is Test {
    function testParseEmpty() external {
        (bytes[] memory sources0, uint256[] memory constants0) = LibParse.parse("");
        assertEq(sources0.length, 0);
        assertEq(constants0.length, 0);

        (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse(":;");
        assertEq(sources1.length, 1);
        assertEq(sources1[0].length, 0);
        assertEq(constants1.length, 0);

        (bytes[] memory sources2, uint256[] memory constants2) = LibParse.parse(":;:;");
        assertEq(sources2.length, 2);
        assertEq(sources2[0].length, 0);
        assertEq(sources2[1].length, 0);
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
}
