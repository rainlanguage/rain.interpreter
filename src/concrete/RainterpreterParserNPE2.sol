// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

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
bytes32 constant PARSER_BYTECODE_HASH = bytes32(0xedebe2f9d01b5e9c588c578348293bd9014be08f31c374f4203be68adebb8f76);

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
    hex"02588423482a0a64a4805a093a0046408a2000483db0020941044cd10693108128940000000000000000000800000000100000000000000000100000000000000000001f49c6a348b005fd0c1dc53744b46c3a1a6b5d512cc697651ba56d9d416380a84768119145bf1f411c9320384025b20727767586017788743d54ad3411facaed0bf793d92a5dd6b80ac51f7f13de413210b7896422844b300fd8f7982b7c1ad31611585907980f123846207d420085742d567a1d4ab12847126e57172f75b953212a4b6e332c3f7f31f3a7222e87d7c63e201236435fbbfc32e281ae25b491eb3f7af18839b31297302973c128b94d704b1ec042237d449e18a0265d3c2223f20482963a035436e60205c2140075eca1152558bb061fa22149a5e8dd144329870d6598183bbd10093462c9701ee60c073664e22009880be535267cb3269879ba1d7d424b4654aa05197e9c533ae38ebd372dd7b205e7bf522908ea4b202f3f5e0e52726c08783df917448fdb248cf8244c9232f7";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler. These
/// positional indexes all map to the same indexes looked up in the parse meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"18d918d918d9196e1a0f1a0f1a0f196e196e18d918d918d91a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a541ae81a0f1a541ae81a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f1a0f18d91bde18d91bde1a0f1a0f";

/// @dev Every two bytes is a function pointer for a literal parser. Literal
/// dispatches are determined by the first byte(s) of the literal rather than a
/// full word lookup, and are done with simple conditional jumps as the
/// possibilities are limited compared to the number of words we have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"0f3a1202161e16f8";

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
