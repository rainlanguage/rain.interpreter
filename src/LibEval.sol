// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "./LibInterpreterState.sol";

library LibEval {
    /// The main eval loop. Does as little as possible as it is an extremely hot
    /// performance and critical security path. Loads opcode/operand pairs from
    /// a precompiled source in the interpreter state and calls the function
    /// that the opcode points to. This function is in turn responsible for
    /// actually pushing/popping from the stack, etc. As `eval` receives the
    /// source index and stack top alongside its state, it supports recursive
    /// calls via. opcodes that can manage scoped substacks, etc. without `eval`
    /// needing to house that complexity itself.
    /// @param state_ The interpreter state to evaluate a source over.
    /// @param sourceIndex_ The index of the source to evaluate. MAY be an
    /// entrypoint or a nested call.
    /// @param stackTop_ The current stack top, MUST be equal to the stack bottom
    /// on the intepreter state if the current eval is for an entrypoint.
    function eval(
        InterpreterState memory state_,
        SourceIndex sourceIndex_,
        Pointer stackTop_
    ) internal view returns (Pointer) {
        unchecked {
            uint256 cursor_;
            uint256 end_;
            assembly ("memory-safe") {
                cursor_ := mload(
                    add(
                        // MUST point to compiled sources. Needs updating if the
                        // `IntepreterState` struct changes fields.
                        mload(add(state_, 0xC0)),
                        add(
                            0x20,
                            mul(
                                0x20,
                                // SourceIndex is a uint16 so needs cleaning.
                                and(sourceIndex_, 0xFFFF)
                            )
                        )
                    )
                )
                end_ := add(cursor_, mload(cursor_))
            }

            // Loop until complete.
            while (cursor_ < end_) {
                function(InterpreterState memory, Operand, Pointer)
                    internal
                    view
                    returns (Pointer) fn_;
                Operand operand_;
                cursor_ += 4;
                {
                    uint256 op_;
                    assembly ("memory-safe") {
                        op_ := mload(cursor_)
                        operand_ := and(op_, 0xFFFF)
                        fn_ := and(shr(16, op_), 0xFFFF)
                    }
                }
                stackTop_ = fn_(state_, operand_, stackTop_);
            }
            return stackTop_;
        }
    }
}