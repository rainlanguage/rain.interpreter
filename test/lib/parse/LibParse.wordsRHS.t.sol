// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

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
        bytes32[] memory words = new bytes32[](16);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        words[2] = bytes32("c");
        words[3] = bytes32("d");
        words[4] = bytes32("e");
        words[5] = bytes32("f");
        words[6] = bytes32("g");
        words[7] = bytes32("h");
        words[8] = bytes32("i");
        words[9] = bytes32("j");
        words[10] = bytes32("k");
        words[11] = bytes32("l");
        words[12] = bytes32("m");
        words[13] = bytes32("n");
        words[14] = bytes32("o");
        words[15] = bytes32("p");
        meta = LibParseMeta.buildMeta(words, 2);
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
        assertEq(sources[0], hex"00010000010000000002000001010000");
        assertEq(constants.length, 0);
    }

    /// Two words on the RHS, one nested as an input to the other.
    function testParseTwoNested() external {
        string memory s = "_:a(b());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // b a
        assertEq(sources[0], hex"0001000001000000");
        assertEq(constants.length, 0);
    }

    /// Three words on the RHS, two sequential nested as an input to the other.
    function testParseTwoNestedAsThirdInput() external {
        string memory s = "_:a(b() c());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // c b a
        assertEq(sources[0], hex"000200000001000002000000");
        assertEq(constants.length, 0);
    }

    /// Several words, mixing sequential and nested logic to some depth, with
    /// several LHS items.
    function testParseSingleLHSNestingAndSequential00() external {
        string memory s = "_:a(b() c(d() e()));";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 20);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // e d c b a
        assertEq(sources[0], hex"0004000000030000020200000001000002000000");
    }

    /// Several words, mixing sequential and nested logic to some depth, with
    /// several LHS items.
    function testParseSingleLHSNestingAndSequential01() external {
        string memory s = "_:a(b() c(d() e()) f() g(h() i()));";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 36);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // i h g f e d c b a
        assertEq(sources[0], hex"000800000007000002060000000500000004000000030000020200000001000004000000");
    }

    /// Several words, mixing sequential and nested logic to some depth, with
    /// several LHS items.
    function testParseSingleLHSNestingAndSequential02() external {
        string memory s = "_ _ _:a(b() c(d())) d() e(b());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 28);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // d c b a d b e
        assertEq(sources[0], hex"00030000010200000001000002000000000300000001000001040000");
    }

    /// More than 14 words deep triggers a whole other internal loop due to there
    /// being 7 words max per active source.
    function testParseSingleLHSNestingAndSequential03() external {
        string memory s =
            "_ _:a(b() c(d() e() f() g() h() i() j() k() l() m() n() o() p())) p(o() n(m() l() k() j() i() h() g() f() e() d() c() b() a()));";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        assertEq(sources.length, 1);
        assertEq(sources[0].length, 128);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // p o n m l k j i h g f e d c b a a b c d e f g h i j k l m n o p
        assertEq(
            sources[0],
            hex"000f0000000e0000000d0000000c0000000b0000000a0000000900000008000000070000000600000005000000040000000300000d020000000100000200000000000000000100000002000000030000000400000005000000060000000700000008000000090000000a0000000b0000000c00000d0d0000000e0000020f0000"
        );
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
