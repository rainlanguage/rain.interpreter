// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {BadDynamicLength} from "../error/ErrOpList.sol";
import {BaseRainterpreterExternNPE2, Operand} from "../abstract/BaseRainterpreterExternNPE2.sol";
import {BaseRainterpreterSubParserNPE2} from "../abstract/BaseRainterpreterSubParserNPE2.sol";
import {LibExtern, EncodedExternDispatch} from "../lib/extern/LibExtern.sol";
import {IInterpreterExternV3} from "../interface/unstable/IInterpreterExternV3.sol";
import {LibSubParse} from "../lib/parse/LibSubParse.sol";
import {AuthoringMetaV2} from "../interface/IParserV1.sol";
import {LibParseState, ParseState} from "../lib/parse/LibParseState.sol";
import {LibParseOperand} from "../lib/parse/LibParseOperand.sol";
import {LibParseLiteral} from "../lib/parse/literal/LibParseLiteral.sol";
import {COMPATIBLITY_V2} from "../interface/unstable/ISubParserV2.sol";
import {LibParseLiteralDecimal} from "../lib/parse/literal/LibParseLiteralDecimal.sol";
import {
    CONTEXT_BASE_COLUMN,
    CONTEXT_BASE_ROW_CALLING_CONTRACT,
    CONTEXT_BASE_ROW_SENDER
} from "../lib/caller/LibContext.sol";

/// @dev The number of subparser functions available to the parser. This is NOT
/// 1:1 with the number of opcodes provided by the extern component of this
/// contract. It is possible to subparse words into opcodes that run entirely
/// within the interpreter, and do not have an associated extern dispatch.
uint256 constant SUB_PARSER_WORD_PARSERS_LENGTH = 4;

/// @dev Real function pointers to the sub parser functions that produce the
/// bytecode that this contract knows about. This is both constructing the extern
/// bytecode that dials back into this contract at eval time, and creating
/// to things that happen entirely on the interpreter such as well known
/// constants and references to the context grid.
bytes constant SUB_PARSER_WORD_PARSERS = hex"0721074407530763";

/// @dev Real sub parser meta bytes that map parsed strings to the functions that
/// know how to parse those strings into opcodes for the main parser. Structured
/// identically to parse meta for the main parser.
bytes constant SUB_PARSER_PARSE_META =
    hex"0100000000008000000000000000000000110000000000000000000000000000008000e438fc025be81c0384254101285ca1";

/// @dev Real function pointers to the operand parsers that are available at
/// parse time, encoded into a single 256 bit word. Each 2 bytes starting from
/// the rightmost position is a pointer to an operand parser function.
bytes constant SUB_PARSER_OPERAND_HANDLERS = hex"088208c708820882";

/// @dev Real function pointers to the literal parsers that are available at
/// parse time, encoded into a single 256 bit word. Each 2 bytes starting from
/// the rightmost position is a pointer to a literal parser function.
bytes constant SUB_PARSER_LITERAL_PARSERS = hex"0853";

/// @dev The number of literal parsers provided by the sub parser.
uint256 constant SUB_PARSER_LITERAL_PARSERS_LENGTH = 1;

/// @dev The keyword for the repeat literal parser. The digit after this keyword
/// is the digit to repeat in the literal when it is parsed to a value.
bytes constant SUB_PARSER_LITERAL_REPEAT_KEYWORD = bytes("ref-extern-repeat-");

/// @dev The keyword for the repeat literal parser, as a bytes32.
bytes32 constant SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32 = bytes32(SUB_PARSER_LITERAL_REPEAT_KEYWORD);

/// @dev The number of bytes in the repeat literal keyword.
uint256 constant SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH = 18;

/// @dev The mask to apply to the dispatch bytes when parsing to determin whether
/// the dispatch is for the repeat literal parser.
bytes32 constant SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK =
    bytes32(~((1 << (32 - SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH) * 8) - 1));

/// @dev The index of the repeat literal parser in the literal parser function
/// pointers.
uint256 constant SUB_PARSER_LITERAL_REPEAT_INDEX = 0;

/// @dev Thrown when the repeat literal parser is not a single digit.
error InvalidRepeatCount(uint256 value);

