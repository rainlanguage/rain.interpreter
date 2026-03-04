# Pass 1 (Security) -- Literal Parsing Libraries

**Audit date:** 2026-03-01
**Files:**
- `src/lib/parse/literal/LibParseLiteral.sol` (A33)
- `src/lib/parse/literal/LibParseLiteralDecimal.sol` (A34)
- `src/lib/parse/literal/LibParseLiteralHex.sol` (A35)
- `src/lib/parse/literal/LibParseLiteralString.sol` (A37)
- `src/lib/parse/literal/LibParseLiteralSubParseable.sol` (A38)

---

## Evidence of Thorough Reading

### LibParseLiteral.sol (A33)

**Library:** `LibParseLiteral` (line 23)

**Constants:**

| Constant | Line | Value |
|---|---|---|
| `LITERAL_PARSERS_LENGTH` | 16 | 4 |
| `LITERAL_PARSER_INDEX_HEX` | 18 | 0 |
| `LITERAL_PARSER_INDEX_DECIMAL` | 19 | 1 |
| `LITERAL_PARSER_INDEX_STRING` | 20 | 2 |
| `LITERAL_PARSER_INDEX_SUB_PARSE` | 21 | 3 |

**Functions:**

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `selectLiteralParserByIndex` | 33 | internal | pure |
| `parseLiteral` | 55 | internal | view |
| `tryParseLiteral` | 77 | internal | view |

**Imports:** `CMASK_STRING_LITERAL_HEAD`, `CMASK_LITERAL_HEX_DISPATCH`, `CMASK_NUMERIC_LITERAL_HEAD`, `CMASK_SUB_PARSEABLE_LITERAL_HEAD` from `rain.string`; `UnsupportedLiteralType` from `ErrParse.sol`; `ParseState`; `LibParseError`.

**Assembly blocks:** Lines 42-44 (selectLiteralParserByIndex, reads function pointer from packed bytes), lines 86-89 (tryParseLiteral, reads head byte), lines 96-98 (tryParseLiteral, reads disambiguate byte). All marked `memory-safe`, all read-only.

**Dispatch logic verified:** Head character mask check determines literal type. Hex dispatch requires `(head | disambiguate) == CMASK_LITERAL_HEX_DISPATCH` which is `CMASK_ZERO | CMASK_LOWER_X`, meaning only `0x` (lowercase) routes to hex. Other numeric heads route to decimal. `"` routes to string. `[` routes to sub-parseable. All other characters return `(false, cursor, 0)`.

---

### LibParseLiteralDecimal.sol (A34)

**Library:** `LibParseLiteralDecimal` (line 10)

**Functions:**

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `parseDecimalFloatPacked` | 20 | internal | pure |

**Imports:** `ParseState`, `LibParseError`, `LibParseDecimalFloat`, `Float`, `LibDecimalFloat`.

**Using-for:** `LibParseError for ParseState` (line 11).

**No assembly blocks.** No `unchecked` blocks. Single function that delegates to `LibParseDecimalFloat.parseDecimalFloatInline` and `LibDecimalFloat.packLossless`. Error propagation via `handleErrorSelector`.

**Delegation chain verified:** `parseDecimalFloatInline` returns `(errorSelector, cursor, signedCoefficient, exponent)`. If `errorSelector != 0`, `handleErrorSelector` reverts with the selector and offset. Otherwise `packLossless` packs the value, reverting with `CoefficientOverflow` if lossy.

---

### LibParseLiteralHex.sol (A35)

**Library:** `LibParseLiteralHex` (line 20)

**Functions:**

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `boundHex` | 31 | internal | pure |
| `parseHex` | 63 | internal | pure |

**Imports:** `ParseState`; errors `MalformedHexLiteral`, `OddLengthHexLiteral`, `ZeroLengthHexLiteral`, `HexLiteralOverflow` from `ErrParse.sol`; masks `CMASK_UPPER_ALPHA_A_F`, `CMASK_LOWER_ALPHA_A_F`, `CMASK_NUMERIC_0_9`, `CMASK_HEX` from `rain.string`; `LibParseError`.

