// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpIntAddNP
/// @notice Opcode to add N integers.
library LibOpIntAddNP {
    using LibPointer for Pointer;

    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        inputs = inputs > 1 ? inputs : 2;
        return (inputs, 1);
    }

    /// add
    /// Addition with implied overflow checks from the Solidity 0.8.x compiler.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a = 0;
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        uint256 i = 0;
        while (i < inputs) {
            uint256 b;
            assembly ("memory-safe") {
                b := mload(stackTop)
                stackTop := add(stackTop, 0x20)
            }
            a += b;
            unchecked {
                i++;
            }
        }
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, a)
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of addition for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Unchecked so that when we assert that an overflow error is thrown, we
        // see the revert from the real function and not the reference function.
        unchecked {
            uint256 sum = 0;
            for (uint256 i = 0; i < inputs.length; i++) {
                sum += inputs[i];
            }
            outputs = new uint256[](1);
            outputs[0] = sum;
        }
    }
}
