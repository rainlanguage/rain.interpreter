# Pass 1 (Security) -- LibParseLiteralRepeat.sol (A23)

**File:** `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol`

## Evidence

### Library
- `LibParseLiteralRepeat` (line 45)

### Constants
- `MAX_REPEAT_LITERAL_LENGTH = 78` (line 34) -- maximum body length (exclusive)

### Custom Errors
- `RepeatLiteralTooLong(uint256 length)` (line 39)
- `RepeatDispatchNotDigit(uint256 dispatchValue)` (line 43)

### Functions
- `parseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end) returns (uint256)` -- line 53, `internal pure`

## Security Review

### Overflow safety in `unchecked` block (lines 57-71)
The entire loop runs in `unchecked`. Overflow safety depends on the length check at line 61: `length >= MAX_REPEAT_LITERAL_LENGTH` (78) reverts, so `length <= 77`. The worst-case accumulation is `9 * (10^0 + 10^1 + ... + 10^76) = 10^77 - 1`, which is less than `2^256 - 1` (`~1.16e77`). This is correct and well-documented.

### Input validation
- `dispatchValue > 9` reverts with `RepeatDispatchNotDigit` (line 54-56). Correct.
- `length >= 78` reverts with `RepeatLiteralTooLong` (line 61-63). Correct.

### Pointer arithmetic (`end - cursor`)
The subtraction `end - cursor` at line 60 is in `unchecked`, so a `cursor > end` would produce an extremely large length. However, the function is `internal pure` and only called from the extern's `matchSubParseLiteralDispatch` which receives cursor/end from the parser infrastructure. The parser guarantees `cursor <= end`. If this invariant were violated, the length check at line 61 would still catch any pathological value (it would be enormous, far exceeding 78).

### No assembly
No assembly blocks. No memory safety concerns.

## Findings

No security findings.