/// @dev Real function pointers to the opcodes for the extern component of this
/// contract. These get run at eval time wehen the interpreter calls into the
/// contract as an `IInterpreterExternV3`.
bytes constant OPCODE_FUNCTION_POINTERS = hex"0805";

/// @dev Number of opcode function pointers available to run at eval time.
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 1;

/// @dev Real function pointers to the integrity checks for the extern component
/// of this contract. These get run at deploy time when the main integrity checks
/// are run, the extern opcode integrity on the deployer will delegate integrity
/// checks to the extern contract.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"095c";

/// @dev Opcode index of the extern increment opcode. Needs to be manually kept
/// in sync with the extern opcode function pointers. Definitely write tests for
/// this to ensure a mismatch doesn't happen silently.
uint256 constant OP_INDEX_INCREMENT = 0;

/// @title LibExternOpIntIncNPE2
/// This is a library that mimics the op libraries elsewhere in this repo, but
/// structured to fit extern dispatching rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
///
/// This op is a simple increment of every input by 1. It is used to demonstrate
/// handling both multiple inputs and outputs in extern dispatching logic.
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

/// @title LibExternOpStackOperandNPE2
/// This is a library that mimics the op libraries elsewhere in this repo, but
/// structured to fit extern dispatching rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
///
/// This op copies its operand value to the stack by copying it to the constants
/// array at parse time. This means that it doesn't exist as an externed opcode,
/// the interpreter will run it directly, therefore it has no `run` or
/// `integrity` logic, only a sub parser. This demonstrates both how to
/// implement constants, and handling operands in the sub parser.
library LibExternOpStackOperandNPE2 {
    //slither-disable-next-line dead-code
    function subParser(uint256 constantsHeight, uint256, Operand operand)
        internal
        pure
        returns (bool, bytes memory, uint256[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserConstant(constantsHeight, Operand.unwrap(operand));
    }
}

/// @title LibExternOpContextSenderNPE2
/// This is a library that mimics the op libraries elsewhere in this repo, but
/// structured to fit extern dispatching rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
///
/// This op is a simple reference to the sender of the transaction that called
/// the interpreter. It is used to demonstrate how to implement context
/// references.
library LibExternOpContextSenderNPE2 {
    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, Operand) internal pure returns (bool, bytes memory, uint256[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_SENDER);
    }
}

/// @title LibExternOpContextCallingContractNPE2
/// This is a library that mimics the op libraries elsewhere in this repo, but
/// structured to fit extern dispatching rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
///
/// This op is a simple reference to the contract that called the interpreter.
/// It is used to demonstrate how to implement context references.
library LibExternOpContextCallingContractNPE2 {
    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, Operand) internal pure returns (bool, bytes memory, uint256[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_CALLING_CONTRACT);
    }
}

