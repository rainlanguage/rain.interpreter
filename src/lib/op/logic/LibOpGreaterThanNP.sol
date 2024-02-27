// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpGreaterThanNP
/// @notice Opcode to return 1 if the first item on the stack is greater than
/// the second item on the stack, else 0.
library LibOpGreaterThanNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// GT
    /// GT is 1 if the first item is greater than the second item, else 0.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            mstore(stackTop, gt(a, mload(stackTop)))
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of GT for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](1);
        outputs[0] = inputs[0] > inputs[1] ? 1 : 0;
    }
}
