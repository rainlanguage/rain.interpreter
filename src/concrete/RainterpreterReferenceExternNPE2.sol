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
import {AuthoringMetaV2} from "../interface/IParserV1.sol";
import {ParseState} from "../lib/parse/LibParseState.sol";
import {LibParseOperand} from "../lib/parse/LibParseOperand.sol";
import {LibParseLiteral} from "../lib/parse/LibParseLiteral.sol";
import {COMPATIBLITY_V0} from "../interface/unstable/ISubParserV1.sol";

/// @dev The number of subparser functions available to the parser. This is NOT
/// 1:1 with the number of opcodes provided by the extern component of this
/// contract. It is possible to subparse words into opcodes that run entirely
/// within the interpreter, and do not have an associated extern dispatch.
uint256 constant SUB_PARSER_FUNCTION_POINTERS_LENGTH = 1;

/// @dev Real function pointers to the sub parser functions that produce the
/// bytecode that this contract knows about. This is both constructing the extern
/// bytecode that dials back into this contract at eval time, and creating
/// to things that happen entirely on the interpreter such as well known
/// constants and references to the context grid.
bytes constant SUB_PARSER_FUNCTION_POINTERS = hex"0981";

/// @dev Real sub parser meta bytes that map parsed strings to the functions that
/// know how to parse those strings into opcodes for the main parser. Structured
/// identically to parse meta for the main parser.
bytes constant SUB_PARSER_PARSE_META =
    hex"010000000000000000000000000000000000000000000000000000000000000000020000ae37f5";

/// @dev Real function pointers to the operand parsers that are available at
/// parse time, encoded into a single 256 bit word. Each 2 bytes starting from
/// the rightmost position is a pointer to an operand parser function. In the
/// future this is likely to be removed, or refactored to value handling only
/// rather than parsing.
uint256 constant SUB_PARSER_OPERAND_HANDLERS = hex"";

/// @dev Real function pointers to the literal parsers that are available at
/// parse time, encoded into a single 256 bit word. Each 2 bytes starting from
/// the rightmost position is a pointer to a literal parser function. In the
/// future this is likely to be removed, in favour of a dedicated literal parser
/// feature.
uint256 constant SUB_PARSER_LITERAL_PARSERS = 0x00000000000000000000000000000000000000000000000000000fd80d030a3b;

/// @dev Real function pointers to the opcodes for the extern component of this
/// contract. These get run at eval time wehen the interpreter calls into the
/// contract as an `IInterpreterExternV3`.
bytes constant OPCODE_FUNCTION_POINTERS = hex"053b";

/// @dev Number of opcode function pointers available to run at eval time.
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 1;

/// @dev Real function pointers to the integrity checks for the extern component
/// of this contract. These get run at deploy time when the main integrity checks
/// are run, the extern opcode integrity on the deployer will delegate integrity
/// checks to the extern contract.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"06be";

/// @dev Opcode index of the extern increment opcode. Needs to be manually kept
/// in sync with the extern opcode function pointers. Definitely write tests for
/// this to ensure a mismatch doesn't happen silently.
uint256 constant OP_INDEX_INCREMENT = 0;

/// @dev The offset of the operand parser for disallowed opcodes. This just
/// happens to be the same as the main parser, but could be different in some
/// other implementation. In the future this is likely to be removed.
uint8 constant SUB_PARSER_OPERAND_PARSER_OFFSET_DISALLOWED = 0;

/// @title LibExternOpIntIncNPE2
/// This is a library that mimics the op libraries elsewhere in this repo, but
/// structured to fit extern dispatching rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
library LibExternOpIntIncNPE2 {
    /// Running the extern increments every input by 1. By allowing many inputs
    /// we can test multi input/output logic is implemented correctly for
    /// externs.
    //slither-disable-next-line dead-code
    function run(Operand, uint256[] memory inputs) internal pure returns (uint256[] memory) {
        for (uint256 i = 0; i < inputs.length; i++) {
            ++inputs[i];
        }
        return inputs;
    }

    /// The integrity check for the extern increment opcode. The inputs and
    /// outputs are the same always.
    //slither-disable-next-line dead-code
    function integrity(Operand, uint256 inputs, uint256) internal pure returns (uint256, uint256) {
        return (inputs, inputs);
    }

    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256 constantsHeight, uint256 inputsByte, Operand operand)
        internal
        view
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV3(address(this)),
            constantsHeight,
            inputsByte,
            // Same number of outputs as inputs for inc.
            inputsByte,
            operand,
            OP_INDEX_INCREMENT
        );
    }
}

/// @title LibRainterpreterReferenceExternNPE2
/// This library allows code SEPARATE FROM the implementation contract to do
/// offchain processing of supporting data without needing to compile all this
/// information into the implementation contract. Any tooling that supports
/// solidity can read this data and expose it to end users.
library LibRainterpreterReferenceExternNPE2 {
    /// This mirrors the `authoringMeta` function in `LibAllStandardOps`. The
    /// goal is to produce a standard encoded `AuthoringMeta[]` that tooling can
    /// use to describe all the parseable words, that can be built directly into
    /// a useable parse meta with the standard libs. Note that the list of
    /// parseable words is not limited to the externs, the sub parser is free
    /// to define words that it then parses back into bytecode that is run by
    /// the interpreter itself.
    //slither-disable-next-line dead-code
    function authoringMetaV2() internal pure returns (bytes memory) {
        AuthoringMetaV2 memory lengthPlaceholder;
        AuthoringMetaV2[SUB_PARSER_FUNCTION_POINTERS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            AuthoringMetaV2(
                "reference-extern-inc",
                "Demonstrates a sugared extern into the reference implementation that increments every input 1:1 with its outputs."
            )
        ];
        AuthoringMetaV2[] memory wordsDynamic;
        uint256 length = SUB_PARSER_FUNCTION_POINTERS_LENGTH;
        assembly {
            wordsDynamic := wordsFixed
            mstore(wordsDynamic, length)
        }
        return abi.encode(wordsDynamic);
    }
}

