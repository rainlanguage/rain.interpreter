// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// @dev 010101... for ctpop
uint256 constant CTPOP_M1 = 0x5555555555555555555555555555555555555555555555555555555555555555;
/// @dev 00110011.. for ctpop
uint256 constant CTPOP_M2 = 0x3333333333333333333333333333333333333333333333333333333333333333;
/// @dev 4 bits alternating for ctpop
uint256 constant CTPOP_M4 = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
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
}
