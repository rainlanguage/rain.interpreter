// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {BadDynamicLength} from "../error/ErrOpList.sol";
import {BaseRainterpreterExternNPE2, Operand} from "../abstract/BaseRainterpreterExternNPE2.sol";

import {LibOpIntAddNP} from "../lib/op/math/int/LibOpIntAddNP.sol";

bytes constant OPCODE_FUNCTION_POINTERS = hex"030b";
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 1;
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"0450";

contract RainterpreterExternNPE2 is BaseRainterpreterExternNPE2 {
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    /// This mimics how LibAllStandardOpsNP builds function pointers for the
    /// Rainterpreter. The same pattern applies to externs but for a different
    /// function signature for each opcode. Call this function somehow, e.g. from
    /// within a test, and then copy the output into the
    /// `OPCODE_FUNCTION_POINTERS` if there is a mismatch. This makes the
    /// function pointer lookup much more gas efficient.
    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function(Operand, uint256[] memory) internal view returns (uint256[] memory) lengthPointer;
            uint256 length = OPCODE_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(Operand, uint256[] memory) internal view returns (uint256[] memory)[OPCODE_FUNCTION_POINTERS_LENGTH
                + 1] memory pointersFixed = [lengthPointer, LibOpIntAddNP.runExtern];
            uint256[] memory pointersDynamic;
            assembly {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != length) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    /// This is the same pattern as `buildOpcodeFunctionPointers` but for
    /// integrity checks. Probably the AI can spit all this out for you, worked
    /// for me.
    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function(Operand, uint256, uint256) internal pure returns (uint256, uint256) lengthPointer;
            uint256 length = OPCODE_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(Operand, uint256, uint256) internal pure returns (uint256, uint256)[OPCODE_FUNCTION_POINTERS_LENGTH
                + 1] memory pointersFixed = [lengthPointer, LibOpIntAddNP.integrityExtern];
            uint256[] memory pointersDynamic;
            assembly {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != length) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }
}
