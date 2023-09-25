// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

import "test/util/lib/parse/LibMetaFixture.sol";

/// @title LibParseNamedRHSTest
/// Test that the parser can handle named RHS values.
contract LibParseNamedRHSTest is Test {
    /// The simplest RHS is a single word.
    function testParseSingleWord() external {
        string memory s = "_:a();";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);
        // a
        assertEq(bytecode, hex"0100000101000102000000");
        assertEq(constants.length, 0);
    }

    /// Two sequential words on the RHS.
    function testParseTwoSequential() external {
        string memory s = "_ _:a() b();";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 2);
        // a b
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // a b ops count
            hex"02"
            // a b stack allocation
            hex"02"
            // a b inputs count
            hex"00"
            // a b outputs count
            hex"02"
            // a
            hex"02000000"
            // b
            hex"03000000"
        );
        assertEq(constants.length, 0);
    }

    /// Two sequential words on the RHS, each with a single input.
    function testParseTwoSequentialWithInputs() external {
        string memory s = "_ _:a(b()) b(c<0 0>());";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 4);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 2);
        // b a c b
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // b a c b ops count
            hex"04"
            // b a c b stack allocation
            hex"02"
            // b a c b inputs count
            hex"00"
            // b a c b outputs count
            hex"02"
            // b
            hex"03000000"
            // a 1 input
            hex"02010000"
            // c
            hex"04000000"
            // b 1 input
            hex"03010000"
        );
        assertEq(constants.length, 0);
    }

    /// Two words on the RHS, one nested as an input to the other.
    function testParseTwoNested() external {
        string memory s = "_:a(b());";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);
        // b a
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // b a ops count
            hex"02"
            // b a stack allocation
            hex"01"
            // b a inputs count
            hex"00"
            // b a outputs count
            hex"01"
            // b
            hex"03000000"
            // a 1 input
            hex"02010000"
        );
        assertEq(constants.length, 0);
    }

    /// Three words on the RHS, two sequential nested as an input to the other.
    function testParseTwoNestedAsThirdInput() external {
        string memory s = "_:a(b() c<0 0>());";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);
        // c b a
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // c b a ops count
            hex"03"
            // c b a stack allocation
            hex"02"
            // c b a inputs count
            hex"00"
            // c b a outputs count
            hex"01"
            // c
            hex"04000000"
            // b
            hex"03000000"
            // a 2 inputs
            hex"02020000"
        );
        assertEq(constants.length, 0);
    }

    /// Several words, mixing sequential and nested logic to some depth, with
    /// several LHS items.
    function testParseSingleLHSNestingAndSequential00() external {
        string memory s = "_:a(b() c<0 0>(d() e<0>()));";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 5);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // e d c b a
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // e d c b a ops count
            hex"05"
            // e d c b a stack allocation
            hex"02"
            // e d c b a inputs count
            hex"00"
            // e d c b a outputs count
            hex"01"
            // e
            hex"06000000"
            // d
            hex"05000000"
            // c 2 inputs
            hex"04020000"
            // b
            hex"03000000"
            // a 2 inputs
            hex"02020000"
        );
    }

    /// Several words, mixing sequential and nested logic to some depth, with
    /// several LHS items.
    function testParseSingleLHSNestingAndSequential01() external {
        string memory s = "_:a(b() c<0 0>(d() e<0>()) f() g(h() i()));";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 9);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 4);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // i h g f e d c b a
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // i h g f e d c b a ops count
            hex"09"
            // i h g f e d c b a stack allocation
            hex"04"
            // i h g f e d c b a inputs count
            hex"00"
            // i h g f e d c b a outputs count
            hex"01"
            // i
            hex"0a000000"
            // h
            hex"09000000"
            // g 2 inputs
            hex"08020000"
            // f
            hex"07000000"
            // e
            hex"06000000"
            // d
            hex"05000000"
            // c 2 inputs
            hex"04020000"
            // b
            hex"03000000"
            // a 4 inputs
            hex"02040000"
        );
    }

    /// Several words, mixing sequential and nested logic to some depth, with
    /// several LHS items.
    function testParseSingleLHSNestingAndSequential02() external {
        string memory s = "_ _ _:a(b() c<0 0>(d())) d() e<0>(b());";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // d c b a d b e ops count
            hex"07"
            // d c b a d b e stack allocation
            hex"03"
            // d c b a d b e inputs count
            hex"00"
            // d c b a d b e outputs count
            hex"03"
            // d
            hex"05000000"
            // c 1 input
            hex"04010000"
            // b
            hex"03000000"
            // a 2 inputs
            hex"02020000"
            // d
            hex"05000000"
            // b
            hex"03000000"
            // e 1 input
            hex"06010000"
        );
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 7);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 3);
        assertEq(constants.length, 0);
    }

    /// More than 14 words deep triggers a whole other internal loop due to there
    /// being 7 words max per active source.
    function testParseSingleLHSNestingAndSequential03() external {
        string memory s =
            "_ _:a(b() c<0 0>(d() e<0>() f() g() h() i() j() k() l() m() n() o() p())) p(o() n(m() l() k() j() i() h() g() f() e<0>() d() c<0 0>() b() a()));";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 0x20);
        // High point is 13 for the second top level item + 1 for the first top
        // level item = 14.
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 14);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 2);
        assertEq(constants.length, 0);
        // Nested words compile RTL so that they execute LTR.
        // p o n m l k j i h g f e d c b a a b c d e f g h i j k l m n o p
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // p o n m l k j i h g f e d c b a a b c d e f g h i j k l m n o p ops count
            hex"20"
            // p o n m l k j i h g f e d c b a a b c d e f g h i j k l m n o p stack allocation
            hex"0e"
            // p o n m l k j i h g f e d c b a a b c d e f g h i j k l m n o p inputs count
            hex"00"
            // p o n m l k j i h g f e d c b a a b c d e f g h i j k l m n o p outputs count
            hex"02"
            // p
            hex"11000000"
            // o
            hex"10000000"
            // n
            hex"0f000000"
            // m
            hex"0e000000"
            // l
            hex"0d000000"
            // k
            hex"0c000000"
            // j
            hex"0b000000"
            // i
            hex"0a000000"
            // h
            hex"09000000"
            // g
            hex"08000000"
            // f
            hex"07000000"
            // e
            hex"06000000"
            // d
            hex"05000000"
            // c 13 inputs
            hex"040d0000"
            // b
            hex"03000000"
            // a 2 inputs
            hex"02020000"
            // a
            hex"02000000"
            // b
            hex"03000000"
            // c
            hex"04000000"
            // d
            hex"05000000"
            // e
            hex"06000000"
            // f
            hex"07000000"
            // g
            hex"08000000"
            // h
            hex"09000000"
            // i
            hex"0a000000"
            // j
            hex"0b000000"
            // k
            hex"0c000000"
            // l
            hex"0d000000"
            // m
            hex"0e000000"
            // n 13 inputs
            hex"0f0d0000"
            // o
            hex"10000000"
            // p 2 inputs
            hex"11020000"
        );
    }

    /// Two lines, each with LHS and RHS.
    function testParseTwoFullLinesSingleRHSEach() external {
        string memory s = "_:a(),_ _:b() c<0 0>(d());";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        assertEq(LibBytecode.sourceCount(bytecode), 1);

        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 4);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 3);

        assertEq(constants.length, 0);
        // a b d c
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // offset 0
            hex"0000"
            // a b d c ops count
            hex"04"
            // a b d c stack allocation
            hex"03"
            // a b d c inputs count
            hex"00"
            // a b d c outputs count
            hex"03"
            // a
            hex"02000000"
            // b
            hex"03000000"
            // d
            hex"05000000"
            // c 1 input
            hex"04010000"
        );
    }

    /// Two full sources, each with a single LHS and RHS.
    function testParseTwoFullSourcesSingleRHSEach() external {
        string memory s = "_:a();_:b();";
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes(s), LibMetaFixture.parseMeta());
        assertEq(LibBytecode.sourceCount(bytecode), 2);

        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        sourceIndex = 1;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 8);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (inputs, outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(constants.length, 0);
        // a ; b
        assertEq(
            bytecode,
            // 2 sources
            hex"02"
            // offset 0
            hex"0000"
            // 8 bytes pointers to second source (4 byte prefix + 1 opcode for a)
            hex"0008"
            // a ops count
            hex"01"
            // a stack allocation
            hex"01"
            // a inputs count
            hex"00"
            // a outputs count
            hex"01"
            // a
            hex"02000000"
            // b ops count
            hex"01"
            // b stack allocation
            hex"01"
            // b inputs count
            hex"00"
            // b outputs count
            hex"01"
            // b
            hex"03000000"
        );
    }
}
