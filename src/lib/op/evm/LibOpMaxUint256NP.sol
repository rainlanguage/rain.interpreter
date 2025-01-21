// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpMaxUint256NP
/// Exposes `type(uint256).max` as a Rainlang opcode.
library LibOpMaxUint256NP {
    function integrity(IntegrityCheckStateNP memory, OperandV2) internal pure returns (uint256, uint256) {
        return (0, 1);
    }

    function run(InterpreterStateNP memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        uint256 value = type(uint256).max;
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, OperandV2, uint256[] memory)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = type(uint256).max;
        return outputs;
    }
}
