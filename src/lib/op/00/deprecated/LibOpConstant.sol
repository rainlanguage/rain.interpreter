// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibStackPointer.sol";
import "../../../state/deprecated/LibInterpreterState.sol";
import "../../../integrity/deprecated/LibIntegrityCheck.sol";

/// Legacy error without op index.
error BadConstantRead(uint256 constantsLength, uint256 constantRead);

/// @title LibOpConstant
/// Implementation of copying a constant from the constants array to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpConstant {
    using LibStackPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;

    /// Copies a constant from the constants array to the stack. Reading past
    /// the end of the constants array will simply error.
    /// @param integrityCheckState The integrity check state.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function integrity(IntegrityCheckState memory integrityCheckState, Operand operand, Pointer stackTop)
        internal
        pure
        returns (Pointer)
    {
        if (Operand.unwrap(operand) >= integrityCheckState.constantsLength) {
            revert BadConstantRead(integrityCheckState.constantsLength, Operand.unwrap(operand));
        }
        return integrityCheckState.push(stackTop);
    }

    /// Copies a constant from the constants array to the stack. Does NOT do
    /// any bounds checking as the integrity check MUST already have been
    /// performed.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function run(InterpreterState memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(stackTop, mload(add(mload(add(state, 0x20)), mul(operand, 0x20))))
            stackTop := add(stackTop, 0x20)
        }
        return stackTop;
    }
}
