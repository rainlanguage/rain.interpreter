// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "rain.lib.typecast/LibConvert.sol";

import "../integrity/LibIntegrityCheckNP.sol";
import "../state/LibInterpreterStateNP.sol";

import "./00/LibOpStackNP.sol";
import "./00/LibOpConstantNP.sol";

import "./crypto/LibOpHashNP.sol";

import "./evm/LibOpBlockNumberNP.sol";
import "./evm/LibOpChainIdNP.sol";
import "./evm/LibOpMaxUint256NP.sol";
import "./evm/LibOpTimestampNP.sol";

import "./logic/LibOpAnyNP.sol";
import "./logic/LibOpConditionsNP.sol";
import "./logic/LibOpEqualToNP.sol";
import "./logic/LibOpEveryNP.sol";
import "./logic/LibOpGreaterThanNP.sol";
import "./logic/LibOpGreaterThanOrEqualToNP.sol";
import "./logic/LibOpIfNP.sol";
import "./logic/LibOpIsZeroNP.sol";
import "./logic/LibOpLessThanNP.sol";
import "./logic/LibOpLessThanOrEqualToNP.sol";

/// Thrown when a dynamic length array is NOT 1 more than a fixed length array.
/// Should never happen outside a major breaking change to memory layouts.
error BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength);

/// @dev Number of ops currently provided by `AllStandardOpsNP`.
uint256 constant ALL_STANDARD_OPS_LENGTH = 17;

/// @title LibAllStandardOpsNP
/// @notice Every opcode available from the core repository laid out as a single
/// array to easily build function pointers for `IInterpreterV1`.
library LibAllStandardOpsNP {
    function authoringMeta() internal pure returns (bytes memory) {
        bytes32[ALL_STANDARD_OPS_LENGTH + 1] memory wordsFixed = [
            bytes32(ALL_STANDARD_OPS_LENGTH),
            // Stack and constant MUST be in this order for parsing to work.
            "stack",
            "constant",
            // These are all ordered according to how they appear in the file system.
            "hash",
            "block-number",
            "chain-id",
            "max-uint-256",
            "block-timestamp",
            "any",
            "conditions",
            "equal-to",
            "every",
            "greater-than",
            "greater-than-or-equal-to",
            "if",
            "is-zero",
            "less-than",
            "less-than-or-equal-to"
        ];
        bytes32[] memory wordsDynamic;
        assembly ("memory-safe") {
            wordsDynamic := wordsFixed
        }
        return abi.encode(wordsDynamic);
    }

    function integrityFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(IntegrityCheckStateNP memory, Operand)
                view
                returns (uint256, uint256) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(IntegrityCheckStateNP memory, Operand)
                view
                returns (uint256, uint256)[ALL_STANDARD_OPS_LENGTH + 1] memory pointersFixed = [
                    lengthPointer,
                    // Stack then constant are the first two ops to match the
                    // field ordering in the interpreter state NOT the lexical
                    // ordering of the file system.
                    LibOpStackNP.integrity,
                    LibOpConstantNP.integrity,
                    // Everything else is alphabetical, including folders.
                    LibOpHashNP.integrity,
                    LibOpBlockNumberNP.integrity,
                    LibOpChainIdNP.integrity,
                    LibOpMaxUint256NP.integrity,
                    LibOpTimestampNP.integrity,
                    LibOpAnyNP.integrity,
                    LibOpConditionsNP.integrity,
                    LibOpEqualToNP.integrity,
                    LibOpEveryNP.integrity,
                    LibOpGreaterThanNP.integrity,
                    LibOpGreaterThanOrEqualToNP.integrity,
                    LibOpIfNP.integrity,
                    LibOpIsZeroNP.integrity,
                    LibOpLessThanNP.integrity,
                    LibOpLessThanOrEqualToNP.integrity
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != ALL_STANDARD_OPS_LENGTH) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    /// All function pointers for the standard opcodes. Intended to be used to
    /// build a `IInterpreterV1` instance, specifically the `functionPointers`
    /// method can just be a thin wrapper around this function.
    function opcodeFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(InterpreterStateNP memory, Operand, Pointer)
                view
                returns (Pointer) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(InterpreterStateNP memory, Operand, Pointer)
                view
                returns (Pointer)[ALL_STANDARD_OPS_LENGTH + 1] memory pointersFixed = [
                    lengthPointer,
                    // Stack then constant are the first two ops to match the
                    // field ordering in the interpreter state NOT the lexical
                    // ordering of the file system.
                    LibOpStackNP.run,
                    LibOpConstantNP.run,
                    // Everything else is alphabetical, including folders.
                    LibOpHashNP.run,
                    LibOpBlockNumberNP.run,
                    LibOpChainIdNP.run,
                    LibOpMaxUint256NP.run,
                    LibOpTimestampNP.run,
                    LibOpAnyNP.run,
                    LibOpConditionsNP.run,
                    LibOpEqualToNP.run,
                    LibOpEveryNP.run,
                    LibOpGreaterThanNP.run,
                    LibOpGreaterThanOrEqualToNP.run,
                    LibOpIfNP.run,
                    LibOpIsZeroNP.run,
                    LibOpLessThanNP.run,
                    LibOpLessThanOrEqualToNP.run
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != ALL_STANDARD_OPS_LENGTH) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }
}
