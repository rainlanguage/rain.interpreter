// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {EMPTY_ACTIVE_SOURCE, LibParseState} from "src/lib/parse/LibParseState.sol";

contract LibParseStateNewActiveSourcePointerTest is Test {
    /// If the old pointer is zero, the new pointer should point to
    /// EMPTY_ACTIVE_SOURCE.
    /// The fuzzed bytes just ensure the memory pointer is always different.
    function testZeroOldPointer(bytes memory) external {
        uint256 oldPointer = 0;
        uint256 newPointer = LibParseState.newActiveSourcePointer(oldPointer);
        uint256 activeSource;
        assembly ("memory-safe") {
            activeSource := mload(newPointer)
        }
        assertTrue(
            activeSource == EMPTY_ACTIVE_SOURCE,
            "new pointer should be EMPTY_ACTIVE_SOURCE"
        );
        assertTrue(
            newPointer % 0x20 == 0,
            "new pointer should be aligned"
        );
    }
}