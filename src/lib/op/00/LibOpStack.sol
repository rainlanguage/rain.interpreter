// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibStackPointer.sol";
import "../../state/LibInterpreterState.sol";
import "../../integrity/LibIntegrityCheck.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// Thrown when a stack read index is outside the current stack top.
error OutOfBoundsStackRead(uint256 stackTopIndex, uint256 stackRead);

/// @title LibOpStack
/// Implementation of copying a stack item from the stack to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpStack {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;
    using LibIntegrityCheckNP for IntegrityCheckStateNP;

    /// Copies a stack item from the stack to the stack. Reading past the end of
    /// the stack is an integrity error. Reading a value moves the highwater so
    /// that the value cannot be consumed. i.e. the stack is immutable once read.
    /// @param integrityCheckState The integrity check state.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function integrity(IntegrityCheckState memory integrityCheckState, Operand operand, Pointer stackTop)
        internal
        pure
        returns (Pointer)
    {
        Pointer operandPointer = integrityCheckState.stackBottom.unsafeAddWords(Operand.unwrap(operand));

        // Ensure that we aren't reading beyond the current stack top.
        if (Pointer.unwrap(operandPointer) >= Pointer.unwrap(stackTop)) {
            revert OutOfBoundsStackRead(
                // Assume that negative stack top has been handled elsewhere by
                // caller.
                uint256(integrityCheckState.stackBottom.toIndexSigned(stackTop)),
                Operand.unwrap(operand)
            );
        }

        // Ensure that highwater is moved past any stack item that we
        // read so that copied values cannot later be consumed.
        if (Pointer.unwrap(operandPointer) > Pointer.unwrap(integrityCheckState.stackHighwater)) {
            integrityCheckState.stackHighwater = operandPointer;
        }

        return integrityCheckState.push(stackTop);
    }

    function integrityNP(IntegrityCheckStateNP memory state, Operand operand, uint256)
        internal
        pure
        returns (Operand, uint256, uint256)
    {
        // Operand is the index so ensure it doesn't exceed the stack index.
        if (Operand.unwrap(operand) >= state.stackIndex) {
            revert OutOfBoundsStackRead(state.stackIndex, Operand.unwrap(operand));
        }

        // Move the read highwater if needed.
        if (Operand.unwrap(operand) > state.readHighwater) {
            state.readHighwater = Operand.unwrap(operand);
        }

        return (operand, 0, 1);
    }

    /// Copies a stack item from the stack array to the stack.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function run(InterpreterState memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(stackTop, mload(add(mload(state), mul(0x20, operand))))
            stackTop := add(stackTop, 0x20)
        }
        return stackTop;
    }
}
