// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {BadDynamicLength} from "../error/ErrOpList.sol";
import {BaseRainterpreterExternNPE2, Operand} from "../abstract/BaseRainterpreterExternNPE2.sol";
import {BaseRainterpreterSubParserNPE2} from "../abstract/BaseRainterpreterSubParserNPE2.sol";
import {OPCODE_EXTERN} from "../interface/unstable/IInterpreterV2.sol";
import {LibExtern, EncodedExternDispatch} from "../lib/extern/LibExtern.sol";
import {IInterpreterExternV3} from "../interface/unstable/IInterpreterExternV3.sol";
import {LibSubParse} from "../lib/parse/LibSubParse.sol";
import {AuthoringMeta} from "../lib/parse/LibParseMeta.sol";
import {ParseState} from "../lib/parse/LibParseState.sol";
import {LibParseOperand} from "../lib/parse/LibParseOperand.sol";
import {LibParseLiteral} from "../lib/parse/LibParseLiteral.sol";
import {COMPATIBLITY_V0} from "../interface/unstable/ISubParserV1.sol";

bytes constant OPCODE_FUNCTION_POINTERS = hex"0536";
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 1;
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"0615";
bytes constant SUB_PARSER_FUNCTION_POINTERS = hex"08dc";
bytes constant SUB_PARSER_PARSE_META =
    hex"010000000000000000000000000000000000000000000000000000000000000000020000ae37f5";
uint256 constant SUB_PARSER_OPERAND_PARSERS = 0x0000000000000000000000000000000000000000000000000000000000000994;
uint256 constant SUB_PARSER_LITERAL_PARSERS = 0;

uint256 constant OP_INDEX_INCREMENT = 0;

uint8 constant SUB_PARSER_OPERAND_PARSER_OFFSET_DISALLOWED = 0;

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

    function subParser(uint256 constantsHeight, uint256 inputsByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        return LibSubParse.subParserExtern(constantsHeight, inputsByte, operand, OP_INDEX_INCREMENT);
    }
}

library LibRainterpreterReferenceExternNPE2 {
    function authoringMeta() internal pure returns (bytes memory) {
        AuthoringMeta memory lengthPlaceholder;
        AuthoringMeta[OPCODE_FUNCTION_POINTERS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            AuthoringMeta(
                "reference-extern-inc",
                SUB_PARSER_OPERAND_PARSER_OFFSET_DISALLOWED,
                "Demonstrates a sugared extern into the reference implementation that increments every input 1:1 with its outputs."
            )
        ];
        AuthoringMeta[] memory wordsDynamic;
        uint256 length = OPCODE_FUNCTION_POINTERS_LENGTH;
        assembly {
            wordsDynamic := wordsFixed
            mstore(wordsDynamic, length)
        }
        return abi.encode(wordsDynamic);
    }

    function buildOperandParsers() internal pure returns (uint256 operandParsers) {
        function(ParseState memory, uint256, uint256) pure returns (uint256, Operand) operandParserDisallowed =
            LibParseOperand.parseOperandDisallowed;
        uint256 parseOperandDisallowedOffset = SUB_PARSER_OPERAND_PARSER_OFFSET_DISALLOWED;
        assembly ("memory-safe") {
            operandParsers := or(operandParsers, shl(parseOperandDisallowedOffset, operandParserDisallowed))
        }
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

    function subParserParseMeta() internal pure override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    function subParserFunctionPointers() internal pure override returns (bytes memory) {
        return SUB_PARSER_FUNCTION_POINTERS;
    }

    function subParserOperandParsers() internal pure override returns (uint256) {
        return SUB_PARSER_OPERAND_PARSERS;
    }

    function subParserLiteralParsers() internal pure override returns (uint256) {
        return SUB_PARSER_LITERAL_PARSERS;
    }

    function subParserCompatibility() internal pure override returns (bytes32) {
        return COMPATIBLITY_V0;
    }

    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    function buildSubParserLiteralParsers() external pure returns (uint256) {
        return LibParseLiteral.buildLiteralParsers();
    }

    function buildSubParserOperandParsers() external pure returns (uint256) {
        return LibRainterpreterReferenceExternNPE2.buildOperandParsers();
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
