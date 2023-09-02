// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/console2.sol";

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

library LibCtPop {
    uint256 private constant m1 = 0x5555555555555555555555555555555555555555555555555555555555555555;
    uint256 private constant m2 = 0x3333333333333333333333333333333333333333333333333333333333333333;
    uint256 private constant m4 = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
    uint256 private constant h01 = 0x0101010101010101010101010101010101010101010101010101010101010101;

    function ctpopD(uint256 x) internal view returns (uint256) {
        uint256 a = gasleft();
        unchecked {
            x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
            x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
            x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
            x = (x * h01) >> 248;  //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ...
        }
        uint256 b = gasleft();
        console2.log("ctpopD gas", a - b);
        return x;
    }

    function ctpop(uint256 x) internal pure returns (uint256) {
        unchecked {
            x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
            x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
            x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
            x = (x * h01) >> 248;  //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ...
        }
        return x;
    }
}
