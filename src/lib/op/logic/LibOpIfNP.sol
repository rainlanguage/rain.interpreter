// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpIfNP
/// @notice Opcode to choose between two values based on a condition. If is
/// eager, meaning both values are evaluated before the condition is checked.
library LibOpIfNP {
    function integrity(IntegrityCheckStateNP memory, OperandV2) internal pure returns (uint256, uint256) {
        return (3, 1);
    }

    /// IF
    /// IF is a conditional. If the first item on the stack is nonero, the second
    /// item is returned, else the third item is returned.
    function run(InterpreterStateNP memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let condition := mload(stackTop)
            stackTop := add(stackTop, 0x40)
            mstore(stackTop, mload(sub(stackTop, mul(0x20, iszero(iszero(condition))))))
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of IF for testing.
    function referenceFn(InterpreterStateNP memory, OperandV2, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](1);
        outputs[0] = inputs[0] > 0 ? inputs[1] : inputs[2];
    }
}
