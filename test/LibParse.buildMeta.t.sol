// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseBuildMetaTest is Test {
    function testBuildMeta0() external {
        bytes32[] memory words = new bytes32[](2);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        bytes memory meta = LibParse.buildMeta(words, 0, 0x100);
        console2.logBytes(meta);
    }

    function testbuildMetaX() external {
        bytes32[] memory words = new bytes32[](2);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        assertEq(LibParse.buildMeta(words, 0, 0x100), LibParse.buildMetaSol(words));
    }

    function testBuildMeta1() external {
        bytes32[] memory words = new bytes32[](70);
        for (uint256 i = 0; i < words.length; i++) {
            words[i] = bytes32(i);
        }
        bytes memory meta = LibParse.buildMeta(words, 0, 100000);
        console2.logBytes(meta);
    }

    function testBuildMetaY() external {
        bytes32[] memory words = new bytes32[](170);
        for (uint256 i = 0; i < words.length; i++) {
            words[i] = bytes32(i);
        }
        bytes memory meta = LibParse.buildMetaSol2(words);
        console2.logBytes(meta);
    }

    function testBuildMetaExpander() external {
        bytes32[] memory words = new bytes32[](1000);
        for (uint256 i = 0; i < words.length; i++) {
            words[i] = bytes32(i);
        }
        bytes memory meta = LibParse.buildMetaExpander(words, 6);
    }
}
