// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "sol.lib.memory/LibPointer.sol";

// Error 1
error MissingFinalSemi(uint256 offset);

// Error 2
error UnexpectedLHSChar(uint256 offset, string char);

// Error 3
error UnexpectedRHSChar(uint256 offset, string char);

// Error 4
error WordTooLong(uint256 offset);

/// @dev \t
uint128 constant CMASK_TAB = 0x200;

/// @dev \n
uint128 constant CMASK_LINE_FEED = 0x400;

/// @dev \r
uint128 constant CMASK_CARRIAGE_RETURN = 0x2000;

/// @dev space
uint128 constant CMASK_SPACE = 0x0100000000;

/// @dev ,
uint128 constant CMASK_COMMA = 0x100000000000;

/// @dev -
uint128 constant CMASK_DASH = 0x200000000000;

/// @dev :
uint128 constant CMASK_COLON = 0x0400000000000000;

/// @dev ;
uint128 constant CMASK_SEMICOLON = 0x800000000000000;

/// @dev _
uint128 constant CMASK_UNDERSCORE = 0x800000000000000000000000;

/// @dev (
uint128 constant CMASK_LEFT_PAREN = 0x10000000000;

/// @dev )
uint128 constant CMASK_RIGHT_PAREN = 0x20000000000;

/// @dev LHS/RHS delimiter is :
uint128 constant CMASK_LHS_RHS_DELIMITER = 0x0400000000000000;
/// @dev lower alpha and underscore a-z _
uint128 constant CMASK_LHS_STACK_HEAD = 0xffffffe800000000000000000000000;

/// @dev lower alpha a-z
uint128 constant CMASK_IDENTIFIER_HEAD = 0xffffffe000000000000000000000000;
/// @dev lower alphanumeric kebab a-z 0-9 -
uint128 constant CMASK_IDENTIFIER_TAIL = 0xffffffe0000000003ff200000000000;
/// @dev NOT lower alphanumeric kebab
uint128 constant CMASK_NOT_IDENTIFIER_TAIL = 0xf0000001fffffffffc00dfffffffffff;

/// @dev stack item delimiter is space
uint128 constant CMASK_LHS_STACK_DELIMITER = 0x0100000000;

/// @dev whitespace is \n \r \t space
uint128 constant CMASK_WHITESPACE = 0x100002600;

/// @dev 010101... for ctpop
uint256 constant CTPOP_M1 = 0x5555555555555555555555555555555555555555555555555555555555555555;
/// @dev 00110011.. for ctpop
uint256 constant CTPOP_M2 = 0x3333333333333333333333333333333333333333333333333333333333333333;
/// @dev 4 bits alternating for ctpop
uint256 constant CTPOP_M4 = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
/// @dev 8 bits alternating for ctpop
uint256 constant CTPOP_M8 = 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF;
/// @dev 16 bits alternating for ctpop
uint256 constant CTPOP_M16 = 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF;
/// @dev 32 bits alternating for ctpop
uint256 constant CTPOP_M32 = 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF;
/// @dev 64 bits alternating for ctpop
uint256 constant CTPOP_M64 = 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF;
/// @dev 128 bits alternating for ctpop
uint256 constant CTPOP_M128 = 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

type Seed is uint256;

struct SeedTracker {
    bool success;
    Seed seed0;
    Seed seed1;
    uint256 collisions;
    Bitmap bitmap0;
    Bitmap bitmap1;
}

type SeedOutcome is uint256;

type Bitmap is uint256;

error NoSeedFound();

