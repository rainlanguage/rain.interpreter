// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseTest is Test {
    function testParseInputsOnly() external {
        string[2] memory examples = ["_:;", "_ _:;"];
        for (uint256 i = 0; i < examples.length; i++) {
            (bytes[] memory sources1, uint256[] memory constants1) = LibParse.parse(bytes(examples[i]));
            assertEq(sources1.length, 1);
            assertEq(sources1[0].length, 0);
            assertEq(constants1.length, 0);
        }
    }

    function testParseGasInputsOnly0() external pure {
        LibParse.parse("_:;");
    }
}
