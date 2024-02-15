// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {LibParseState} from "src/lib/parse/LibParseState.sol";
import {LibCtPop} from "src/lib/bitwise/LibCtPop.sol";

/// @title LibParseStateConstantValueBloomTest
contract LibParseStateConstantValueBloomTest is Test {
    /// This is a kinda pointless test, it just duplicates the internal logic...
    function testConstantValueBloom(uint256 value) external {
        assertEq(LibParseState.constantValueBloom(value), uint256(1) << (value % 256));
    }

    /// Exactly one bit should be set for any value.
    function testConstantValueBloomSingleBit(uint256 value) external {
        assertEq(LibCtPop.ctpop(LibParseState.constantValueBloom(value)), 1);
    }

    /// All bits should be set over 256 values.
    function testConstantValueBloomAllBits() external {
        uint256 bloom = 0;
        for (uint256 i = 0; i < 256; i++) {
            bloom |= LibParseState.constantValueBloom(i);
        }
        assertEq(bloom, type(uint256).max);
    }
}
