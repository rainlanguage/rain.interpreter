// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "test/util/lib/parse/LibMetaFixture.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseNOutputTest
/// Test that the parser can handle multi and zero outputs for RHS items when
/// they are singular on a line, and mandates individual items otherwise.
contract LibParseNOutputTest is Test {
    /// A single RHS item MAY have 0 outputs.
    function testParseNOutputExcessRHS0() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(":a();", LibMetaFixture.parseMetaV2());
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 1 ops
            hex"01"
            // 0 stack allocation
            hex"00"
            // 0 input
            hex"00"
            // 0 outputs
            hex"00"
            // a
            hex"02000000"
        );
        assertEq(constants.length, 0);
    }

    /// Multiple RHS items MUST NOT have 0 outputs. Tests two RHS items and zero
    /// LHS items.
    function testParseNOutputExcessRHS1() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 8));
        LibParse.parse(":a() b();", LibMetaFixture.parseMetaV2());
    }

    /// Multiple RHS items MUST NOT have 0 outputs. Tests two RHS items and one
    /// LHS item.
    function testParseNOutputExcessRHS2() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessRHSItems.selector, 9));
        LibParse.parse("_:a() b();", LibMetaFixture.parseMetaV2());
    }

    /// A single RHS item can have multiple outputs. This RHS item has nesting.
    function testParseNOutputNestedRHS() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse(":,_ _:a(b());", LibMetaFixture.parseMetaV2());
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 2 ops
            hex"02"
            // 2 stack allocation
            hex"02"
            // 0 inputs
            hex"00"
            // 2 outputs
            hex"02"
            // b
            hex"03000000"
            // a 1 input
            hex"02010000"
        );
        assertEq(constants.length, 0);
    }

    /// Multiple RHS items MUST NOT have multiple outputs. Tests two RHS items
    /// and three LHS items.
    function testParseNOutputExcessRHS3() external {
        vm.expectRevert(abi.encodeWithSelector(ExcessLHSItems.selector, 13));
        LibParse.parse("_ _ _:a() b();", LibMetaFixture.parseMetaV2());
    }

    /// Multiple output RHS items MAY be followed by single output RHS items,
    /// on a new line.
    function testParseBalanceStackOffsetsInputs() external {
        (bytes memory bytecode, uint256[] memory constants) =
            LibParse.parse("_ _:a(), _:b();", LibMetaFixture.parseMetaV2());
        assertEq(LibBytecode.sourceCount(bytecode), 1);
        assertEq(constants.length, 0);
        // a and b should be parsed and inputs are just ignored in the output
        // source.
        assertEq(
            bytecode,
            // 1 source
            hex"01"
            // 0 offset
            hex"0000"
            // 2 ops
            hex"02"
            // 3 stack allocation
            hex"03"
            // 0 inputs
            hex"00"
            // 3 outputs
            hex"03"
            // a
            hex"02000000"
            // b
            hex"03000000"
        );

        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 2);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 3);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 0);
        assertEq(outputs, 3);
    }
}
