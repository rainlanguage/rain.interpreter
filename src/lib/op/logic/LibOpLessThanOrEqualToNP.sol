// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpLessThanOrEqualToNP
/// @notice Opcode to return 1 if the first item on the stack is less than or
/// equal to the second item on the stack, else 0.
library LibOpLessThanOrEqualToNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// LTE
    /// LTE is 1 if the first item is less than or equal to the second item,
    /// else 0.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            mstore(stackTop, iszero(gt(a, mload(stackTop))))
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of LTE for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs) internal pure returns (uint256[] memory outputs) {
        outputs = new uint256[](1);
        outputs[0] = inputs[0] <= inputs[1] ? 1 : 0;
    }
}
