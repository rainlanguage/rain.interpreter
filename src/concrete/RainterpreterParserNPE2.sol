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
import {
    BYTECODE_HASH as PARSER_BYTECODE_HASH,
    LITERAL_PARSER_FUNCTION_POINTERS
} from "../generated/RainterpreterParserNPE2.pointers.sol";

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
    hex"027d02482901b41410193601380a408092011324604290a201223062960011040a8900000000000000000800000008000000100000000000000000000000000000000037af1e5831ee31ff1a4c426226d999cd14d454a62287204a17ca041510bfc04d05382451258fb9fe30e745fd28dbc3c529415aff38530a92368e9cbd2f4c3a173b402c5804ea67600a2aa235164d56371805a7653edd323d0cd5a68e1e3f22703f2237031f80073412d4a5b3119bd3ec068483ae402e554c35f6dc5d23f0c0a632fef45a2da6feff1c9677b92edb58d43c742e374178613501d4fa88030cae020885d59f2b766a3e158413022a67b453194070aa2040ab0f245a53d84392737c335bcbd00ff7e3283d5a200713686f5c39bd3f5f024641b909f14a300b1ec71b27a38323349552b91d792a60425d96b7457b8cf22153f8d14433bccc0d403ded0791b7eb002ddffc0e1abd702ce98c713ac04abd1b4507bb";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler. These
/// positional indexes all map to the same indexes looked up in the parse meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"18d818d818d8193d19b619b619b6193d193d18d818d818d819b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619b619fb19b61acd19fb19b61acd19b619b618d81b3619b619b6";

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
        return interfaceId == type(IParserV1).interfaceId || interfaceId == type(IParserPragmaV1).interfaceId
            || super.supportsInterface(interfaceId);
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
