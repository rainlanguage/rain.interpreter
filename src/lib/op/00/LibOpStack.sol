// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibStackPointer.sol";
import "../../state/LibInterpreterState.sol";
import "../../integrity/LibIntegrityCheck.sol";

/// Thrown when a stack read index is outside the current stack top.
error OutOfBoundsStackRead(int256 stackTopIndex, uint256 stackRead);

/// @title LibOpStack
/// Implementation of copying a stack item from the stack to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpStack {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;

    /// Copies a stack item from the stack to the stack. Reading past the end of
    /// the stack is an integrity error. Reading below the highwater is also an
    /// integrity error.
    /// @param integrityCheckState The integrity check state.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function integrity(IntegrityCheckState memory integrityCheckState, Operand operand, Pointer stackTop)
        internal
        pure
        returns (Pointer)
    {
        unchecked {
            Pointer operandPointer = integrityCheckState.stackBottom.unsafeAddWords(Operand.unwrap(operand));

            // Ensure that we aren't reading beyond the current stack top.
            if (Pointer.unwrap(operandPointer) >= Pointer.unwrap(stackTop)) {
                revert OutOfBoundsStackRead(
                    integrityCheckState.stackBottom.toIndexSigned(stackTop), Operand.unwrap(operand)
                );
            }

            // Ensure that highwater is moved past any stack item that we
            // read so that copied values cannot later be consumed.
            if (Pointer.unwrap(operandPointer) > Pointer.unwrap(integrityCheckState.stackHighwater)) {
                integrityCheckState.stackHighwater = operandPointer;
            }

            return integrityCheckState.push(stackTop);
        }
    }

    /// Copies a constant from the constants array to the stack.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function run(InterpreterState memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            assembly ("memory-safe") {
                mstore(stackTop, mload(add(mload(state), mul(0x20, operand))))
                stackTop := add(stackTop, 0x20)
            }
            return stackTop;
        }
    }
}
