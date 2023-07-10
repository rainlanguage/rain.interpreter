// SPDX-License-Identifier: CAL
pragma solidity ^0.8.19;

import "rain.lib.typecast/LibConvert.sol";

import "../state/LibInterpreterState.sol";
import "./evm/LibOpChainId.sol";

/// Thrown when a dynamic length array is NOT 1 more than a fixed length array.
/// Should never happen outside a major breaking change to memory layouts.
error BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength);

/// @dev Number of ops currently provided by `AllStandardOpsNP`.
uint256 constant ALL_STANDARD_OPS_LENGTH = 1;

/// @title LibAllStandardOpsNP
/// @notice Every opcode available from the core repository laid out as a single
/// array to easily build function pointers for `IInterpreterV1`.
library LibAllStandardOpsNP {
    /// All function pointers for the integrity checks of the standard opcodes.
    /// Intended to be used internally by a deployer when building an expression.
    function integrityFunctionPointers()
        internal
        pure
        returns (
            function(IntegrityCheckState memory, Operand, Pointer)
                                                                                                                                                                                                                        view
                                                                                                                                                                                                                        returns (Pointer)[]
                memory pointers
        )
    {
        unchecked {
            function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(IntegrityCheckState memory, Operand, Pointer)
                view
                returns (Pointer)[ALL_STANDARD_OPS_LENGTH + 1] memory pointersFixed =
                    [lengthPointer, LibOpChainId.integrity];
            assembly ("memory-safe") {
                pointers := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointers.length != ALL_STANDARD_OPS_LENGTH) {
                revert BadDynamicLength(pointers.length, length);
            }
        }
    }

    /// All function pointers for the standard opcodes. Intended to be used to
    /// build a `IInterpreterV1` instance, specifically the `functionPointers`
    /// method can just be a thin wrapper around this function.
    function opcodeFunctionPointers() internal pure returns (bytes memory) {
        unchecked {
            function(InterpreterState memory, Operand, Pointer)
                view
                returns (Pointer) lengthPointer;
            uint256 length = ALL_STANDARD_OPS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(InterpreterState memory, Operand, Pointer)
                view
                returns (Pointer)[ALL_STANDARD_OPS_LENGTH + 1] memory pointersFixed =
                    [lengthPointer, LibOpChainId.run];
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
