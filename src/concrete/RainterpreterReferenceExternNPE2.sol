// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {BadDynamicLength} from "../error/ErrOpList.sol";
import {BaseRainterpreterExternNPE2, Operand} from "../abstract/BaseRainterpreterExternNPE2.sol";
import {BaseRainterpreterSubParserNPE2} from "../abstract/BaseRainterpreterSubParserNPE2.sol";
import {OPCODE_EXTERN} from "../interface/unstable/IInterpreterV2.sol";
import {LibExtern, EncodedExternDispatch} from "../lib/extern/LibExtern.sol";
import {IInterpreterExternV3} from "../interface/unstable/IInterpreterExternV3.sol";

bytes constant OPCODE_FUNCTION_POINTERS = hex"031f03d3";
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 1;
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"04b204d2";
bytes constant SUB_PARSER_FUNCTION_POINTERS = hex"";

uint256 constant OP_INDEX_INCREMENT = 0;

library LibExternOpIntIncNPE2 {
    /// int-inc
    /// Increment an integer.
    function run(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory) {
        for (uint256 i = 0; i < inputs.length; i++) {
            ++inputs[i];
        }
        return inputs;
    }

    function integrity(Operand, uint256 inputs, uint256) internal pure returns (uint256, uint256) {
        return (inputs, inputs);
    }

    function subParser(uint256 constantsHeight, uint256 ioByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        // Build an extern call that dials back into the current contract at eval
        // time with the current opcode index.
        bytes memory bytecode = new bytes(4);
        uint256 opIndex = OPCODE_EXTERN;
        assembly ("memory-safe") {
            // Main opcode is extern, to call back into current contract.
            mstore8(add(bytecode, 0x20), opIndex)
            // Use the io byte as is for inputs.
            mstore8(add(bytecode, 0x21), ioByte)
            // The outputs are the same as inputs for inc.
            mstore8(add(bytecode, 0x22), ioByte)
            // The extern dispatch is the index to the new constant that we will
            // add to the constants array.
            mstore8(add(bytecode, 0x23), constantsHeight)
        }

        uint256[] memory constants = new uint256[](1);
        constants[0] = EncodedExternDispatch.unwrap(
            LibExtern.encodeExternCall(
                IInterpreterExternV3(address(this)), LibExtern.encodeExternDispatch(OP_INDEX_INCREMENT, operand)
            )
        );

        return (true, bytecode, constants);
    }
}

contract RainterpreterReferenceExternNPE2 is BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function subParserFunctionPointers() internal pure override returns (bytes memory) {
        return SUB_PARSER_FUNCTION_POINTERS;
    }

    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    function buildSubParserFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)
                lengthPointer;
            uint256 length = OPCODE_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[OPCODE_FUNCTION_POINTERS_LENGTH
                + 1] memory pointersFixed = [lengthPointer, LibExternOpIntIncNPE2.subParser];
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
                + 1] memory pointersFixed = [lengthPointer, LibExternOpIntIncNPE2.run];
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
                + 1] memory pointersFixed = [lengthPointer, LibExternOpIntIncNPE2.integrity];
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
