// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "../../../interface/IInterpreterV1.sol";
import {LibInterpreterStateNP, InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {LibIntegrityCheckNP, IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibBytecode} from "../../bytecode/LibBytecode.sol";
import {LibEvalNP} from "../../eval/LibEvalNP.sol";

library LibOpCallNP {
    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal pure returns (uint256, uint256) {
        uint256 sourceIndex = Operand.unwrap(operand) & 0xFF;
        uint256 outputs = (Operand.unwrap(operand) >> 8) & 0xFF;

        (uint256 sourceInputs, uint256 sourceOutputs) =
            LibBytecode.sourceInputsOutputsLength(state.bytecode, sourceIndex);

        // Defer to the source inputs for the integrity check.
        // Outputs is the smaller of the source outputs and the call outputs.
        return (sourceInputs, outputs < sourceOutputs ? outputs : sourceOutputs);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 sourceIndex = Operand.unwrap(operand) & 0xFF;
        uint256 outputs = (Operand.unwrap(operand) >> 8) & 0xFF;
        uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0xFF;
        Pointer[] memory stackBottoms = state.stackBottoms;
        Pointer evalStackTop;

        // Copy inputs in.
        assembly ("memory-safe") {
            evalStackTop := mload(add(stackBottoms, mul(add(sourceIndex, 1), 0x20)))
            let end := evalStackTop
            evalStackTop := sub(evalStackTop, mul(inputs, 0x20))
            let cursor := evalStackTop
            for {

            } lt(cursor, end) {
                cursor := add(cursor, 0x20)
            } {
                mstore(cursor, mload(stackTop))
                stackTop := add(stackTop, 0x20)
            }
        }

        evalStackTop = LibEvalNP.evalLoopNP(state, evalStackTop);

        // Copy outputs out.
        assembly ("memory-safe") {
            let cursor := add(evalStackTop, mul(outputs, 0x20))
            for { } gt(cursor, evalStackTop) {
                cursor := sub(cursor, 0x20)
                stackTop := sub(stackTop, 0x20)
            } {
                mstore(stackTop, mload(cursor))
            }
        }

        return stackTop;
    }
}
