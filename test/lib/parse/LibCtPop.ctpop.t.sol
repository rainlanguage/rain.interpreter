// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "../../../lib/forge-std/src/Test.sol";

import "../../../src/lib/parse/LibCtPop.sol";

/// @title LibCtPopTest
/// CTPOP (count population) is a function that counts the number of bits set in
/// a `uint256`. The reference implementations are taken directly from Wikipedia.
/// https://en.wikipedia.org/wiki/Hamming_weight
contract LibCtPopTest is Test {
    /// We should be able to count the number of bits set when we simply set a
    /// sequence of bits from the low bit to some mid bit.
    function testCTPOPUnshuffled(uint8 n) external {
        uint256 x = (1 << n) - 1;
        uint256 ct = LibCtPop.ctpop(x);
        assertEq(n, ct);
    }

    /// The distribution of bits in the underlying `uint256` should not matter.
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

        uint256 ct = LibCtPop.ctpop(y);
        assertEq(n, ct);
    }
}
