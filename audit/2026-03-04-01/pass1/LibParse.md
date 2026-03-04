# A102 -- Pass 1 (Security) -- LibParse.sol

## Evidence of Thorough Reading

**Library name:** `LibParse`

**File:** `src/lib/parse/LibParse.sol` (459 lines)

**Pragma:** `solidity ^0.8.25`

**License:** `LicenseRef-DCL-1.0`

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 106 | `parseWord(uint256 cursor, uint256 end, uint256 mask)` | function | internal | pure |
| 142 | `parseLHS(ParseState memory state, uint256 cursor, uint256 end)` | function | internal | pure |
| 220 | `parseRHS(ParseState memory state, uint256 cursor, uint256 end)` | function | internal | view |
| 435 | `parse(ParseState memory state)` | function | internal | view |

**Custom errors imported (from `ErrParse.sol`):**

| Error | Parameters |
|-------|-----------|
| `UnexpectedRHSChar` | `uint256 offset` |
| `UnexpectedRightParen` | `uint256 offset` |
| `WordSize` | `string word` |
| `DuplicateLHSItem` | `uint256 offset` |
| `ParserOutOfBounds` | (none) |
| `ExpectedLeftParen` | `uint256 offset` |
| `UnexpectedLHSChar` | `uint256 offset` |
| `MissingFinalSemi` | `uint256 offset` |
| `UnexpectedComment` | `uint256 offset` |
| `ParenOverflow` | (none) |
| `LHSItemCountOverflow` | `uint256 offset` |

**Constants defined:**

| Line | Name | Value | Description |
|------|------|-------|-------------|
| 59 | `SUB_PARSER_BYTECODE_HEADER_SIZE` | 5 | Fixed header size for sub-parser bytecode |
| 66 | `MAX_PAREN_OFFSET` | 59 | Maximum paren offset before tracker overflow |

**Types/structs defined:** None (uses `ParseState` from `LibParseState.sol`).

**Using-for declarations (lines 76-87):**
- `LibPointer for Pointer`
- `LibParseStackName for ParseState`
- `LibParseState for ParseState`
- `LibParseInterstitial for ParseState`
- `LibParseError for ParseState`
- `LibParseMeta for ParseState`
- `LibParsePragma for ParseState`
- `LibParse for ParseState`
- `LibParseOperand for ParseState`
- `LibSubParse for ParseState`
- `LibBytes for bytes`
- `LibBytes32Array for bytes32[]`

---

## Security Review

### Assembly memory safety

The file contains four assembly blocks, all tagged `"memory-safe"`:

1. **`parseWord` (lines 115-126):** Reads 32 bytes at `cursor` via `mload(cursor)`. May read past `end` if `end - cursor < 32`, but this is safe because:
   - `iEnd` is capped at `min(0x20, end - cursor)` (line 113), so the loop only considers valid bytes.
   - The word is scrubbed to `i` bytes at lines 123-124, discarding any garbage.
   - No writes to memory occur in this block; only `word` and `cursor` are modified.

2. **`parseLHS` (lines 147-149):** Single `mload` at `cursor` to extract one char via `byte(0, ...)`. Cursor is known to be `< end` from the loop guard at line 144. Read-only; no memory writes.

3. **`parseRHS` (lines 225-227):** Identical pattern to `parseLHS`. Cursor bounded by loop guard at line 222.

4. **`parseRHS` paren open (lines 347-349):** Reads from `state + parenTracker0Offset`, increments by 3, writes back via `mstore8`. The `MAX_PAREN_OFFSET` check at line 351 prevents writing beyond the 62-byte paren tracker region.

5. **`parseRHS` paren close (lines 373-388):** Reads paren offset, decrements by 3, writes input counter via `mstore8`. The `parenOffset == 0` guard at line 365 prevents underflow. The `mstore8` at line 383 writes to an address derived from the paren tracker's stored pointer, which was written by `pushOpToSource` and points into the active source region.

6. **`parseRHS` sub-parser bytecode (lines 287-300):** Allocates memory via `mload(0x40)` / `mstore(0x40, ...)`. The bump includes `subParserBytecodeLength + 0x20` which correctly accounts for the Solidity `bytes` length prefix. The comment notes this is not an aligned allocation; alignment is restored by `endSource` (line 893) or `buildBytecode` (line 981). No out-of-bounds writes: the total allocation size matches `SUB_PARSER_BYTECODE_HEADER_SIZE + wordLength + operandValues.length * 0x20 + 0x20`.

All assembly blocks are read-correct and write-bounded. No memory safety violations found.

### Bounds checks and cursor invariants

**`parse()` (line 435):** The top-level loop `while (cursor < end)` delegates to `parseInterstitial`, `parseLHS`, and `parseRHS` sequentially. All three functions:
- Accept `(cursor, end)` and return a new cursor.
- Guarantee `cursor <= end` on return (verified by tracing all cursor-advancing paths).
- The defensive check at line 447 (`cursor != end`) catches any internal bug where a sub-parser overshoots `end`.

**`parseWord()` (line 106):** Returns cursor at `cursor + i` where `i <= iEnd <= min(0x20, end - cursor)`, so the returned cursor never exceeds `end`.

**`parseLHS()` (line 142):** The `while (cursor < end)` guard bounds all paths. `cursor++` at line 197 is inside the loop, so `cursor` can reach `end` but not exceed it. `parseWord` and `skipMask` are both bounded by `end`.

