// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";

import {console2} from "forge-std/console2.sol";

import {ISubParserV1} from "../interface/unstable/ISubParserV1.sol";
import {IncompatibleSubParser} from "../error/ErrSubParse.sol";
import {LibSubParse, ParseState} from "../lib/parse/LibSubParse.sol";
import {CMASK_RHS_WORD_TAIL} from "../lib/parse/LibParseCMask.sol";
import {LibParse, Operand} from "../lib/parse/LibParse.sol";
import {LibParseMeta} from "../lib/parse/LibParseMeta.sol";
import {LibParseOperand} from "../lib/parse/LibParseOperand.sol";

/// @dev This is a placeholder for the subparser function pointers.
/// The subparser function pointers are a list of 16 bit function pointers,
/// where each subparser function is responsible for parsing a particular
/// word into a an opcode that will be used by the main parser to build the
/// final bytecode.
bytes constant SUB_PARSER_FUNCTION_POINTERS = hex"";

/// @dev This is a placeholder for the subparser meta bytes.
/// The subparser meta bytes are the same structure as the main parser meta
/// bytes. The exact same process of hashing, blooming, fingeprinting and index
/// lookup applies to the subparser meta bytes as the main parser meta bytes.
bytes constant SUB_PARSER_PARSE_META = hex"";

/// @dev This is a placeholder for the int that encodes pointers to operand
/// parsers. In the future this will probably be removed and the main parser
/// will handle all operand parsing, the subparser will only be responsible for
/// checking the validity of the operand values and encoding them into the
/// resulting bytecode.
bytes constant SUB_PARSER_OPERAND_HANDLERS = hex"";

/// @dev This is a placeholder for the int that encodes pointers to literal
/// parsers. In the future this will probably be removed and there will be
/// dedicated concepts for "sub literal" and "sub word" parsing, that should be
/// more composable than the current approach.
uint256 constant SUB_PARSER_LITERAL_PARSERS = 0;

/// @dev This is a placeholder for compatibility version. The child contract
/// should override this to define its own compatibility version.
bytes32 constant SUB_PARSER_COMPATIBLITY = bytes32(0);

/// Base implementation of `ISubParserV1`. Inherit from this contract and
/// override the virtual functions to align all the relevant pointers and
/// metadata bytes so that it can actually run.
/// The basic workflow for subparsing via this contract is:
/// - The main parser will call `subParse` with the subparser's compatibility
///   version and the data to parse.
/// - The subparser will check the compatibility is an exact match and revert if
///   not. This is the simplest and most conservative approach, if there's a new
///   compatibility version, a new version of the subparser will need to be
///   deployed even if the upstream changes are backwards compatible.
/// - The subparser will then parse the data, using the `subParserParseMeta`
///   function to get the metadata bytes, which must be overridden by the child
///   contract in order to be useful. The sub parser meta bytes are constructed
///   exactly the same as the main parser meta bytes, so the same types and libs
///   can be used to build them. The key difference is that the index of each
///   word in the authoring meta maps to a _parser_ function pointer, rather
///   than a _handler_ function pointer. What this means is that the function
///   at index N of `subParserFunctionPointers` is responsible for parsing
///   whatever data the main parser has passed to `subParse` into whatever the
///   final output of the subparser is. For example, the 5th parser function
///   might convert some word string `"foo"` into the bytecode that represents
///   an extern call on the main interpreter into the contract that provides
///   that extern logic. This decoupling allows any subparser function to
///   generate any runtime behaviour at all, provided it knows how to construct
///   the opcode for it.
/// - Currently the subparse handles literals and operands in the same way as
///   the main parser, but this may change in future. Likely that there will be
///   dedicated "sub literal" and "sub word" concepts, that should be more
///   composable than the current approach.
/// - The final result of the subparser is returned as a tuple of success,
///   bytecode and constants. The success flag is used to indicate whether the
///   subparser was able to parse the data, and the bytecode and constants are
///   the same as the main parser, and are used to construct the final bytecode
///   of the main parser. The expectation on failure is that there may be some
///   other subparser that can parse the data, so the main parser will handle
///   fallback logic.
abstract contract BaseRainterpreterSubParserNPE2 is ERC165, ISubParserV1 {
    using LibBytes for bytes;
    using LibParse for ParseState;
    using LibParseMeta for ParseState;
    using LibParseOperand for ParseState;

    /// Overrideable function to allow implementations to define their parse
    /// meta bytes.
    //slither-disable-next-line dead-code
    function subParserParseMeta() internal pure virtual returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    /// Overrideable function to allow implementations to define their function
    /// pointers to each sub parser.
    //slither-disable-next-line dead-code
    function subParserFunctionPointers() internal pure virtual returns (bytes memory) {
        return SUB_PARSER_FUNCTION_POINTERS;
    }

    /// Overrideable function to allow implementations to define their operand
    /// handlers.
    //slither-disable-next-line dead-code
    function subParserOperandHandlers() internal pure virtual returns (bytes memory) {
        return SUB_PARSER_OPERAND_HANDLERS;
    }

    /// Overrideable function to allow implementations to define their literal
    /// parsers.
    //slither-disable-next-line dead-code
    function subParserLiteralParsers() internal pure virtual returns (uint256) {
        return SUB_PARSER_LITERAL_PARSERS;
    }

    /// Overrideable function to allow implementations to define their
    /// compatibility version.
    //slither-disable-next-line dead-code
    function subParserCompatibility() internal pure virtual returns (bytes32) {
        return SUB_PARSER_COMPATIBLITY;
    }

    /// A basic implementation of sub parsing that uses encoded function pointers
    /// to dispatch everything necessary in O(1) and allows for the child
    /// contract to override all relevant functions with some modest boilerplate.
    /// This is virtual but the expectation is that it generally DOES NOT need
    /// to be overridden, as the function pointers and metadata bytes are all
    /// that need to be changed to implement a new subparser.
    /// @inheritdoc ISubParserV1
    function subParse(bytes32 compatibility, bytes memory data)
        external
        pure
        virtual
        returns (bool success, bytes memory bytecode, uint256[] memory constants)
    {
        if (compatibility != subParserCompatibility()) {
            revert IncompatibleSubParser();
        }
        console2.logBytes(data);

        (uint256 constantsHeight, uint256 ioByte, ParseState memory state) = LibSubParse.consumeInputData(
            data, subParserParseMeta(), subParserOperandHandlers(), subParserLiteralParsers()
        );
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        uint256 end = cursor + state.data.length;

        bytes32 word;
        (cursor, word) = LibParse.parseWord(cursor, end, CMASK_RHS_WORD_TAIL);
        (bool exists, uint256 index) = state.lookupWord(word);
        console2.log(exists, index);
        console2.logBytes(abi.encodePacked(word));
        if (exists) {
            Operand operand = state.handleOperand(index);
            function (uint256, uint256, Operand) internal pure returns (bool, bytes memory, uint256[] memory) subParser;
            bytes memory localSubParserFunctionPointers = subParserFunctionPointers();
            assembly ("memory-safe") {
                subParser := and(mload(add(localSubParserFunctionPointers, mul(add(index, 1), 2))), 0xFFFF)
            }
            return subParser(constantsHeight, ioByte, operand);
        } else {
            return (false, "", new uint256[](0));
        }
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ISubParserV1).interfaceId || super.supportsInterface(interfaceId);
    }
}
