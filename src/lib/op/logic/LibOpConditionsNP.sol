// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "rain.solmem/lib/LibPointer.sol";

import "../../state/LibInterpreterStateNP.sol";
import "../../integrity/LibIntegrityCheckNP.sol";

/// Thrown if no nonzero condition is found.
/// @param condCode The condition code that was evaluated. This is the low 16
/// bits of the operand. Allows the author to provide more context about which
/// condition failed if there is more than one in the expression.
error NoConditionsMet(uint256 condCode);

/// @title LibOpConditionsNP
/// @notice Opcode to return the first nonzero item on the stack up to the inputs
/// limit.
library LibOpConditionsNP {
    using LibPointer for Pointer;

    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = Operand.unwrap(operand) >> 0x10;
        inputs = inputs > 0 ? inputs : 2;
        // Odd inputs are not allowed.
        unchecked {
            inputs = inputs % 2 == 0 ? inputs : inputs + 1;
        }
        return (inputs, 1);
    }

    /// `conditions`
    /// Pairwise list of conditions and values. The first nonzero condition
    /// evaluated puts its corresponding value on the stack. `conditions` is
    /// eagerly evaluated. If no condition is nonzero, the expression will
    /// revert. The number of inputs must be even. The number of outputs is 1.
    /// If an author wants to provide some default value, they can set the last
    /// condition to some nonzero constant value such as 1.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 condition;
        assembly ("memory-safe") {
            let cursor := stackTop
            for {
                let end := add(cursor, mul(shr(0x10, operand), 0x20))
                stackTop := sub(end, 0x20)
            } lt(cursor, end) { cursor := add(cursor, 0x40) } {
                condition := mload(cursor)
                if condition {
                    mstore(stackTop, mload(add(cursor, 0x20)))
                    break
                }
            }
        }
        if (condition == 0) {
            revert NoConditionsMet(uint16(Operand.unwrap(operand)));
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of `condition` for testing.
    function referenceFn(Operand operand, uint256[] memory inputs) internal pure returns (uint256[] memory outputs) {
        unchecked {
            uint256 length = inputs.length;
            require(length % 2 == 0, "Odd number of inputs");
            outputs = new uint256[](1);
            for (uint256 i = 0; i < length; i += 2) {
                if (inputs[i] != 0) {
                    outputs[0] = inputs[i + 1];
                    return outputs;
                }
            }
            revert NoConditionsMet(uint16(Operand.unwrap(operand)));
        }
    }
}
