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
    /// @param state The interpreter state to evaluate a source over.
    /// @param sourceIndex The index of the source to evaluate. MAY be an
    /// entrypoint or a nested call.
    /// @param stackTop The current stack top, MUST be equal to the stack bottom
    /// on the intepreter state if the current eval is for an entrypoint.
    function eval(InterpreterState memory state, SourceIndex sourceIndex, Pointer stackTop)
        internal
        view
        returns (Pointer)
    {
        unchecked {
            uint256 cursor;
            uint256 end;
            uint256 length;
            uint256 m;
            assembly ("memory-safe") {
                cursor :=
                    mload(
                        add(
                            // MUST point to compiled sources. Needs updating if the
                            // `IntepreterState` struct changes fields.
                            mload(add(state, 0xC0)),
                            add(
                                0x20,
                                mul(
                                    0x20,
                                    // SourceIndex is a uint16 so needs cleaning.
                                    and(sourceIndex, 0xFFFF)
                                )
                            )
                        )
                    )
                length := mload(cursor)
                m := mod(length, 0x20)
                cursor := add(cursor, 0x20)
                end := add(cursor, sub(length, m))
            }

            function(InterpreterState memory, Operand, Pointer)
                    internal
                    view
                    returns (Pointer) f;
            Operand operand;
            uint256 op;
            while (cursor < end) {
                assembly ("memory-safe") {
                    op := mload(cursor)
                    f := shr(240, op)
                    operand := and(shr(224, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(208, op), 0xFFFF)
                    operand := and(shr(192, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(176, op), 0xFFFF)
                    operand := and(shr(160, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(144, op), 0xFFFF)
                    operand := and(shr(128, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(112, op), 0xFFFF)
                    operand := and(shr(96, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(80, op), 0xFFFF)
                    operand := and(shr(64, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(48, op), 0xFFFF)
                    operand := and(shr(32, op), 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                assembly ("memory-safe") {
                    f := and(shr(16, op), 0xFFFF)
                    operand := and(op, 0xFFFF)
                }
                stackTop = f(state, operand, stackTop);
                cursor += 0x20;
            }

            // Loop until complete.
            cursor -= 0x20;
            end = cursor + m;
            while (cursor < end) {
                cursor += 4;
                {
                    assembly ("memory-safe") {
                        op := mload(cursor)
                        operand := and(op, 0xFFFF)
                        f := and(shr(16, op), 0xFFFF)
                    }
                }
                stackTop = f(state, operand, stackTop);
            }
            return stackTop;
        }
    }
}
