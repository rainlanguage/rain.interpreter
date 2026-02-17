# Pass 2 — Test Coverage: LibParseStackTracker

**Source:** `src/lib/parse/LibParseStackTracker.sol`
**Tests:** None (no direct test file exists)

## Source Inventory

### Functions

| Function | Line | Visibility |
|---|---|---|
| `pushInputs(ParseStackTracker, uint256)` | 19 | internal pure |
| `push(ParseStackTracker, uint256)` | 41 | internal pure |
| `pop(ParseStackTracker, uint256)` | 68 | internal pure |

### Errors Used

| Error | Used In |
|---|---|
| `ParseStackOverflow()` | `pushInputs` (line 25), `push` (line 48) |
| `ParseStackUnderflow()` | `pop` (line 72) |

### Key Internals

- `ParseStackTracker` is a `uint256` user-defined value type packing three fields:
  - bits [7:0]: current stack height
  - bits [15:8]: inputs count
  - bits [255:16]: high watermark (max height reached)
- `push` updates current and max; uses unchecked add safe only when `n <= 0xFF`
- `pop` subtracts `n` directly from the packed word (safe because `n <= current <= 0xFF`)
- `pushInputs` calls `push` then separately increments the inputs byte

## Test Coverage Analysis

### Direct Tests

**No direct test file exists.** Glob for `test/src/lib/parse/LibParseStackTracker*.t.sol` returned no results.

### Indirect Coverage

- Grep for `ParseStackTracker`, `pushInputs`, `push(`, `pop(` across `test/` returned no direct references.
- Grep for `ParseStackOverflow` and `ParseStackUnderflow` across `test/` returned no results.
- The functions are called indirectly through `LibParseState.endLine()` (lines 426, 467, 475) and `LibParseState.endSource()` (line 767), which are exercised by the full parser integration tests.
- However, no test specifically targets the tracker's overflow/underflow revert paths.

## Findings

### A42-1: No direct unit tests for any function (CRITICAL)

`LibParseStackTracker` has zero dedicated test coverage. All three public functions (`pushInputs`, `push`, `pop`) lack direct unit tests. This is a security-relevant library that tracks stack height for integrity checking. Incorrect behavior would silently produce invalid bytecode.

**Evidence:** No file matching `test/src/lib/parse/LibParseStackTracker*.t.sol` exists. No grep hits for the type or function names in any test file.

### A42-2: ParseStackOverflow in push() never tested (HIGH)

The `push` function reverts with `ParseStackOverflow` when `current + n > 0xFF` (line 47-49). No test triggers this revert. The overflow guard protects against corrupting the packed representation -- if it were missing, `current` could wrap into the `inputs` byte.

**Evidence:** Grep for `ParseStackOverflow` across `test/` returns no results.

### A42-3: ParseStackUnderflow in pop() never tested (HIGH)

The `pop` function reverts with `ParseStackUnderflow` when `current < n` (line 71-73). No test triggers this revert. A missing underflow check would cause the subtraction to borrow into the `inputs` byte, corrupting tracker state.

**Evidence:** Grep for `ParseStackUnderflow` across `test/` returns no results.

### A42-4: ParseStackOverflow in pushInputs() never tested (HIGH)

The `pushInputs` function reverts with `ParseStackOverflow` when the inputs byte exceeds `0xFF` (line 24-26). No test triggers this revert. This is distinct from the overflow in `push` -- it guards the inputs counter specifically.

**Evidence:** Same grep as A42-2.

### A42-5: High watermark update logic not tested (MEDIUM)

The `push` function updates `max` when `current > max` (line 50-52). No test verifies that the watermark is correctly maintained across push/pop sequences (e.g., push 5, pop 3, push 2 should keep max at 5).

**Evidence:** No direct tests exist for any aspect of the tracker.

### A42-6: Packed representation correctness not tested (MEDIUM)

The three-field packing (current | inputs << 8 | max << 16) is never verified in isolation. A test should confirm that after a sequence of operations, unpacking the tracker yields the expected current, inputs, and max values.

**Evidence:** No direct tests exist.
