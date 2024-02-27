// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserV1} from "rain.interpreter.interface/interface/IParserV1.sol";
import {LibParseState, ParseState} from "../lib/parse/LibParseState.sol";
import {LibParseLiteral} from "../lib/parse/literal/LibParseLiteral.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";

/// @dev The known hash of the parser bytecode. This is used by the deployer to
/// check that it is deploying a parser that is compatible with the interpreter.
bytes32 constant PARSER_BYTECODE_HASH = bytes32(0x6ebdf4615e027e4d771f6c37dc02d32adee31504069a05227054ec8d4844fe7e);

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
    hex"02588423402e0844a4805a093a0046408a2000483db0000941044dd10693108128940000000000000000000800000000000000000000000000100000000000000000001f49c6a345b005fd0c1dc53741b46c3a1a6b5d512bc697651ba56d9d3e6380a84468119142bf1f411c9320383d25b20726767586017788743a54ad3411facaed0bf793d9295dd6b83598844e0ac51f7f13de413210b7896422844b300fd8f7982a7c1ad31611585907980f123f0085742c567a1d47b12847126e57172e75b953212a4b6e322c3f7f30f3a7222d87d7c63b201236405fbbfc31e281ae24b491eb3c7af18837b312972f2973c127b94d70481ec042237d449e18a0265d392223f20482963a035436e60205c2140075eca1152558bb061fa22146a5e8dd144329870d65981838bd10093362c9701ee60c0709880be5259879ba1d7d424b3498ad584354aa05197e9c53362dd7b205e7bf522808ea4b202f3f5e0e52726c08783df917448fdb499232f7";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler. These
/// positional indexes all map to the same indexes looked up in the parse meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"10dc10dc10dc11711212121212121171117110dc10dc10dc1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212125712eb121212eb12121212121212121212121212121212121212121212121210dc13e110dc13e112121212";

/// @dev Every two bytes is a function pointer for a literal parser. Literal
/// dispatches are determined by the first byte(s) of the literal rather than a
/// full word lookup, and are done with simple conditional jumps as the
/// possibilities are limited compared to the number of words we have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"086e0b360e330eeb";

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
