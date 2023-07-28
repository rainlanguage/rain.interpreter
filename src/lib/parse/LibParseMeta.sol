// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./LibCtPop.sol";

// For metadata builder.
error DuplicateFingerprint();

uint256 constant FINGERPRINT_MASK = 0xFFFFFFFF;
/// @dev 7 = 1 byte opcode index + 2 byte io fn ptr + 6 byte fingerprint
uint256 constant META_ITEM_SIZE = 7;
uint256 constant META_ITEM_MASK = (1 << META_ITEM_SIZE) - 1;
/// @dev 33 = 32 bytes for expansion + 1 byte for seed
uint256 constant META_EXPANSION_SIZE = 0x21;
/// @dev 1 = 1 byte for depth
uint256 constant META_PREFIX_SIZE = 1;

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
        //slither-disable-next-line incorrect-shift
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

    function buildMeta(bytes32[] memory words, uint8 maxDepth) internal pure returns (bytes memory meta) {
        unchecked {
            uint8[] memory seeds = new uint8[](maxDepth);
            uint256[] memory expansions = new uint256[](maxDepth);
            uint256 depth = 0;
            bytes32[] memory ogWords = words;
            while (words.length > 0) {
                uint8 seed;
                uint256 expansion;
                (seed, expansion, words) = findBestExpander(words);
                seeds[depth] = seed;
                expansions[depth] = expansion;
                depth++;
            }
            // 1 = depth
            // 0x21 per depth = expansion + seed
            // 6 per word = 4 byte fingerprint + 2 byte opcode
            uint256 metaLength = META_PREFIX_SIZE + depth * META_EXPANSION_SIZE + ogWords.length * META_ITEM_SIZE;
            meta = new bytes(metaLength);
            assembly ("memory-safe") {
                mstore8(add(meta, 0x20), depth)
            }
            for (uint256 j = 0; j < depth; j++) {
                assembly ("memory-safe") {
                    // Write each seed immediately before its expansion.
                    let seedWriteAt := add(add(meta, 0x21), mul(0x21, j))
                    mstore8(seedWriteAt, mload(add(seeds, add(0x20, mul(0x20, j)))))
                    mstore(add(seedWriteAt, 1), mload(add(expansions, add(0x20, mul(0x20, j)))))
                }
            }

            uint256 dataStart;
            {
                uint256 dataOffset = META_PREFIX_SIZE + META_ITEM_SIZE + depth * META_EXPANSION_SIZE;
                assembly ("memory-safe") {
                    dataStart := add(meta, dataOffset)
                }
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
                    // @todo real pointer.
                    uint256 toWrite;
                    {
                        uint256 ioFnPtr = 0;
                        toWrite = wordFingerprint | (ioFnPtr << 0x20) | (k << 0x30);
                    }

                    uint256 pos = LibCtPop.ctpop(expansion & (shifted - 1)) + cumulativePos;
                    uint256 posFingerprint;
                    uint256 writeAt;
                    uint256 metaItemSize = META_ITEM_SIZE;
                    assembly ("memory-safe") {
                        writeAt := add(dataStart, mul(pos, metaItemSize))
                        posFingerprint := and(mload(writeAt), 0xFFFFFFFF)
                    }

                    if (posFingerprint == 0) {
                        uint256 mask = ~META_ITEM_MASK;
                        assembly ("memory-safe") {
                            mstore(writeAt, or(and(mload(writeAt), mask), toWrite))
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

    function lookupIndexFromMeta(bytes memory meta, bytes32 word) internal pure returns (bool exists, uint256 index) {
        unchecked {
            uint256 dataStart;
            uint256 cursor;
            uint256 end;
            uint256 metaExpansionSize = META_EXPANSION_SIZE;
            uint256 metaItemSize = META_ITEM_SIZE;
            assembly ("memory-safe") {
                // Read depth from first meta byte.
                cursor := add(meta, 1)
                let depth := and(mload(cursor), 0xFF)
                // 33 bytes per depth
                end := add(cursor, mul(depth, metaExpansionSize))
                dataStart := add(end, metaItemSize)
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
                    posData := mload(add(dataStart, mul(pos, metaItemSize)))
                }
                // Match
                if (wordFingerprint == posData & FINGERPRINT_MASK) {
                    return (true, (posData >> 0x30) & 0xFF);
                } else {
                    cumulativeCt += LibCtPop.ctpop(expansion);
                }
            }
            return (false, 0);
        }
    }
}
