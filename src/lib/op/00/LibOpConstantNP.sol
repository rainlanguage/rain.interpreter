// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// Thrown when a constant read index is outside the constants array.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);

/// @title LibOpConstantNP
/// Implementation of copying a constant from the constants array to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpConstantNP {
    function integrity(IntegrityCheckStateNP memory state, Operand operand) internal pure returns (uint256, uint256) {
        // Operand is the index so ensure it doesn't exceed the constants length.
        if (Operand.unwrap(operand) >= state.constantsLength) {
            revert OutOfBoundsConstantRead(state.opIndex, state.constantsLength, Operand.unwrap(operand));
        }
        // As inputs MUST always be 0, we don't have to check the high byte of
        // the operand here, the integrity check will do that for us.
        return (0, 1);
    }

    function run(InterpreterStateNP memory state, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let constantValue := mload(add(mload(add(state, 0x20)), mul(operand, 0x20)))
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, constantValue)
        }
        return stackTop;
    }
}
