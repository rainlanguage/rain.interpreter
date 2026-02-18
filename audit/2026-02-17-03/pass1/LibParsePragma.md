# Pass 1 (Security) -- LibParsePragma.sol

**File:** `src/lib/parse/LibParsePragma.sol`

## Evidence of Thorough Reading

### Contract/Library Name
- `LibParsePragma` (library, line 20)

### Functions
| Function | Line |
|---|---|
| `parsePragma(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256)` | 33 |

### Errors/Events/Structs Defined in This File
None defined directly in this file. The file imports:
- `NoWhitespaceAfterUsingWordsFrom` from `../../error/ErrParse.sol` (used at lines 56, 66)

### Constants Defined
| Constant | Line |
|---|---|
| `PRAGMA_KEYWORD_BYTES` (`bytes("using-words-from")`) | 12 |
| `PRAGMA_KEYWORD_BYTES32` (`bytes32(PRAGMA_KEYWORD_BYTES)`) | 15 |
| `PRAGMA_KEYWORD_BYTES_LENGTH` (16) | 16 |
| `PRAGMA_KEYWORD_MASK` (upper 16 bytes set, lower 16 bytes zero) | 18 |

### Using Declarations (line 21-24)
- `LibParseError for ParseState`
- `LibParseInterstitial for ParseState`
- `LibParseLiteral for ParseState`
- `LibParseState for ParseState`

## Security Findings

### 1. INFO -- `mload` reads beyond data boundary during pragma keyword check

**Location:** Line 40-42

```solidity
assembly ("memory-safe") {
    maybePragma := mload(cursor)
}
```

When `cursor` is within 32 bytes of the end of the `bytes memory data` buffer, `mload(cursor)` reads 32 bytes starting at `cursor`, which extends beyond the logical end of the data. The `PRAGMA_KEYWORD_MASK` (which zeroes the lower 16 bytes) mitigates this for the comparison, but the read still touches bytes beyond the data boundary.

**Assessment:** This is a standard Solidity assembly pattern. The `mload` reads from allocated heap memory (the `bytes memory` buffer has already been allocated), so no out-of-bounds memory access occurs. The mask correctly isolates only the relevant 16 bytes. Additionally, if the remaining data is less than 16 bytes, the comparison against `PRAGMA_KEYWORD_BYTES32` will fail because the trailing bytes within the mask range will not match the keyword, causing the function to return `cursor` unchanged. No risk.

### 2. INFO -- Entire function body is in an `unchecked` block

**Location:** Line 34-90

The entire function body is wrapped in `unchecked { ... }`. The arithmetic operations within are:

- `cursor += PRAGMA_KEYWORD_BYTES_LENGTH` (line 51): `PRAGMA_KEYWORD_BYTES_LENGTH` is 16. Since `cursor` is a memory pointer (well within `uint256` range), overflow is impossible.
- `++cursor` (line 68): Same reasoning as above.

**Assessment:** Safe. All arithmetic is on memory pointers that cannot realistically overflow a `uint256`. The cursor is also bounds-checked against `end` at lines 55 and 71 before being used for reads.

### 3. INFO -- Assembly block marked `memory-safe` at line 40-42

```solidity
assembly ("memory-safe") {
    maybePragma := mload(cursor)
}
```

This block only reads from memory (no writes) and stores the result into a local variable. The `memory-safe` annotation is correct.

### 4. INFO -- Assembly block marked `memory-safe` at line 61-63

```solidity
assembly ("memory-safe") {
    //slither-disable-next-line incorrect-shift
    char := shl(byte(0, mload(cursor)), 1)
}
```

This block reads one byte from cursor position and shifts it to create a bitmask for the character-class lookup. It only reads memory and writes to a local variable. The `memory-safe` annotation is correct.

The `byte(0, mload(cursor))` reads at cursor position, which at this point has already been validated to be `< end` (checked at line 55). This is safe.

### 5. INFO -- No validation that pragma provides at least one address

**Location:** Lines 71-87

After parsing the `using-words-from` keyword and whitespace, the function enters a while loop to parse literal addresses. If no literals are found (e.g., `using-words-from ` followed by non-literal content), the loop body's `tryParseLiteral` returns `success = false` immediately, and the function returns without having pushed any sub-parsers.

**Assessment:** This means `using-words-from` with zero addresses is silently accepted. Whether this is a security concern depends on context -- it results in an empty sub-parser list, which is functionally equivalent to no pragma at all. The caller (parser) would simply proceed without external words. This is likely an intentional design choice to keep parsing lenient, but could mask user errors where they intended to provide an address but made a typo.

### 6. INFO -- All reverts use custom errors

The function uses `NoWhitespaceAfterUsingWordsFrom(uint256 offset)` from `src/error/ErrParse.sol` at lines 56 and 66. No string-based reverts are used. Compliant with project conventions.

The `pushSubParser` function (called at line 85, defined in `LibParseState.sol:265`) uses `InvalidSubParser(uint256 offset)` for non-address-sized values. Also compliant.

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings. The code is compact, well-structured, and follows safe patterns. The `unchecked` block contains only memory-pointer arithmetic that cannot overflow. Assembly blocks are correctly annotated as `memory-safe`. All reverts use custom errors. Input validation is delegated appropriately to downstream functions (`tryParseLiteral` for literal parsing, `pushSubParser` for address-range validation).
