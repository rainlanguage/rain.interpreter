// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseSourceInputsTest
/// Test that inputs to the source (leading LHS items) are handled.
contract LibParseSourceInputsTest is Test {
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

    /// A single LHS item is parsed as a source input.
    function testParseSourceInputsSingle() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":,_:;", meta);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 0 ops
            hex"00"
            // 1 stack allocation
            hex"01"
            // 1 inputs
            hex"01"
            // 1 outputs
            hex"01"
        );
        assertEq(constants.length, 0);
    }

    /// Inputs can appear on the second line, even after an empty line, provided
    /// no RHS items have appeared yet.
    function testParseSourceInputsEmptyLinePrefix() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":,_:;", meta);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 0 ops
            hex"00"
            // 1 stack allocation
            hex"01"
            // 1 inputs
            hex"01"
            // 1 outputs
            hex"01"
        );
        assertEq(constants.length, 0);
    }

    /// Inputs can be spread across multiple lines, provided no RHS items have
    /// appeared yet. Tests one item per line, two times.
    function testParseSourceInputsMultipleLines() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":,_:,\n_:;", meta);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 0 ops
            hex"00"
            // 2 stack allocation
            hex"02"
            // 2 inputs
            hex"02"
            // 2 outputs
            hex"02"
        );
        assertEq(constants.length, 0);
    }
}
