// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";

import "prb-math/UD60x18.sol";

import "../../../state/LibInterpreterStateNP.sol";
import "../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpDecimal18DivNP
/// @notice Opcode to div N 18 decimal fixed point values. Errors on overflow.
library LibOpDecimal18DivNP {
    using LibPointer for Pointer;

    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        inputs = inputs > 1 ? inputs : 2;
        return (inputs, 1);
    }

    /// decimal18-div
    /// 18 decimal fixed point division with implied overflow checks from PRB
    /// Math.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        uint256 b;
        assembly ("memory-safe") {
            a := mload(stackTop)
            b := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }
        a = UD60x18.unwrap(div(UD60x18.wrap(a), UD60x18.wrap(b)));

        {
            uint256 inputs = Operand.unwrap(operand) >> 0x10;
            uint256 i = 2;
            while (i < inputs) {
                assembly ("memory-safe") {
                    b := mload(stackTop)
                    stackTop := add(stackTop, 0x20)
                }
                a = UD60x18.unwrap(div(UD60x18.wrap(a), UD60x18.wrap(b)));
                unchecked {
                    i++;
                }
            }
        }
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of division for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Unchecked so that when we assert that an overflow error is thrown, we
        // see the revert from the real function and not the reference function.
        unchecked {
            uint256 acc = inputs[0];
            for (uint256 i = 1; i < inputs.length; i++) {
                acc = UD60x18.unwrap(div(UD60x18.wrap(acc), UD60x18.wrap(inputs[i])));
            }
            outputs = new uint256[](1);
            outputs[0] = acc;
        }
    }
}
