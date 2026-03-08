# Pass 5 -- Opcode referenceFn Correctness (Agent A03)

Scope: Verify that `referenceFn` implementations correctly implement the claimed
mathematical/logical operations, that `run()` assembly matches `referenceFn`,
that integrity declarations match actual stack behavior, and that operand bit
layouts are correct.

## Files Reviewed

1. `src/lib/op/math/LibOpAdd.sol`
2. `src/lib/op/math/LibOpSub.sol`
3. `src/lib/op/math/LibOpMul.sol`
4. `src/lib/op/math/LibOpDiv.sol`
5. `src/lib/op/math/LibOpPower.sol`
6. `src/lib/op/math/LibOpSqrt.sol`
7. `src/lib/op/math/LibOpAvg.sol`
8. `src/lib/op/math/LibOpGm.sol`
9. `src/lib/op/math/growth/LibOpExponentialGrowth.sol`
10. `src/lib/op/math/growth/LibOpLinearGrowth.sol`
11. `src/lib/op/logic/LibOpConditions.sol`
12. `src/lib/op/logic/LibOpEnsure.sol`
13. `src/lib/op/bitwise/LibOpBitwiseDecode.sol`
14. `src/lib/op/bitwise/LibOpBitwiseEncode.sol`
15. `src/lib/op/store/LibOpGet.sol`
16. `src/lib/op/store/LibOpSet.sol`

## Analysis

### 1. Mathematical Correctness of referenceFn

| Opcode | Claimed operation | referenceFn implementation | Correct? |
|--------|------------------|---------------------------|----------|
| add | a + b + c + ... | `LibDecimalFloatImplementation.add` accumulated left-to-right | Yes |
| sub | a - b - c - ... | `LibDecimalFloatImplementation.sub` accumulated left-to-right | Yes |
| mul | a * b * c * ... | `LibDecimalFloatImplementation.mul` accumulated left-to-right | Yes |
| div | a / b / c / ... | `LibDecimalFloatImplementation.div` accumulated left-to-right | Yes (see INFO-1) |
| pow | a^b | `a.pow(b, ...)` | Yes |
| sqrt | sqrt(a) | `a.sqrt(...)` | Yes |
| avg | (a + b) / 2 | `a.add(b).div(FLOAT_TWO)` | Yes |
| gm | sign * sqrt(\|a\| * \|b\|) | `a.abs().mul(b.abs()).pow(FLOAT_HALF, ...)` with sign correction | Yes |
| exponential-growth | base * (1 + rate)^t | `base.mul(rate.add(FLOAT_ONE).pow(t, ...))` | Yes |
| linear-growth | base + rate * t | `base.add(rate.mul(t))` | Yes |
| conditions | first nonzero condition's value | Iterates pairs, returns first nonzero match or reverts | Yes |
| ensure | revert if zero | Checks condition, reverts if zero with reason string | Yes |
| decode-bits | extract bits [start, start+len) | `(value >> startBit) & ((2**length) - 1)` | Yes |
| encode-bits | insert bits [start, start+len) | Clear-and-set bitmask pattern | Yes |
| get | read key from store | Cache-miss falls through to external store | Yes |
| set | write key-value to store | Writes to in-memory KV for later flush | Yes |

### 2. run() vs referenceFn Consistency

All `run()` implementations use the same underlying library functions as their
corresponding `referenceFn`, ensuring algorithmic equivalence:

- **N-ary ops (add, sub, mul, div):** Both `run()` and `referenceFn` use the
  same `LibDecimalFloatImplementation` function in a left-to-right accumulation
  loop, with `packLossy` at the end.
- **Fixed-arity math ops (pow, sqrt, avg, gm, growth ops):** Both call the
  same `LibDecimalFloat` high-level methods with identical argument ordering.
- **Logic ops (conditions, ensure):** Both implement the same
  condition-checking logic with `Float.isZero()` and `IntOrAString.toStringV3()`.
- **Bitwise ops (decode, encode):** Both use the same mask computation and
  bit-shift logic. `run()` uses `1 << length` (in unchecked/assembly) while
  `referenceFn` uses `2 ** length`; these are equivalent for the valid range
  1..255 enforced by integrity.
