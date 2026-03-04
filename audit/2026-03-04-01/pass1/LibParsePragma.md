# Pass 1 — Security: LibParsePragma (A106)

**File:** `src/lib/parse/LibParsePragma.sol`

## Evidence

### Library
- `LibParsePragma` (line 28)

### Functions
| Function | Line | Visibility |
|---|---|---|
| `parsePragma(ParseState memory, uint256, uint256)` | 41 | internal view |

### Types / Errors / Constants
| Name | Kind | Line |
|---|---|---|
| `PRAGMA_KEYWORD_BYTES` | constant bytes | 13 |
| `PRAGMA_KEYWORD_BYTES32` | constant bytes32 | 17 |
| `PRAGMA_KEYWORD_BYTES_LENGTH` | constant uint256 | 19 |
| `PRAGMA_KEYWORD_MASK` | constant bytes32 | 23 |

### Imports
- `NoWhitespaceAfterUsingWordsFrom` error
- `LibParseState`, `LibParseError`, `LibParseInterstitial`, `LibParseLiteral`

## Assembly Review

### `parsePragma` — keyword detection (line 48-49)
```solidity
assembly ("memory-safe") {
    maybePragma := mload(cursor)
}
```
- Reads 32 bytes at cursor. This is within memory (the parse data buffer). Only the first `PRAGMA_KEYWORD_BYTES_LENGTH` (16) bytes are compared via the mask. No writes. Correct.

### `parsePragma` — whitespace character read (lines 69-71)
```solidity
assembly ("memory-safe") {
    char := shl(byte(0, mload(cursor)), 1)
}
```
- Reads single byte at cursor. Guarded by `cursor >= end` check at line 63, which reverts if cursor is at or past end. So this read is in bounds. Correct.

## Security Assessment

### EXT-M02 fix verification (OOB memory read in pragma)

The prior finding (EXT-M02) reported an out-of-bounds memory read when `parseInterstitial` consumed trailing whitespace up to `end`, and then `tryParseLiteral` was called with `cursor >= end`, causing an `mload(cursor)` past the data bounds.

**Fix is in place at lines 86-90:**
```solidity
// parseInterstitial may have consumed trailing whitespace
// up to end. Must re-check before tryParseLiteral, which
// does mload(cursor) and would read past bounds.
if (cursor >= end) {
    break;
}
```

This bounds check between `parseInterstitial` and `tryParseLiteral` correctly prevents the OOB read. The fix is complete and correct.

### Pragma keyword comparison
- `PRAGMA_KEYWORD_MASK` is computed as `~((1 << (32 - 16) * 8) - 1)` = `~((1 << 128) - 1)` which zeroes out the lower 128 bits (16 bytes) and keeps the upper 128 bits (16 bytes). This correctly isolates the first 16 bytes for comparison.
- The `mload(cursor)` at the start may read up to 32 bytes, extending past `end` if fewer than 32 bytes remain. However, only the masked portion is compared, and the read is from valid EVM memory (just beyond the parse data, which is still within Solidity's allocated memory region). This is harmless.

### Whitespace validation
- After advancing past the keyword (`cursor += PRAGMA_KEYWORD_BYTES_LENGTH`), the code checks `cursor >= end` (line 63) before reading the next character. If at `end`, it reverts with `NoWhitespaceAfterUsingWordsFrom`. Correct.
- If the character is not whitespace, it also reverts. Correct.

### Sub parser address validation
- `pushSubParser` validates `uint256(subParser) > uint256(type(uint160).max)` and reverts with `InvalidSubParser` if the literal exceeds an address size. Correct.

No findings.
