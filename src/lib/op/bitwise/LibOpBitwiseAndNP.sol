// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpBitwiseAndNP
/// @notice Opcode for computing bitwise AND from the top two items on the stack.
library LibOpBitwiseAndNP {
    /// The operand does nothing. Always 2 inputs and 1 output.
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // Always 2 inputs and 1 output.
        return (2, 1);
    }

    /// Bitwise AND the top two items on the stack.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        Pointer stackTopAfter;
        assembly ("memory-safe") {
            stackTopAfter := add(stackTop, 0x20)
            mstore(stackTopAfter, and(mload(stackTop), mload(stackTopAfter)))
        }
        return stackTopAfter;
    }

    /// Reference implementation for bitwise AND.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = inputs[0] & inputs[1];
        return outputs;
    }
}
