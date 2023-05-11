// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../src/LibInterpreterState.sol";

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
}