library LibParse {
    function stringToChar(string memory s) external pure returns (uint256 char) {
        return 1 << uint256(uint8(bytes1(bytes(s))));
    }

    function ctpop(uint256 x) internal pure returns (uint256) {
        unchecked {
            // https://en.wikipedia.org/wiki/Hamming_weight
            // @todo - currently using naive/slow implementation
            x = (x & CTPOP_M1) + ((x >> 1) & CTPOP_M1);
            x = (x & CTPOP_M2) + ((x >> 2) & CTPOP_M2);
            x = (x & CTPOP_M4) + ((x >> 4) & CTPOP_M4);
            x = (x & CTPOP_M8) + ((x >> 8) & CTPOP_M8);
            x = (x & CTPOP_M16) + ((x >> 16) & CTPOP_M16);
            x = (x & CTPOP_M32) + ((x >> 32) & CTPOP_M32);
            x = (x & CTPOP_M64) + ((x >> 64) & CTPOP_M64);
            x = (x & CTPOP_M128) + ((x >> 128) & CTPOP_M128);

            return x;
        }
    }

    function wordHashed(Seed seed, bytes32 word) internal pure returns (bytes32 hashed) {
        assembly ("memory-safe") {
            mstore(0, seed)
            mstore(0x20, word)
            hashed := keccak256(0, 0x40)
        }
    }

    function wordBitmapped(Seed seed, bytes32 word) internal pure returns (uint256) {
        return 1 << (uint256(wordHashed(seed, word)) & 0xFF);
    }

    function checkSeed(Seed seed0, Seed seed1, bytes32[] memory words)
        internal
        pure
        returns (bool success, Bitmap bitmap0, Bitmap bitmap1, uint256 collisions)
    {
        unchecked {
            uint256 start;
            uint256 end;
            assembly ("memory-safe") {
                start := add(words, 0x20)
                end := add(start, mul(mload(words), 0x20))
            }
            collisions = 0;
            for (uint256 cursor = start; cursor < end; cursor += 0x20) {
                bytes32 word;
                assembly ("memory-safe") {
                    word := mload(cursor)
                }
                uint256 shifted = wordBitmapped(seed0, word);

                if (shifted & Bitmap.unwrap(bitmap0) == 0) {
                    bitmap0 = Bitmap.wrap(Bitmap.unwrap(bitmap0) | shifted);
                    // Single collision. Try backup space.
                } else {
                    collisions++;
                    shifted = wordBitmapped(seed1, word);
                    if (shifted & Bitmap.unwrap(bitmap1) == 0) {
                        bitmap1 = Bitmap.wrap(Bitmap.unwrap(bitmap1) | shifted);
                    }
                    // Double collision. Failure.
                    else {
                        return (false, bitmap0, bitmap1, collisions);
                    }
                }
            }
            return (true, bitmap0, bitmap1, collisions);
        }
    }

    function collideOrWrite(Seed seed, Pointer start, Bitmap bitmap, bytes32 word, uint256 i)
        internal
        pure
        returns (bool didCollide)
    {
        unchecked {
            bytes32 hashed = wordHashed(seed, word);
            uint256 bitmapMask = (1 << uint256(uint256(hashed) & 0xFF)) - 1;
            Pointer writeAt = Pointer.wrap(Pointer.unwrap(start) + (6 * ctpop(Bitmap.unwrap(bitmap) & bitmapMask)));
            assembly ("memory-safe") {
                let metaCollData := and(mload(writeAt), 0xFFFFFFFF)
                let hashedCollData := and(hashed, 0xFFFFFFFF)

                switch metaCollData
                // Write.
                case 0 { mstore(writeAt, or(and(mload(writeAt), not(0xFFFFFFFFFFFF)), or(shl(32, i), hashedCollData))) }
                // Collide.
                default {
                    // Ambiguous coll data. Unrecoverable.
                    if eq(hashedCollData, metaCollData) {
                        mstore(0, 2)
                        revert(0, 0x20)
                    }
                    didCollide := 1
                }
            }
        }
    }

    function buildMetaFromSeedTracker(SeedTracker memory seedTracker, bytes32[] memory words)
        internal
        pure
        returns (bytes memory meta)
    {
        unchecked {
            uint256 wordsCount = words.length;
            // 2 byte for base seed
            // 2 bytes for collisions count
            // 6 bytes per word => 4 bytes collision check, 2 bytes index
            uint256 metaLength = 4 + 6 * wordsCount;

            assembly ("memory-safe") {
                // Allocate meta without zeroing it out.
                meta := mload(0x40)
                mstore(meta, metaLength)
                mstore(0x40, add(meta, and(add(add(metaLength, 0x20), 0x1f), not(0x1f))))
            }

            Pointer metaStart0;
            Pointer metaStart1;
            assembly {
                metaStart0 := add(meta, 10)
            }
            metaStart1 = Pointer.wrap(Pointer.unwrap(metaStart0) + (ctpop(Bitmap.unwrap(seedTracker.bitmap0)) * 6));

            Pointer wordsStart;
            assembly {
                wordsStart := add(words, 0x20)
            }
            for (uint256 i = 0; i < wordsCount; i++) {
                bytes32 word;
                assembly ("memory-safe") {
                    word := mload(add(wordsStart, mul(i, 0x20)))
                }

                if (collideOrWrite(seedTracker.seed0, metaStart0, seedTracker.bitmap0, word, i)) {
                    bool _didCollide = collideOrWrite(seedTracker.seed1, metaStart1, seedTracker.bitmap1, word, i);
                }
            }
        }
    }

    function buildMetaSol(bytes32[] memory words) internal pure returns (bytes memory) {
        SeedTracker memory seedTracker;
        Bitmap bitmap0;
        Bitmap bitmap1;

        unchecked {
            uint256 collisions;
            bool success;
            for (Seed seed0 = Seed.wrap(0); Seed.unwrap(seed0) < 0x100; seed0 = Seed.wrap(Seed.unwrap(seed0) + 1)) {
                Seed seed1 = Seed.wrap(Seed.unwrap(seed0) + 1);
                (success, bitmap0, bitmap1, collisions) = checkSeed(seed0, seed1, words);
                if (!success) {
                    continue;
                } else {
                    if (collisions < seedTracker.collisions || collisions == 0) {
                        seedTracker.success = true;
                        seedTracker.collisions = collisions;
                        seedTracker.seed0 = seed0;
                        seedTracker.seed1 = seed1;
                        seedTracker.bitmap0 = bitmap0;
                        seedTracker.bitmap1 = bitmap1;
                    }
                }

                // Perfect result.
                if (collisions == 0) {
                    break;
                }
            }

            if (seedTracker.success == false) {
                revert NoSeedFound();
            }

            return buildMetaFromSeedTracker(seedTracker, words);
        }
    }

    function buildMeta(bytes32[] memory words, uint256 startSeed, uint256 endSeed)
        internal
        pure
        returns (bytes memory meta)
    {
        assembly ("memory-safe") {
            function ctpop(i) -> x {
                // https://en.wikipedia.org/wiki/Hamming_weight
                // @todo - currently using naive/slow implementation

                {
                    let m1 := 0x5555555555555555555555555555555555555555555555555555555555555555
                    x := add(and(i, m1), and(shr(1, i), m1))
                }

                {
                    let m2 := 0x3333333333333333333333333333333333333333333333333333333333333333
                    x := add(and(x, m2), and(shr(2, x), m2))
                }

                {
                    let m4 := 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F
                    x := add(and(x, m4), and(shr(4, x), m4))
                }

                {
                    let m8 := 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF
                    x := add(and(x, m8), and(shr(8, x), m8))
                }

                {
                    let m16 := 0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff
                    x := add(and(x, m16), and(shr(16, x), m16))
                }

                {
                    let m32 := 0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff
                    x := add(and(x, m32), and(shr(32, x), m32))
                }

                {
                    let m64 := 0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff
                    x := add(and(x, m64), and(shr(64, x), m64))
                }

                {
                    let m128 := 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff
                    x := add(and(x, m128), and(shr(128, x), m128))
                }
            }

            function wordHashed(seed, word) -> hashed {
                mstore(0, seed)
                mstore(0x20, word)
                hashed := keccak256(0, 0x40)
            }

            function wordBitmapped(seed, word) -> shifted {
                shifted := shl(and(wordHashed(seed, word), 0xFF), 1)
            }

            function collideOrWrite(seed, start, bitmap, word, i) -> didCollide {
                let hashed := wordHashed(seed, word)
                let bitmapMask := sub(shl(and(hashed, 0xFF), 1), 1)
                let mtaCursor := add(start, mul(ctpop(and(bitmap, bitmapMask)), 6))
                let mtaCollData := and(mload(mtaCursor), 0xFFFFFFFF)
                let hashedCollData := and(hashed, 0xFFFFFFFF)

                switch mtaCollData
                // Write.
                case 0 {
                    mstore(mtaCursor, or(and(mload(mtaCursor), not(0xFFFFFFFFFFFF)), or(shl(32, i), hashedCollData)))
                }
                // Collide.
                default {
                    // Ambiguous coll data. Unrecoverable.
                    if eq(hashedCollData, mtaCollData) {
                        mstore(0, 2)
                        revert(0, 0x20)
                    }
                    didCollide := 1
                }
            }

            function checkSeed(seed, wrds) -> bitmap0, bitmap1, outcome {
                bitmap0 := 0
                bitmap1 := 0
                let start := add(wrds, 0x20)
                let end := add(start, mul(mload(wrds), 0x20))
                let collisions := 0
                for { let cursor := start } lt(cursor, end) { cursor := add(cursor, 0x20) } {
                    let word := mload(cursor)
                    let shifted := wordBitmapped(seed, word)

                    switch and(shifted, bitmap0)
                    // Not collision
                    case 0 { bitmap0 := or(bitmap0, shifted) }
                    // Collision
                    default {
                        collisions := add(collisions, 1)
                        shifted := wordBitmapped(add(seed, 1), word)
                        switch and(shifted, bitmap1)
                        case 0 { bitmap1 := or(bitmap1, shifted) }
                        // Double collision. Failure.
                        default {
                            outcome := 0
                            leave
                        }
                    }
                }
                outcome := or(1, shl(1, collisions))
            }

            function buildMetaFromSeedTracker(bitmap0, bitmap1, seedTracker, wrds) -> mta {
                let wordsCount := mload(wrds)
                let start := add(wrds, 0x20)
                let end := add(start, mul(wordsCount, 0x20))
                let seed := shr(16, seedTracker)

                {
                    mta := mload(0x40)
                    // 2 byte for base seed
                    // 2 bytes for collisions count
                    // 6 bytes per word => 4 bytes collision check, 2 bytes index
                    let metaLength := add(4, mul(6, wordsCount))
                    mstore(mta, metaLength)
                    mstore(0x40, add(mta, and(add(add(metaLength, 0x20), 0x1f), not(0x1f))))
                }

                let mtaStart0 := add(mta, 10)
                let mtaStart1 := add(mtaStart0, mul(ctpop(bitmap0), 6))
                for { let i := 0 } lt(i, wordsCount) { i := add(i, 1) } {
                    let word := mload(add(start, mul(i, 0x20)))

                    if collideOrWrite(seed, mtaStart0, bitmap0, word, i) {
                        let _didCollide := collideOrWrite(add(seed, 1), mtaStart1, bitmap1, word, i)
                    }
                }
            }

            function trackSeed(seed, collisions) -> seedTracker {
                seedTracker := or(or(1, shl(1, collisions)), shl(16, seed))
            }

            let seedTracker := 0
            let bitmap0 := 0
            let bitmap1 := 0
            for {
                let outcome := 0
                let seed := startSeed
            } lt(seed, endSeed) { seed := add(seed, 1) } {
                bitmap0, bitmap1, outcome := checkSeed(seed, words)
                switch outcome
                // Double collision. Failure.
                case 0 { continue }
                // Zero collisions. Perfect.
                case 1 {
                    seedTracker := trackSeed(seed, 0)
                    break
                }
                default {
                    let collisions := shr(1, outcome)
                    let pbCollisions := shr(1, and(seedTracker, 0xFFFF))
                    if lt(collisions, pbCollisions) { seedTracker := trackSeed(seed, collisions) }
                }
            }
            if iszero(seedTracker) {
                mstore(0, 1)
                revert(0, 0x20)
            }

            meta := buildMetaFromSeedTracker(bitmap0, bitmap1, seedTracker, words)
        }
    }

    function buildMeta1(bytes32[] memory words) internal pure returns (bytes memory meta) {
        assembly ("memory-safe") {
            let brutus := 0
            let wordLength := mload(words)
            let start := add(words, 0x20)
            meta := mload(0x40)
            // 4 bytes per meta. 2 bytes for brutus.
            let metaLength := add(mul(wordLength, 4), 2)
            mstore(meta, metaLength)
            mstore(0x40, add(meta, and(add(add(metaLength, 0x20), 0x1f), not(0x1f))))

            for { let i := 0 } lt(i, wordLength) { i := add(i, 1) } {
                mstore(0, mload(add(start, mul(i, 0x20))))
                mstore8(0x20, brutus)
                let word := keccak256(0, 0x21)

                let index := mod(word, mul(wordLength, shr(8, brutus)))
                let cursor := add(meta, add(mul(add(index, 1), 4), 2))
                // Collision brutally resets everything.
                if and(mload(cursor), 0xFFFFFFFF) {
                    // This is going to inc to 0 before next iteration.
                    i := not(0)
                    brutus := shl(8, add(byte(30, brutus), 1))
                    let end := mload(0x40)
                    for { cursor := add(meta, 0x20) } lt(cursor, end) { cursor := add(cursor, 0x20) } {
                        mstore(cursor, 0)
                    }
                    continue
                }
                mstore(cursor, or(and(mload(cursor), not(0xFFFFFFFF)), and(or(shl(0x10, word), i), 0xFFFFFFFF)))
            }

            if gt(brutus, 0xFFFF) { revert(0, 0) }
            let offset := add(meta, 2)
            mstore(offset, or(and(mload(offset), not(0xFFFF)), brutus))
        }
    }

    function parse(bytes memory data) internal pure returns (bytes[] memory, uint256[] memory) {
        if (data.length > 0) {
            uint256 char;
            uint256 errorCode;
            uint256 state;
            assembly ("memory-safe") {
                function buildErrorCode(data_, cursor_, byteCode_) -> errorCode_ {
                    errorCode_ :=
                        or(shl(16, sub(cursor_, add(data_, 1))), or(shl(8, byteCode_), and(mload(cursor_), 0xFF)))
                }

                // Notable excerpts from ASCII as shifted chars
                // mask for structure , : ;
                // 0x0C00100000000000
                //
                // mask for a-z
                // 0xffffffe000000000000000000000000
                //
                // mask for 0-9
                // 0x3ff000000000000
                //
                // mask for lower alphanumeric kebab case a-z 0-9 -
                // 0xffffffe0000000003ff200000000000
                //
                // mask for lower alpha kebab case a-z -
                // 0xffffffe000000000000200000000000
                //
                // mask for lower alpha and underscore a-z _
                // 0xffffffe800000000000000000000000
                let outputCursor := mload(0x40)

                // Layout of state is
                // EXTREME care must be taken if the layout changes to ensure ALL
                // reads and writes are updated to match.
                // 0 => lhs/rhs and yin/yang flags
                // 0x20 => stackIndex
                // 0x40 => pointer to sources
                // 0x60 => named stack linked list head
                // 0x80 => current source linked list head
                state := outputCursor
                outputCursor := add(outputCursor, 0xA0)

                // start with lhs = 1 and yin/yang = 0
                mstore(state, 1)

                // start with empty stack
                mstore(add(state, 0x20), 0)

                // start with empty sources
                mstore(add(state, 0x40), 0x60)

                // base of stack linked list is 0
                mstore(add(state, 0x60), 0)

                // base of source linked list is 0
                // low 32 bits are the pointer to the next item
                // high bits are bytecode of the source
                mstore(add(state, 0x80), 0)

                // Additionally we are using the scratch space to build source
                // 0x0 => for tracking length of the current source, sources and
                // pointers to all sources (max 14)
                // low 16 bits = length of source (# of ops NOT bytes/bits)
                // high 16 bits = length of sources
                // big endian middle bits = 16 bit pointers to sources
                mstore(0, 0)

                let cursor := add(data, 1)
                let end := add(cursor, mload(data))
                for {} lt(cursor, end) { cursor := add(cursor, 1) } {
                    // Cursor must be incremented by the inner logic.
                    char := shl(and(mload(cursor), 0xFF), 1)

                    switch and(mload(state), 1)
                    // Process LHS (stack items).
                    case 1 {
                        // stack items
                        // first char is lower alpha a-z _
                        // tail chars will be lower alphanumeric kebab a-z 0-9 -
                        if and(char, 0xffffffe800000000000000000000000) {
                            // if yang we can't start a new stack item
                            if and(mload(state), 2) {
                                errorCode := buildErrorCode(data, cursor, 2)
                                break
                            }

                            let word := mload(add(cursor, 0x20))

                            // loop over the word
                            let i := 0
                            for {} and(
                                lt(i, 0x20),
                                // not not a tail char
                                iszero(and(shl(byte(i, word), 1), 0xf0000001fffffffffc00dfffffffffff))
                            ) { i := add(i, 1) } {}
                            if lt(i, 0x20) {
                                // If the stack item is named, save its stack
                                // position in a FILO linked list structure.
                                if and(char, 0xffffffe000000000000000000000000) {
                                    let name := shr(sub(256, mul(add(i, 1), 8)), mload(add(cursor, 0x1F)))
                                    mstore(outputCursor, name)
                                    name := keccak256(outputCursor, 0x20)

                                    // Prepend name to linked list.
                                    mstore(outputCursor, mload(add(state, 0x60)))
                                    mstore(
                                        add(state, 0x60),
                                        or(
                                            // make room in the name for pointers
                                            shl(0x20, name),
                                            // pointers
                                            or(
                                                // current stack height, assume
                                                // it can't exceed 16 bits.
                                                shl(0x10, mload(add(state, 0x20))),
                                                // pointer to old head, assume
                                                // it can't exceed 16 bits of
                                                // memory (64Kb)
                                                outputCursor
                                            )
                                        )
                                    )
                                    outputCursor := add(outputCursor, 0x20)
                                }

                                // Update state ready for next char.
                                {
                                    // increment stack height
                                    let stateStackOffset := add(state, 0x20)
                                    mstore(stateStackOffset, add(mload(stateStackOffset), 1))

                                    // lhs/rhs = 1, yin/yang = 1
                                    mstore(state, 3)
                                }

                                cursor := add(cursor, i)
                                continue
                            }
                            errorCode := buildErrorCode(data, cursor, 4)
                            break
                        }

                        // whitespace
                        if and(char, 0x100002600) {
                            // lhs/rhs = 1, yin/yang = 0
                            mstore(state, 1)
                            continue
                        }

                        // end of lhs
                        // char equals :
                        if eq(char, 0x0400000000000000) {
                            // lhs/rhs = 0, yin/yang = 0
                            mstore(state, 0)
                            continue
                        }
                        errorCode := buildErrorCode(data, cursor, 2)
                        break
                    }
                    // Process RHS (opcodes).
                    case 0 {
                        // words
                        // first char is lower a-z
                        if and(char, 0xffffffe000000000000000000000000) {
                            // if yang we can't start a new word
                            if and(mload(state), 2) {
                                errorCode := buildErrorCode(data, cursor, 2)
                                break
                            }

                            let word := mload(add(cursor, 0x20))

                            // loop over the word
                            let i := 0
                            for {} and(
                                lt(i, 0x20),
                                // not not a tail char
                                iszero(and(shl(byte(i, word), 1), 0xf0000001fffffffffc00dfffffffffff))
                            ) { i := add(i, 1) } {}

                            // RHS words MUST be appended by a left paren (
                            // literal byte check here, NOT a char shifted mask
                            // for efficiency
                            if eq(byte(i, word), 0x28) {
                                let op := shr(sub(256, mul(add(i, 1), 8)), mload(add(cursor, 0x1F)))
                                mstore(outputCursor, op)
                                // @todo this is fake, the hash bytes are mimic
                                // for the opcode and the operand is left as 0
                                op := shl(0x10, and(keccak256(outputCursor, 0x20), 0xFFFF))

                                // Prepend op to source linked list
                                let sourceLength := and(mload(0), 0xFFFF)
                                let offset := mul(add(mod(sourceLength, 0x07), 1), 0x20)

                                mstore(add(state, 0x80), or(mload(add(state, 0x80)), shl(offset, op)))
                                // inc source length
                                mstore(
                                    0,
                                    or(
                                        add(sourceLength, 1),
                                        and(
                                            mload(0), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
                                        )
                                    )
                                )

                                if eq(offset, 0xe0) {
                                    mstore(outputCursor, mload(add(state, 0x80)))
                                    mstore(
                                        add(state, 0x80),
                                        // assume output cursor can't exceed 16
                                        // bits.
                                        outputCursor
                                    )
                                    outputCursor := add(outputCursor, 0x20)
                                }

                                cursor := add(cursor, add(i, 1))
                                continue
                            }

                            if eq(i, 0x20) {
                                errorCode := buildErrorCode(data, cursor, 4)
                                break
                            }

                            errorCode := buildErrorCode(data, add(cursor, i), 3)
                            break
                        }

                        // closing paren
                        // char equals )
                        if eq(char, 0x20000000000) {
                            // rhs = 0, yin = 0
                            mstore(state, 0)

                            // @todo track nested inputs
                            continue
                        }

                        // whitespace
                        if and(char, 0x100002600) {
                            // rhs = 0, yin = 0
                            mstore(state, 0)
                            continue
                        }

                        // end of rhs
                        // char equals ,
                        if eq(char, 0x100000000000) {
                            // lhs/rhs = 1, yin/yang = 0
                            mstore(state, 1)
                            continue
                        }

                        // end of source
                        // implies end of rhs
                        // char equals ;
                        if eq(char, 0x0800000000000000) {
                            // lhs/rhs = 1, yin/yang = 0
                            mstore(state, 1)

                            // Update sources
                            {
                                let sourcesLength := byte(1, mload(0))
                                mstore8(1, add(sourcesLength, 1))
                                mstore(0, or(mload(0), shl(sub(0xe0, mul(sourcesLength, 0x10)), outputCursor)))
                            }

                            // Build solidity compatible `bytes` out of source
                            // linked list
                            let sourceLength := and(mload(0), 0xFFFF)
                            // Reset source length in memory.
                            mstore(0, and(mload(0), not(0xFFFF)))

                            mstore(outputCursor, mul(sourceLength, 0x04))
                            outputCursor := add(outputCursor, 0x20)

                            let sourceHead := mload(add(state, 0x80))
                            // Write the head opcodes into the bytes
                            mstore(
                                outputCursor,
                                // shift the ops up to start at the outputCursor
                                shl(
                                    // it's not possible to have a full item in
                                    // the head position, as full items are
                                    // always bumped to the tail, so we always
                                    // shift at least one slot to the left
                                    mul(sub(0x07, mod(sourceLength, 0x07)), 0x20),
                                    // mask out the pointer to the next list item
                                    and(sourceHead, not(0xFFFF))
                                )
                            )
                            outputCursor := add(outputCursor, mul(mod(sourceLength, 0x07), 0x04))

                            // Loop over the tail
                            for { let tailPointer := and(sourceHead, 0xFFFF) } iszero(iszero(tailPointer)) {} {
                                tailPointer := and(mload(tailPointer), 0xFFFF)
                                mstore(outputCursor, and(mload(tailPointer), not(0xFFFF)))
                                outputCursor := add(outputCursor, 0x1c)
                            }

                            // Reset the linked list
                            mstore(add(state, 0x80), 0)
                            // Realign outputCursor with 32 byte memory
                            {
                                let unaligned := mod(outputCursor, 0x20)
                                outputCursor := add(sub(outputCursor, unaligned), and(add(unaligned, 0x1F), not(0x1F)))
                            }

                            continue
                        }

                        errorCode := buildErrorCode(data, cursor, 3)
                        break
                    }
                    // unreachable, implies broken lhs flag.
                    default { revert(0, 0) }
                }

                // Build real sources
                {
                    let sourcesScratch := mload(0)
                    let sourcesLength := byte(1, sourcesScratch)
                    mstore(add(state, 0x40), outputCursor)
                    mstore(outputCursor, sourcesLength)
                    outputCursor := add(outputCursor, 0x20)
                    for {
                        let offset := 0xe0
                        let sourcesEnd := sub(offset, mul(sourcesLength, 0x10))
                    } gt(offset, sourcesEnd) {
                        offset := sub(offset, 0x10)
                        outputCursor := add(outputCursor, 0x20)
                    } { mstore(outputCursor, and(shr(offset, sourcesScratch), 0xFFFF)) }
                }

                // Sync free memory pointer with final output cursor
                mstore(0x40, outputCursor)

                // missing final semi
                if and(iszero(errorCode), iszero(eq(char, 0x0800000000000000))) {
                    errorCode := buildErrorCode(data, cursor, 1)
                }
            }

            bytes[] memory sources;
            uint256[] memory constants;
            assembly ("memory-safe") {
                sources := mload(add(state, 0x40))
            }

            if (errorCode > 0) {
                string memory s = string(abi.encodePacked(uint8(errorCode)));
                uint256 code = errorCode >> 8 & 0xFF;
                uint256 offset = errorCode >> 16;
                if (code == 1) {
                    revert MissingFinalSemi(offset);
                } else if (code == 2) {
                    revert UnexpectedLHSChar(offset, s);
                } else if (code == 3) {
                    revert UnexpectedRHSChar(offset, s);
                } else if (code == 4) {
                    revert WordTooLong(offset);
                }
            }

            return (sources, constants);
        } else {
            return (new bytes[](0), new uint256[](0));
        }
    }
}

