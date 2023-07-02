//// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

library LibBloom {
    /// Returns true if any of the words are duplicates according to a bloom filter.
    /// The bloom filter is 512 bits.
    function bloomFindsDupes(bytes32[] memory words) internal pure returns (bool dupes) {
        assembly ("memory-safe") {
            let bloom0 := 0
            let bloom1 := 0
            let cursor := add(words, 0x20)
            let end := add(cursor, mul(mload(words), 0x20))

            for {} lt(cursor, end) { cursor := add(cursor, 0x20) } {
                let word := mload(cursor)
                // Bloom filter is the mod of the word by the size of the bloom filter.
                // As the filter is a uint256, the length of the filter is 256 bits.
                // Ignore the low bit to ensure we don't correlate with the
                // switch logic somehow.
                let shifted := shl(mod(shr(1, word), 0x100), 0x1)

                // If the low bit of shifted is set, then the bloom filter is in
                // bloom1, otherwise it is in bloom0.
                switch and(word, 0x01)
                case 0 {
                    if and(bloom0, shifted) {
                        dupes := 1
                        break
                    }
                    bloom0 := or(bloom0, shifted)
                }
                case 1 {
                    if and(bloom1, shifted) {
                        dupes := 1
                        break
                    }
                    bloom1 := or(bloom1, shifted)
                }
                default {
                    revert(0, 0)
                }
            }
        }
    }
}
