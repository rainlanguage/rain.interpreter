// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol

// This file is committed to the repository because there is a circular
// dependency between the contract and its pointers file. The contract
// needs the pointers file to exist so that it can compile, and the pointers
// file needs the contract to exist so that it can be compiled.

// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

/// @dev Hash of the known bytecode.
bytes32 constant BYTECODE_HASH = bytes32(0x0913de8e0b36ea4fde9df417b198d01eba3e5cb78da1c5c6bbc50bea09444023);

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
    hex"027d02482901b41410193e01380a408092011324604390a201223062960051044a890000000080000000080000000800000010000000000000000000000000000000003caf1e5836ee31ff1e4c42622ad999cd17d454a61a378a702687204a1bca041513bfc04d2fac003405382451298fb9fe35e745fd2cdbc3c52d415aff3d530a923b8e9cbd344c3a171096c4d004ea67600a2aa235194d56371c05a76543dd323d0cd5a68e223f22704422370312f1ac932380073415d4a5b3149bd3ec068483ae452e554c3af6dc5d27f0c0a637fef45a32a6feff209677b933db58d441742e374678613501d4fa88030cae020885d59f30766a3e188413022e67b4531d4070aa2440ab0f285a53d84892737c115fb368385bcbd00ff7e328425a200716686f5c3ebd3f5f024641b909f14a300b1ec71b2ba38323399552b921792a60475d96b74a7b8cf22553f8d14933bccc0d403ded0791b7eb002ddffc0e1abd7031e98c713fc04abd1f4507bb407db187";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler.
/// These positional indexes all map to the same indexes looked up in the parse
/// meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"190019001900196519de19de19de1965196519001900190019de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de19de1a2319de1af51a2319de1af519de19de19001b5e19de19de";

/// @dev Every two bytes is a function pointer for a literal parser.
/// Literal dispatches are determined by the first byte(s) of the literal
/// rather than a full word lookup, and are done with simple conditional
/// jumps as the possibilities are limited compared to the number of words we
/// have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"0f76123e1645171f";
