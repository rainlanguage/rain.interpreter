// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UD60x18, floor} from "prb-math/UD60x18.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV2.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpDecimal18FloorNP
/// @notice Opcode for the floor of an decimal 18 fixed point number.
library LibOpDecimal18FloorNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // There must be one input and one output.
        return (1, 1);
    }

    /// decimal18-floor
    /// 18 decimal fixed point floor of a number.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = UD60x18.unwrap(floor(UD60x18.wrap(a)));

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of floor for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = UD60x18.unwrap(floor(UD60x18.wrap(inputs[0])));
        return outputs;
    }
}
