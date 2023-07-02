// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParseMeta.sol";
import "test/lib/parse/LibBloom.sol";

contract LibParseMetaBuildMetaTest is Test {
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

    /// This is super loose from limited empirical testing.
    function expanderDepth(uint256 n) internal pure returns (uint8) {
        return uint8(n / type(uint256).max + 2);
    }

    function testBuildMetaExpander(bytes32[] memory words) external view {
        vm.assume(!LibBloom.bloomFindsDupes(words));
        bytes memory meta = LibParseMeta.buildMetaExpander(words, expanderDepth(words.length));
        (meta);
    }

    function testRoundMetaExpander(bytes32[] memory words, uint8 j, bytes32 notFound) external {
        vm.assume(words.length > 0);
        vm.assume(!LibBloom.bloomFindsDupes(words));
        for (uint256 i = 0; i < words.length; i++) {
            vm.assume(words[i] != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(words.length) - 1));

        bytes memory meta = LibParseMeta.buildMetaExpander(words, expanderDepth(words.length));
        (bool exists, uint256 k) = LibParseMeta.lookupIndexMetaExpander(meta, words[j]);
        assertTrue(exists);
        assertEq(j, k);

        (bool notExists, uint256 l) = LibParseMeta.lookupIndexMetaExpander(meta, notFound);
        assertTrue(!notExists);
        assertEq(0, l);
    }

    function testRoundMetaExpanderDeeper(bytes32[] memory words, uint8 j, bytes32 notFound) external {
        vm.assume(words.length > 50);
        vm.assume(!LibBloom.bloomFindsDupes(words));
        for (uint256 i = 0; i < words.length; i++) {
            vm.assume(words[i] != notFound);
        }
        j = uint8(bound(j, uint8(0), uint8(words.length) - 1));

        bytes memory meta = LibParseMeta.buildMetaExpander(words, expanderDepth(words.length));
        (bool exists, uint256 k) = LibParseMeta.lookupIndexMetaExpander(meta, words[j]);
        assertTrue(exists);
        assertEq(j, k);

        (bool notExists, uint256 l) = LibParseMeta.lookupIndexMetaExpander(meta, notFound);
        assertTrue(!notExists);
        assertEq(0, l);
    }

}
