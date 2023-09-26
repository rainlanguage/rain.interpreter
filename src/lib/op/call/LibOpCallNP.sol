// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "../../../interface/IInterpreterV1.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
import {LibBytecode} from "../../bytecode/LibBytecode.sol";
import {LibEvalNP} from "../../eval/LibEvalNP.sol";

/// Thrown when the outputs requested by the operand exceed the outputs
/// available from the source.
/// @param sourceOutputs The number of outputs available from the source.
/// @param outputs The number of outputs requested by the operand.
error CallOutputsExceedSource(uint256 sourceOutputs, uint256 outputs);

library LibOpCallNP {
    using LibPointer for Pointer;

    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal pure returns (uint256, uint256) {
        uint256 sourceIndex = Operand.unwrap(operand) & 0xFF;
        uint256 outputs = (Operand.unwrap(operand) >> 8) & 0xFF;

        (uint256 sourceInputs, uint256 sourceOutputs) =
            LibBytecode.sourceInputsOutputsLength(state.bytecode, sourceIndex);

        if (sourceOutputs < outputs) {
            revert CallOutputsExceedSource(sourceOutputs, outputs);
        }

        return (sourceInputs, outputs);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 sourceIndex = Operand.unwrap(operand) & 0xFF;
        uint256 outputs = (Operand.unwrap(operand) >> 8) & 0xFF;
        uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0xFF;
        Pointer[] memory stackBottoms = state.stackBottoms;
        Pointer evalStackTop;

        // Copy inputs in. The inputs have to be copied in reverse order so that
        // the top of the stack from the perspective of `call`, i.e. the first
        // input to call, is the bottom of the stack from the perspective of the
        // callee.
        assembly ("memory-safe") {
            evalStackTop := mload(add(stackBottoms, mul(add(sourceIndex, 1), 0x20)))
            let end := add(stackTop, mul(inputs, 0x20))
            for {} lt(stackTop, end) { stackTop := add(stackTop, 0x20) } {
                evalStackTop := sub(evalStackTop, 0x20)
                mstore(evalStackTop, mload(stackTop))
            }
        }

        uint256 currentSourceIndex = state.sourceIndex;
        state.sourceIndex = sourceIndex;
        evalStackTop = LibEvalNP.evalLoopNP(state, evalStackTop);
        state.sourceIndex = currentSourceIndex;

        // Copy outputs out.
        assembly ("memory-safe") {
            stackTop := sub(stackTop, mul(outputs, 0x20))
            let end := add(evalStackTop, mul(outputs, 0x20))
            let cursor := stackTop
            for {} lt(evalStackTop, end) {
                cursor := add(cursor, 0x20)
                evalStackTop := add(evalStackTop, 0x20)
            } { mstore(cursor, mload(evalStackTop)) }
        }

        return stackTop;
    }
}
