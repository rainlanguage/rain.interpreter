# Pass 1 (Security) -- LibParseLiteralRepeat.sol

## Evidence of Thorough Reading

**File:** `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol` (57 lines)

**Library:** `LibParseLiteralRepeat` (line 39)

**Functions:**

| Function | Line | Visibility |
|----------|------|------------|
| `parseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end)` | 41 | internal pure |

**Errors (file-level):**

| Error | Line |
|-------|------|
| `RepeatLiteralTooLong(uint256 length)` | 33 |
| `RepeatDispatchNotDigit(uint256 dispatchValue)` | 37 |

**Events/Structs:** None.

## Context

This library is a reference/demo literal parser for the extern sub-parser system. It is called from `BaseRainterpreterSubParser.subParseLiteral2` via function pointer dispatch. The `dispatchValue` parameter receives a packed `Float` (decimal float) which, for valid inputs (digits 0-9 with exponent 0), happens to equal the raw integer 0-9. The `cursor` and `end` parameters define the body of the literal in memory but the function only uses their difference (length), never reading the body content.

## Findings

### INFO-1: Custom errors defined in library file rather than `src/error/`

**Severity:** INFO

The errors `RepeatLiteralTooLong` and `RepeatDispatchNotDigit` are defined at file scope in `LibParseLiteralRepeat.sol` (lines 33, 37) rather than in a dedicated file under `src/error/`. The audit instructions note that custom errors should be defined in `src/error/`. However, this is a reference/example extern library and the same pattern is used in `RainterpreterReferenceExtern.sol` (line 74, `InvalidRepeatCount`), suggesting reference extern code follows a different convention from the core interpreter. No functional impact.

### INFO-2: No guard against `cursor > end` underflow

**Severity:** INFO

At line 47 inside an `unchecked` block, `uint256 length = end - cursor` would underflow to a very large value if `cursor > end`. This would then be caught by the `length >= 78` check on line 48, so it is not exploitable. However, the revert message would be `RepeatLiteralTooLong` with a misleading length value rather than a more descriptive error.

In practice, the callers (`BaseRainterpreterSubParser.subParseLiteral2` via `consumeSubParseLiteralInputData`) guarantee `bodyStart <= bodyEnd` because `bodyEnd - bodyStart` equals the body length encoded in the input data. The body bounds are derived from parsed input structure where `bodyEnd = data + 0x20 + len(data)` and `bodyStart = dispatchStart + dispatchLength`, ensuring `bodyStart <= bodyEnd` by construction. No exploitable path exists.

### INFO-3: `dispatchValue` validation relies on packed float encoding coincidence

**Severity:** INFO

The `dispatchValue > 9` check on line 42 works correctly because the caller (`matchSubParseLiteralDispatch` in `RainterpreterReferenceExtern`) validates the dispatch is a single integer digit 0-9 and returns it via `packLossless(n, 0)`. For these values, the packed float representation equals the raw integer (coefficient in low 224 bits, exponent 0 shifted to high 32 bits yields 0). If a different caller were to pass a packed float with a non-zero exponent (e.g., `packLossless(1, 1)` representing 10), the raw `bytes32` would be `0x0000000100000000...0001` which is much larger than 9 and would be correctly rejected.

The function is `internal pure` and only callable from within the same contract's code, so the trust boundary is appropriate. However, the parameter name `dispatchValue` and the `> 9` check give no indication that the value is expected to be a packed float, which could be confusing for future extern implementers who use this as a reference.

### LOW-1: Unchecked arithmetic is safe but merits explicit documentation

**Severity:** LOW

The entire function body (lines 45-55) is wrapped in `unchecked`. The arithmetic is safe:

1. **`end - cursor` (line 47):** Cannot underflow in practice (see INFO-2). Even if it did, caught by line 48.
2. **`10 ** i` (line 52):** `i` ranges from 0 to at most 76 (since `length < 78`). `10^76 < 2^256`. Safe.
3. **`dispatchValue * 10 ** i` (line 52):** Max is `9 * 10^76 < 2^256`. Safe.
4. **`value += ...` (line 52):** The accumulated sum is at most `9 * (10^0 + 10^1 + ... + 10^76) = 10^77 - 1 < 2^256`. Safe.

The bound of 78 is correctly chosen: `10^77 < 2^256 < 10^78`. The accumulation sum cannot exceed `10^77 - 1`. All arithmetic is safe.

While correct, the `unchecked` block covers 10 lines including the subtraction on line 47. A comment documenting why each operation is safe would help reviewers, especially since this is meant as a reference implementation.

## Summary

No CRITICAL, HIGH, or MEDIUM findings. This is a small, well-bounded reference library with correct overflow protection. The `unchecked` arithmetic is safe due to the `length >= 78` guard and the `dispatchValue <= 9` constraint. The function uses custom errors (not string reverts) and contains no assembly blocks. The main observations are stylistic: error placement conventions and documentation of safety invariants.
