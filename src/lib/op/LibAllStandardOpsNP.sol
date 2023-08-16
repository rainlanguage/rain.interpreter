// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "rain.lib.typecast/LibConvert.sol";

import "../integrity/LibIntegrityCheckNP.sol";
import "../state/LibInterpreterStateNP.sol";
import {AuthoringMeta} from "../parse/LibParseMeta.sol";
import {
    OPERAND_PARSER_OFFSET_DISALLOWED,
    OPERAND_PARSER_OFFSET_SINGLE_FULL,
    OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT
} from "../parse/LibParseOperand.sol";

import "./00/LibOpStackNP.sol";
import "./00/LibOpConstantNP.sol";

import "./context/LibOpContextNP.sol";

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
uint256 constant ALL_STANDARD_OPS_LENGTH = 18;

/// @title LibAllStandardOpsNP
/// @notice Every opcode available from the core repository laid out as a single
/// array to easily build function pointers for `IInterpreterV1`.
library LibAllStandardOpsNP {
    function authoringMeta() internal pure returns (bytes memory) {
        AuthoringMeta memory lengthPlaceholder;
        AuthoringMeta[ALL_STANDARD_OPS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            // Stack and constant MUST be in this order for parsing to work.
            AuthoringMeta("stack", OPERAND_PARSER_OFFSET_SINGLE_FULL, "Copies an existing value from the stack."),
            AuthoringMeta("constant", OPERAND_PARSER_OFFSET_SINGLE_FULL, "Copies a constant value onto the stack."),
            // These are all ordered according to how they appear in the file system.
            AuthoringMeta(
                "context",
                OPERAND_PARSER_OFFSET_DOUBLE_PERBYTE_NO_DEFAULT,
                "Copies a value from the context. The first operand is the context column and second is the context row."
            ),
            AuthoringMeta(
                "hash", OPERAND_PARSER_OFFSET_DISALLOWED, "Hashes all inputs into a single 32 byte value using keccak256."
            ),
            AuthoringMeta("block-number", OPERAND_PARSER_OFFSET_DISALLOWED, "The current block number."),
            AuthoringMeta("chain-id", OPERAND_PARSER_OFFSET_DISALLOWED, "The current chain id."),
            AuthoringMeta(
                "max-uint-256", OPERAND_PARSER_OFFSET_DISALLOWED, "The maximum possible unsigned 32 byte integer value."
            ),
            AuthoringMeta("block-timestamp", OPERAND_PARSER_OFFSET_DISALLOWED, "The current block timestamp."),
            AuthoringMeta(
                "any",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "The first non-zero value out of all inputs, or 0 if every input is 0."
            ),
            AuthoringMeta(
                "conditions",
                OPERAND_PARSER_OFFSET_SINGLE_FULL,
                "Treats inputs as pairwise condition/value pairs. The first nonzero condition's value is used. If no conditions are nonzero, the expression reverts. The operand can be used as an error code to differentiate between multiple conditions in the same expression."
            ),
            AuthoringMeta("equal-to", OPERAND_PARSER_OFFSET_DISALLOWED, "1 if all inputs are equal, 0 otherwise."),
            AuthoringMeta(
                "every",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "The last nonzero value out of all inputs, or 0 if any input is 0."
            ),
            AuthoringMeta(
                "greater-than",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "1 if the first input is greater than the second input, 0 otherwise."
            ),
            AuthoringMeta(
                "greater-than-or-equal-to",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "1 if the first input is greater than or equal to the second input, 0 otherwise."
            ),
            AuthoringMeta(
                "if",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "If the first input is nonzero, the second input is used. Otherwise, the third input is used. If is eagerly evaluated."
            ),
            AuthoringMeta("is-zero", OPERAND_PARSER_OFFSET_DISALLOWED, "1 if the input is 0, 0 otherwise."),
            AuthoringMeta(
                "less-than",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "1 if the first input is less than the second input, 0 otherwise."
            ),
            AuthoringMeta(
                "less-than-or-equal-to",
                OPERAND_PARSER_OFFSET_DISALLOWED,
                "1 if the first input is less than or equal to the second input, 0 otherwise."
            )
        ];
        AuthoringMeta[] memory wordsDynamic;
        uint256 length = ALL_STANDARD_OPS_LENGTH;
        assembly ("memory-safe") {
            wordsDynamic := wordsFixed
            mstore(wordsDynamic, length)
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
                    LibOpContextNP.integrity,
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
                    LibOpContextNP.run,
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
