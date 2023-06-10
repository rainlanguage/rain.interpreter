// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseBuildMetaTest is Test {
    function testBuildMeta0() external {
        bytes32[] memory words = new bytes32[](2);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        bytes memory meta = LibParse.buildMeta(words);
        console2.logBytes(meta);
    }

    function testBuildMeta1() external {
        bytes32[] memory words = new bytes32[](20);
        for (uint256 i = 0; i < words.length; i++) {
            words[i] = bytes32(i);
        }
        bytes memory meta = LibParse.buildMeta(words);
        console2.logBytes(meta);
    }
}
