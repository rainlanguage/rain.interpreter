// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// Thrown if a zero condition is found.
/// @param ensureCode The ensure code that was evaluated. This is the low 16
/// bits of the operand. Allows the author to provide more context about which
/// condition failed if there is more than one in the expression.
/// @param errorIndex The index of the condition that failed.
error EnsureFailed(uint256 ensureCode, uint256 errorIndex);

/// @title LibOpEnsureNP
/// @notice Opcode to revert if any condition is zero.
library LibOpEnsureNP {
    using LibPointer for Pointer;

    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least one input.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        inputs = inputs > 0 ? inputs : 1;
        return (inputs, 0);
    }

    /// `ensure`
    /// List of conditions. If any condition is zero, the expression will revert.
    /// All conditions are eagerly evaluated and there are no outputs.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 condition;
        Pointer cursor = stackTop;
        assembly ("memory-safe") {
            for {
                let end := add(cursor, mul(shr(0x10, operand), 0x20))
                condition := mload(cursor)
            } and(lt(cursor, end), gt(condition, 0)) {} {
                cursor := add(cursor, 0x20)
                condition := mload(cursor)
            }
        }
        if (condition == 0) {
            // If somehow we hit an underflow on the pointer math, we'd still
            // prefer to see our ensure error rather than the generic underflow
            // error.
            unchecked {
                revert EnsureFailed(
                    uint16(Operand.unwrap(operand)), (Pointer.unwrap(cursor) - Pointer.unwrap(stackTop)) / 0x20
                );
            }
        }
        return cursor;
    }

    /// Gas intensive reference implementation of `ensure` for testing.
    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Unchecked so that any overflow errors come from the real
        // implementation.
        unchecked {
            for (uint256 i = 0; i < inputs.length; i++) {
                if (inputs[i] == 0) {
                    revert EnsureFailed(uint16(Operand.unwrap(operand)), i);
                }
            }
            outputs = new uint256[](0);
        }
    }
}
