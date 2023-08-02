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
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_;"), "");
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

    /// Test multiple inputs.
    function testParseInputsOnlyMultiple() external {
        (bytes memory bytecode, uint256[] memory constants) = LibParse.parse(bytes("_ _;"), "");
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
}
