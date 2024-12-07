// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.18;

import {ZeroLengthBitwiseEncoding, TruncatedBitwiseEncoding} from "../../../error/ErrBitwise.sol";
import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "rain.interpreter.interface/interface/IInterpreterV3.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// @title LibOpEncodeBitsNP
/// @notice Opcode for encoding binary data into a 256 bit value.
library LibOpEncodeBitsNP {
    /// Encode takes two values and returns one value. The first value is the
    /// source, the second value is the target.
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        uint256 startBit = Operand.unwrap(operand) & 0xFF;
        uint256 length = (Operand.unwrap(operand) >> 8) & 0xFF;

        if (length == 0) {
            revert ZeroLengthBitwiseEncoding();
        }
        if (startBit + length > 256) {
            revert TruncatedBitwiseEncoding(startBit, length);
        }
        return (2, 1);
    }

    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            uint256 source;
            uint256 target;
            assembly ("memory-safe") {
                source := mload(stackTop)
                stackTop := add(stackTop, 0x20)
                target := mload(stackTop)
            }

            // We encode as a start and length of bits. This avoids mistakes such as
            // inclusive/exclusive ranges, and makes it easier to reason about the
            // encoding.
            uint256 startBit = Operand.unwrap(operand) & 0xFF;
            uint256 length = (Operand.unwrap(operand) >> 8) & 0xFF;

            // Build a bitmask of desired length. Max length is uint8 max which
            // is 255. A 256 length doesn't really make sense as that isn't an
            // encoding anyway, it's just the source verbatim.
            uint256 mask = (2 ** length - 1);

            // Punch a mask sized hole in target.
            target &= ~(mask << startBit);

            // Fill the hole with masked bytes from source.
            target |= (source & mask) << startBit;

            assembly ("memory-safe") {
                mstore(stackTop, target)
            }
            return stackTop;
        }
    }

    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        uint256 source = inputs[0];
        uint256 target = inputs[1];

        // We encode as a start and length of bits. This avoids mistakes such as
        // inclusive/exclusive ranges, and makes it easier to reason about the
        // encoding.
        uint256 startBit = Operand.unwrap(operand) & 0xFF;
        uint256 length = (Operand.unwrap(operand) >> 8) & 0xFF;

        // Build a bitmask of desired length. Max length is uint8 max which
        // is 255. A 256 length doesn't really make sense as that isn't an
        // encoding anyway, it's just the source verbatim.
        uint256 mask = (2 ** length - 1);

        // Punch a mask sized hole in target.
        target &= ~(mask << startBit);

        // Fill the hole with masked bytes from source.
        target |= (source & mask) << startBit;

        outputs = new uint256[](1);
        outputs[0] = target;
    }
}
