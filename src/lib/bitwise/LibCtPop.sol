// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev 010101... for ctpop
uint256 constant CTPOP_M1 = 0x5555555555555555555555555555555555555555555555555555555555555555;
/// @dev 00110011.. for ctpop
uint256 constant CTPOP_M2 = 0x3333333333333333333333333333333333333333333333333333333333333333;
/// @dev 4 bits alternating for ctpop
uint256 constant CTPOP_M4 = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
/// @dev 8 bits alternating for ctpop
uint256 constant CTPOP_M8 = 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF;
/// @dev 16 bits alternating for ctpop
uint256 constant CTPOP_M16 = 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF;
/// @dev 32 bits alternating for ctpop
uint256 constant CTPOP_M32 = 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF;
/// @dev 64 bits alternating for ctpop
uint256 constant CTPOP_M64 = 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF;
/// @dev 128 bits alternating for ctpop
uint256 constant CTPOP_M128 = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
/// @dev 1 bytes for ctpop
uint256 constant CTPOP_H01 = 0x0101010101010101010101010101010101010101010101010101010101010101;

library LibCtPop {
    /// Optimised version of ctpop.
    /// https://en.wikipedia.org/wiki/Hamming_weight
    function ctpop(uint256 x) internal pure returns (uint256) {
        // This edge case is not handled by the algorithm below.
        if (x == type(uint256).max) {
            return 256;
        }
        unchecked {
            x -= (x >> 1) & CTPOP_M1;
            x = (x & CTPOP_M2) + ((x >> 2) & CTPOP_M2);
            x = (x + (x >> 4)) & CTPOP_M4;
            x = (x * CTPOP_H01) >> 248;
        }
        return x;
    }

    /// This is the slowest possible implementation of ctpop. It is used to
    /// verify the correctness of the optimized implementation in LibCtPop.
    /// It should be obviously correct by visual inspection, referencing the
    /// wikipedia article.
    /// https://en.wikipedia.org/wiki/Hamming_weight
    function ctpopSlow(uint256 x) internal pure returns (uint256) {
        unchecked {
            x = (x & CTPOP_M1) + ((x >> 1) & CTPOP_M1);
            x = (x & CTPOP_M2) + ((x >> 2) & CTPOP_M2);
            x = (x & CTPOP_M4) + ((x >> 4) & CTPOP_M4);
            x = (x & CTPOP_M8) + ((x >> 8) & CTPOP_M8);
            x = (x & CTPOP_M16) + ((x >> 16) & CTPOP_M16);
            x = (x & CTPOP_M32) + ((x >> 32) & CTPOP_M32);
            x = (x & CTPOP_M64) + ((x >> 64) & CTPOP_M64);
            x = (x & CTPOP_M128) + ((x >> 128) & CTPOP_M128);
        }
        return x;
    }
}
