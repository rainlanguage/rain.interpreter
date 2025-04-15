// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol

// This file is committed to the repository because there is a circular
// dependency between the contract and its pointers file. The contract
// needs the pointers file to exist so that it can compile, and the pointers
// file needs the contract to exist so that it can be compiled.

// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

/// @dev Hash of the known bytecode.
bytes32 constant BYTECODE_HASH = bytes32(0x6775c5f4371918d47f9ec1f3d8aec7022d890d33a7f248a2e1b059576f1af857);

/// @dev The parse meta that is used to lookup word definitions.
/// The structure of the parse meta is:
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
    hex"0105000000008080000080040004082020000080400e000200421800040a000280061865912a097c4c45175e75790b7ca67d1073777004806f0701b724cd16b651f2030f55d100133c2414347e350d53e76d0e8e6c74158a931112fdfb9211a8fcc50a2af447071c897208d3469002b3116f13cf63ef0582592f0c69a2ee0629ca940f0b5704";

/// @dev The build depth of the parser meta.

uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler.
/// These positional indexes all map to the same indexes looked up in the parse
/// meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"1d201d201d201df51f0c1f0c1f0c1df51df51d201d201d201f0c1f0c1f0c1f0c1f0c1f0c1f0c1f0c1f0c1f0c1f0c1f0c1f0c";

/// @dev Every two bytes is a function pointer for a literal parser.
/// Literal dispatches are determined by the first byte(s) of the literal
/// rather than a full word lookup, and are done with simple conditional
/// jumps as the possibilities are limited compared to the number of words we
/// have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"175c1a241a551b2f";
