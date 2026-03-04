# A111 -- Pass 1 (Security) -- LibParseLiteral.sol

## Evidence of Thorough Reading

**Library name:** `LibParseLiteral`

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 43 | `selectLiteralParserByIndex(ParseState memory, uint256)` | function | internal | pure |
| 65 | `parseLiteral(ParseState memory, uint256, uint256)` | function | internal | view |
| 87 | `tryParseLiteral(ParseState memory, uint256, uint256)` | function | internal | view |

**Constants (file-level):**
- `LITERAL_PARSERS_LENGTH = 4` (line 19)
- `LITERAL_PARSER_INDEX_HEX = 0` (line 22)
- `LITERAL_PARSER_INDEX_DECIMAL = 1` (line 24)
- `LITERAL_PARSER_INDEX_STRING = 2` (line 26)
- `LITERAL_PARSER_INDEX_SUB_PARSE = 3` (line 28)

**Errors used (imported):**
- `UnsupportedLiteralType(uint256)` from `ErrParse.sol`
- `UppercaseHexPrefix(uint256)` from `ErrParse.sol`

**Using-for declarations:**
- `LibParseLiteral for ParseState`
- `LibParseError for ParseState`

---

## Security Review

### EXT-M01 verification (OOB second-byte read)

The prior finding EXT-M01 concerned an out-of-bounds read of the second byte when disambiguating `0x` vs decimal at the end of the source. The fix is at line 110: `if (cursor + 1 < end)` guards the second-byte read. If the numeric literal is the last byte of the source, the code defaults to decimal (line 129) without reading byte 1. Fix is in place.

### EXT-L01 verification (uppercase hex prefix bypass)

The prior finding EXT-L01 concerned `0X` (uppercase) silently parsing as decimal zero. The fix is at lines 123-124: after checking for lowercase `0x`, the code explicitly checks for `(head | disambiguate) == (CMASK_ZERO | CMASK_UPPER_X)` and reverts with `UppercaseHexPrefix`. Fix is in place.

### Assembly memory safety

**`selectLiteralParserByIndex` (lines 52-54):**
- `mload(add(literalParsers, add(2, mul(index, 2))))` reads a 2-byte function pointer from the packed `literalParsers` bytes array. The mask `0xFFFF` extracts only the lower 16 bits. Tagged `memory-safe`. Correct.
- NatSpec (lines 38-39, 51) explicitly documents that bounds checking is NOT performed because indexes are parser-internal. The indexes used are the four `LITERAL_PARSER_INDEX_*` constants (0-3), all hardcoded in `tryParseLiteral`. This is safe.

**`tryParseLiteral` (lines 96-100, 112-114):**
- Line 97: `mload(cursor)` reads 32 bytes at cursor. Safe within the source data allocation.
- Line 99: `head := shl(byte(0, word), 1)` converts byte 0 to a character mask bit.
- Line 114: `disambiguate := shl(byte(1, word), 1)` reads byte 1 of the same word. This is safe because `cursor + 1 < end` is checked at line 110, and the `mload(cursor)` already loaded 32 bytes so byte(1, word) is within the loaded word. Note: the `end` check ensures the byte is within the source data, preventing stale/adjacent memory from being treated as source.

### Bounds checks and dispatch logic

The dispatch logic in `tryParseLiteral` covers all four literal types:
1. Numeric head (0-9) -> further disambiguate hex vs decimal
2. String literal head (") -> string parser
3. Sub-parseable head ([) -> sub-parse parser
4. Default -> return false (not a literal)

The index values (0-3) are all within the `LITERAL_PARSERS_LENGTH = 4` bounds. No user input can influence the index value -- it is entirely determined by the character class matching.

### Function pointer dispatch

Line 146: `state.selectLiteralParserByIndex(index)(state, cursor, end)` calls the selected parser function pointer. The index is guaranteed to be 0-3 from the dispatch logic. If `literalParsers` has fewer than 4 entries, this would be an OOB read, but the array is populated by `literalParserFunctionPointers()` which is generated at build time from `LITERAL_PARSERS_LENGTH`. No risk.

### Custom errors

No string reverts. `UnsupportedLiteralType` and `UppercaseHexPrefix` are custom errors.

---

## Findings

No LOW+ findings.

Both prior findings (EXT-M01, EXT-L01) have been verified as fixed. The dispatch logic is clean and the function pointer indexing is safe with hardcoded indexes.