// // The second char is not a word char so do nothing.
// if iszero(and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000)) { continue }

// // inline the first 16 word chars for gas efficiency.
// // It is usual for named stack items to be more than
// // one char long, so we can do better than looping in
// // terms of gas.
// if and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000) {
//     if and(shl(byte(0x01, word), 1), 0xffffffe0000000003ff200000000000) {
//         if and(shl(byte(0x02, word), 1), 0xffffffe0000000003ff200000000000) {
//             if and(shl(byte(0x03, word), 1), 0xffffffe0000000003ff200000000000) {
//                 if and(shl(byte(0x04, word), 1), 0xffffffe0000000003ff200000000000) {
//                     if and(shl(byte(0x05, word), 1), 0xffffffe0000000003ff200000000000) {
//                         if and(shl(byte(0x06, word), 1), 0xffffffe0000000003ff200000000000)
//                         {
//                             if and(
//                                 shl(byte(0x07, word), 1), 0xffffffe0000000003ff200000000000
//                             ) {
//                                 if and(
//                                     shl(byte(0x08, word), 1),
//                                     0xffffffe0000000003ff200000000000
//                                 ) {
//                                     if and(
//                                         shl(byte(0x09, word), 1),
//                                         0xffffffe0000000003ff200000000000
//                                     ) {
//                                         if and(
//                                             shl(byte(0x0A, word), 1),
//                                             0xffffffe0000000003ff200000000000
//                                         ) {
//                                             if and(
//                                                 shl(byte(0x0B, word), 1),
//                                                 0xffffffe0000000003ff200000000000
//                                             ) {
//                                                 if and(
//                                                     shl(byte(0x0C, word), 1),
//                                                     0xffffffe0000000003ff200000000000
//                                                 ) {
//                                                     if and(
//                                                         shl(byte(0x0D, word), 1),
//                                                         0xffffffe0000000003ff200000000000
//                                                     ) {
//                                                         if and(
//                                                             shl(byte(0x0E, word), 1),
//                                                             0xffffffe0000000003ff200000000000
//                                                         ) {
//                                                             if and(
//                                                                 shl(byte(0x0F, word), 1),
//                                                                 0xffffffe0000000003ff200000000000
//                                                             ) {
//                                                                 // loop for the remainder for 16+ char words.
//                                                                 let i := 0x10
//                                                                 for {} and(
//                                                                     lt(i, 0x20),
//                                                                     iszero(
//                                                                         iszero(
//                                                                             and(
//                                                                                 shl(
//                                                                                     byte(
//                                                                                         i,
//                                                                                         word
//                                                                                     ),
//                                                                                     1
//                                                                                 ),
//                                                                                 0xffffffe0000000003ff200000000000
//                                                                             )
//                                                                         )
//                                                                     )
//                                                                 ) { i := add(i, 1) } {}
//                                                                 if lt(i, 0x20) {
//                                                                     cursor := add(cursor, i)
//                                                                     continue
//                                                                 }
//                                                                 errorCode :=
//                                                                     buildErrorCode(
//                                                                         data, cursor, 4
//                                                                     )
//                                                                 break
//                                                             }
//                                                             cursor := add(cursor, 0x0F)
//                                                             continue
//                                                         }
//                                                         cursor := add(cursor, 0x0E)
//                                                         continue
//                                                     }
//                                                     cursor := add(cursor, 0x0D)
//                                                     continue
//                                                 }
//                                                 cursor := add(cursor, 0x0C)
//                                                 continue
//                                             }
//                                             cursor := add(cursor, 0x0B)
//                                             continue
//                                         }
//                                         cursor := add(cursor, 0x0A)
//                                         continue
//                                     }
//                                     cursor := add(cursor, 0x09)
//                                     continue
//                                 }
//                                 cursor := add(cursor, 0x08)
//                                 continue
//                             }
//                             cursor := add(cursor, 0x07)
//                             continue
//                         }
//                         cursor := add(cursor, 0x06)
//                         continue
//                     }
//                     cursor := add(cursor, 0x05)
//                     continue
//                 }
//                 cursor := add(cursor, 0x04)
//                 continue
//             }
//             cursor := add(cursor, 0x03)
//             continue
//         }
//         cursor := add(cursor, 0x02)
//         continue
//     }
//     cursor := add(cursor, 0x01)
//     continue
// }
