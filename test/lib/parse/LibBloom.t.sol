// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "test/lib/parse/LibBloom.sol";

/// @title LibBloomTest
/// @notice This is a test contract for LibBloom. LibBloom itself is only used
/// for testing currently, but if it is buggy it undermines a lot of the rest
/// of the test suite.
contract LibBloomTest is Test {
    /// A bloom filter should never return false negatives, even though it
    /// typically has a high false positive rate.
    function testLibBloomNoFalseNegatives(bytes32[] memory words, uint256 a, uint256 b) external {
        vm.assume(words.length > 1);
        /// Copy a random work to another random word to force a dupe.
        uint256 j = a % words.length;
        uint256 k = b % words.length;
        vm.assume(j != k);
        words[k] = words[j];

        assertTrue(LibBloom.bloomFindsDupes(words));
    }

    /// With random words the chance of false positives is much higher. Described
    /// by the birthday paradox.
    function testLibBloomVaguelyAvoidsFalsePositives(uint256 start, uint8 len) external pure {
        vm.assume(type(uint256).max - len > start);
        // The ability for the bloom filter to avoid saturation starts to max out
        // around 180 words. This is a very loose bound.
        vm.assume(len < 180);
        bool offsetFound = false;
        while (!offsetFound) {
            start++;
            bytes32[] memory words = new bytes32[](len);
            for (uint256 i = 0; i < len; i++) {
                // Do a keccak256 here to avoid the trivial case of the bloom filter
                // just mapping every sequential value to a bit in the filter.
                words[i] = keccak256(abi.encodePacked(bytes32(start + i)));
            }
            offsetFound = !LibBloom.bloomFindsDupes(words);
        }
    }
}
