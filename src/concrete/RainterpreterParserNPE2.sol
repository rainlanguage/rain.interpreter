// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserPragmaV1, PragmaV1} from "rain.interpreter.interface/interface/unstable/IParserPragmaV1.sol";
import {IParserV1} from "rain.interpreter.interface/interface/IParserV1.sol";
import {LibParseState, ParseState} from "../lib/parse/LibParseState.sol";
import {LibParsePragma} from "../lib/parse/LibParsePragma.sol";
import {LibParseLiteral} from "../lib/parse/literal/LibParseLiteral.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseInterstitial} from "../lib/parse/LibParseInterstitial.sol";

/// @dev The known hash of the parser bytecode. This is used by the deployer to
/// check that it is deploying a parser that is compatible with the interpreter.
bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x3b05d76ef696ad0698c2894de3cba709ae6d58a4468a5e2a1133be7ea8e61b6f);

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
    hex"029280d0000430610132c412e1426060706098a2144a04900817008118207c1122080000400000000000000000000000000000000000000000000000004000000000000b5e49bb380578dd354d94b70369074e10212ea109609a690dbdd2601ab661e606e9a0f11e79a3c019a3bf081571cbb03a253a5641142dec43939f82322fe3673f8bd71b1114140208a6bbfd22b37cbc37fe60ab2bd890881b00e7793df9f87b1783810e287eb62d2165d32307a294af2df7d93e2336225029e1166b4502286c2fde1fc436d9b5932cedb4ad2627277e12db71382a77ab82166e13b00c9d78f61409a0b03b0c6db8135dfecc0ea46b263ebb5ab92012325b1cd0e81840b898c418f0b3c82e49f5b3443326d604095a090f9e8635026d7b0d245b862742b77f3d25b47f030a2081ac310a9c5e278d28c1003a80e53064dd3133a5359601571cc305b71f5d1db3cf3739c6e9c61f86455b3c8cf0fc34ae0940";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler. These
/// positional indexes all map to the same indexes looked up in the parse meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"188c188c188c18f1196a196a196a18f118f1188c188c188c196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a196a19af196a1a8119af196a1a81196a196a188c1aea196a196a";

/// @dev Every two bytes is a function pointer for a literal parser. Literal
/// dispatches are determined by the first byte(s) of the literal rather than a
/// full word lookup, and are done with simple conditional jumps as the
/// possibilities are limited compared to the number of words we have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"0f0211ca15d116ab";

/// @title RainterpreterParserNPE2
/// @dev The parser implementation.
contract RainterpreterParserNPE2 is IParserV1, IParserPragmaV1, ERC165 {
    using LibParse for ParseState;
    using LibParseState for ParseState;
    using LibParsePragma for ParseState;
    using LibParseInterstitial for ParseState;
    using LibBytes for bytes;

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

    /// @inheritdoc IParserPragmaV1
    function parsePragma1(bytes memory data) external pure virtual override returns (PragmaV1 memory) {
        ParseState memory parseState =
            LibParseState.newState(data, parseMeta(), operandHandlerFunctionPointers(), literalParserFunctionPointers());
        uint256 cursor = Pointer.unwrap(data.dataPointer());
        uint256 end = Pointer.unwrap(data.endDataPointer());
        cursor = parseState.parseInterstitial(cursor, end);
        cursor = parseState.parsePragma(cursor, end);
        (cursor);
        return PragmaV1(parseState.exportSubParsers());
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
