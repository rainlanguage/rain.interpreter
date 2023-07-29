// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "test/util/lib/io/LibIOFnPointers.sol";

/// @title LibParseBalanceStackOffsetsTest
/// Test that the parser correctly balances the stack offsets each line.
contract LibParseBalanceStackOffsetsTest is Test {
    /// Build a shared meta for all the tests to simplify the implementation
    /// of each. It also makes it easier to compare the expected bytes across
    /// tests.
    bytes internal meta;

    /// Constructor just builds the shared meta.
    constructor() {
        bytes32[] memory words = new bytes32[](5);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        words[2] = bytes32("c");
        words[3] = bytes32("d");
        words[4] = bytes32("e");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// The parser should revert if there are too many RHS items. This is
    /// testing one RHS items and zero LHS items.
    function testParseBalanceStackOffsetsExcessRHS0() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 4));
        LibParse.parse(":a();", meta);
    }

    /// The parser should revert if there are too many RHS items. This is
    /// testing two RHS items and zero LHS items.
    function testParseBalanceStackOffsetsExcessRHS1() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 8));
        LibParse.parse(":a() b();", meta);
    }

    /// The parser should revert if there are too many RHS items. This is
    /// testing two RHS items and one LHS item.
    function testParseBalanceStackOffsetsExcessRHS2() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 9));
        LibParse.parse("_:a() b();", meta);
    }

    /// The parser should revert if there are too many LHS items. This is
    /// testing zero RHS items and one LHS item.
    function testParseBalanceStackOffsetsExcessLHS() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessLHSItems.selector, 4));
        LibParse.parse(":,_:;", meta);
    }

    /// The parser should revert if there are too many LHS items. This is
    /// testing one RHS item and two LHS items.
    function testParseBalanceStackOffsetsExcessLHS2() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessLHSItems.selector, 9));
        LibParse.parse(":,_ _:a();", meta);
    }

    /// The parser should revert if there are too many LHS items. This is
    /// testing zero RHS items and one LHS item.
    function testParseBalanceStackOffsetsExcessLHS3() external {
        // no inputs
        vm.expectRevert(abi.encodeWithSelector(ExcessLHSItems.selector, 4));
        LibParse.parse(":,_:;", meta);

        // with an input
        vm.expectRevert(abi.encodeWithSelector(ExcessLHSItems.selector, 6));
        LibParse.parse("_:,_:;", meta);
    }

    /// Inputs don't cause a revert but should still balance the stack offsets.
    function testParseBalanceStackOffsetsInputs() external {
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse("_ _:a(), _:b();", meta);
        assertEq(sources.length, 1);
        // a and b should be parsed and inputs are just ignored in the output
        // source.
        assertEq(sources[0], hex"0000000000010000");
        assertEq(constants.length, 0);
    }

    /// Nested RHS items only count as one LHS item.
    function testParseBalanceStackOffsetsNestedRHS() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessLHSItems.selector, 12));
        LibParse.parse(":,_ _:a(b());", meta);
    }
}
