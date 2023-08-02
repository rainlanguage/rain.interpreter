// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseIgnoredLHSTest
/// Tests parsing ignored LHS items. An ignored LHS item is one that starts with
/// an underscore and is cheaper than named LHS items as they don't need to be
/// tracked for potential use in the RHS.
contract LibParseIgnoredLHSTest is Test {
    bytes internal meta;

    /// Constructor just builds the shared meta.
    constructor() {
        bytes32[] memory words = new bytes32[](1);
        words[0] = bytes32("a");
        meta = LibParseMeta.buildMeta(words, 1);
    }

    /// A lone underscore should parse to an empty source and constant.
    function testParseIgnoredLHSLoneUnderscore() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:;", "");
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
        assertEq(bytecode, hex"");
        assertEq(constants.length, 0);
    }

    /// Two underscores should parse to an empty source and constant.
    function testParseIgnoredLHSTwoUnderscores() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_ _:;", "");
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 2);
        assertEq(bytecode, hex"");

        assertEq(constants.length, 0);
    }

    /// An underscore that is NOT an input should parse to a non-empty source
    /// with no constants.
    function testParseIgnoredLHSUnderscoreNotInput() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":,_:a();", meta);
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
        assertEq(bytecode, hex"00000000");

        assertEq(constants.length, 0);
    }

    /// An underscore followed by some alpha chars should parse to an empty
    /// source and constant.
    function testParseIgnoredLHSUnderscoreAlpha() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_a:;", "");
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
        assertEq(bytecode, hex"");
        assertEq(constants.length, 0);
    }

    /// Two ignored alphas should parse to an empty source and constant.
    function testParseIgnoredLHSTwoAlphas() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_a _b:;", "");
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 2);
        assertEq(bytecode, hex"");

        assertEq(constants.length, 0);
    }

    // Ignored alphas can be multiple chars long each.
    function testParseIgnoredLHSAlphaTooLong() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_foo _bar:;", "");
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
        assertEq(bytecode, hex"");
        assertEq(constants.length, 0);
    }

    /// Ignored words have no size limit. We can parse a 32 char ignored word.
    /// Normally words are limited to 31 chars.
    function testParseIgnoredWordTooLong() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
        assertEq(bytecode, hex"");
        assertEq(constants.length, 0);
    }
}
