// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibStackPointer.sol";
import "../../LibOp.sol";
import "../../../state/deprecated/LibInterpreterState.sol";
import "../../../integrity/deprecated/LibIntegrityCheck.sol";

/// @title LibOpChainId
/// Implementation of the EVM `CHAINID` opcode as a standard Rainlang opcode.
library LibOpChainId {
    using LibStackPointer for Pointer;
    using LibIntegrityCheck for IntegrityCheckState;

    /// Chain ID is an EVM constant, so it's always safe to push.
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

    /// Pushes the current chain ID onto the stack.
    /// @param stackTop The stack top.
    /// @return The new stack top.
    function run(InterpreterState memory, Operand, Pointer stackTop) internal view returns (Pointer) {
        return stackTop.unsafePush(block.chainid);
    }
}
