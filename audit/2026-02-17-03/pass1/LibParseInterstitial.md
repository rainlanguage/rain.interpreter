# Pass 1 (Security) — LibParseInterstitial.sol

**File:** `src/lib/parse/LibParseInterstitial.sol`
**Auditor:** Claude Opus 4.6
**Date:** 2026-02-17

---

## Evidence of Thorough Reading

### Contract/Library Name

- `LibParseInterstitial` (library, line 17)

### Functions

| Function | Line | Visibility |
|---|---|---|
| `skipComment(ParseState memory, uint256 cursor, uint256 end)` | 28 | `internal pure` |
| `skipWhitespace(ParseState memory, uint256 cursor, uint256 end)` | 96 | `internal pure` |
| `parseInterstitial(ParseState memory, uint256 cursor, uint256 end)` | 111 | `internal pure` |

### Errors/Events/Structs Defined

No errors, events, or structs are defined in this file. The file imports two custom errors from `src/error/ErrParse.sol`:
- `MalformedCommentStart(uint256 offset)` (used at line 49)
- `UnclosedComment(uint256 offset)` (used at lines 40, 83)

### Imports

- `FSM_YANG_MASK`, `ParseState` from `LibParseState.sol`
- `CMASK_COMMENT_HEAD`, `CMASK_WHITESPACE`, `COMMENT_END_SEQUENCE`, `COMMENT_START_SEQUENCE`, `CMASK_COMMENT_END_SEQUENCE_END` from `rain.string` `LibParseCMask.sol`
- `MalformedCommentStart`, `UnclosedComment` from `ErrParse.sol`
- `LibParseError` from `LibParseError.sol`
- `LibParseChar` from `rain.string` `LibParseChar.sol`

### Using Directives

- `LibParseError for ParseState` (line 18)
- `LibParseInterstitial for ParseState` (line 19)

---

## Security Findings

### Finding 1: Semantic mismatch — comparing a byte value against a bitmask constant

**Severity:** LOW

**Location:** Line 63

**Description:**
On line 63, the code compares `charByte` (an individual byte value 0x00-0xFF read from memory) against `CMASK_COMMENT_END_SEQUENCE_END`. The constant `CMASK_COMMENT_END_SEQUENCE_END` is defined as:

```solidity
uint256 constant CMASK_COMMENT_END_SEQUENCE_END = COMMENT_END_SEQUENCE & 0xFF;
```

Where `COMMENT_END_SEQUENCE = uint256(uint16(bytes2("*/")))` = `0x2A2F`. So `CMASK_COMMENT_END_SEQUENCE_END = 0x2F`, which is the ASCII value of `/`.

The comparison `charByte == CMASK_COMMENT_END_SEQUENCE_END` is checking whether the current byte equals `/` (0x2F). Despite the confusing naming convention (the `CMASK_` prefix suggests a bitmask, but this constant is used as a raw byte value), the comparison is functionally correct. The byte value `0x2F` is indeed the `/` character that terminates `*/`.

This is a naming/convention concern rather than a bug: the `CMASK_` prefix is used inconsistently here. All other `CMASK_` constants are bitmasks (a single bit set via `1 << charValue`), but `CMASK_COMMENT_END_SEQUENCE_END` is a raw byte value. If someone later refactored this to use it as a mask, the logic would break silently. However, the current code is correct.

### Finding 2: Assembly blocks — memory safety analysis

**Severity:** INFO

**Location:** Lines 45-47, 60-62, 67-69, 114-117

**Description:**
All four assembly blocks are marked `"memory-safe"`. Analysis of each:

1. **Lines 45-47:** `startSequence := shr(0xf0, mload(cursor))` — Reads 32 bytes from `cursor` and right-shifts by 240 bits to isolate the top 16 bits (2 bytes). This is a read-only operation. The cursor has been bounds-checked against `end` at line 39 (`cursor + 4 > end` reverts), ensuring at least 4 bytes are available. Reading 32 bytes from `cursor` may read past `end` into adjacent memory, but this is benign since `mload` is read-only and the result is masked down to 2 bytes. Correctly marked memory-safe.

2. **Lines 60-62:** `charByte := byte(0, mload(cursor))` — Reads 32 bytes from `cursor` and extracts the most significant byte. Read-only, bounded by `cursor < end` loop condition at line 58. Correctly marked memory-safe.

