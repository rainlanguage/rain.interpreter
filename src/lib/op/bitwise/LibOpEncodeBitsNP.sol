// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckStateNP} from "../../integrity/LibIntegrityCheckNP.sol";
import {Operand} from "../../../interface/IInterpreterV1.sol";
import {InterpreterStateNP} from "../../state/LibInterpreterStateNP.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

// import "rain.interpreter/lib/op/LibOp.sol";
// import "rain.interpreter/lib/state/LibInterpreterState.sol";
// import "rain.interpreter/lib/integrity/LibIntegrityCheck.sol";
// import "sol.lib.binmaskflag/Binary.sol";

/// Thrown during integrity check when the encoding is truncated due to the end
/// bit being over 256.
/// @param startBit The start of the OOB encoding.
/// @param length The length of the OOB encoding.
error TruncatedEncoding(uint256 startBit, uint256 length);

/// @title LibOpEncodeBitsNP
/// @notice Opcode for encoding binary data into a 256 bit value.
library LibOpEncodeBitsNP {
    // using LibOp for Pointer;
    // using LibIntegrityCheck for IntegrityCheckState;

    /// Encode takes two values and returns one value. The first value is the
    /// source, the second value is the target.
    function integrity(IntegrityCheckStateNP memory, Operand operand) internal pure returns (uint256, uint256) {
        uint256 startBit = (Operand.unwrap(operand) >> 8) & 0xFF;
        uint256 length = Operand.unwrap(operand) & 0xFF;
        if (startBit + length > 256) {
            revert TruncatedEncoding(startBit, length);
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
            uint256 startBit = (Operand.unwrap(operand) >> 8) & 0xFF;
            uint256 length = Operand.unwrap(operand) & 0xFF;

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

    // function f(Operand operand_, uint256 source_, uint256 target_) internal pure returns (uint256) {
    //     unchecked {
    //         uint256 startBit_ = (Operand.unwrap(operand_) >> 8) & MASK_8BIT;
    //         uint256 length_ = Operand.unwrap(operand_) & MASK_8BIT;

    //         // Build a bitmask of desired length. Max length is uint8 max which
    //         // is 255. A 256 length doesn't really make sense as that isn't an
    //         // encoding anyway, it's just the source_ verbatim.
    //         uint256 mask_ = (2 ** length_ - 1);

    //         return
    //         // Punch a mask sized hole in target.
    //         (target_ & ~(mask_ << startBit_))
    //         // Fill the hole with masked bytes from source.
    //         | ((source_ & mask_) << startBit_);
    //     }
    // }

    // function integrity(IntegrityCheckState memory integrityCheckState_, Operand operand_, Pointer stackTop_)
    //     internal
    //     pure
    //     returns (Pointer)
    // {
    //     unchecked {
    //         uint256 startBit_ = (Operand.unwrap(operand_) >> 8) & MASK_8BIT;
    //         uint256 length_ = Operand.unwrap(operand_) & MASK_8BIT;
    //         if (startBit_ + length_ > 256) {
    //             revert TruncatedEncoding(startBit_, length_);
    //         }
    //         return integrityCheckState_.applyFn(stackTop_, f);
    //     }
    // }

    // function run(InterpreterState memory, Operand operand_, Pointer stackTop_) internal view returns (Pointer) {
    //     return stackTop_.applyFn(f, operand_);
    // }
}
