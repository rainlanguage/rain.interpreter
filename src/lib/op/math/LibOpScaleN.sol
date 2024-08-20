// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpScaleN
/// @notice Opcode for scaling a decimal18 number to some other scale N.
library LibOpScaleN {
    using LibFixedPointDecimalScale for uint256;

    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (1, 1);
    }

    /// scale-n
    /// Scale from 18 decimal to n decimal.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = a.scaleN(Operand.unwrap(operand) & 0xFF, Operand.unwrap(operand) >> 8);
        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](1);
        outputs[0] = inputs[0].scaleN(Operand.unwrap(operand) & 0xFF, Operand.unwrap(operand) >> 8);
    }
}
