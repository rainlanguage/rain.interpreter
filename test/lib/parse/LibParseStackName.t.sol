//// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/parse/LibParseStackName.sol";

/// @title LibParseStackNameTest
/// Tests for handling named stack items.
contract LibParseStackNameTest is Test {
    /// Test that we can push and retrieve a stack name.
    function testPushAndRetrieveStackNameSingle(ParseState memory state, bytes32 word) external {
        state.stackLHSIndex = 0;
        state.stackNames = 0;

        LibParseStackName.pushStackName(state, word);

        assertEq(state.stackLHSIndex, 1);

        (uint256 exists, uint256 index) = LibParseStackName.stackNameIndex(state, word);
        assertEq(exists, 1);
        assertEq(index, 0);
    }

    /// Test that we can push and retrieve two different stack names.
    function testPushAndRetrieveStackNameDouble(ParseState memory state, bytes32 word1, bytes32 word2) external {
        vm.assume(word1 != word2);
        state.stackLHSIndex = 0;
        state.stackNames = 0;

        (uint256 exists, uint256 index) = LibParseStackName.pushStackName(state, word1);
        assertEq(exists, 0);
        assertEq(index, 1);
        state.stackLHSIndex = index;

        (exists, index) = LibParseStackName.pushStackName(state, word2);
        assertEq(exists, 0);
        assertEq(index, 2);
        state.stackLHSIndex = index;

        (exists, index) = LibParseStackName.stackNameIndex(state, word1);
        assertEq(exists, 1);
        assertEq(index, 0);

        (exists, index) = LibParseStackName.stackNameIndex(state, word2);
        assertEq(exists, 1);
        assertEq(index, 1);
    }

    /// Test that two identical stack names are not pushed.
    function testPushAndRetrieveStackNameDoubleIdentical(ParseState memory state, bytes32 word) external {
        state.stackLHSIndex = 0;
        state.stackNames = 0;

        (uint256 exists, uint256 index) = LibParseStackName.pushStackName(state, word);
        assertEq(exists, 0);
        assertEq(index, 1);
        state.stackLHSIndex = index;

        (exists, index) = LibParseStackName.pushStackName(state, word);
        assertEq(exists, 1);
        assertEq(index, 0);
    }

    /// Test that we can push and retrieve many stack names.
    function testPushAndRetrieveStackName(ParseState memory state, bytes32[] memory words) external {
        vm.assume(words.length > 0);
        state.stackLHSIndex = 0;
        state.stackNames = 0;

        for (uint256 i = 0; i < words.length; i++) {
            LibParseStackName.pushStackName(state, words[i]);
        }

        assertEq(state.stackLHSIndex, words.length);

        for (uint256 i = 0; i < words.length; i++) {
            (uint256 exists, uint256 index) = LibParseStackName.stackNameIndex(state, words[i]);
            assertEq(exists, 1);
            assertEq(index, i);
        }
    }
}