**`parseRHS()` (line 220):** Same pattern. All `cursor++` operations (lines 354, 390, 405, 412) occur inside the `while (cursor < end)` guard.

### Parser state corruption protections

**LHS item count overflow (line 182):** Checks `(state.topLevel1 & 0xFF) == 0xFF || (state.lineTracker & 0xFF) == 0xFF` before incrementing. This prevents the 256th LHS item from silently wrapping the single-byte counter into an adjacent packed field. Tested in `LibParse.lhsOverflow.t.sol`.

**Paren depth overflow (line 351):** Checks `newParenOffset > MAX_PAREN_OFFSET` (59) after incrementing by 3. The maximum valid offset is 57 (19 groups of 3 bytes), fitting within the 62-byte paren tracker region. Tested in `LibParseState.overflow.t.sol`.

**Per-item ops overflow:** Handled in `LibParseState.pushOpToSource()` at line 686, which checks `val == 0xFF` before incrementing. Tested in `LibParseState.overflow.t.sol`.

**Total source ops overflow:** Handled in `LibParseState.endSource()` at line 877, which checks `div(length, 4) - 1 > 0xFF`. Tested in `LibParseState.endSourceTotalOpsOverflow.t.sol`.

**Paren input overflow:** Handled in `LibParseState.pushOpToSource()` at line 728, which checks `val == 0xFF` before incrementing. Tested in `LibParseState.parenInputOverflow.t.sol`.

**Line RHS items overflow:** Handled in `LibParseState.snapshotSourceHeadToLineTracker()` at line 386, which checks `offset > 0xF0`. Tested in `LibParseState.overflow.t.sol`.

### Prior finding A43-1 verification (endSource ops-count byte overflow when total ops > 255)

**Status: FIXED.**

The fix adds two overflow checks:

1. **Per-item check** in `pushOpToSource()` (LibParseState.sol:686): When the per-item byte counter would wrap from 0xFF to 0x00, reverts with `SourceItemOpsOverflow()`.

2. **Total ops check** in `endSource()` (LibParseState.sol:877): After computing the total length, checks `sub(div(length, 4), 1) > 0xFF` and reverts with `SourceTotalOpsOverflow()`.

Both checks have direct test coverage:
- `LibParseState.overflow.t.sol`: Tests 255 ops (no overflow) and 256+ ops (overflow) for per-item counter.
- `LibParseState.endSourceTotalOpsOverflow.t.sol`: Tests 254 total ops (no overflow) and 256/510 total ops (overflow) across multiple items.

The error types `SourceItemOpsOverflow` and `SourceTotalOpsOverflow` are custom errors (no string reverts), consistent with project conventions.

### Operand validation

Operand parsing is delegated to `LibParseOperand.parseOperand()`, which:
- Resets operand values to length 0 before each parse.
- Bounds-checks the operand values count against `OPERAND_VALUES_LENGTH` (4).
- Reverts with `OperandValuesOverflow` if exceeded.
- Reverts with `UnclosedOperand` if the closing `>` is not found.

The `handleOperand` function at LibParseOperand.sol:139 dispatches to a handler via function pointer without bounds-checking the `wordIndex`. The comment explains this is intentional -- the index comes from the parser's own bloom-filter lookup, not user input. Any corruption would require a parser bug, which should be caught by direct test coverage.

### Custom errors

No string reverts anywhere in the file. All error paths use properly defined custom errors from `ErrParse.sol`. The `WordSize` error at line 128 uses `string(abi.encodePacked(word))` as a parameter, not as a revert string.

### Sub-parser bytecode construction

The sub-parser bytecode allocation at lines 287-300 computes the total length as:
```
SUB_PARSER_BYTECODE_HEADER_SIZE + wordLength + operandValues.length * 0x20 + 0x20
```

The memory copy at lines 303-310 (`unsafeCopyBytesTo`) copies `wordLength` bytes from the original cursor position into the bytecode buffer after the header. The second copy at lines 316-319 (`unsafeCopyWordsTo`) copies `operandValues.length + 1` words (including the length slot) to the end of the buffer. Both copies fit within the allocated region.

The `operand` is set to the `subParserBytecode` pointer (line 299), which is later passed to `pushOpToSource` as a full 256-bit value. The operand field in the active source is only 16 bits wide (see LibParseState.sol:660-661 NatSpec). However, for `OPCODE_UNKNOWN` words, the operand is a memory pointer, not a packed value. The 16-bit truncation is handled during sub-parsing in `LibSubParse.subParseWords()`, where unknown opcodes are resolved before the final bytecode is emitted. The pointer is valid because `checkParseMemoryOverflow` ensures all memory stays below `0x10000`.

---

## Findings

No LOW+ findings.

This library is the core parsing engine. Its security model relies on:
1. Defensive cursor bounding -- all loops are guarded by `cursor < end`, all sub-functions receive and respect `end`.
2. Overflow guards on all packed byte counters -- LHS items, per-item ops, total ops, paren inputs, paren depth, and line RHS items all have explicit overflow checks with custom error reverts.
3. Post-parse memory overflow check -- `checkParseMemoryOverflow()` enforces the 16-bit pointer invariant.
4. No string reverts -- all error paths use custom errors.

The A43-1 fix (ops-count byte overflow) is confirmed present and tested. All assembly blocks are correctly tagged `memory-safe` and operate within their documented bounds. The sub-parser bytecode construction correctly sizes its allocation and copies data within bounds.