**Assembly blocks:** Lines 40-45 (boundHex, forward scan with hex mask, read-only), lines 84-86 (parseHex, reads hex char byte, read-only). Both marked `memory-safe`.

**Unchecked block:** Lines 64-121, entire `parseHex` body. Verified arithmetic safety:
- `hexEnd - hexStart`: safe because `hexEnd >= hexStart` (boundHex only increments).
- `hexEnd - 1`: safe because `hexLength >= 2` at this point.
- `cursor--` at line 115: when `cursor == hexStart`, decrements to `hexStart - 1`. Since `hexStart` is a memory pointer (always >> 0), `hexStart - 1 < hexStart`, so loop condition `cursor >= hexStart` becomes false. No underflow to `type(uint256).max`.
- `valueOffset += 4`: max 64 iterations * 4 = 256, but shift at line 113 uses `valueOffset` before increment, so max shift is 252. Correct.

**Overflow check verified:** `hexLength > 0x40` (line 71) correctly limits to 64 hex digits = 32 bytes = `uint256` max.

**Backward loop verified:** Iterates from `hexEnd - 1` down to `hexStart` inclusive, processing `hexLength` nybbles. Each nybble is shifted into `value` at the correct bit offset. Produces right-aligned value in `bytes32`, consistent with `uint256` encoding.

---

### LibParseLiteralString.sol (A37)

**Library:** `LibParseLiteralString` (line 13)

**Functions:**

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `boundString` | 26 | internal | pure |
| `parseString` | 88 | internal | pure |

**Imports:** `ParseState`; `IntOrAString`, `LibIntOrAString` from `rain.intorastring`; `UnclosedStringLiteral`, `StringTooLong` from `ErrParse.sol`; `CMASK_STRING_LITERAL_END`, `CMASK_STRING_LITERAL_TAIL` from `rain.string`; `LibParseError`.

**Assembly blocks:** Lines 39-51 (boundString, scans string characters), lines 58-59 (boundString, reads final char), lines 100-105 (parseString, fabricates string memory layout), lines 107-109 (parseString, restores memory). All marked `memory-safe`.

**Unchecked block:** Lines 31-74, entire `boundString` body. Key analysis:
- `cursor + 1` (line 32): cursor is a memory pointer, cannot overflow.
- `sub(end, innerStart)` in assembly (line 40): if `innerStart > end`, this underflows in EVM to a very large number. But `max` is clamped via `if lt(distanceFromEnd, 0x20) { max := distanceFromEnd }`. When underflow produces a huge value, `lt(huge, 0x20)` is false, so `max = 0x20`. However, this case is unreachable because the caller guarantees `cursor < end` (literal head character was already checked), so `innerStart = cursor + 1 <= end`.
- When `innerStart == end`, `distanceFromEnd = 0`, `max = 0`, loop doesn't execute, `i = 0`, `innerEnd = end`, `end == innerEnd` triggers `UnclosedStringLiteral`. Correct.

**Memory mutation in `parseString` verified:** Saves word at `str = stringStart - 0x20`, writes length, calls `fromStringV3` (which only uses scratch space 0x00-0x3f), then restores. No reentrancy possible (pure function). Correctly bracketed.

**String length limit:** Max 31 bytes (loop runs at most 0x1F iterations before hitting a terminator; reaching 0x20 reverts with `StringTooLong`). Consistent with `IntOrAString` 5-bit length field.

---

### LibParseLiteralSubParseable.sol (A38)

**Library:** `LibParseLiteralSubParseable` (line 14)

**Functions:**

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `parseSubParseable` | 35 | internal | view |

**Imports:** `ParseState`; `LibParse`; `UnclosedSubParseableLiteral`, `SubParseableMissingDispatch` from `ErrParse.sol`; `CMASK_WHITESPACE`, `CMASK_SUB_PARSEABLE_LITERAL_END` from `rain.string`; `LibParseInterstitial`; `LibParseError`; `LibSubParse`; `LibParseChar`.