/// @title RainterpreterReferenceExternNPE2
/// This is a reference implementation of BOTH the sub parser and extern
/// interfaces. It is NOT REQUIRED that these be one and the same. It is entirely
/// possible to implement standalone parsers and extern contracts that each
/// implement the relevant interface. In that case, the parser could construct
/// extern dispatches that encode the address of the extern contract, rather than
/// using `this` as the extern address.
///
/// Parser implementation
/// ---------------------
/// The parser implementation overrides all the virtual functions of the base
/// contracts. This is mandatory for the default implementation to work. The
/// implementation also builds function pointers to sub parsers, literals and
/// operands as external functions so that tooling can check that the constants
/// compiled internally into the contract match what they would be if dynamically
/// calculated. Any discprepancy there is definitely a critical issue that causes
/// undefined behaviour in production, so ALWAYS test this, preferably in an
/// automated way.
///
/// Extern implementation
/// ---------------------
/// The extern implementation overrides the virtual functions of the base
/// contracts. This is mandatory for the default implementation to work. The
/// implementation also builds function pointers to opcodes and integrity checks
/// as external functions so that tooling can check that the constants compiled
/// internally into the contract match what they would be if dynamically
/// calculated. Any discprepancy there is definitely a critical issue that causes
/// undefined behaviour in production, so ALWAYS test this, preferably in an
/// automated way.
contract RainterpreterReferenceExternNPE2 is BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2 {
    /// Overrides the base parse meta for sub parsing. Simply returns the known
    /// constant value, which should allow the compiler to optimise the entire
    /// function call away.
    function subParserParseMeta() internal pure virtual override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    /// Overrides the base function pointers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserFunctionPointers() internal pure override returns (bytes memory) {
        return SUB_PARSER_FUNCTION_POINTERS;
    }

    /// Overrides the base operand handlers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserOperandHandlers() internal pure override returns (bytes memory) {
        return SUB_PARSER_OPERAND_HANDLERS;
    }

    /// Overrides the base literal parsers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserLiteralParsers() internal pure override returns (uint256) {
        return SUB_PARSER_LITERAL_PARSERS;
    }

    /// Overrides the compatibility version for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserCompatibility() internal pure override returns (bytes32) {
        return COMPATIBLITY_V0;
    }

    /// Overrides the base function pointers for opcodes. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    /// Overrides the base function pointers for integrity checks. Simply returns
    /// the known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    /// The literal parsers are the same as the main parser. In the future this
    /// is likely to be changed so that sub parsers only have to define
    /// _additional_ literal parsers that they provide, as it is redundant and
    /// fragile to have to define the same literal parsers in multiple places.
    function buildSubParserLiteralParsers() external pure returns (uint256) {
        return LibParseLiteral.buildLiteralParsers();
    }

    /// There's only one operand parser for this implementation, the disallowed
    /// parser. We haven't implemented any words with meaningful operands yet.
    function buildSubParserOperandHandlers() external pure returns (bytes memory) {
        unchecked {
            function(uint256[] memory) internal pure returns (Operand) lengthPointer;
            uint256 length = SUB_PARSER_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(uint256[] memory) internal pure returns (Operand)[SUB_PARSER_FUNCTION_POINTERS_LENGTH
                + 1] memory handlersFixed = [lengthPointer, LibParseOperand.handleOperandDisallowed];
            uint256[] memory handlersDynamic;
            assembly {
                handlersDynamic := handlersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (handlersDynamic.length != length) {
                revert BadDynamicLength(handlersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(handlersDynamic);
        }
    }

    /// This mimics how `LibAllStandardOpsNP` builds bytes out of function
    /// pointers, but for sub parser functions. This is NOT intended to be
    /// called at runtime, instead tooling (e.g. the test suite) can call this
    /// function and compare it to `subParserFunctionPointers` to ensure they
    /// are in sync. This makes the runtime function pointer lookup much more
    /// gas efficient by allowing it to be constant. The reason this can't be
    /// done within the test itself is that the pointers need to be calculated
    /// relative to the bytecode of the current contract, not the test contract.
    function buildSubParserFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)
                lengthPointer;
            uint256 length = SUB_PARSER_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[SUB_PARSER_FUNCTION_POINTERS_LENGTH
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
    /// function pointer lookup much more gas efficient. The reason this can't be
    /// done within the test itself is that the pointers need to be calculated
    /// relative to the bytecode of the current contract, not the test contract.
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

    /// This applies the same pattern to integrity function pointers as the
    /// opcode and parser function pointers on this same contract. Call this
    /// function somehow, e.g. from within a test, and then check there is no
    /// mismatch with the `INTEGRITY_FUNCTION_POINTERS` constant. This makes the
    /// function pointer lookup at runtime much more gas efficient by allowing
    /// it to be constant. The reason this can't be done within the test itself
    /// is that the pointers need to be calculated relative to the bytecode of
    /// the current contract, not the test contract.
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

    /// This is only needed because the parser and extern base contracts both
    /// implement IERC165, and the compiler needs to be told how to resolve the
    /// ambiguity.
    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
