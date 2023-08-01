// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibStackPointer.sol";
import "../../state/LibInterpreterState.sol";
import "../../integrity/LibIntegrityCheck.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpMaxUint256
/// Exposes `type(uint256).max` as a Rainlang opcode.
library LibOpMaxUint256 {
    using LibStackPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;
    using LibIntegrityCheckNP for IntegrityCheckStateNP;

    /// `type(uint256).max` is an Solidity constant, so it's always safe to push.
    /// There are no inputs, so no need to check the stack.
    /// @param integrityCheckState The integrity check state.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function integrity(IntegrityCheckState memory integrityCheckState, Operand, Pointer stackTop)
        internal
        pure
        returns (Pointer)
    {
        return integrityCheckState.push(stackTop);
    }

    function integrityNP(IntegrityCheckStateNP memory, Operand, uint256) internal pure returns (Operand, uint256, uint256) {
        return (Operand.wrap(0), 0, 1);
    }

    /// Pushes `type(uint256).max` onto the stack.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function run(InterpreterState memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        return stackTop.unsafePush(type(uint256).max);
    }
}
