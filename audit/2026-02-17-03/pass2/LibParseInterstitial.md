# Pass 2: Test Coverage -- LibParseInterstitial

## Source File
`src/lib/parse/LibParseInterstitial.sol`

## Evidence of Thorough Reading

**Library:** `LibParseInterstitial`

**Functions:**
- `skipComment(ParseState memory state, uint256 cursor, uint256 end) -> uint256` (line 28)
- `skipWhitespace(ParseState memory state, uint256 cursor, uint256 end) -> uint256` (line 96)
- `parseInterstitial(ParseState memory state, uint256 cursor, uint256 end) -> uint256` (line 111)

**Errors used:**
- `MalformedCommentStart` (from `ErrParse.sol`, line 49)
- `UnclosedComment` (from `ErrParse.sol`, lines 40, 83)

**Assembly blocks:**
- Line 45-47: Reads 2-byte start sequence from cursor via `shr(0xf0, mload(cursor))`
- Line 60-62: Reads single byte at cursor via `byte(0, mload(cursor))`
- Line 67-69: Reads 2-byte end sequence from `cursor-1` via `shr(0xf0, mload(sub(cursor, 1)))`
- Line 114-117: Reads single byte for interstitial dispatch via `shl(byte(0, mload(cursor)), 1)`

**Key behaviors:**
- `skipComment` sets `FSM_YANG_MASK` to force whitespace after comments
- `skipComment` skips 3 chars after `/*` before checking for `*/` (prevents `/*/` matching)
- `skipWhitespace` clears `FSM_YANG_MASK` (yin state)
- `parseInterstitial` loops dispatching between whitespace and comment skipping

## Test Coverage Analysis

**Direct test files:** None. No `test/src/lib/parse/LibParseInterstitial*.t.sol` files exist.

**Indirect coverage search:**
- Grep for `skipComment`, `skipWhitespace`, `parseInterstitial` across `test/` -- no results.
- Grep for `LibParseInterstitial` across `test/` -- no results.

**Indirect coverage via integration tests:**
- `test/src/lib/parse/LibParse.comments.t.sol` exercises `skipComment` through the full parser:
  - `testParseCommentNoWords` -- basic comment
  - `testParseCommentSingleWord` -- comment with trailing content
  - `testParseCommentSingleWordSameLine` -- comment on same line
  - `testParseCommentBetweenSources` -- interstitial comment
  - `testParseCommentAfterSources` -- trailing comment
  - `testParseCommentMultiple` -- multiple consecutive comments
  - `testParseCommentManyAstericks` -- extra leading `*`
  - `testParseCommentManyAstericksTrailing` -- extra trailing `*`
  - `testParseCommentLong` -- multiline comment
  - `testParseCommentNoTrailingWhitespace` -- yang enforcement
  - `testParseCommentUnclosed` -- unclosed comment error
  - `testParseCommentUnclosed2` -- partial end sequence
  - Tests for comments in disallowed positions (LHS, RHS)

## Findings

### A32-1 No direct unit tests for `skipComment`, `skipWhitespace`, or `parseInterstitial`
**Severity:** LOW

All three functions in `LibParseInterstitial` lack direct unit tests. They are only tested indirectly through `LibParse.comments.t.sol` integration tests. Unit tests would allow precise validation of:
- Cursor position after skipping
- FSM state changes (yang mask set/cleared)
- Boundary behavior when cursor equals end

### A32-2 `MalformedCommentStart` error path is never tested
**Severity:** MEDIUM

The `MalformedCommentStart` revert (line 49) is triggered when the comment head character is `/` but the following character is not `*` (i.e., the two bytes starting at cursor do not form `/*`). Grep for `MalformedCommentStart` across `test/` finds zero matches. No integration test triggers this path. This is a revert path in assembly-adjacent code with no test verifying it fires correctly.

Note: This path may be difficult to reach through the full parser because `parseInterstitial` dispatches to `skipComment` based on `CMASK_COMMENT_HEAD`, which matches `/`. A standalone `/` followed by a non-`*` character would trigger this error. The full parser may route this character differently before reaching `skipComment`, but the error exists as a defensive check and should still be tested.

### A32-3 No test for `skipComment` when `cursor + 4 > end` (too-short comment)
**Severity:** LOW

The `UnclosedComment` revert at line 40 fires when there are fewer than 4 bytes remaining. The integration test `testParseCommentUnclosed` tests an unclosed comment that is long enough (19 bytes) -- it hits the `!foundEnd` path at line 82, not the `cursor + 4 > end` check at line 39. The short-data path (e.g., just `/*` with nothing after) is not directly tested.

### A32-4 No test for `skipWhitespace` in isolation
**Severity:** LOW

`skipWhitespace` delegates to `LibParseChar.skipMask` and clears the yang mask. While whitespace is implicitly tested everywhere the parser processes source code, there is no test verifying:
- That the FSM yang mask is correctly cleared
- Correct cursor advancement over various whitespace characters (space, tab, newline, carriage return)
- Behavior when cursor equals end (empty whitespace)

### A32-5 No test for `parseInterstitial` loop with mixed whitespace and comments
**Severity:** INFO

The `parseInterstitial` function loops over alternating whitespace and comment sequences. While `testParseCommentMultiple` tests consecutive comments (which implicitly includes whitespace between them), there is no test that verifies the exact cursor position after processing mixed interstitial sequences, or that confirms the function terminates correctly on the first non-interstitial character.