**Using-for:** `LibParse for ParseState` (line 15, unused in this file), `LibParseInterstitial for ParseState` (line 16), `LibParseError for ParseState` (line 17), `LibSubParse for ParseState` (line 18).

**Assembly block:** Lines 73-76 (reads final char for bracket check). Marked `memory-safe`, read-only.

**Unchecked block:** Lines 40-86, entire function body. Key analysis:
- `++cursor` (line 44): cursor is a memory pointer, cannot overflow.
- `++cursor` (line 83): same.
- Guard at line 68 (`cursor >= end`) correctly prevents out-of-bounds read before the assembly block at line 73-76. This was a prior audit finding (A38-1) that has been fixed.

**Dispatch/body parsing verified:**
1. Skip opening `[` (line 44).
2. Scan non-whitespace, non-`]` chars for dispatch (line 49). If empty, revert `SubParseableMissingDispatch` (line 53).
3. Skip whitespace (line 57).
4. Scan non-`]` chars for body (line 65).
5. If `cursor >= end`, revert `UnclosedSubParseableLiteral` (lines 68-69).
6. Verify char at cursor is `]` (lines 72-79).
7. Skip closing `]` (line 83).
8. Delegate to `subParseLiteral` (line 85).

---

## Security Findings

### A35-1: Dead code -- `MalformedHexLiteral` revert is unreachable

**Severity:** LOW

**Location:** `src/lib/parse/literal/LibParseLiteralHex.sol`, line 110

**Description:**

The `parseHex` function calls `boundHex` internally (line 68) to determine the range `[hexStart, hexEnd)` of hex digits. `boundHex` scans forward from `cursor + 2` using `CMASK_HEX` (which is `CMASK_NUMERIC_0_9 | CMASK_LOWER_ALPHA_A_F | CMASK_UPPER_ALPHA_A_F`), stopping at the first non-hex character. This guarantees every byte between `hexStart` and `hexEnd` matches `CMASK_HEX`.

The backward parsing loop in `parseHex` (lines 82-116) then checks each character against `CMASK_NUMERIC_0_9`, `CMASK_LOWER_ALPHA_A_F`, and `CMASK_UPPER_ALPHA_A_F` individually. Since these three masks are the exact components of `CMASK_HEX`, every character validated by `boundHex` will match one of the three branches. The `else` branch at line 109-111 that reverts with `MalformedHexLiteral` can never execute.

Dead code is a maintenance concern: it provides a false sense of coverage (the revert path appears tested-for but cannot actually be triggered), and it adds bytecode size without providing any runtime benefit. More importantly, if a future change alters `boundHex` to accept different characters, the dead code might create a false assumption that `parseHex` independently validates characters, when in fact the validation is redundant under current invariants.

**Recommendation:** Either:
(a) Remove the `else` branch and `MalformedHexLiteral` import, since `boundHex` guarantees only hex characters are in the range, or
(b) Add a comment documenting that the branch is a defensive guard that is currently unreachable due to the `boundHex` invariant.

---

### A38-2: Unused `using LibParse for ParseState` declaration

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteralSubParseable.sol`, line 15

**Description:**

The `using LibParse for ParseState` declaration is present but no function from `LibParse` is called anywhere in this file. This was noted in the prior audit. The unused declaration adds a small amount of compilation overhead and reduces readability by suggesting a dependency that does not exist.

---

### A33-1: No bounds check in `selectLiteralParserByIndex`

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteral.sol`, lines 33-46

**Description:**

The function reads a 2-byte function pointer from the `literalParsers` array at position `2 + index * 2` without bounds checking. The comment documents this as intentional. All call sites (line 122) pass an index from `tryParseLiteral`'s dispatch logic, which only produces values 0-3. For a `literalParsers` array with `LITERAL_PARSERS_LENGTH * 2 = 8` bytes of data, index 3 reads at offset `literalParsers + 8`, which `mload` loads bytes [8..39] and masks to the lowest 16 bits (bytes [38..39] -- but actually `mload(literalParsers + 8)` reads bytes at memory positions `literalParsers+8` through `literalParsers+39`; the lowest 16 bits correspond to positions `literalParsers+38` and `literalParsers+39`, which are the data bytes at index [6..7], i.e., the 4th function pointer). This is correct.

