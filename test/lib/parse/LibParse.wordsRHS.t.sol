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
    function testParseSingleWord() external view {
        string memory s = "_:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        console2.log(s);
        console2.logBytes(sources[0]);
    }

    /// Two sequential words on the RHS.
    function testParseTwoSequential() external view {
        string memory s = "_ _:a() b();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        console2.log(s);
        console2.logBytes(sources[0]);
    }

    /// Two words on the RHS, one nested as an input to the other.
    function testParseTwoNested() external view {
        string memory s = "_:a(b());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        console2.log(s);
        console2.logBytes(sources[0]);
    }

    /// Three words on the RHS, two sequential nested as an input to the other.
    function testParseTwoNestedAsThirdInput() external view {
        string memory s = "_:a(b() c());";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        console2.log(s);
        console2.logBytes(sources[0]);
    }

    /// Several words, mixing sequential and nested logic to some depth, but
    /// still only one LHS in aggregate.
    function testParseSingleLHSNestingAndSequential() external view {
        string memory s = "_:a(b() c(d() e()));";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        console2.log(s);
        console2.logBytes(sources[0]);
    }

    /// Two full lines, each with a single LHS and RHS.
    function testParseTwoFullLinesSingleRHSEach() external view {
        string memory s = "_:a();_:b();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        (constants);
        console2.log(s);
        console2.logBytes(sources[0]);
        console2.logBytes(sources[1]);
    }


    // function testParseNamedGas00() external pure {
    //     LibParse.parse("a:;");
    // }

    // function testParseNamedGas01() external pure {
    //     LibParse.parse("a:;");
    // }

    // function testParseNamedGas02() external pure {
    //     LibParse.parse("aa:;");
    // }

    // function testParseNamedGas03() external pure {
    //     LibParse.parse("aaa:;");
    // }

    // function testParseNamedGas04() external pure {
    //     LibParse.parse("aaaa:;");
    // }

    // function testParseNamedGas05() external pure {
    //     LibParse.parse("aaaaa:;");
    // }

    // function testParseNamedGas06() external pure {
    //     LibParse.parse("aaaaaa:;");
    // }

    // function testParseNamedGas07() external pure {
    //     LibParse.parse("aaaaaaa:;");
    // }

    // function testParseNamedGas08() external pure {
    //     LibParse.parse("aaaaaaaa:;");
    // }

    // function testParseNamedGas09() external pure {
    //     LibParse.parse("aaaaaaaaa:;");
    // }

    // function testParseNamedGas10() external pure {
    //     LibParse.parse("aaaaaaaaaa:;");
    // }

    // function testParseNamedGas11() external pure {
    //     LibParse.parse("aaaaaaaaaaa:;");
    // }

    // function testParseNamedGas12() external pure {
    //     LibParse.parse("aaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas13() external pure {
    //     LibParse.parse("aaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas14() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas15() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas16() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas17() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas18() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas19() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas20() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas21() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas22() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas23() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas24() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas25() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas26() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas27() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas28() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas29() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas30() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas31() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas32() external pure {
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }

    // function testParseNamedGas33() external {
    //     vm.expectRevert(abi.encodeWithSelector(WordTooLong.selector, 0));
    //     LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;");
    // }
}
