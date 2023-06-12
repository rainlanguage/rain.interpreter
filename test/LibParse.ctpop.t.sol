// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/LibParse.sol";

contract LibParseCTPOPTest is Test {
    function testCTPOPUnshuffled(uint8 n) external {
        uint256 x = (1 << n) - 1;
        uint256 ct = LibParse.ctpop(x);
        assertEq(n, ct);
    }

    function testCTPOPShuffled(uint8 n, bytes32 rand) external {
        uint256 x = (1 << n) - 1;
        uint256 y = 0;

        // Fisher-yates to show pop count can handle any distribution of bits.
        for (uint256 i = 256; i > 0; i--) {
            rand = keccak256(bytes.concat(rand));
            uint256 offset = uint256(rand) % i;
            uint256 lowMask = (1 << offset) - 1;
            uint256 low = x & lowMask;
            uint256 high = x & ~lowMask;
            uint256 bit = (high >> offset) & 1;
            x = (high >> 1) | low;
            y = y | (bit << (i - 1));
        }

        uint256 ct = LibParse.ctpop(y);
        assertEq(n, ct);
    }
}
