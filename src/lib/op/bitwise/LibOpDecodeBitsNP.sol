// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "../../../interface/IInterpreterV1.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {TruncatedEncoding} from "./LibOpEncodeBitsNP.sol";

// import "rain.interpreter/lib/op/LibOp.sol";
// import "rain.solmem/lib/LibStackPointer.sol";
// import "rain.interpreter/lib/state/LibInterpreterState.sol";
// import "rain.interpreter/lib/integrity/LibIntegrityCheck.sol";
// import "sol.lib.binmaskflag/Binary.sol";
// import "./OpEncode256.sol";

/// @title LibOpDecodeBitsNP
/// @notice Opcode for decoding binary data from a 256 bit value that was encoded
/// with LibOpEncodeBitsNP.
library LibOpDecodeBitsNP {
    // using LibOp for Pointer;
    // using LibStackPointer for Pointer;
    // using LibIntegrityCheck for IntegrityCheckState;

    /// Decode takes a single value and returns the decoded value.
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        uint256 startBit_ = (Operand.unwrap(operand) >> 8) & 0xFF;
        uint256 length_ = Operand.unwrap(operand) & 0xFF;

        if (startBit_ + length_ > 256) {
            revert TruncatedEncoding(startBit_, length_);
        }

        return (1, 1);
    }

    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        unchecked {
            uint256 value;
            assembly ("memory-safe") {
                value := mload(stackTop)
            }

            // We decode as a start and length of bits. This avoids mistakes such as
            // inclusive/exclusive ranges, and makes it easier to reason about the
            // encoding.
            uint256 startBit = (Operand.unwrap(operand) >> 8) & 0xFF;
            uint256 length = Operand.unwrap(operand) & 0xFF;

            // Build a bitmask of desired length. Max length is uint8 max which
            // is 255. A 256 length doesn't really make sense as that isn't an
            // encoding anyway, it's just the value verbatim.
            uint256 mask = (2 ** length - 1);
            value = (value >> startBit) & mask;

            assembly ("memory-safe") {
                mstore(stackTop, value)
            }
            return stackTop;
        }
    }

    // function f(
    //     Operand operand_,
    //     uint256 source_
    // ) internal pure returns (uint256) {
    //     unchecked {
    //         uint256 startBit_ = (Operand.unwrap(operand_) >> 8) & MASK_8BIT;
    //         uint256 length_ = Operand.unwrap(operand_) & MASK_8BIT;

    //         // Build a bitmask of desired length. Max length is uint8 max which
    //         // is 255. A 256 length doesn't really make sense as that isn't an
    //         // encoding anyway, it's just the source_ verbatim.
    //         uint256 mask_ = (2 ** length_ - 1);

    //         return (source_ >> startBit_) & mask_;
    //     }
    // }

    // function integrity(
    //     IntegrityCheckState memory integrityCheckState_,
    //     Operand operand_,
    //     Pointer stackTop_
    // ) internal pure returns (Pointer) {
    //     unchecked {
    //         uint256 startBit_ = (Operand.unwrap(operand_) >> 8) & MASK_8BIT;
    //         uint256 length_ = Operand.unwrap(operand_) & MASK_8BIT;

    //         if (startBit_ + length_ > 256) {
    //             revert TruncatedEncoding(startBit_, length_);
    //         }
    //         return integrityCheckState_.applyFn(stackTop_, f);
    //     }
    // }

    // function run(
    //     InterpreterState memory,
    //     Operand operand_,
    //     Pointer stackTop_
    // ) internal view returns (Pointer) {
    //     return stackTop_.applyFn(f, operand_);
    // }
}
