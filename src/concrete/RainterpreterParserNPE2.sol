// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "../interface/IParserV1.sol";
import {LibParseState, ParseState} from "../lib/parse/LibParseState.sol";
import {LibParseLiteral} from "../lib/parse/literal/LibParseLiteral.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";

/// @dev The known hash of the parser bytecode. This is used by the deployer to
/// check that it is deploying a parser that is compatible with the interpreter.
bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x437d1fdaaf5d913168e0d3a9ce7dd80110cda6a8810e380bd263085f4b784f85);

/// @dev Encodes the parser meta that is used to lookup word definitions.
/// The structure of the parser meta is:
/// - 1 byte: The depth of the bloom filters
/// - 1 byte: The hashing seed
/// - The bloom filters, each is 32 bytes long, one for each build depth.
/// - All the items for each word, each is 4 bytes long. Each item's first byte
///   is its opcode index, the remaining 3 bytes are the word fingerprint.
/// To do a lookup, the word is hashed with the seed, then the first byte of the
/// hash is compared against the bloom filter. If there is a hit then we count
/// the number of 1 bits in the bloom filter up to this item's 1 bit. We then
/// treat this a the index of the item in the items array. We then compare the
/// word fingerprint against the fingerprint of the item at this index. If the
/// fingerprints equal then we have a match, else we increment the seed and try
/// again with the next bloom filter, offsetting all the indexes by the total
/// bit count of the previous bloom filter. If we reach the end of the bloom
/// filters then we have a miss.
bytes constant PARSE_META =
    hex"02588423402e0844a4805a09380046408a2000483d10000941044dd10693108128840000000000000000000800000000000000000000000000100000000000000000001f49c6a30c1dc5373fb46c3a1a6b5d512ac697651ba56d9d3c6380a84268119140bf1f411c9320383b25b20725767586017788743854ad3411facaed0bf793d9285dd6b83398844e0ac51f7f13de413210b7896422844b300fd8f798297c1ad31611585907980f123d008574126e57172c75b953212a4b6e302c3f7f2ef3a7222b87d7c6392012363e5fbbfc2fe281ae23b491eb3a7af18835b312972d2973c126b94d70441ec04218a0265d372223f20482963a035436e60205c2140075eca1152558bb061fa22143a5e8dd144329870d65981836bd10093162c9701ee60c0709880be5249879ba1d7d424b3298ad584154aa05197e9c53342dd7b205e7bf522708ea4b202f3f5e0e52726c08783df917448fdb459232f7";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler. These
/// positional indexes all map to the same indexes looked up in the parse meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"10bc10bc10bc115111f211f211f21151115110bc10bc10bc11f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f211f2123712cb11f212cb11f211f211f211f211f211f211f211f211f211f211f211f210bc10bc11f211f2";

/// @dev Every two bytes is a function pointer for a literal parser. Literal
/// dispatches are determined by the first byte(s) of the literal rather than a
/// full word lookup, and are done with simple conditional jumps as the
/// possibilities are limited compared to the number of words we have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"084e0b160e130ecb";

/// @title RainterpreterParserNPE2
/// @dev The parser implementation.
contract RainterpreterParserNPE2 is IParserV1, ERC165 {
    using LibParse for ParseState;

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IParserV1).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IParserV1
    function parse(bytes memory data) external pure virtual override returns (bytes memory, uint256[] memory) {
        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return LibParseState.newState(
            data, parseMeta(), operandHandlerFunctionPointers(), literalParserFunctionPointers()
        ).parse();
    }

    /// Virtual function to return the parse meta.
    function parseMeta() internal pure virtual returns (bytes memory) {
        return PARSE_META;
    }

    /// Virtual function to return the operand handler function pointers.
    function operandHandlerFunctionPointers() internal pure virtual returns (bytes memory) {
        return OPERAND_HANDLER_FUNCTION_POINTERS;
    }

    /// Virtual function to return the literal parser function pointers.
    function literalParserFunctionPointers() internal pure virtual returns (bytes memory) {
        return LITERAL_PARSER_FUNCTION_POINTERS;
    }

    /// External function to build the operand handler function pointers.
    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory) {
        return LibAllStandardOpsNP.operandHandlerFunctionPointers();
    }

    /// External function to build the literal parser function pointers.
    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return LibAllStandardOpsNP.literalParserFunctionPointers();
    }
}
