# Pass 1: Security Review of Literal Parsing Files

Agent: A17
Date: 2026-03-07

## Files Reviewed

### 1. LibParseLiteral.sol

**Library:** `LibParseLiteral`

**Constants (file-level):**
- `LITERAL_PARSERS_LENGTH = 4` (line 19)
- `LITERAL_PARSER_INDEX_HEX = 0` (line 22)
- `LITERAL_PARSER_INDEX_DECIMAL = 1` (line 24)
- `LITERAL_PARSER_INDEX_STRING = 2` (line 26)
- `LITERAL_PARSER_INDEX_SUB_PARSE = 3` (line 28)

**Functions:**
- `selectLiteralParserByIndex(ParseState memory, uint256)` -- line 43
- `parseLiteral(ParseState memory, uint256, uint256)` -- line 65
- `tryParseLiteral(ParseState memory, uint256, uint256)` -- line 87

**Analysis:**
- `selectLiteralParserByIndex` (line 52-54): Assembly reads 2-byte function pointer from packed `literalParsers` bytes. No bounds check, but callers only pass hardcoded index constants 0-3 matching `LITERAL_PARSERS_LENGTH = 4`. Safe.
- `tryParseLiteral` (line 96-99): `mload(cursor)` is safe because the main parse loop guarantees `cursor < end`. Reading `byte(0, word)` extracts the first byte.
- Second-byte read for hex disambiguation (line 110-114): Guarded by `cursor + 1 < end` check. This is the EXT-M01 fix. Correctly prevents OOB read.
- Uppercase hex prefix detection (lines 122-125): Uses `CMASK_ZERO | CMASK_UPPER_X` and reverts with `UppercaseHexPrefix`. This is the EXT-L01 fix.
- All revert paths use custom errors. No string reverts.

### 2. LibParseLiteralDecimal.sol

**Library:** `LibParseLiteralDecimal`

**Constants:** None.

**Functions:**
- `parseDecimalFloatPacked(ParseState memory, uint256, uint256)` -- line 23

**Analysis:**
- Delegates to `LibParseDecimalFloat.parseDecimalFloatInline(start, end)` from `rain.math.float`. Error handling via `state.handleErrorSelector(cursor, errorSelector)`.
- Result packed via `LibDecimalFloat.packLossless(signedCoefficient, exponent)`. If packing fails (overflow), that library reverts.
- No assembly in this file. No direct memory manipulation.
- Clean delegation pattern. No issues.

### 3. LibParseLiteralHex.sol

**Library:** `LibParseLiteralHex`

**Constants:** None (imports `CMASK_*` from rain.string).

**Imported errors:**
- `MalformedHexLiteral` (line 7)
- `OddLengthHexLiteral` (line 8)
- `ZeroLengthHexLiteral` (line 9)
- `HexLiteralOverflow` (line 10)

**Functions:**
- `boundHex(ParseState memory, uint256, uint256)` -- line 36
- `parseHex(ParseState memory, uint256, uint256)` -- line 68