- **Store ops (get, set):** Both use `LibMemoryKV` with identical
  cache-miss/hit logic.

### 3. Integrity Declarations vs Actual Stack Behavior

| Opcode | integrity (inputs, outputs) | run() stack delta | Match? |
|--------|---------------------------|-------------------|--------|
| add | (max(operand, 2), 1) | Reads 2 + (operand-2) extra, writes 1 | Yes |
| sub | (max(operand, 2), 1) | Reads 2 + (operand-2) extra, writes 1 | Yes |
| mul | (max(operand, 2), 1) | Reads 2 + (operand-2) extra, writes 1 | Yes |
| div | (max(operand, 2), 1) | Reads 2 + (operand-2) extra, writes 1 | Yes |
| pow | (2, 1) | Reads 2, writes 1 at stackTop+0x20 | Yes |
| sqrt | (1, 1) | Reads 1, writes 1 in-place | Yes |
| avg | (2, 1) | Reads 2, writes 1 at stackTop+0x20 | Yes |
| gm | (2, 1) | Reads 2, writes 1 at stackTop+0x20 | Yes |
| exponential-growth | (3, 1) | Reads 3, writes 1 at stackTop+0x40 | Yes |
| linear-growth | (3, 1) | Reads 3, writes 1 at stackTop+0x40 | Yes |
| conditions | (max(operand, 2), 1) | Reads operand items, writes 1 | Yes |
| ensure | (2, 0) | Reads 2, writes 0 | Yes |
| decode-bits | (1, 1) | Reads 1, writes 1 in-place | Yes |
| encode-bits | (2, 1) | Reads 2, writes 1 at stackTop+0x20 | Yes |
| get | (1, 1) | Reads 1, writes 1 in-place | Yes |
| set | (2, 0) | Reads 2, writes 0 | Yes |

### 4. Operand Bit Layouts

- **N-ary ops (add, sub, mul, div):** `(operand >> 0x10) & 0x0F` -- bits
  [16:19] encode input count. Consistent between `integrity()` and `run()`.
- **conditions:** Same layout `(operand >> 0x10) & 0x0F` -- bits [16:19]
  encode input count. Consistent between `integrity()` and `run()`.
- **Bitwise ops:** `operand & 0xFF` for startBit (bits [0:7]),
  `(operand >> 8) & 0xFF` for length (bits [8:15]). Consistent between
  `integrity()`, `run()`, and `referenceFn()`.
- **All other ops:** Do not use the operand (ignored). Correct.

## Findings

### INFO-1: LibOpDiv.referenceFn sentinel value is overwritten by packLossy

**File:** `src/lib/op/math/LibOpDiv.sol`, lines 92-101

**Description:** When the `referenceFn` encounters a zero divisor, it sets `a`
to a collision-resistant sentinel value and breaks out of the loop (line 93).
However, after the loop, line 101 unconditionally overwrites `a` with
`LibDecimalFloat.packLossy(signedCoefficient, exponent)`, where
`signedCoefficient` and `exponent` still hold the result from before the zero
was encountered (or the initial numerator if the first divisor is zero). The
sentinel value is lost.

**Impact:** Informational. The sentinel's purpose is to ensure that if `run()`
fails to revert on divide-by-zero, the test comparison would catch the
discrepancy. Since the sentinel is overwritten, if `run()` returned the
partially-computed quotient instead of reverting, `referenceFn` would return the
same value, and the fuzz test would not detect the bug. In practice,
`LibDecimalFloatImplementation.div` does revert on zero division, so the test
never reaches the comparison step -- the entire external call reverts and the
test passes via `vm.expectRevert()`. This is a latent test weakness, not a
runtime issue.

**Severity:** Informational

## Conclusion

All 16 opcode implementations are mathematically correct. The `referenceFn`
functions match their `run()` counterparts in algorithm and result. Integrity
declarations accurately reflect actual stack consumption and production. Operand
bit layouts are consistent across `integrity()`, `run()`, and `referenceFn()`.

One informational finding (INFO-1) identifies a latent test weakness in
`LibOpDiv.referenceFn` where a sentinel value is overwritten. No LOW or higher
findings.
