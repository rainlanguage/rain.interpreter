// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseNamedLHSTest
contract LibParseNamedLHSTest is Test {
    /// A few simple examples that should create some empty sources.
    function testParseNamedLHSEmptySourceExamples() external {
        string[3] memory examples0 = ["a _:;", "a b:;", "foo bar:;"];
        for (uint256 i = 0; i < examples0.length; i++) {
            (bytes memory bytecode0, uint256[] memory constants0) = LibParse.parse(bytes(examples0[i]), "");
            assertEq(LibBytecode.sourceCount(bytecode0), 1);
            SourceIndex sourceIndex0 = SourceIndex.wrap(0);
            assertEq(LibBytecode.sourceRelativeOffset(bytecode0, sourceIndex0), 0);
            assertEq(LibBytecode.sourceOpsLength(bytecode0, sourceIndex0), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode0, sourceIndex0), 2);
            assertEq(LibBytecode.sourceInputsLength(bytecode0, sourceIndex0), 2);
            assertEq(LibBytecode.sourceOutputsLength(bytecode0, sourceIndex0), 2);
            assertEq(constants0.length, 0);
        }
    }

    /// Two sources with one named input each.
    function testParseNamedLHSTwoInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("a:;b:;", "");
        assertEq(bytecode,
        // 2 sources.
        hex"02"
        // offset 0
        hex"0000"
        // offset 4
        hex"0004"
        // 0 ops
        hex"00"
        // 1 stack allocation
        hex"01"
        // 1 input
        hex"01"
        // 1 output
        hex"01"
        // 0 ops
        hex"00"
        // 1 stack allocation
        hex"01"
        // 1 input
        hex"01"
        // 1 output
        hex"01");

        assertEq(LibBytecode.sourceCount(bytecode), 2);

        SourceIndex sourceIndex = SourceIndex.wrap(0);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);

        sourceIndex = SourceIndex.wrap(1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 4);
        assertEq(LibBytecode.sourceOpsLength(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceInputsLength(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceOutputsLength(bytecode, sourceIndex), 1);

        assertEq(constants.length, 0);
    }

    /// Exceeding the maximum length of a word should revert. Testing a 32 char
    /// is right at the limit.
    function testParseNamedError32() external {
        // Only the first 32 chars are visible in the error.
        vm.expectRevert(abi.encodeWithSelector(WordSize.selector, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        // 32 chars is too long.
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }

    /// Exceeding the maximum length of a word should revert. Testing a 33 char
    /// word shows the difference between the actual source and the error.
    /// (The latter is truncated).
    function testParseNamedError33() external {
        // Only the first 32 chars are visible in the error.
        vm.expectRevert(abi.encodeWithSelector(WordSize.selector, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        // 33 chars is too long.
        LibParse.parse("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;", "");
    }
}
