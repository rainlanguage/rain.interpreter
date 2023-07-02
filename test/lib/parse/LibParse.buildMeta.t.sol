// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

contract LibParseBuildMetaTest is Test {
    // function testBuildMeta0() external view {
    //     bytes32[] memory words = new bytes32[](2);
    //     words[0] = bytes32("a");
    //     words[1] = bytes32("b");
    //     bytes memory meta = LibParse.buildMeta(words, 0, 0x100);
    //     console2.logBytes(meta);
    // }

    // function testbuildMetaX() external {
    //     bytes32[] memory words = new bytes32[](2);
    //     words[0] = bytes32("a");
    //     words[1] = bytes32("b");
    //     assertEq(LibParse.buildMeta(words, 0, 0x100), LibParse.buildMetaSol(words));
    // }

    // function testBuildMeta1() external view {
    //     bytes32[] memory words = new bytes32[](70);
    //     for (uint256 i = 0; i < words.length; i++) {
    //         words[i] = bytes32(i);
    //     }
    //     bytes memory meta = LibParse.buildMeta(words, 0, 100000);
    //     console2.logBytes(meta);
    // }

    // function testBuildMetaY() external view {
    //     bytes32[] memory words = new bytes32[](170);
    //     for (uint256 i = 0; i < words.length; i++) {
    //         words[i] = bytes32(i);
    //     }
    //     bytes memory meta = LibParse.buildMetaSol2(words);
    //     console2.logBytes(meta);
    // }

    function assumeNoDupes(bytes32[] memory words) internal pure {
        uint256 bloom;
        for (uint256 i = 0; i < words.length; i++) {
            uint256 shifted = 1 << (uint256(words[i]) & 0xFF);
            vm.assume(bloom & shifted == 0);
            bloom |= shifted;
        }
    }

    /// This is super loose from limited empirical testing.
    function expanderDepth(uint256 n) internal pure returns (uint8) {
        return uint8(n / type(uint256).max + 2);
    }

    function testBuildMetaExpander(bytes32[] memory words) external view {
        assumeNoDupes(words);
        bytes memory meta = LibParse.buildMetaExpander(words, expanderDepth(words.length));
        // console2.logBytes(meta);
    }

    function testRoundMetaExpander(bytes32[] memory words, uint8 j, bytes32 notFound) external {
        vm.assume(words.length > 0);
        assumeNoDupes(words);
        for (uint256 i = 0; i < words.length; i++) {
            vm.assume(words[i] != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(words.length) - 1));

        bytes memory meta = LibParse.buildMetaExpander(words, expanderDepth(words.length));
        (bool exists, uint256 k) = LibParse.lookupIndexMetaExpander(meta, words[j]);
        assertTrue(exists);
        assertEq(j, k);

        (bool notExists, uint256 l) = LibParse.lookupIndexMetaExpander(meta, notFound);
        assertTrue(!notExists);
        assertEq(0, l);
    }
}
