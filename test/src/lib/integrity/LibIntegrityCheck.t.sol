// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibIntegrityCheck, IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheck.sol";
import {OpcodeOutOfRange} from "src/error/ErrIntegrity.sol";
import {INTEGRITY_FUNCTION_POINTERS} from "src/generated/RainterpreterExpressionDeployer.pointers.sol";
import {ALL_STANDARD_OPS_LENGTH} from "src/lib/op/LibAllStandardOps.sol";

/// @title LibIntegrityCheckTest
/// @notice Tests for LibIntegrityCheck, particularly the OpcodeOutOfRange
/// bounds check on opcode indexes in bytecode.
contract LibIntegrityCheckTest is Test {
    /// Wrap integrityCheck2 in an external call so vm.expectRevert works.
    function integrityCheck2External(bytes memory fPointers, bytes memory bytecode, bytes32[] memory constants)
        external
        view
        returns (bytes memory)
    {
        return LibIntegrityCheck.integrityCheck2(fPointers, bytecode, constants);
    }

    /// Build minimal valid-structure bytecode containing a single source with
    /// a single opcode at the given opcode index. The ioByte declares 0 inputs
    /// and 1 output, and the stack allocation is 1.
    function buildSingleOpBytecode(uint256 opcodeIndex) internal pure returns (bytes memory) {
        // Bytecode layout:
        // [0]    sourceCount = 1
        // [1-2]  relative offset for source 0 = 0x0000
        // [3]    opsCount = 1
        // [4]    stackAllocation = 1
        // [5]    inputs = 0
        // [6]    outputs = 1
        // [7]    opcodeIndex
        // [8]    ioByte = 0x10 (0 inputs, 1 output)
        // [9-10] operand = 0x0000
        return abi.encodePacked(
            uint8(1), // sourceCount
            uint16(0), // relative offset source 0
            uint8(1), // opsCount
            uint8(1), // stackAllocation
            uint8(0), // inputs
            uint8(1), // outputs
            // Truncation is safe because callers bound opcodeIndex to uint8 range.
            // forge-lint: disable-next-line(unsafe-typecast)
            uint8(opcodeIndex), // opcode index
            uint8(0x10), // ioByte: 0 inputs, 1 output
            uint16(0) // operand
        );
    }

    /// An opcode index >= ALL_STANDARD_OPS_LENGTH must revert with
    /// OpcodeOutOfRange during the integrity check.
    function testOpcodeOutOfRange(uint256 opcodeIndex) external {
        opcodeIndex = bound(opcodeIndex, ALL_STANDARD_OPS_LENGTH, type(uint8).max);
        bytes memory bytecode = buildSingleOpBytecode(opcodeIndex);
        bytes32[] memory constants = new bytes32[](0);

        vm.expectRevert(abi.encodeWithSelector(OpcodeOutOfRange.selector, 0, opcodeIndex, ALL_STANDARD_OPS_LENGTH));
        this.integrityCheck2External(INTEGRITY_FUNCTION_POINTERS, bytecode, constants);
    }

    /// An opcode index just below the boundary must NOT revert with
    /// OpcodeOutOfRange. It may revert for other reasons (e.g., the opcode's
    /// own integrity function may reject the operand), but not OpcodeOutOfRange.
    function testOpcodeInRange() external view {
        // Opcode 0 is "stack", which with operand 0 reads stack index 0.
        // With 0 inputs declared, stack index 0 is out of bounds, so it will
        // revert — but NOT with OpcodeOutOfRange.
        uint256 maxValidIndex = ALL_STANDARD_OPS_LENGTH - 1;
        bytes memory bytecode = buildSingleOpBytecode(maxValidIndex);
        bytes32[] memory constants = new bytes32[](0);

        // We just verify the revert is NOT OpcodeOutOfRange.
        // The actual revert depends on what opcode maxValidIndex is, but
        // it should never be OpcodeOutOfRange.
        try this.integrityCheck2External(INTEGRITY_FUNCTION_POINTERS, bytecode, constants) {
        // If it doesn't revert, that's fine too — the opcode is in range.
        }
        catch (bytes memory reason) {
            // Ensure the revert is NOT OpcodeOutOfRange.
            // Truncation is guarded by the reason.length < 4 check.
            // forge-lint: disable-next-line(unsafe-typecast)
            bytes4 errorSig = reason.length >= 4 ? bytes4(reason) : bytes4(0);
            assertTrue(
                errorSig != OpcodeOutOfRange.selector, "should not revert with OpcodeOutOfRange for in-range opcode"
            );
        }
    }
}
