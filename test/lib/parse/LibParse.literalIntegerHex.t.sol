// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {Test} from "forge-std/Test.sol";
import {LibMetaFixture} from "test/util/lib/parse/LibMetaFixture.sol";

import {LibParse} from "src/lib/parse/LibParse.sol";
import {LibBytecode} from "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseLiteralIntegerHexTest
/// Tests parsing integer literal hex values.
contract LibParseLiteralIntegerHexTest is Test {
    /// Check a single hex literal. Should not revert and return length 1
    /// sources and constants.
    function testParseIntegerLiteralHex00() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse("_: 0xa2;", LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);

        assertEq(
            bytecode,
            // 1 source.
            hex"01"
            // offset 0
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // constant 0
            hex"01000000"
        );

        assertEq(constants.length, 1);
        assertEq(constants[0], 0xa2);
    }

    /// Check 2 hex literals. Should not revert and return one source and
    /// length 2 constants.
    function testParseIntegerLiteralHex01() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_ _: 0xa2 0x03;", LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 2);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 2);

        assertEq(
            bytecode,
            // 1 source.
            hex"01"
            // offset 0
            hex"0000"
            // 2 ops
            hex"02"
            // 2 stack allocation
            hex"02"
            // 0 inputs
            hex"00"
            // 2 outputs
            hex"02"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
        );

        assertEq(constants.length, 2);
        assertEq(constants[0], 0xa2);
        assertEq(constants[1], 0x03);
    }

    /// Check 3 hex literals with 2 dupes. Should dedupe and respect ordering.
    function testParseIntegerLiteralHex02() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_ _ _: 0xa2 0x03 0xa2;", LibMetaFixture.parseMeta());
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 3);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 3);
        // Sources represents all 3 literals, but the dupe is deduped so that the
        // operands only reference the first instance of the duped constant.
        assertEq(
            bytecode,
            // 1 source.
            hex"01"
            // offset 0
            hex"0000"
            // 3 ops
            hex"03"
            // 3 stack allocation
            hex"03"
            // 0 inputs
            hex"00"
            // 3 outputs
            hex"03"
            // constant 0
            hex"01000000"
            // constant 1
            hex"01000001"
            // constant 0
            hex"01000000"
        );

        assertEq(constants.length, 2);
        assertEq(constants[0], 0xa2);
        assertEq(constants[1], 0x03);
    }

    /// Check that we can parse uint256 max int in hex form.
    function testParseIntegerLiteralHexUint256Max() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(
            "_: 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;", LibMetaFixture.parseMeta()
        );
        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 1);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 1);
        assertEq(
            bytecode,
            // 1 source.
            hex"01"
            // offset 0
            hex"0000"
            // 1 op
            hex"01"
            // 1 stack allocation
            hex"01"
            // 0 inputs
            hex"00"
            // 1 output
            hex"01"
            // constant 0
            hex"01000000"
        );
        assertEq(constants.length, 1);
        assertEq(constants[0], type(uint256).max);
    }
}
