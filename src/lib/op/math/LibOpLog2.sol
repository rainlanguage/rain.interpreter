// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UD60x18, log2} from "prb-math/UD60x18.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpLog2
/// @notice Opcode for the binary logarithm of an decimal 18 fixed point number.
library LibOpLog2 {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // There must be one inputs and one output.
        return (1, 1);
    }

    /// log2
    /// 18 decimal fixed point binary logarithm of a number.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = UD60x18.unwrap(log2(UD60x18.wrap(a)));

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of log2 for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = UD60x18.unwrap(log2(UD60x18.wrap(inputs[0])));
        return outputs;
    }
}
