// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseNamedRHSTest
/// Test that the parser can handle named RHS values.
contract LibParseNamedRHSTest is Test {
    /// We build a shared meta for all the tests to simplify the implementation
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
        meta = LibParseMeta.buildMetaExpander(words, 2);
    }

    /// The simplest RHS is a single word.
    function testParseSingleWord() external {
        string memory s = "_:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// Two sequential words on the RHS.
    function testParseTwoSequential() external {
        string memory s = "_ _:a() b();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a b
        assertEq(sources[0], hex"0000000000010000");
        assertEq(constants.length, 0);
    }

    /// Two sequential words on the RHS, each with a single input.
    function testParseTwoSequentialWithInputs() external {
        string memory s = "_ _:a(b()) b(c());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // b a c b
        assertEq(sources[0], hex"00010000000000000002000000010000");
        assertEq(constants.length, 0);
    }

    /// Two words on the RHS, one nested as an input to the other.
    function testParseTwoNested() external {
        string memory s = "_:a(b());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // b a
        assertEq(sources[0], hex"0001000000000000");
        assertEq(constants.length, 0);
    }

    /// Three words on the RHS, two sequential nested as an input to the other.
    function testParseTwoNestedAsThirdInput() external {
        string memory s = "_:a(b() c());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // c b a
        assertEq(sources[0], hex"000200000001000000000000");
        assertEq(constants.length, 0);
    }

    /// Several words, mixing sequential and nested logic to some depth, but
    /// still only one LHS in aggregate.
    function testParseSingleLHSNestingAndSequential() external {
        string memory s = "_:a(b() c(d() e()));";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 20);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // e d c b a
        assertEq(sources[0], hex"0004000000030000000200000001000000000000");
    }

    /// Two full lines, each with a single LHS and RHS.
    function testParseTwoFullLinesSingleRHSEach() external {
        string memory s = "_:a();_:b();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        assertEq(sources.length, 2);
        assertEq(sources[0].length, 4);
        assertEq(sources[1].length, 4);
        assertEq(constants.length, 0);
        // a
        assertEq(sources[0], hex"00000000");
        // b
        assertEq(sources[1], hex"00010000");
    }
}
