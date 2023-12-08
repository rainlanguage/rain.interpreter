// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";

import {ExpectedOperand, UnclosedOperand} from "src/error/ErrParse.sol";
import {OPERAND_PARSER_OFFSET_DISALLOWED} from "src/lib/parse/LibParseOperand.sol";
import {AuthoringMeta, LibParseMeta} from "src/lib/parse/LibParseMeta.sol";
import {LibParse, DuplicateLHSItem, WordSize} from "src/lib/parse/LibParse.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseNamedLHSTest
contract LibParseNamedLHSTest is Test {
    /// A few simple examples that should create some empty sources.
    function testParseNamedLHSEmptySourceExamples() external {
        string[3] memory examples0 = ["a _:;", "a b:;", "foo bar:;"];
        for (uint256 i = 0; i < examples0.length; i++) {
            (bytes memory bytecode0, uint256[] memory constants0) = LibParse.parse(bytes(examples0[i]), "");
            assertEq(LibBytecode.sourceCount(bytecode0), 1);
            uint256 sourceIndex0 = 0;
            assertEq(LibBytecode.sourceRelativeOffset(bytecode0, sourceIndex0), 0);
            assertEq(LibBytecode.sourceOpsCount(bytecode0, sourceIndex0), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode0, sourceIndex0), 2);
            (uint256 inputs0, uint256 outputs0) = LibBytecode.sourceInputsOutputsLength(bytecode0, sourceIndex0);
            assertEq(inputs0, 2);
            assertEq(outputs0, 2);
            assertEq(constants0.length, 0);
        }
    }

    /// Two sources with one named input each.
    function testParseNamedLHSTwoInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("a:;b:;", "");
        assertEq(
            bytecode,
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
            hex"01"
        );

        assertEq(LibBytecode.sourceCount(bytecode), 2);

        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 1);
        assertEq(outputs, 1);

        sourceIndex = 1;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 4);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (inputs, outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 1);
        assertEq(outputs, 1);

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

    /// Stack needs to index items by name correctly across lines.
    function testParseNamedLHSStackIndex() external {
        AuthoringMeta[] memory meta = new AuthoringMeta[](3);
        meta[0] = AuthoringMeta("stack", OPERAND_PARSER_OFFSET_DISALLOWED, "stack");
        meta[1] = AuthoringMeta("constant", OPERAND_PARSER_OFFSET_DISALLOWED, "constant");
        meta[2] = AuthoringMeta("c", OPERAND_PARSER_OFFSET_DISALLOWED, "c");
        bytes memory parseMeta = LibParseMeta.buildParseMeta(meta, 1);

        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("a _:1 2,b:a,:c(),d:3,e:d;", parseMeta);
        assertEq(
            bytecode,
            // 2 sources.
            hex"01"
            // offset 0
            hex"0000"
            // 6 ops
            hex"06"
            // 5 stack allocation
            hex"05"
            // 0 input
            hex"00"
            // 5 output
            hex"05"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
            // stack 0
            hex"00000000"
            // c
            hex"02000000"
            // constant 2
            hex"01000002"
            // stack 3
            hex"00000003"
        );
        assertEq(constants.length, 3);
        assertEq(constants[0], 1);
        assertEq(constants[1], 2);
        assertEq(constants[2], 3);
    }

    /// Duplicate names are disallowed in the same source.
    function testParseNamedErrorDuplicateSameSource() external {
        vm.expectRevert(abi.encodeWithSelector(DuplicateLHSItem.selector, 4));
        LibParse.parse("a:,a:;", "");
    }

    /// Duplicate names are allowed across different sources.
    function testParseNamedDuplicateDifferentSource() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("a b:1 2, e:a;c d:3 4,e:d;", "");
        assertEq(
            bytecode,
            // 2 sources.
            hex"02"
            // offset 0
            hex"0000"
            // offset 16
            hex"0010"
            // 3 ops
            hex"03"
            // 3 stack allocation
            hex"03"
            // 0 input
            hex"00"
            // 3 output
            hex"03"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
            // stack 0
            hex"00000000"
            // 3 ops
            hex"03"
            // 1 stack allocation
            hex"03"
            // 0 input
            hex"00"
            // 3 outputs
            hex"03"
            // constant 2
            hex"01000002"
            // constant 3
            hex"01000003"
            // stack 1
            hex"00000001"
        );
        assertEq(constants.length, 4);
        assertEq(constants[0], 1);
        assertEq(constants[1], 2);
        assertEq(constants[2], 3);
        assertEq(constants[3], 4);
    }
}
