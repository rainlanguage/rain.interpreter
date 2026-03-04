# Pass 2: Test Coverage — Parse Utilities and Literals

**Audit:** 2026-03-01-01
**Agent IDs:** A32, A42, A44

## Findings

### A32-1 (LOW) `skipComment` — no test for `UnclosedComment` when comment is well-formed but never closed (A32)

Source: `src/lib/parse/LibParseInterstitial.sol`, line 83.

`skipComment` has two distinct revert paths for `UnclosedComment`:
1. Line 40: `cursor + 4 > end` — the comment cannot fit. Tested by `testSkipCommentTooShort` and `testSkipCommentThreeBytes`.
2. Line 83: `!foundEnd` — the `/*` is well-formed, data >= 4 bytes, but `*/` is never found. **Not tested.**

The existing tests cover the "too short" path (< 4 bytes). There is no test with data like `"/* no end here"` where the comment opens validly but never closes.

### A32-2 (LOW) `skipComment` — no fuzz test for well-formed comments (A32)

Source: `src/lib/parse/LibParseInterstitial.sol`, lines 58-79.

All `skipComment` tests use hardcoded strings (`"/**/"`, `"/* hello world */"`). No fuzz test generates arbitrary comment content to verify the cursor lands correctly. A fuzz test would exercise the byte-scanning loop with diverse content including `*` characters inside comments that don't form `*/`.

### A42-1 (LOW) `pushInputs` — no test for push-overflow-inside-pushInputs (A42)

Source: `src/lib/parse/LibParseStackTracker.sol`, line 21.

`pushInputs` calls `push(n)` internally, which can revert with `ParseStackOverflow` if `current + n > 0xFF`. The test `testPushInputsOverflow` only tests the `inputs` field overflow (line 24), setting up the tracker with `current = 0`. No test exercises the case where `push(n)` overflows because `current` is already non-zero (e.g., `current=200`, `pushInputs(100)` should revert from the inner `push`).

### A44-1 (LOW) `subParseWordSlice` — no test for no-sub-parsers-registered path (A44)

Source: `src/lib/parse/LibSubParse.sol`, line 224.

`subParseWordSlice` iterates over sub parsers in `while (deref != 0)` at line 224. If `state.subParsers` is zero, the loop body never executes and the code falls through to `UnknownWord` revert. All existing unknown-word tests register at least one sub parser. No test covers an `OPCODE_UNKNOWN` opcode with zero registered sub parsers.
