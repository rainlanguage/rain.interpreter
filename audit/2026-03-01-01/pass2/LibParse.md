# Pass 2: Test Coverage — LibParse, LibParseState

**Audit:** 2026-03-01-01
**Agent IDs:** A30, A43

## Findings

### A30-P2-1 (MEDIUM) No test for total source ops count > 255 across multiple top-level items (A30)

Related to Pass 1 finding A43-1. The source code in `endSource()` at lines 871-878 writes the total ops count into a single byte of the source prefix. If the total across all top-level items exceeds 255, the shifted value overflows bit 31 and corrupts the source length word. `LibBytecode.sourceOpsCount` reads only 1 byte (`byte(0, mload(pointer))`), so the count is silently truncated.

**Test gap**: No test constructs a source with more than 255 total ops across multiple top-level items. Existing tests only cover the per-item limit:
- `testSourceItemOps255NoOverflow` / `testSourceItemOpsOverflow` in `overflow.t.sol` — per-item counter only
- `testPushOpToSourceItemOpsOverflow` in `pushOpToSource.t.sol` — per-item counter only
- `testBuildBytecodeFuzz` caps at 20 ops total per source
- `testEndSourceByteLengthFuzz` caps at 50 ops total per source

With 2 top-level items of 128 ops each, the per-item counter never overflows (each stays at 128), but the total is 256 — overflowing the prefix byte.

### A30-P2-2 (LOW) No test for `ParserOutOfBounds` error in `parse()` (A30)

The `ParserOutOfBounds` error at line 438 in `LibParse.sol` guards against `cursor != end` after the main parse loop. No test triggers this error. This is likely unreachable defensive code (all character-reading paths check `cursor < end`), but defensive code deserves a test documenting the invariant.

### A30-P2-3 (LOW) `testEndSourceByteLengthFuzz` upper bound too low (A30)

The fuzz test in `LibParseState.endSource.t.sol` (line 104) bounds `opCount` to `[1, 50]`. This misses multi-slot linked-list edge cases beyond 49 ops (7 ops per slot = 7+ slot transitions) and does not approach the 255 ops prefix limit. Should be extended to at least 200.

### A30-P2-4 (INFO) No integration test for stack-name-only RHS with paren state

Stack name references work correctly inside paren groups (tested indirectly via `testParseNamedLHSStackIndex`), but no test explicitly verifies the `highwater()` call path when a stack name appears as a paren input. Low impact — the code path is covered indirectly.
