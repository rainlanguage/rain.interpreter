// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibOpEncodeBitsNP} from "./LibOpEncodeBitsNP.sol";

/// @title LibOpDecodeBitsNP
/// @notice Opcode for decoding binary data from a 256 bit value that was encoded
/// with LibOpEncodeBitsNP.
library LibOpDecodeBitsNP {
    /// Decode takes a single value and returns the decoded value.
    function integrity(IntegrityCheckStateNP memory state, OperandV2 operand) internal pure returns (uint256, uint256) {
        // Use exact same integrity check as encode other than the return values.
        // All we're interested in is the errors that might be thrown.
        //slither-disable-next-line unused-return
        LibOpEncodeBitsNP.integrity(state, operand);

        return (1, 1);
    }

    function run(InterpreterStateNP memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            uint256 value;
            assembly ("memory-safe") {
                value := mload(stackTop)
            }

            // We decode as a start and length of bits. This avoids mistakes such as
            // inclusive/exclusive ranges, and makes it easier to reason about the
            // encoding.
            uint256 startBit = OperandV2.unwrap(operand) & 0xFF;
            uint256 length = (OperandV2.unwrap(operand) >> 8) & 0xFF;

            // Build a bitmask of desired length. Max length is uint8 max which
            // is 255. A 256 length doesn't really make sense as that isn't an
            // encoding anyway, it's just the value verbatim.
            //slither-disable-next-line incorrect-shift
            uint256 mask = (1 << length) - 1;
            value = (value >> startBit) & mask;

            assembly ("memory-safe") {
                mstore(stackTop, value)
            }
            return stackTop;
        }
    }

    function referenceFn(InterpreterStateNP memory, OperandV2 operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        // We decode as a start and length of bits. This avoids mistakes such as
        // inclusive/exclusive ranges, and makes it easier to reason about the
        // encoding.
        uint256 startBit = OperandV2.unwrap(operand) & 0xFF;
        uint256 length = (OperandV2.unwrap(operand) >> 8) & 0xFF;

        // Build a bitmask of desired length. Max length is uint8 max which
        // is 255. A 256 length doesn't really make sense as that isn't an
        // encoding anyway, it's just the value verbatim.
        uint256 mask = (2 ** length) - 1;
        outputs = new uint256[](1);
        outputs[0] = (inputs[0] >> startBit) & mask;
    }
}
