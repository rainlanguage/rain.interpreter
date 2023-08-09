// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/lib/parse/LibParse.sol";
import "src/lib/bytecode/LibBytecode.sol";

/// @title LibParseInputsOnlyTest
/// @notice Tests that inputs (leading LHS items without RHS items) to an
/// expression are parsed correctly. This test only considers the case where
/// the expression is empty, and the inputs are the entire expression.
/// I.e. the expression is basically an identity function.
contract LibParseInputsOnlyTest is Test {
    /// Some inputs-only examples. Should produce an empty source.
    /// Test a single input.
    function testParseInputsOnlySingle() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_:;"), "");
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

    /// Test multiple inputs.
    function testParseInputsOnlyMultiple() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_ _:;"), "");
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
}
