# Pass 2 (Test Coverage) -- LibParseLiteralSubParseable.sol

## Evidence of Thorough Reading

### Source File: `src/lib/parse/literal/LibParseLiteralSubParseable.sol`

**Library name:** `LibParseLiteralSubParseable`

**Functions:**

| Function | Line |
|---|---|
| `parseSubParseable(ParseState memory state, uint256 cursor, uint256 end) -> (uint256, bytes32)` | 30 |

**Errors used (imported from `src/error/ErrParse.sol`):**

| Error | Source Line | Usage Line(s) |
|---|---|---|
| `UnclosedSubParseableLiteral(uint256 offset)` | ErrParse.sol:133 | 64, 73 |
| `SubParseableMissingDispatch(uint256 offset)` | ErrParse.sol:136 | 48 |

**Other imports used:**
- `LibParseChar.skipMask` -- lines 44, 60 (skip dispatch chars, skip body chars)
- `CMASK_WHITESPACE` -- line 44, 52 (dispatch termination, whitespace skipping)
- `CMASK_SUB_PARSEABLE_LITERAL_END` -- lines 44, 60, 72 (bracket detection)
- `LibParseInterstitial.skipWhitespace` -- line 52
- `LibSubParse.subParseLiteral` -- line 80 (delegate to sub parser)

**Code path analysis of `parseSubParseable` (line 30-82):**

1. Line 39: Increment cursor past opening `[`
2. Lines 41-45: Skip non-whitespace, non-bracket chars to find dispatch end
3. Lines 47-49: If dispatch is empty, revert `SubParseableMissingDispatch`
4. Line 52: Skip whitespace between dispatch and body
5. Lines 54-61: Skip all chars until closing `]` or end
6. Lines 63-65: If `cursor >= end`, revert `UnclosedSubParseableLiteral`
7. Lines 66-75: Check final char is actually `]`; if not, revert `UnclosedSubParseableLiteral`
8. Line 78: Increment cursor past closing `]`
9. Line 80: Delegate to `state.subParseLiteral` with dispatch and body bounds

### Test File: `test/src/lib/parse/literal/LibParseLiteralSubParseable.parseSubParseable.t.sol`

**Contract name:** `LibParseLiteralSubParseableTest`

**Functions:**

| Function | Line |
|---|---|
| `checkParseSubParseable(string, string, string, uint256, bytes)` (public) | 20 |
| `checkParseSubParseable(string, string, string, uint256)` (internal, overload) | 48 |
| `checkParseSubParseableError(string, bytes)` (internal) | 57 |
| `testParseLiteralSubParseableUnclosedDispatch0()` | 63 |
| `testParseLiteralSubParseableUnclosedDispatchWhitespace1()` | 68 |
| `testParseLiteralSubParseableUnclosedDispatchWhitespace0()` | 73 |
| `testParseLiteralSubParseableUnclosedDispatchBody()` | 79 |
| `testParseLiteralSubParseableUnclosedDoubleOpen()` | 84 |
| `testParseLiteralSubParseableMissingDispatchEmpty()` | 89 |
| `testParseLiteralSubParseableMissingDispatchUnclosed()` | 94 |
| `testParseLiteralSubParseableMissingDispatchUnclosedWhitespace0()` | 99 |
| `testParseLiteralSubParseableMissingDispatchUnclosedWhitespace1()` | 104 |
| `testParseLiteralSubParseableEmptyBody()` | 109 |
| `testParseLiteralSubParseableBody()` | 116 |
| `testParseLiteralSubParseableHappyFuzz(string, string, string)` | 131 |
| `parseSubParseableBracketPastEnd(bytes)` (external helper) | 170 |
| `testParseLiteralSubParseableUnclosedBracketPastEnd()` | 184 |
| `testParseLiteralSubParseableHappyKnown()` | 189 |

## Coverage Analysis

### `parseSubParseable` coverage

