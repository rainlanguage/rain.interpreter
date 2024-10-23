//// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/parse/LibParseStackName.sol";

/// @title LibParseStackNameTest
/// Tests for handling named stack items.
contract LibParseStackNameTest is Test {
    /// Test that we can push and retrieve a stack name.
    function testPushAndRetrieveStackNameSingle(ParseState memory state, bytes32 word) external pure {
        state.lineTracker = 0;
        state.topLevel1 = 0;
        state.stackNames = 0;

        (bool exists, uint256 index) = LibParseStackName.pushStackName(state, word);
        assertFalse(exists);
        assertEq(index, 1);

        state.lineTracker = index;
        state.topLevel1 = index;

        (exists, index) = LibParseStackName.stackNameIndex(state, word);
        assertTrue(exists);
        assertEq(index, 0);
    }

    /// Test that we can push and retrieve two different stack names.
    function testPushAndRetrieveStackNameDouble(ParseState memory state, bytes32 word1, bytes32 word2) external pure {
        vm.assume(word1 != word2);
        state.lineTracker = 0;
        state.topLevel1 = 0;
        state.stackNames = 0;

        (bool exists, uint256 index) = LibParseStackName.pushStackName(state, word1);
        assertFalse(exists);
        assertEq(index, 1);

        state.lineTracker = index;
        state.topLevel1 = index;

        (exists, index) = LibParseStackName.pushStackName(state, word2);
        assertFalse(exists);
        assertEq(index, 2);

        state.lineTracker = index;
        state.topLevel1 = index;

        (exists, index) = LibParseStackName.stackNameIndex(state, word1);
        assertTrue(exists);
        assertEq(index, 0);

        (exists, index) = LibParseStackName.stackNameIndex(state, word2);
        assertTrue(exists);
        assertEq(index, 1);
    }

    /// Test that two identical stack names are not pushed.
    function testPushAndRetrieveStackNameDoubleIdentical(ParseState memory state, bytes32 word) external pure {
        state.lineTracker = 0;
        state.topLevel1 = 0;
        state.stackNames = 0;

        (bool exists, uint256 index) = LibParseStackName.pushStackName(state, word);
        assertFalse(exists);
        assertEq(index, 1);

        state.lineTracker = index;
        state.topLevel1 = index;

        (exists, index) = LibParseStackName.pushStackName(state, word);
        assertTrue(exists);
        assertEq(index, 0);
    }

    /// Test that we can push and retrieve many stack names.
    function testPushAndRetrieveStackNameMany(ParseState memory state, uint256 n) external pure {
        n = bound(n, 1, 100);
        state.lineTracker = 0;
        state.topLevel1 = 0;
        state.stackNames = 0;

        // Do this sequentially to avoid dupes.
        for (uint256 i = 0; i < n; i++) {
            (bool exists, uint256 index) = LibParseStackName.pushStackName(state, bytes32(i));
            assertFalse(exists);
            assertEq(index, i + 1);
            state.lineTracker = index;
            state.topLevel1 = index;
        }

        for (uint256 i = 0; i < n; i++) {
            (bool exists, uint256 index) = LibParseStackName.stackNameIndex(state, bytes32(i));
            assertTrue(exists);
            assertEq(index, i);
        }
    }
}
