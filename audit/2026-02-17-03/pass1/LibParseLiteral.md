# Pass 1 (Security) -- LibParseLiteral.sol

**File:** `src/lib/parse/literal/LibParseLiteral.sol`

## Evidence of Thorough Reading

### Contract/Library Name

`LibParseLiteral` (library, line 25)

### Functions

| Function | Line | Visibility |
|---|---|---|
| `selectLiteralParserByIndex` | 34 | internal pure |
| `parseLiteral` | 51 | internal pure |
| `tryParseLiteral` | 67 | internal pure |

### Errors/Events/Structs Defined

None defined directly in this file. The file imports `UnsupportedLiteralType` from `src/error/ErrParse.sol`.

### Constants Defined

| Constant | Line | Value |
|---|---|---|
| `LITERAL_PARSERS_LENGTH` | 18 | 4 |
| `LITERAL_PARSER_INDEX_HEX` | 20 | 0 |
| `LITERAL_PARSER_INDEX_DECIMAL` | 21 | 1 |
| `LITERAL_PARSER_INDEX_STRING` | 22 | 2 |
| `LITERAL_PARSER_INDEX_SUB_PARSE` | 23 | 3 |

---

## Security Findings

### Finding 1: No bounds check in `selectLiteralParserByIndex`

**Severity:** LOW

**Location:** Lines 34-47

**Description:**
`selectLiteralParserByIndex` loads a 2-byte function pointer from the `literalParsers` bytes array at a position determined by `index`, without any bounds check. The assembly reads from `literalParsers + 2 + index * 2`, extracting the lowest 16 bits via `and(..., 0xFFFF)`.

The comment on lines 41-42 explicitly acknowledges this: "This is NOT bounds checked because the indexes are all expected to be provided by the parser itself and not user input."

**Analysis:**
Within this file, `selectLiteralParserByIndex` is only called from `tryParseLiteral` (line 112) with `index` set to one of the four hardcoded constants (0, 1, 2, or 3). The `tryParseLiteral` dispatch logic at lines 84-109 guarantees `index` is always one of these four values -- there is no code path that leaves `index` at a different value while also reaching line 112 (the `else` branch at line 107 returns early).

As long as the `literalParsers` bytes array has at least `LITERAL_PARSERS_LENGTH * 2 = 8` bytes of data (which is the caller's responsibility during construction in `newState`), no out-of-bounds read occurs. The maximum access for index 3 is at offset `literalParsers + 8`, which reads bytes at positions 8..39 from the array start. The data portion starts at offset 32 (after the length word), so the lowest 16 bits of the `mload` capture `data[6..7]`, which is within bounds for an 8-byte data section.

**Risk:** Theoretical only. The function is `internal` and only called with compile-time constants from `tryParseLiteral`. A future caller passing an arbitrary index could cause an out-of-bounds read from memory, but this would not be exploitable in practice (it would just read adjacent memory and treat it as a function pointer, which would revert if invalid). The `internal` visibility and the documented invariant make this acceptable as-is.

---

### Finding 2: `mload(cursor)` at end-of-data boundary reads beyond allocation

**Severity:** INFO

**Location:** Line 77

**Description:**
In `tryParseLiteral`, line 77 performs `word := mload(cursor)` which always reads 32 bytes from cursor. If `cursor` is near the end of the source data, this may read past the data boundary into adjacent memory.

**Analysis:**
This is safe for two reasons:
1. Memory reads in the EVM never fault -- they simply return whatever is at that address (zero if never written).
2. The caller in `LibParse.sol` (line 374-375) already checks that the character at `cursor` matches `CMASK_LITERAL_HEAD` before calling `pushLiteral`, which in turn calls `tryParseLiteral`. The character mask check implicitly guarantees `cursor < end` and that the first byte is a valid literal head character.
3. Even if `cursor == end` and memory beyond is zeroed, `head = shl(0, 1) = 1` (bit 0), which does not match any of the literal head masks (`CMASK_NUMERIC_LITERAL_HEAD`, `CMASK_STRING_LITERAL_HEAD`, `CMASK_SUB_PARSEABLE_LITERAL_HEAD`), so the function returns `(false, cursor, 0)` safely.

The read of `byte(1, word)` at line 88 (for hex dispatch disambiguation) similarly reads from the same 32-byte `mload` result, so no additional memory access occurs.

**Risk:** None. This is a standard pattern in the codebase.

---

### Finding 3: Hex dispatch logic correctness

**Severity:** INFO

**Location:** Lines 84-96

**Description:**
The hex literal detection uses `(head | disambiguate) == CMASK_LITERAL_HEX_DISPATCH` where `CMASK_LITERAL_HEX_DISPATCH = CMASK_ZERO | CMASK_LOWER_X = (1 << 0x30) | (1 << 0x78)`.

**Analysis:**
Verified that this logic is correct:
- `head = shl(byte(0, word), 1)` produces a single-bit value `1 << char_value`.
- Since the code only reaches line 92 when `head & CMASK_NUMERIC_LITERAL_HEAD != 0`, `head` must correspond to a digit 0-9 or `-` character.
- For `head | disambiguate` to equal `CMASK_LITERAL_HEX_DISPATCH`, `head` must be `1 << 0x30` (the '0' bit) and `disambiguate` must be `1 << 0x78` (the 'x' bit). No other numeric character can produce the 0x30 bit position, and only 'x' produces 0x78.
- The comment on line 91 correctly notes that "x0" cannot accidentally match because the head is already filtered to be 0-9 or `-`.

**Risk:** None. The logic is sound.

---

### Finding 4: All reverts use custom errors

**Severity:** INFO

**Location:** Line 60

**Description:**
The only revert in this file is at line 60: `revert UnsupportedLiteralType(state.parseErrorOffset(cursor))`. This correctly uses a custom error type defined in `src/error/ErrParse.sol` (line 30). No string-based `revert("...")` is used anywhere in this file.

**Risk:** None. Compliant with codebase conventions.

---

### Finding 5: No unchecked arithmetic

**Severity:** INFO

**Location:** Entire file

**Description:**
There is no `unchecked` block in this file. The only arithmetic occurs inside assembly blocks (lines 44, 79, 88), which inherently do not have Solidity overflow checks but operate on values that cannot overflow:
- Line 44: `add(2, mul(index, 2))` where index is 0-3, producing values 2-8. No overflow.
- Line 79: `shl(byte(0, word), 1)` where `byte(0, word)` is 0-255. The shift is well-defined for all values.
- Line 88: `shl(byte(1, word), 1)` -- same as above.

**Risk:** None.

---

## Summary

This is a small, focused dispatch library with minimal attack surface. All indexes passed to `selectLiteralParserByIndex` are compile-time constants derived from deterministic character mask matching. The single revert uses a proper custom error. No unchecked arithmetic or memory safety issues were found. The only notable design decision is the lack of bounds checking in `selectLiteralParserByIndex`, which is documented and justified by the internal-only usage with hardcoded indices.
