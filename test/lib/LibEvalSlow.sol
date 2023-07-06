// SPDX-License-Identifier: CAL
pragma solidity =0.8.18;

<<<<<<<< HEAD:test/lib/eval/LibEvalSlow.sol
import "src/lib/state/LibInterpreterState.sol";
========
import "src/lib/LibInterpreterState.sol";
>>>>>>>> 430eee5c5936112da2bdffd65d846224e8332055:test/lib/LibEvalSlow.sol

library LibEvalSlow {
    function evalSlow(InterpreterState memory state, SourceIndex sourceIndex, Pointer stackTop)
        internal
        view
        returns (Pointer)
    {
        bytes memory compiledSource = state.compiledSources[SourceIndex.unwrap(sourceIndex)];

        for (uint256 i = 0; i < compiledSource.length; i += 4) {
            uint256 pointer = uint256(uint8(compiledSource[i])) << 8 | uint256(uint8(compiledSource[i + 1]));
            uint256 operand = uint256(uint8(compiledSource[i + 2])) << 8 | uint256(uint8(compiledSource[i + 3]));

            function(InterpreterState memory, Operand, Pointer)
                internal
                view
                returns (Pointer) f;
            assembly ("memory-safe") {
                f := pointer
            }

            stackTop = f(state, Operand.wrap(operand), stackTop);
        }
        return stackTop;
    }

    function evalSimpleLoop(InterpreterState memory state, SourceIndex sourceIndex, Pointer stackTop)
        internal
        view
        returns (Pointer)
    {
        unchecked {
            uint256 cursor;
            uint256 end;
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
                end := add(cursor, mload(cursor))
            }

            // Loop until complete.
            while (cursor < end) {
                function(InterpreterState memory, Operand, Pointer)
                    internal
                    view
                    returns (Pointer) f;
                Operand operand;
                cursor += 4;
                {
                    uint256 op;
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