No external caller can invoke this function (it is `internal`). The risk is limited to future code changes that might pass an out-of-range index.

---

### A37-1: `mload` reads past logical end of data in `boundString`

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteralString.sol`, lines 58-59

**Description:**

When the string scanning loop terminates at `innerEnd == end` (no closing quote found before end of data), `mload(innerEnd)` reads 32 bytes starting from `end`, which extends past the logical end of the parse data. The read is safe because:
1. EVM `mload` at any valid memory address is safe (memory is zero-initialized beyond the free memory pointer).
2. The `end == innerEnd` guard on line 66 catches this case and reverts with `UnclosedStringLiteral`, so the read result is never used to make a correctness-affecting decision.
3. Even if the byte at `end` happens to be `"` (0x22), the `end == innerEnd` condition still triggers the revert.

No action required.

---

### A34-1: Security depends on `rain.math.float` library

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteralDecimal.sol`, lines 25-28

**Description:**

`parseDecimalFloatPacked` is a thin wrapper that delegates all parsing logic to `LibParseDecimalFloat.parseDecimalFloatInline` and all packing logic to `LibDecimalFloat.packLossless`, both from the `rain.math.float` submodule. The wrapper correctly propagates all error selectors via `handleErrorSelector` and does not suppress any return values. Any parsing or precision bugs would originate in the submodule, not in this file.

The error types propagated include: `ParseEmptyDecimalString`, `MalformedDecimalPoint`, `MalformedExponentDigits`, `ParseDecimalPrecisionLoss`, and `CoefficientOverflow`. All are custom errors.

No action required at this layer.

---

### A35-2: Assembly blocks correctly annotated `memory-safe`

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteralHex.sol`, lines 40 and 84

**Description:**

Both assembly blocks perform only `mload` (read) operations. Neither writes to memory. The `memory-safe` annotations are accurate.

---

### A33-2: All assembly blocks correctly annotated `memory-safe`

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteral.sol`, lines 42, 86, 96

**Description:**

All three assembly blocks perform read-only operations (`mload`, `byte`, `shl`). None write to memory. Annotations are accurate.

---

### A37-2: Temporary memory mutation correctly bracketed

**Severity:** INFO

**Location:** `src/lib/parse/literal/LibParseLiteralString.sol`, lines 100-109

**Description:**

`parseString` temporarily writes a length prefix at `str = stringStart - 0x20` to fabricate a `string memory`. The original word is saved to `memSnapshot` before writing and restored immediately after `fromStringV3` returns. `fromStringV3` only writes to scratch space (addresses 0x00-0x3f) via `mstore(0, ...)` and `mcopy(sub(0x20, ...), ...)`. The function is `pure`, so no reentrancy is possible. The save-restore bracket is correct.

---

## Summary

| File | Severity | Count |
|---|---|---|
| LibParseLiteral.sol (A33) | INFO | 2 |
| LibParseLiteralDecimal.sol (A34) | INFO | 1 |
| LibParseLiteralHex.sol (A35) | LOW | 1 |
| LibParseLiteralHex.sol (A35) | INFO | 1 |
| LibParseLiteralString.sol (A37) | INFO | 2 |
| LibParseLiteralSubParseable.sol (A38) | INFO | 1 |

**Total:** 1 LOW, 7 INFO. No CRITICAL, HIGH, or MEDIUM findings.

The literal parsing subsystem is well-structured with proper bounds checking, correct use of custom errors, safe assembly annotations, and sound arithmetic. The single LOW finding (dead code in the hex parser) is a code quality issue rather than a correctness or exploitability concern. The prior audit's A38-1 finding (out-of-bounds read in sub-parseable parser) has been fixed with the `cursor >= end` guard at line 68.
