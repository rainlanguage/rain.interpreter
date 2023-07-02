// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./LibCtPop.sol";

// For metadata builder.
error DuplicateFingerprint();

uint256 constant FINGERPRINT_MASK = 0xFFFFFFFF;

library LibParseMeta {
    /// @return shifted
    /// @return bitmapped
    function wordBitmapped(uint256 seed, bytes32 word) internal pure returns (uint256, uint256) {
        uint256 hashed;
        assembly ("memory-safe") {
            mstore(0, word)
            mstore8(0x20, seed)
            hashed := keccak256(0, 0x21)
        }
        return (1 << uint8(hashed), hashed);
    }

    function findBestExpander(bytes32[] memory words)
        internal
        pure
        returns (uint8 bestSeed, uint256 bestExpansion, bytes32[] memory remaining)
    {
        unchecked {
            {
                uint256 bestCt = 0;
                for (uint256 seed = 0; seed < type(uint8).max; seed++) {
                    uint256 expansion = 0;
                    for (uint256 i = 0; i < words.length; i++) {
                        (uint256 shifted, uint256 hashed) = wordBitmapped(seed, words[i]);
                        (hashed);
                        expansion = shifted | expansion;
                    }
                    uint256 ct = LibCtPop.ctpop(expansion);
                    if (ct > bestCt) {
                        bestCt = ct;
                        bestSeed = uint8(seed);
                        bestExpansion = expansion;
                    }
                    // perfect expansion.
                    if (ct == words.length) {
                        break;
                    }
                }
            }
            remaining = new bytes32[](words.length - LibCtPop.ctpop(bestExpansion));
            uint256 usedExpansion = 0;
            uint256 j = 0;
            for (uint256 i = 0; i < words.length; i++) {
                (uint256 shifted, uint256 hashed) = wordBitmapped(bestSeed, words[i]);
                (hashed);
                if ((shifted & usedExpansion) == 0) {
                    usedExpansion = shifted | usedExpansion;
                } else {
                    remaining[j] = words[i];
                    j++;
                }
            }
        }
    }

    function buildMetaExpander(bytes32[] memory words, uint8 maxDepth) internal pure returns (bytes memory meta) {
        unchecked {
            uint8[] memory seeds = new uint8[](maxDepth);
            uint256[] memory expansions = new uint256[](maxDepth);
            uint256 i = 0;
            bytes32[] memory ogWords = words;
            while (words.length > 0) {
                uint8 seed;
                uint256 expansion;
                (seed, expansion, words) = findBestExpander(words);
                seeds[i] = seed;
                expansions[i] = expansion;
                i++;
            }
            // 1 = depth
            // 0x21 per depth = expansion + seed
            // 6 per word = 4 byte fingerprint + 2 byte opcode
            uint256 metaLength = 1 + i * 0x21 + ogWords.length * 6;
            meta = new bytes(metaLength);
            assembly ("memory-safe") {
                mstore8(add(meta, 0x20), i)
            }
            for (uint256 j = 0; j < i; j++) {
                uint8 seed = seeds[j];
                uint256 expansion = expansions[j];
                assembly ("memory-safe") {
                    mstore8(add(meta, add(0x21, j)), seed)
                    mstore(add(add(meta, 1), add(add(0x20, i), mul(0x20, j))), expansion)
                }
            }

            uint256 dataStart;
            assembly ("memory-safe") {
                dataStart := add(add(meta, 7), mul(0x21, i))
            }
            for (uint256 k = 0; k < ogWords.length; k++) {
                uint256 s = 0;
                bool didCollide = true;
                uint256 cumulativePos = 0;
                while (didCollide) {
                    uint8 seed = seeds[s];
                    uint256 expansion = expansions[s];
                    (uint256 shifted, uint256 hashed) = wordBitmapped(seed, ogWords[k]);
                    uint256 wordFingerprint = hashed & FINGERPRINT_MASK;
                    uint256 toWrite = wordFingerprint | (k << 32);

                    uint256 pos = LibCtPop.ctpop(expansion & (shifted - 1)) + cumulativePos;

                    uint256 posFingerprint;
                    uint256 writeAt;
                    assembly ("memory-safe") {
                        writeAt := add(dataStart, mul(pos, 6))
                        posFingerprint := and(mload(writeAt), 0xFFFFFFFF)
                    }

                    if (posFingerprint == 0) {
                        assembly ("memory-safe") {
                            mstore(writeAt, or(and(mload(writeAt), not(0xFFFFFFFFFFFF)), toWrite))
                        }
                        didCollide = false;
                    } else if (posFingerprint == wordFingerprint) {
                        revert DuplicateFingerprint();
                    }
                    s++;
                    cumulativePos = cumulativePos + LibCtPop.ctpop(expansion);
                }
            }
        }
    }

    function lookupIndexMetaExpander(bytes memory meta, bytes32 word)
        internal
        pure
        returns (bool exists, uint256 index)
    {
        unchecked {
            uint256 dataStart;
            uint256 cursor;
            uint256 end;
            assembly ("memory-safe") {
                // Read depth from first meta byte.
                cursor := add(meta, 1)
                let depth := and(mload(cursor), 0xFF)
                // 33 bytes per depth
                end := add(cursor, mul(depth, 0x21))
                dataStart := add(end, 6)
            }
            uint256 cumulativeCt = 0;
            while (cursor < end) {
                uint256 seed;
                uint256 expansion;
                assembly ("memory-safe") {
                    cursor := add(cursor, 1)
                    seed := and(mload(cursor), 0xFF)
                    cursor := add(cursor, 0x20)
                    expansion := mload(cursor)
                }

                (uint256 shifted, uint256 hashed) = wordBitmapped(seed, word);
                uint256 pos = LibCtPop.ctpop(expansion & (shifted - 1)) + cumulativeCt;
                uint256 wordFingerprint = hashed & FINGERPRINT_MASK;
                uint256 posData;
                assembly ("memory-safe") {
                    posData := mload(add(dataStart, mul(pos, 6)))
                }
                // Match
                if (wordFingerprint == posData & FINGERPRINT_MASK) {
                    return (true, (posData >> 0x20) & 0xFFFF);
                } else {
                    cursor += 0x21;
                    cumulativeCt += LibCtPop.ctpop(expansion);
                }
            }
            return (false, 0);
        }
    }
}