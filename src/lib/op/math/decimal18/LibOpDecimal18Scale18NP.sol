// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {FixedPointDecimalScale} from "rain.math.fixedpoint/FixedPointDecimalScale.sol";
import "sol.lib.binmaskflag/Binary.sol";

import "../../../state/LibInterpreterStateNP.sol";
import "../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpDecimal18Scale18NP
/// @notice Opcode for scaling a number to 18 decimal fixed point.
library LibOpDecimal18Scale18NP {
    using FixedPointDecimalScale for uint256;

    function integrity(IntegrityCheckStateNP memory, Operand) internal pure returns (uint256, uint256) {
        return (1, 1);
    }

    /// decimal18-scale18
    /// 18 decimal fixed point scaling.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        assembly ("memory-safe") {
            a := mload(stackTop)
        }
        a = a.scale18(Operand.unwrap(operand) & 0xFF, Operand.unwrap(operand) >> 8);
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
        outputs[0] = inputs[0].scale18(Operand.unwrap(operand) >> 2, Operand.unwrap(operand) & MASK_2BIT);
    }
}
