// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParseMeta.sol";
import "test/util/lib/bloom/LibBloom.sol";

contract LibParseMetaBuildMetaTest is Test {
    /// This is super loose from limited empirical testing.
    function expanderDepth(uint256 n) internal pure returns (uint8) {
        // Number of fully saturated expanders
        // + 1 for solidity flooring everything
        // + 1 for a non-fully saturated but still quite full expander
        // + 1 for a potentially nearly empty expander
        return uint8(n / type(uint8).max + 3);
    }

    function testBuildMetaExpander(bytes32[] memory words) external pure {
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