3. **Lines 67-69:** `endSequence := shr(0xf0, mload(sub(cursor, 1)))` — Reads 2 bytes starting at `cursor - 1`. Since `cursor` started at the original position + 3 (line 55) and has been incremented, `cursor - 1` is always a valid position within or before `end`. The `sub(cursor, 1)` cannot underflow because `cursor >= original_cursor + 3`. Read-only. Correctly marked memory-safe.

4. **Lines 114-117:** `char := shl(byte(0, mload(cursor)), 1)` — Reads byte at `cursor` and left-shifts `1` by that amount. This converts a character byte into a bitmask for comparison. Read-only, bounded by `cursor < end` at line 112. Correctly marked memory-safe.

All assembly blocks perform only reads (`mload`, `byte`, `shr`, `shl`). No writes to memory occur. All are correctly marked `"memory-safe"`.

### Finding 3: Unchecked arithmetic review

**Severity:** INFO

**Location:** Lines 36-87 (entire `skipComment` body), lines 97-101 (`skipWhitespace`)

**Description:**
The `skipComment` function wraps its entire body in `unchecked`. The arithmetic operations within are:

- `cursor + 4` (line 39): Used for bounds check. The comment at lines 33-35 acknowledges that overflow is not a concern because if cursor or end were near `uint256` max, something has already gone catastrophically wrong. This is reasonable — cursor values are derived from Solidity `bytes memory` data pointers, which are well below `uint256` max.
- `cursor += 3` (line 55): Same reasoning — cursor is a memory pointer.
- `++cursor` (lines 73, 78): Same reasoning.
- `sub(cursor, 1)` in assembly (line 68): Cannot underflow because `cursor >= original + 3` at this point.

The `skipWhitespace` function also uses `unchecked` but only contains a bitwise AND operation (`state.fsm &= ~FSM_YANG_MASK`) and a delegate call to `LibParseChar.skipMask`. No arithmetic overflow risk.

All unchecked arithmetic is safe given the constraints on cursor values.

### Finding 4: All reverts use custom errors

**Severity:** INFO

**Location:** Lines 40, 49, 83

**Description:**
The file contains three revert statements:
- Line 40: `revert UnclosedComment(state.parseErrorOffset(cursor));`
- Line 49: `revert MalformedCommentStart(state.parseErrorOffset(cursor));`
- Line 83: `revert UnclosedComment(state.parseErrorOffset(cursor));`

All use custom error types with offset parameters, conforming to the project convention. No string-based reverts are present.

### Finding 5: Comment end detection reads one byte before cursor

**Severity:** INFO

**Location:** Lines 67-69

**Description:**
When detecting the comment end sequence `*/`, the code reads `mload(sub(cursor, 1))` to get the two-byte sequence starting one byte before the current position. This is safe because:

- `cursor` is at least `original_cursor + 3` when the loop starts (line 55: `cursor += 3`).
- The loop increments `cursor` further (line 78: `++cursor`), so `cursor - 1` is always at least `original_cursor + 3` on the first iteration.
- Since `original_cursor` points to valid memory (the start of the `/*` sequence), `cursor - 1` always points to valid allocated memory.

No out-of-bounds risk exists here.

### Finding 6: `parseInterstitial` does not use `unchecked` but has no arithmetic

**Severity:** INFO

**Location:** Lines 111-127

**Description:**
The `parseInterstitial` function itself does not wrap its body in `unchecked`. It contains no arithmetic operations — only comparisons and function calls. The cursor advancement is delegated to `skipWhitespace` and `skipComment`, which handle their own arithmetic. This is correct and consistent.

---

## Summary

No CRITICAL, HIGH, or MEDIUM severity issues were found in `LibParseInterstitial.sol`. The library is a straightforward parser utility that skips whitespace and comments, advancing a cursor through source text. All assembly blocks are read-only and correctly marked memory-safe. All unchecked arithmetic is justified by the constraints on cursor values (memory pointers well below `uint256` max). All reverts use custom errors. The one LOW finding is a naming convention inconsistency in an imported constant (`CMASK_COMMENT_END_SEQUENCE_END` is not actually a character mask despite the `CMASK_` prefix), which resides in the external `rain.string` dependency rather than in this file.
