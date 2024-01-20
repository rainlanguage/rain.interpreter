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
bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x949cf4381e191ea99f058b93cbb81d158c2bb07f289e0bd3faa6a3997ec1ca19);

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
    hex"02588423002e084484805a09380046608a2404483d10000941044dd10693108128840000000000000000000800000000000000000000000000100000000000000000001f49c6a30c1dc5373db46c3a1a6b5d512ac697651ba56d9d3a6380a8406811913ebf1f411c9320383925b20725767586017788743654ad3411facaed0bf793d9285dd6b83498844e0ac51f7f13de413210b7896422844b300fd8f798297c1ad31611585907980f123b008574126e57172c75b953212a4b6e302c3f7f2ef3a7222b87d7c6372012364652960745f3a07e3c5fbbfc2fe281ae23b491eb387af1884454e39235b312972d2973c126b94d70421ec04218a0265d322223f20482963a035436e60205c2140075eca1152558bb061fa22141a5e8dd144329870d6598183162c9701ee60c0709880be5249879ba1d7d424b3398ad583f54aa05197e9c5305e7bf522708ea4b202f3f5e0e52726c08783df917448fdb439232f7";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler. These
/// positional indexes all map to the same indexes looked up in the parse meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"10c410c41159115911fa11fa11fa1159115910c410c4115911fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa10c410c411fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa123f12d312d311fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa11fa10c410c410c4";

/// @dev Every two bytes is a function pointer for a literal parser. Literal
/// dispatches are determined by the first byte(s) of the literal rather than a
/// full word lookup, and are done with simple conditional jumps as the
/// possibilities are limited compared to the number of words we have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"08560b1e0e1b0ed3";

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
