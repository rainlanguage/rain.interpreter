// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/parse/LibMetaFixture.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseIgnoredLHSTest
/// Tests parsing ignored LHS items. An ignored LHS item is one that starts with
/// an underscore and is cheaper than named LHS items as they don't need to be
/// tracked for potential use in the RHS.
contract LibParseIgnoredLHSTest is Test {
    /// A lone underscore should parse to an empty source and constant.
    function testParseIgnoredLHSLoneUnderscore() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
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
            // 1 input
            hex"01"
            // 1 output
            hex"01"
        );
        assertEq(constants.length, 0);
    }

    /// Two underscores should parse to an empty source and constant.
    function testParseIgnoredLHSTwoUnderscores() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_ _:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 2);
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

    /// Inputs can be on multiple lines if there are no RHS items.
    function testParseIgnoredLHSMultipleLines() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_:,_ _:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 3);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 0 ops
            hex"00"
            // 3 stack allocation
            hex"03"
            // 3 inputs
            hex"03"
            // 3 outputs
            hex"03"
        );

        assertEq(constants.length, 0);
    }

    /// An underscore that is NOT an input should parse to a non-empty source
    /// with no constants.
    function testParseIgnoredLHSUnderscoreNotInput() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":,_:a();", LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 ops
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // a
            hex"00000000"
        );

        assertEq(constants.length, 0);
    }

    /// An underscore followed by some alpha chars should parse to an empty
    /// source and constant.
    function testParseIgnoredLHSUnderscoreAlpha() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_a:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
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
            // 1 input
            hex"01"
            // 1 output
            hex"01"
        );
        assertEq(constants.length, 0);
    }

    /// Two ignored alphas should parse to an empty source and constant.
    function testParseIgnoredLHSTwoAlphas() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_a _b:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 2);
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

    // Ignored alphas can be multiple chars long each.
    function testParseIgnoredLHSAlphaTooLong() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_foo _bar:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 2);
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
            // 2 output
            hex"02"
        );
        assertEq(constants.length, 0);
    }

    /// Ignored words have no size limit. We can parse a 32 char ignored word.
    /// Normally words are limited to 31 chars.
    function testParseIgnoredWordTooLong() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);
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
            // 1 input
            hex"01"
            // 1 output
            hex"01"
        );
        assertEq(constants.length, 0);
    }
}
