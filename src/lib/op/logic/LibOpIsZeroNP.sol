// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpIsZeroNP
/// @notice Opcode to return 1 if the top item on the stack is zero, else 0.
library LibOpIsZeroNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (1, 1);
    }

    /// ISZERO
    /// ISZERO is 1 if the top item is zero, else 0.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            mstore(stackTop, iszero(mload(stackTop)))
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of ISZERO for testing.
    function referenceFn(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory outputs) {
        outputs = new uint256[](1);
        outputs[0] = inputs[0] == 0 ? 1 : 0;
    }
}
