// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

<<<<<<< HEAD
import {Operand} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
=======
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
>>>>>>> a29afe65b34c94b2b6dd9b99bc33061fed5878c6
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";

/// @title LibOpConditionsNP
/// @notice Opcode to return the first nonzero item on the stack up to the inputs
/// limit.
library LibOpConditionsNP {
    using LibIntOrAString for IntOrAString;

    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        // There must be at least two inputs.
        uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0x0F;
        inputs = inputs > 2 ? inputs : 2;
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
        IntOrAString reason = IntOrAString.wrap(0);
        assembly ("memory-safe") {
            let inputs := and(shr(0x10, operand), 0x0F)
            let oddInputs := mod(inputs, 2)

            let cursor := stackTop
            for {
                let end := add(cursor, mul(sub(inputs, oddInputs), 0x20))
                stackTop := sub(end, mul(iszero(oddInputs), 0x20))
                if oddInputs { reason := mload(end) }
            } lt(cursor, end) { cursor := add(cursor, 0x40) } {
                condition := mload(cursor)
                if condition {
                    mstore(stackTop, mload(add(cursor, 0x20)))
                    break
                }
            }
        }
        require(condition > 0, reason.toString());
        return stackTop;
    }

    /// Gas intensive reference implementation of `condition` for testing.
    function referenceFn(InterpreterStateNP memory, Operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // Unchecked so that any overflow errors come from the real
        // implementation.
        unchecked {
            uint256 length = inputs.length;
            outputs = new uint256[](1);
            for (uint256 i = 0; i < length; i += 2) {
                if (inputs[i] != 0) {
                    outputs[0] = inputs[i + 1];
                    return outputs;
                }
            }
            if (inputs.length % 2 != 0) {
                IntOrAString reason = IntOrAString.wrap(inputs[length - 1]);
                require(false, reason.toString());
            } else {
                require(false, "");
            }
        }
    }
}