**Analysis:**
- `boundHex` (line 45-50): Assembly loop scans forward while chars match `CMASK_HEX` and `innerEnd < end`. `mload(innerEnd)` may read at or beyond `end` (EVM memory reads don't revert), but the `lt(innerEnd, end)` guard in the `and` condition prevents any iteration past bounds. Safe.
- `parseHex` (line 69-126): Entire function in `unchecked` block.
  - Overflow check: `hexLength > 0x40` (64 nybbles = 32 bytes = bytes32 max). Correct.
  - Zero-length and odd-length checks present.
  - Backward loop (line 85-121): `cursor = hexEnd - 1`, loops while `cursor >= hexStart`. Since `hexStart` is a memory pointer (always >= 2 due to `cursor + 2`), when `cursor` is decremented past `hexStart`, it wraps to a huge value (unsigned), which is `< hexStart` is false, but `>= hexStart` is true for `type(uint256).max`. Wait -- no. In `unchecked`, `cursor--` when `cursor == hexStart` gives `hexStart - 1`. For unsigned integers, `hexStart - 1 < hexStart` is true (no underflow to max because `hexStart >= 2`). The loop terminates correctly.
  - `MalformedHexLiteral` at line 115: Defense-in-depth; `boundHex` already ensures only hex chars are in range. This is the A35-1 finding, DISMISSED.
  - Nybble computation (lines 98-113): Correctly handles 0-9, a-f, A-F character ranges.
  - Value accumulation (line 118): `value |= nybble << valueOffset` with `valueOffset` incrementing by 4. Maximum `valueOffset` = `(0x40 - 1) * 4 = 252`, which is within `bytes32` range.

### 4. LibParseLiteralString.sol

**Library:** `LibParseLiteralString`

**Constants:** None (imports `CMASK_*` from rain.string).

**Imported errors:**
- `UnclosedStringLiteral` (line 7)
- `StringTooLong` (line 7)

**Functions:**
- `boundString(ParseState memory, uint256, uint256)` -- line 26
- `parseString(ParseState memory, uint256, uint256)` -- line 88

**Analysis:**
- `boundString` (line 31-75): In `unchecked` block.
  - `distanceFromEnd = sub(end, innerStart)` (line 40): If `innerStart > end` (i.e., cursor >= end), this underflows to a huge value in assembly. The `max` would remain `0x20`, and the scan would read up to 32 bytes past the source. However, the caller (`tryParseLiteral`) is only invoked when `cursor < end` (enforced by the main parse loop). With `innerStart = cursor + 1`, `innerStart` could equal `end` when cursor is at the very last byte. In that case `distanceFromEnd = 0`, `max = 0`, the loop doesn't iterate, `i = 0` (not 0x20), `innerEnd = innerStart`, and `finalChar` is read at `innerEnd`. Since `end == innerEnd`, line 66 reverts with `UnclosedStringLiteral`. Correct.
  - String length limit (line 53): `i == 0x20` catches strings that exhaust 32 bytes.
  - Closing quote check (line 66): Checks both that the char matches `CMASK_STRING_LITERAL_END` AND that `end != innerEnd`. Correct.
- `parseString` (line 88-111): Temporarily mutates memory to create a `string memory` view.
  - `str = sub(stringStart, 0x20)` (line 102): Points 32 bytes before string content, within the source `bytes memory` array. Valid allocated memory.
  - Snapshot/restore pattern (lines 103-104, 107-108): Memory at `str` is saved before overwriting with length, then restored after `fromStringV3`. If `fromStringV3` reverts, the restore doesn't execute, but the entire call frame reverts, discarding all memory changes. Safe.
  - `memory-safe` annotation: Correct -- writes only to allocated memory within the source data array.
  - `fromStringV3` uses scratch space (0x00-0x1F) and `mcopy`. Does not modify the source data. Clean.

### 5. LibParseLiteralSubParseable.sol

**Library:** `LibParseLiteralSubParseable`

**Constants:** None (imports `CMASK_*` from rain.string).

**Imported errors:**
- `UnclosedSubParseableLiteral` (line 7)
- `SubParseableMissingDispatch` (line 7)

**Functions:**
- `parseSubParseable(ParseState memory, uint256, uint256)` -- line 38

**Analysis:**
- In `unchecked` block.
- `++cursor` on line 47: Moves past `[`. Caller guarantees cursor is at `[`.
- Dispatch extraction (lines 49-57): `skipMask` with `~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_END)` skips non-whitespace, non-`]` chars. Empty dispatch reverts correctly.
- Whitespace skip (line 60): Moves past whitespace between dispatch and body.
- Body extraction (lines 62-70): `skipMask` with `~CMASK_SUB_PARSEABLE_LITERAL_END` skips everything except `]`. NatSpec (lines 64-68) correctly documents that multibyte encodings are not understood but that valid UTF-8 is safe since continuation bytes (0x80-0xBF) never equal `]` (0x5D).
- End-of-data check (line 72): `cursor >= end` reverts with `UnclosedSubParseableLiteral`. Correct.
- Closing bracket verification (lines 76-84): Redundant with `skipMask` behavior but provides defense-in-depth. The `mload(cursor)` is safe because `cursor < end` was just verified.
- Cursor advanced past `]` on line 87.
- Delegates to `state.subParseLiteral(dispatchStart, dispatchEnd, bodyStart, bodyEnd)` for actual sub-parsing.
- All revert paths use custom errors.

## Previously Triaged Findings

- **EXT-M01** (second-byte OOB read in decimal): FIXED at line 110 of LibParseLiteral.sol. Not re-flagged.
- **EXT-L01** (uppercase hex prefix): FIXED at lines 122-125 of LibParseLiteral.sol. Not re-flagged.
- **A35-1** (MalformedHexLiteral dead code): DISMISSED. Defense-in-depth at line 115 of LibParseLiteralHex.sol. Not re-flagged.

## Findings

No findings.

All five files demonstrate correct memory safety in assembly, proper bounds checking, appropriate input validation of untrusted literal text, correct arithmetic handling (including unchecked blocks), and exclusive use of custom error types. The code is well-structured with clear separation of concerns between bounding (finding literal extent) and parsing (extracting value).
