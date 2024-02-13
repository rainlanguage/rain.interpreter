// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "../../../interface/unstable/IInterpreterV2.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// Thrown when a constant read index is outside the constants array.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);

/// @title LibOpConstantNP
/// Implementation of copying a constant from the constants array to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpConstantNP {
    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal pure returns (uint256, uint256) {
        // Operand is the index so ensure it doesn't exceed the constants length.
        if ((Operand.unwrap(operand) & 0xFFFF) >= state.constants.length) {
            revert OutOfBoundsConstantRead(state.opIndex, state.constants.length, Operand.unwrap(operand));
        }
        // As inputs MUST always be 0, we don't have to check the high byte of
        // the operand here, the integrity check will do that for us.
        return (0, 1);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256[] memory constants = state.constants;
        // Skip index OOB check and rely on integrity check for that.
        assembly ("memory-safe") {
            let value := mload(add(constants, mul(add(and(operand, 0xFFFF), 1), 0x20)))
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory state, Operand operand, uint256[] memory)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        uint256 index = Operand.unwrap(operand) & 0xFFFF;
        outputs = new uint256[](1);
        outputs[0] = state.constants[index];
    }
}
