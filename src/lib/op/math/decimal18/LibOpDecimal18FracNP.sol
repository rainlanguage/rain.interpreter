// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {UD60x18, frac} from "prb-math/UD60x18.sol";
import {Operand} from "../../../../interface/unstable/IInterpreterV2.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterStateNP} from "../../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpDecimal18FracNP
/// @notice Opcode for the frac of an decimal 18 fixed point number.
library LibOpDecimal18FracNP {
    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        // There must be one input and one output.
        return (1, 1);
    }

    /// decimal18-frac
    /// 18 decimal fixed point frac of a number.
    function run(InterpreterStateNP memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = UD60x18.unwrap(frac(UD60x18.wrap(a)));

        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of frac for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = UD60x18.unwrap(frac(UD60x18.wrap(inputs[0])));
        return outputs;
    }
}