| Code Path / Condition | Covered? | Test(s) |
|---|---|---|
| Happy path: dispatch only, no body `[pi]` | Yes | `testParseLiteralSubParseableEmptyBody` |
| Happy path: dispatch with trailing whitespace `[pi ]` | Yes | `testParseLiteralSubParseableEmptyBody` |
| Happy path: dispatch + body `[hi a]` | Yes | `testParseLiteralSubParseableBody` |
| Happy path: multiple whitespace between dispatch and body | Yes | `testParseLiteralSubParseableBody` |
| Happy path: newline as whitespace delimiter | Yes | `testParseLiteralSubParseableBody` |
| Happy path: nested bracket in dispatch `[[pi...]` | Yes | `testParseLiteralSubParseableBody` (line 127) |
| Happy path: fuzz with arbitrary valid dispatch/whitespace/body | Yes | `testParseLiteralSubParseableHappyFuzz` |
| Revert `SubParseableMissingDispatch`: empty brackets `[]` | Yes | `testParseLiteralSubParseableMissingDispatchEmpty` |
| Revert `SubParseableMissingDispatch`: leading whitespace `[ a` | Yes | `testParseLiteralSubParseableUnclosedDispatchWhitespace1` |
| Revert `SubParseableMissingDispatch`: unclosed empty `[` | Yes | `testParseLiteralSubParseableMissingDispatchUnclosed` |
| Revert `SubParseableMissingDispatch`: unclosed whitespace `[ ` | Yes | `testParseLiteralSubParseableMissingDispatchUnclosedWhitespace0` |
| Revert `SubParseableMissingDispatch`: unclosed whitespace `[  ` | Yes | `testParseLiteralSubParseableMissingDispatchUnclosedWhitespace1` |
| Revert `UnclosedSubParseableLiteral`: `cursor >= end` path (line 63-65) | Yes | `testParseLiteralSubParseableUnclosedDispatch0`, `testParseLiteralSubParseableUnclosedDispatchWhitespace0`, `testParseLiteralSubParseableUnclosedDispatchBody` |
| Revert `UnclosedSubParseableLiteral`: final char not `]` (line 72-74) | Yes | `testParseLiteralSubParseableUnclosedDoubleOpen` |
| Revert `UnclosedSubParseableLiteral`: `]` past logical end | Yes | `testParseLiteralSubParseableUnclosedBracketPastEnd` |
| `subParseLiteral` delegation (line 80) | Yes | All happy-path tests mock `ISubParserV4.subParseLiteral2` |

## Findings

### A38-1: No test for `subParseLiteral` returning `(false, ...)` (sub-parser rejection)

**Severity:** MEDIUM

**Description:** All happy-path tests mock `ISubParserV4.subParseLiteral2` to return `(true, returnValue)`. There is no test that exercises the case where the sub-parser returns `(false, ...)`, which according to the `LibSubParse.subParseLiteral` implementation would cause the parser to try the next sub-parser or revert. This is a meaningful code path for error handling -- if no sub-parser accepts the literal, the system should revert with an appropriate error. While this behavior lives in `LibSubParse` rather than `LibParseLiteralSubParseable` directly, the integration between `parseSubParseable` and `subParseLiteral` is untested for the rejection case.

### A38-2: No fuzz test for the error paths

**Severity:** LOW

**Description:** All error-path tests use hardcoded concrete inputs (`"[a"`, `"[ a"`, `"[a "`, `"[a b"`, `"[["`, `"[]"`, `"["`, `"[ "`, `"[  "`). While the happy path has thorough fuzz coverage via `testParseLiteralSubParseableHappyFuzz`, the error paths are only tested with a small set of specific strings. A fuzz test that generates strings without a closing `]` (or with the closing `]` truncated from `end`) would provide broader confidence that all `UnclosedSubParseableLiteral` revert conditions are hit correctly for arbitrary input content.

### A38-3: No test for non-ASCII characters in dispatch or body

**Severity:** INFO

**Description:** The NatSpec at lines 57-59 documents: "Note that as multibyte is not supported, and the mask is 128 bits, non-ascii chars MAY either fail to be skipped or will be treated as a closing bracket." This behavior is not tested. No test provides a dispatch or body containing bytes with values >= 128 to verify the documented behavior. The fuzz test `testParseLiteralSubParseableHappyFuzz` uses `conformStringToMask` which constrains inputs to the valid ASCII mask, so non-ASCII bytes are never generated. A test demonstrating the documented behavior for non-ASCII input would confirm the code matches the documentation.

### A38-4: No test for dispatch containing a `[` character

**Severity:** INFO

**Description:** The `skipMask` at line 44 uses `~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_END)` to find the dispatch end, which means `[` (an opening bracket) is treated as a dispatch-terminating character. The test at line 127 (`"[[pi\n\n\n\na]"`) covers the case where `[` is the first character after the opening bracket (making it part of the dispatch `[pi`), but this works because the first `[` is skipped at line 39 and the second `[` is the start of the dispatch. The `conformStringToMask` in the fuzz test also excludes `CMASK_SUB_PARSEABLE_LITERAL_END` from dispatches, so dispatches containing `]` are never fuzzed. While `]` in the dispatch would cause early termination (tested implicitly), an explicit test demonstrating that `]` inside a dispatch position terminates the dispatch correctly would improve clarity.
