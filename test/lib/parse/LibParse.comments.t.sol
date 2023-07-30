// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";

/// @title LibParseCommentsTest
/// Test that the parser correctly parses comments.
contract LibParseCommentsTest is Test {
    /// Build a shared meta for all the tests to simplify the implementation
    /// of each. It also makes it easier to compare the expected bytes across
    /// tests.
    bytes internal meta;

    /// Constructor just builds the shared meta.
    constructor() {
        bytes32[] memory words = new bytes32[](2);
        words[0] = bytes32("a");
        words[1] = bytes32("b");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// A single comment with no expected bytecode.
    function testParseCommentNoWords() external {
        string memory s = "/* empty output */:;";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        assertEq(sources[0], hex"");
        assertEq(constants.length, 0);
    }

    /// A single comment with a single word in the bytecode.
    function testParseCommentSingleWord() external {
        string memory s = "/* one word */\n_:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// Comments can be on the same line as source if there is some whitespace.
    function testParseCommentSingleWordSameLine() external {
        string memory s = "/* same line comment */ _:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// Comments can appear between sources.
    function testParseCommentBetweenSources() external {
        string memory s = "_:a(); /* interstitial comment */ _:b();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 2);
        // a
        assertEq(sources[0], hex"00000000");
        // b
        assertEq(sources[1], hex"00010000");
        assertEq(constants.length, 0);
    }

    /// Comments can appear after sources.
    function testParseCommentAfterSources() external {
        string memory s = "_:a(); _:b(); /* trailing comment */";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 2);
        // a
        assertEq(sources[0], hex"00000000");
        // b
        assertEq(sources[1], hex"00010000");
        assertEq(constants.length, 0);
    }

    /// Multiple comments can appear in a row.
    function testParseCommentMultiple() external {
        string memory s = "/* comment 1 */ /* comment 2 */ _:a(); /* comment 3 */ _:b(); /* comment 4 */";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 2);
        // a
        assertEq(sources[0], hex"00000000");
        // b
        assertEq(sources[1], hex"00010000");
        assertEq(constants.length, 0);
    }

    /// Comments can have many astericks within them without breaking out of the
    /// comment. Tests extra leading astericks.
    function testParseCommentManyAstericks() external {
        string memory s = "/** _ */ _:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// Comments can have many astericks within them without breaking out of the
    /// comment. Tests extra trailing astericks.
    function testParseCommentManyAstericksTrailing() external {
        string memory s = "/* _ **/ _:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// Comments can be very long and span multiple lines.
    function testParseCommentLong() external {
        string memory s =
            "/* this is a very \nlong comment that \nspans multiple lines **** and has many \nwords */ _:a();";
        (bytes[] memory sources, uint256[] memory constants) = LibParse.parse(bytes(s), meta);
        assertEq(sources.length, 1);
        // a
        assertEq(sources[0], hex"00000000");
        assertEq(constants.length, 0);
    }

    /// Comments cause yang so cannot be without trailing whitespace.
    function testParseCommentNoTrailingWhitespace() external {
        string memory s = "/* comment */_:a();";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedLHSChar.selector, 13, "_"));
        LibParse.parse(bytes(s), meta);
    }

    /// Comments cannot be in an ignored LHS item.
    function testParseCommentInIgnoredLHS() external {
        string memory s = "_/* comment */:a();";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedComment.selector, 1));
        LibParse.parse(bytes(s), meta);
    }

    /// Comments cannot be in a named LHS item.
    function testParseCommentInNamedLHS() external {
        string memory s = "_a/* comment */:a();";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedComment.selector, 2));
        LibParse.parse(bytes(s), meta);
    }

    /// Comments cannot be in the whitespace between LHS items.
    function testParseCommentInLHSWhitespace() external {
        string memory s = "_ /* comment */ _:a();";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedComment.selector, 2));
        LibParse.parse(bytes(s), meta);
    }

    /// Comments cannot be in the RHS. Tests the start of the RHS.
    function testParseCommentInRHS() external {
        string memory s = "_:/* comment */a();";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedComment.selector, 2));
        LibParse.parse(bytes(s), meta);
    }

    /// Comments cannot be in the RHS. Tests the middle of the RHS.
    function testParseCommentInRHS2() external {
        string memory s = "_:a()/* comment */ b();";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedComment.selector, 5));
        LibParse.parse(bytes(s), meta);
    }

    /// Comments cannot be in the RHS. Tests the end of the RHS.
    function testParseCommentInRHS3() external {
        string memory s = "_:a()/* comment */;";
        vm.expectRevert(abi.encodeWithSelector(UnexpectedComment.selector, 5));
        LibParse.parse(bytes(s), meta);
    }

    /// Unclosed comments don't escape the data bounds.
    function testParseCommentUnclosed() external {
        string memory s = "/* unclosed comment";
        vm.expectRevert(abi.encodeWithSelector(ParserOutOfBounds.selector));
        LibParse.parse(bytes(s), meta);
    }

    /// A comment that starts the end sequence but doesn't finish it is unclosed
    /// so must revert and not escape the data bounds.
    function testParseCommentUnclosed2() external {
        string memory s = "/* unclosed comment *";
        vm.expectRevert(abi.encodeWithSelector(ParserOutOfBounds.selector));
        LibParse.parse(bytes(s), meta);
    }
}
