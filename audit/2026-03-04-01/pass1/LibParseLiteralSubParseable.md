# A115 -- Pass 1 (Security) -- LibParseLiteralSubParseable.sol

## Evidence of Thorough Reading

**Library name:** `LibParseLiteralSubParseable`

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 38 | `parseSubParseable(ParseState memory, uint256, uint256)` | function | internal | view |

**Errors used (imported):**
- `UnclosedSubParseableLiteral(uint256)` from `ErrParse.sol`
- `SubParseableMissingDispatch(uint256)` from `ErrParse.sol`

**Character masks (imported):**
- `CMASK_WHITESPACE`, `CMASK_SUB_PARSEABLE_LITERAL_END` from `rain.string`

**Using-for declarations:**
- `LibParse for ParseState`
- `LibParseInterstitial for ParseState`
- `LibParseError for ParseState`
- `LibSubParse for ParseState`

---

## Security Review

### Assembly memory safety

**`parseSubParseable` (lines 77-79):**
- Single assembly block reads `byte(0, mload(cursor))` and shifts to create a character mask. The cursor is within bounds because `cursor < end` is checked at line 72. Tagged `memory-safe`. Correct.

### Parsing logic

The function parses `[dispatch body]` literals:

1. **Line 47**: Advance past opening `[`.
2. **Lines 49-53**: Scan for dispatch string (non-whitespace, non-`]` characters). Uses `LibParseChar.skipMask` with the complement mask `~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_END)`. This correctly stops at whitespace or `]`.
3. **Line 55**: Check dispatch is non-empty. Reverts `SubParseableMissingDispatch` if empty.
4. **Line 60**: Skip whitespace between dispatch and body.
5. **Lines 62-70**: Scan for body (all characters except `]`). The NatSpec (lines 64-68) correctly documents that this is byte-level scanning and multibyte encodings where a continuation byte equals `]` (0x5D) could cause premature termination. This is acceptable for valid UTF-8 where continuation bytes are 0x80-0xBF.
6. **Line 72**: Check cursor hasn't reached end (unclosed literal).
7. **Lines 76-83**: Verify the character at cursor is actually `]`. This double-check is defensive -- `skipMask` should have stopped at `]`, but the check handles the case where the scan stopped at `end` instead.
8. **Line 87**: Advance past closing `]`.
9. **Line 89**: Delegate to `state.subParseLiteral`.

### Bounds checks

- `cursor >= end` at line 72 catches unclosed literals.
- Empty dispatch at line 55 is explicitly checked.
- The closing bracket is verified at lines 76-83.

### Edge case: empty body

If there's no whitespace between the dispatch and `]`, then `dispatchEnd = cursor` (after non-whitespace scan), whitespace skip is a no-op, `bodyStart = cursor`, body scan finds `]` immediately so `bodyEnd = cursor = bodyStart`. This results in an empty body, which is valid -- the body may be empty.

### Edge case: body is all whitespace before `]`

The body scan does NOT strip trailing whitespace. If the input is `[dispatch  foo  ]`, the body is `  foo  ` (with trailing spaces). The NatSpec at line 32 documents this: "trailing whitespace... will be treated as part of the body." This is by design.

### Custom errors

No string reverts. `UnclosedSubParseableLiteral` and `SubParseableMissingDispatch` are custom errors.

---

## Findings

No LOW+ findings.

The parsing logic is straightforward with proper bounds checking. The cursor always advances forward, preventing infinite loops. The delegation to `state.subParseLiteral` is where the actual sub-parser external call occurs (analyzed in `LibSubParse.sol`). The byte-level scanning limitation with multibyte encodings is correctly documented.
