// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseEmptyTest
/// Tests parsing empty sources and constants. All we want to check is that the
/// parser doesn't revert and the correct number of sources and constants are
/// returned.
contract LibParseEmptyTest is Test {
    /// Check truly empty input bytes. Should not revert and return length 0
    /// sources and constants.
    function testParseEmpty00() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("", "");

        assertEq(LibBytecode.sourceCount(bytecode), 0);
        assertEq(bytecode, hex"");

        assertEq(constants.length, 0);
    }

    /// Check a single empty expression. Should not revert and return length 1
    /// sources and constants.
    function testParseEmpty01() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":;", "");
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(bytecode, hex"");

        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);

        assertEq(constants.length, 0);
    }

    /// Check two empty expressions. Should not revert and return length 2
    /// sources and constants.
    function testParseEmpty02() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":;:;", "");
        assertEq(LibBytecode.sourceCount(bytecode), 2);
        assertEq(bytecode, hex"");

        for (uint256 i = 0; i < 2; i++) {
            SourceIndex sourceIndex = SourceIndex.wrap(uint16(i));
            assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 0);
        }

        assertEq(constants.length, 0);
    }

    /// Check three empty expressions. Should not revert and return length 3
    /// sources and constants.
    function testParseEmpty03() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":;:;:;", "");
        assertEq(LibBytecode.sourceCount(bytecode), 3);
        assertEq(bytecode, hex"");

        for (uint256 i = 0; i < 3; i++) {
            SourceIndex sourceIndex = SourceIndex.wrap(uint16(i));
            assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 0);
        }

        assertEq(constants.length, 0);
    }

    /// Check four empty expressions. Should not revert and return length 4
    /// sources and constants.
    function testParseEmpty04() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":;:;:;:;", "");
        assertEq(LibBytecode.sourceCount(bytecode), 4);
        assertEq(bytecode, hex"");

        for (uint256 i = 0; i < 4; i++) {
            SourceIndex sourceIndex = SourceIndex.wrap(uint16(i));
            assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 0);
        }

        assertEq(constants.length, 0);
    }

    /// Check eight empty expressions. Should not revert and return length 8
    /// sources and constants.
    function testParseEmpty08() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":;:;:;:;:;:;:;:;", "");
        assertEq(LibBytecode.sourceCount(bytecode), 8);
        assertEq(bytecode, hex"");

        for (uint256 i = 0; i < 8; i++) {
            SourceIndex sourceIndex = SourceIndex.wrap(uint16(i));
            assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 0);
        }

        assertEq(constants.length, 0);
    }

    /// Check fifteen empty expressions. Should not revert and return length 15
    /// sources and constants.
    function testParseEmpty15() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":;:;:;:;:;:;:;:;:;:;:;:;:;:;:;", "");
        assertEq(LibBytecode.sourceCount(bytecode), 15);
        assertEq(bytecode, hex"");

        for (uint256 i = 0; i < 15; i++) {
            SourceIndex sourceIndex = SourceIndex.wrap(uint16(i));
            assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 0);
            assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 0);
        }

        assertEq(constants.length, 0);
    }

    /// Check sixteen empty expressions. Should revert as one of the sources is
    /// actually reserved to track the length of the sources in the internal
    /// state of the parser.
    function testParseEmptyError16() external {
        vm.expectRevert(abi.encodeWithSelector(MaxSources.selector));
        LibParse.parse(":;:;:;:;:;:;:;:;:;:;:;:;:;:;:;:;", "");
    }
}