/// @title LibParseLiteralRepeat
/// This is a library that mimics the literal libraries elsewhere in this repo,
/// but structured to fit sub parsing rather than internal logic. It is NOT
/// required to use this pattern, of libs outside the implementation contract,
/// but it MAY be convenient to do so, as the libs can be moved to dedicated
/// files, easily tested and reviewed directly, etc.
///
/// This literal parser is a simple repeat literal parser. It is extremely
/// contrived and serves no real world purpose. It is used to demonstrate how
/// to implement a literal parser, including extracting a value from the
/// dispatch data and providing it to the parser.
///
/// The repeat literal parser takes a single digit as input, and repeats that
/// digit for every byte in the literal.
/// ```
/// /* 000 */
/// [ref-extern-repeat-0 abc]
/// /* 111 */
/// [ref-extern-repeat-1 cde]
/// /* 222 */
/// [ref-extern-repeat-2 zzz]
/// /* 333 */
/// [ref-extern-repeat-3 123]
/// ```
library LibParseLiteralRepeat {
    //slither-disable-next-line dead-code
    function parseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end) internal pure returns (uint256) {
        unchecked {
            uint256 value;
            uint256 length = end - cursor;
            for (uint256 i = 0; i < length; ++i) {
                value += dispatchValue * 10 ** i;
            }
            return value;
        }
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
        AuthoringMetaV2[SUB_PARSER_WORD_PARSERS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            AuthoringMetaV2(
                "ref-extern-inc",
                "Demonstrates a sugared extern into the reference implementation that increments every input 1:1 with its outputs."
            ),
            AuthoringMetaV2(
                "ref-extern-stack-operand",
                "Demonstrates using the reference extern to put the operand of a word back into a constant opcode on the main interpreter, without any extern dispatch."
            ),
            AuthoringMetaV2(
                "ref-extern-context-sender",
                "Demonstrates a sugared context reference to the sender assuming the standard position in the context grid at <0 0>."
            ),
            AuthoringMetaV2(
                "ref-extern-context-contract",
                "Demonstrates a sugared context reference to the calling contract assuming the standard position in the context grid at <0 1>."
            )
        ];
        AuthoringMetaV2[] memory wordsDynamic;
        uint256 length = SUB_PARSER_WORD_PARSERS_LENGTH;
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
    function subParserWordParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_WORD_PARSERS;
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
    function subParserLiteralParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_LITERAL_PARSERS;
    }

    /// Overrides the compatibility version for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserCompatibility() internal pure override returns (bytes32) {
        return COMPATIBLITY_V2;
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

    /// The literal parsers are the same as the main parser.
    function buildSubParserLiteralParsers() external pure returns (bytes memory) {
        unchecked {
            function (uint256, uint256, uint256) internal pure returns (uint256) lengthPointer;
            uint256 length = SUB_PARSER_LITERAL_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function (uint256, uint256, uint256) internal pure returns (uint256)[SUB_PARSER_LITERAL_PARSERS_LENGTH + 1]
                memory parsersFixed = [lengthPointer, LibParseLiteralRepeat.parseRepeat];
            uint256[] memory parsersDynamic;
            assembly {
                parsersDynamic := parsersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (parsersDynamic.length != length) {
                revert BadDynamicLength(parsersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(parsersDynamic);
        }
    }

    function matchSubParseLiteralDispatch(uint256 cursor, uint256 end)
        internal
        pure
        virtual
        override
        returns (bool, uint256, uint256)
    {
        unchecked {
            uint256 length = end - cursor;
            bytes32 word;
            assembly ("memory-safe") {
                word := mload(cursor)
            }
            if (
                length > SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH
                    && (word & SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK) == SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32
            ) {
                ParseState memory state = LibParseState.newState("", "", "", "");
                // If we have a match on the keyword then the next chars MUST
                // be a decimal, otherwise it's an error.
                uint256 value;
                (cursor, value) = LibParseLiteralDecimal.parseDecimal(
                    state, cursor + SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH, end
                );
                // We can only repeat a single digit.
                if (value > 9) {
                    revert InvalidRepeatCount(value);
                }

                return (true, SUB_PARSER_LITERAL_REPEAT_INDEX, value);
            } else {
                return (false, 0, 0);
            }
        }
    }

    /// There's only one operand parser for this implementation, the disallowed
    /// parser. We haven't implemented any words with meaningful operands yet.
    function buildSubParserOperandHandlers() external pure returns (bytes memory) {
        unchecked {
            function(uint256[] memory) internal pure returns (Operand) lengthPointer;
            uint256 length = SUB_PARSER_WORD_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(uint256[] memory) internal pure returns (Operand)[SUB_PARSER_WORD_PARSERS_LENGTH + 1] memory
                handlersFixed = [
                    lengthPointer,
                    // inc
                    LibParseOperand.handleOperandDisallowed,
                    // Stack operand
                    LibParseOperand.handleOperandSingleFull,
                    // Context sender
                    LibParseOperand.handleOperandDisallowed,
                    // Context contract
                    LibParseOperand.handleOperandDisallowed
                ];
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
    function buildSubParserWordParsers() external pure returns (bytes memory) {
        unchecked {
            function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)
                lengthPointer;
            uint256 length = SUB_PARSER_WORD_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(uint256, uint256, Operand) internal view returns (bool, bytes memory, uint256[] memory)[SUB_PARSER_WORD_PARSERS_LENGTH
                + 1] memory pointersFixed = [
                    lengthPointer,
                    LibExternOpIntIncNPE2.subParser,
                    LibExternOpStackOperandNPE2.subParser,
                    LibExternOpContextSenderNPE2.subParser,
                    LibExternOpContextCallingContractNPE2.subParser
                ];
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
