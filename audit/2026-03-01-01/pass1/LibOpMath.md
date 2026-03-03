# Pass 1 (Security) -- Math Opcodes

**Auditors**: A24 (decimal float math), A29 (growth/uint256 math)
**Date**: 2026-03-01
**Scope**: All math opcode libraries in `src/lib/op/math/`, `src/lib/op/math/growth/`, `src/lib/op/math/uint256/`

---

## Evidence of Thorough Reading

### Decimal Float Math (`src/lib/op/math/`)

| Library | Functions (line numbers) | Lines |
|---|---|---|
| `LibOpAbs` | `integrity` (19), `run` (28), `referenceFn` (44) | 53 |
| `LibOpAdd` | `integrity` (22), `run` (33), `referenceFn` (76) | 98 |
| `LibOpAvg` | `integrity` (19), `run` (28), `referenceFn` (47) | 61 |
| `LibOpCeil` | `integrity` (19), `run` (28), `referenceFn` (44) | 55 |
| `LibOpDiv` | `integrity` (21), `run` (33), `referenceFn` (74) | 107 |
| `LibOpE` | `integrity` (17), `run` (24), `referenceFn` (35) | 44 |
| `LibOpExp` | `integrity` (19), `run` (28), `referenceFn` (44) | 56 |
| `LibOpExp2` | `integrity` (19), `run` (28), `referenceFn` (45) | 57 |
| `LibOpFloor` | `integrity` (19), `run` (28), `referenceFn` (44) | 53 |
| `LibOpFrac` | `integrity` (19), `run` (28), `referenceFn` (44) | 53 |
| `LibOpGm` | `integrity` (21), `run` (31), `referenceFn` (55) | 74 |
| `LibOpHeadroom` | `integrity` (20), `run` (30), `referenceFn` (49) | 65 |
| `LibOpInv` | `integrity` (19), `run` (28), `referenceFn` (44) | 53 |
| `LibOpMax` | `integrity` (20), `run` (32), `referenceFn` (67) | 79 |
| `LibOpMaxNegativeValue` | `integrity` (19), `run` (26), `referenceFn` (37) | 46 |
| `LibOpMaxPositiveValue` | `integrity` (19), `run` (26), `referenceFn` (37) | 46 |
| `LibOpMin` | `integrity` (20), `run` (32), `referenceFn` (68) | 84 |
| `LibOpMinNegativeValue` | `integrity` (19), `run` (26), `referenceFn` (37) | 46 |
| `LibOpMinPositiveValue` | `integrity` (19), `run` (26), `referenceFn` (37) | 46 |
| `LibOpMul` | `integrity` (21), `run` (32), `referenceFn` (74) | 101 |
| `LibOpPow` | `integrity` (19), `run` (28), `referenceFn` (47) | 60 |
| `LibOpSqrt` | `integrity` (19), `run` (28), `referenceFn` (44) | 56 |
| `LibOpSub` | `integrity` (21), `run` (33), `referenceFn` (75) | 101 |

### Growth (`src/lib/op/math/growth/`)

| Library | Functions (line numbers) | Lines |
|---|---|---|
| `LibOpExponentialGrowth` | `integrity` (18), `run` (26), `referenceFn` (47) | 60 |
| `LibOpLinearGrowth` | `integrity` (18), `run` (26), `referenceFn` (48) | 60 |

### Uint256 (`src/lib/op/math/uint256/`)

| Library | Functions (line numbers) | Lines |
|---|---|---|
| `LibOpMaxUint256` | `integrity` (14), `run` (21), `referenceFn` (31) | 40 |
| `LibOpUint256Add` | `integrity` (17), `run` (30), `referenceFn` (64) | 80 |
| `LibOpUint256Div` | `integrity` (18), `run` (30), `referenceFn` (65) | 82 |
| `LibOpUint256Mul` | `integrity` (17), `run` (30), `referenceFn` (64) | 80 |
| `LibOpUint256Pow` | `integrity` (17), `run` (30), `referenceFn` (64) | 80 |
| `LibOpUint256Sub` | `integrity` (17), `run` (30), `referenceFn` (64) | 81 |

---

## Security Analysis

### 1. Assembly Memory Safety

All assembly blocks across all 29 files are marked `"memory-safe"`. The patterns used are:

**Stack read pattern** (1-input opcodes: abs, ceil, floor, frac, headroom, inv, exp, exp2, sqrt):
```solidity
assembly ("memory-safe") {
    a := mload(stackTop)
}
```
Reads from the current stack top. Correct -- `stackTop` is always a valid memory pointer managed by the interpreter loop.

**Stack read pattern** (2-input opcodes: avg, gm, pow):
```solidity
assembly ("memory-safe") {
    a := mload(stackTop)
    stackTop := add(stackTop, 0x20)
    b := mload(stackTop)
}
```
Reads two values and advances `stackTop` by one slot (net consumption of 1, since the result is written back to the current `stackTop`). Correct.

**N-ary stack read pattern** (add, sub, mul, div, max, min):
```solidity
assembly ("memory-safe") {
    a := mload(stackTop)
    b := mload(add(stackTop, 0x20))
    stackTop := add(stackTop, 0x40)
}
```
Initial read of two values, then loop reads additional values. Final write-back:
```solidity
assembly ("memory-safe") {
    stackTop := sub(stackTop, 0x20)
    mstore(stackTop, a)
}
```
This pops N items and pushes 1, for a net consumption of N-1. Correct.

**Stack push pattern** (0-input opcodes: e, max-uint256, constant value opcodes):
```solidity
assembly ("memory-safe") {
    stackTop := sub(stackTop, 0x20)
    mstore(stackTop, value)
}
```
Pushes one value onto the stack. Correct.

All assembly blocks only touch the stack pointer region. No free memory pointer manipulation, no scratch space use. All reads and writes are within the bounds managed by the interpreter's stack allocation.

**Conclusion**: Assembly memory safety is correctly maintained across all files.

### 2. Integrity/Run Consistency

For each opcode, the `integrity` function declares how many stack items are consumed and produced. The `run` function must match this exactly.

| Opcode | integrity inputs | integrity outputs | run pops | run pushes | Match |
|---|---|---|---|---|---|
| abs | 1 | 1 | 1 (read+overwrite) | 1 | Yes |
| add | N (min 2) | 1 | N | 1 | Yes |
| avg | 2 | 1 | 2 | 1 | Yes |
| ceil | 1 | 1 | 1 | 1 | Yes |
| div | N (min 2) | 1 | N | 1 | Yes |
| e | 0 | 1 | 0 | 1 | Yes |
| exp | 1 | 1 | 1 | 1 | Yes |
| exp2 | 1 | 1 | 1 | 1 | Yes |
| floor | 1 | 1 | 1 | 1 | Yes |
| frac | 1 | 1 | 1 | 1 | Yes |
| gm | 2 | 1 | 2 | 1 | Yes |
| headroom | 1 | 1 | 1 | 1 | Yes |
| inv | 1 | 1 | 1 | 1 | Yes |
| max | N (min 2) | 1 | N | 1 | Yes |
| max-negative-value | 0 | 1 | 0 | 1 | Yes |
| max-positive-value | 0 | 1 | 0 | 1 | Yes |
| min | N (min 2) | 1 | N | 1 | Yes |
| min-negative-value | 0 | 1 | 0 | 1 | Yes |
| min-positive-value | 0 | 1 | 0 | 1 | Yes |
| mul | N (min 2) | 1 | N | 1 | Yes |
| pow | 2 | 1 | 2 | 1 | Yes |
| sqrt | 1 | 1 | 1 | 1 | Yes |
| sub | N (min 2) | 1 | N | 1 | Yes |
| exponential-growth | 3 | 1 | 3 | 1 | Yes |
| linear-growth | 3 | 1 | 3 | 1 | Yes |
| max-uint256 | 0 | 1 | 0 | 1 | Yes |
| uint256-add | N (min 2) | 1 | N | 1 | Yes |
| uint256-div | N (min 2) | 1 | N | 1 | Yes |
| uint256-mul | N (min 2) | 1 | N | 1 | Yes |
| uint256-pow | N (min 2) | 1 | N | 1 | Yes |
| uint256-sub | N (min 2) | 1 | N | 1 | Yes |

**Conclusion**: All integrity declarations match their run implementations exactly.

### 3. Arithmetic Overflow/Underflow

**Decimal float opcodes**: All arithmetic is delegated to `LibDecimalFloat` / `LibDecimalFloatImplementation` functions (`add`, `sub`, `mul`, `div`, `pow`, `sqrt`, etc.). These are external library functions that handle overflow internally -- either by reverting (`ExponentOverflow`) or by lossy packing (`packLossy`). The opcode wrappers do not perform any arithmetic on the float values themselves (except `unchecked { i++; }` in loops, analyzed below).

**Uint256 opcodes**: The main arithmetic operations (`a += b`, `a -= b`, `a *= b`, `a /= b`, `a = a ** b`) are in checked Solidity 0.8.25 context, which will automatically revert on overflow/underflow.

**Loop counter `unchecked { i++; }`**: All N-ary opcodes use `unchecked { i++; }` for the loop counter. The counter `i` starts at 2 and is bounded by `inputs`, which is masked to 4 bits (`& 0x0F`), giving a maximum value of 15. The increment from 14 to 15 is the maximum, which cannot overflow a `uint256`. Safe.

**Conclusion**: No overflow or underflow vulnerabilities.

### 4. Division by Zero

**LibOpDiv (float)**: Division by zero handling is delegated to `LibDecimalFloatImplementation.div()`, which reverts on division by zero. The `referenceFn` (line 92) explicitly checks `if (b.isZero())` and bails out with a sentinel value, confirming the real implementation is expected to revert.

**LibOpUint256Div**: Uses Solidity's `/=` operator, which reverts on division by zero via the compiler's built-in check.

**LibOpInv (float)**: Delegates to `Float.inv()` which computes `1/x`. Division by zero when `x == 0` is handled by the underlying `LibDecimalFloat.div()`.

**Conclusion**: Division by zero is correctly handled (reverts) in all cases.

### 5. packLossy Precision Loss

The N-ary float opcodes (`add`, `sub`, `mul`, `div`) unpack inputs, perform multi-step arithmetic on raw `(signedCoefficient, exponent)` pairs, and then call `packLossy` once at the end to re-pack the result. This is the correct pattern -- it maximizes precision by keeping values in unpacked form during intermediate calculations.

The single-step float opcodes (`abs`, `ceil`, `floor`, `frac`, `avg`, `headroom`, `inv`) use the high-level `Float` methods (e.g., `a.add(b)`, `a.ceil()`) which call `packLossy` internally after each operation. For `avg` (line 36 of LibOpAvg.sol), this means `packLossy` is called twice: once after `a.add(b)` and once after `.div(FLOAT_TWO)`. This is the expected behavior for these convenience methods, and the precision loss is bounded by the float format (int224 coefficient, int32 exponent).

**Conclusion**: `packLossy` usage is consistent and precision loss is bounded by the float format. No unbounded or undocumented precision loss.

### 6. N-ary Operand Parsing

All N-ary opcodes extract the input count with:
```solidity
uint256 inputs = uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F;
inputs = inputs > 1 ? inputs : 2;
```

The 4-bit mask limits inputs to 0-15. Values 0 and 1 are clamped to 2 (minimum). Both `integrity` and `run` use identical extraction logic, so they always agree on the input count.

**Conclusion**: Operand parsing is consistent between integrity and run for all N-ary opcodes.

### 7. Uint256 Overflow Protection

All uint256 opcodes (`uint256-add`, `uint256-sub`, `uint256-mul`, `uint256-pow`) use checked Solidity arithmetic. The `referenceFn` implementations use `unchecked` blocks intentionally, so that test harnesses can verify the real implementation throws overflow errors while the reference produces a different (wrapped) result.

`uint256-div` relies on the compiler's built-in division-by-zero check.

**Conclusion**: Uint256 opcodes correctly leverage Solidity 0.8.x checked arithmetic.

### 8. Growth Opcodes

**LibOpExponentialGrowth**: Computes `base * (1 + rate)^t` (line 36). Uses `rate.add(FLOAT_ONE).pow(t, LOG_TABLES_ADDRESS)` then multiplies by `base`. Delegates all arithmetic to `LibDecimalFloat`. No direct arithmetic in the opcode itself. The `pow` function requires `LOG_TABLES_ADDRESS` to be deployed, making this a `view` function.

**LibOpLinearGrowth**: Computes `base + rate * t` (line 37). Uses `base.add(rate.mul(t))`. Pure function. No issues.

**Conclusion**: Growth opcodes correctly delegate to float library. No arithmetic bugs.

---

## Findings

### A24-1 -- INFO: NatSpec missing `@notice` tag on integrity functions in growth opcodes

**Location**: `LibOpExponentialGrowth.sol` line 17, `LibOpLinearGrowth.sol` line 17

**Description**: The `integrity` function NatSpec uses a bare `///` comment without any tag:
```solidity
/// `exponential-growth` integrity check. Requires exactly 3 inputs and produces 1 output.
```
Per the project's NatSpec convention: when no explicit tags are used in a doc block, the text is implicitly `@notice`. Since no other tags are present in this doc block, this is technically valid Solidity NatSpec. However, it is inconsistent with all other math opcodes which use explicit `@notice` tags. This inconsistency is also present in `LibOpMaxUint256.sol` line 13.

**Severity**: INFO

### A24-2 -- INFO: NatSpec missing `@notice` tag on integrity and referenceFn in LibOpMaxUint256

**Location**: `LibOpMaxUint256.sol` line 13, line 30

**Description**: Same pattern as A24-1. The `integrity` function (line 13) and `referenceFn` (line 30) use bare `///` without `@notice`. This is consistent with the growth opcodes but inconsistent with the majority of math opcodes.

**Severity**: INFO

### A24-3 -- INFO: Intermediate packLossy in LibOpAvg vs N-ary opcodes

**Location**: `LibOpAvg.sol` line 36

**Description**: `LibOpAvg.run()` computes `a.add(b).div(FLOAT_TWO)` using high-level `Float` methods. This results in two `packLossy` calls (one inside `add`, one inside `div`), whereas the N-ary opcodes (add, sub, mul, div) use unpacked intermediate arithmetic with a single final `packLossy`. The extra packing step in `avg` can cause slightly different rounding compared to computing the average using unpacked values. This is by design -- `avg` uses the convenience API for simplicity and the precision loss is bounded by the float format. The `referenceFn` uses the same code path, so tests will validate consistency.

**Severity**: INFO

### A24-4 -- INFO: Unchecked loop counters in N-ary opcodes are provably safe

**Location**: All N-ary opcodes (LibOpAdd line 57-59, LibOpSub line 57-59, LibOpMul line 56-58, LibOpDiv line 57-59, LibOpMax line 51-53, LibOpMin line 52-54, LibOpUint256Add line 49-51, LibOpUint256Div line 49-51, LibOpUint256Mul line 49-51, LibOpUint256Pow line 49-51, LibOpUint256Sub line 49-51)

**Description**: All N-ary opcodes use `unchecked { i++; }` for loop counter increments. The counter `i` starts at 2 and is bounded by `inputs`, which is extracted as `(operand >> 0x10) & 0x0F`, giving a maximum value of 15. The maximum increment is from 14 to 15, which cannot overflow `uint256`. This is safe.

**Severity**: INFO

### A24-5 -- INFO: LibOpHeadroom returns 1 for integer inputs

**Location**: `LibOpHeadroom.sol` lines 35-38

**Description**: The headroom opcode computes `ceil(x) - x`, and when the result is zero (i.e., `x` is already an integer), it returns `FLOAT_ONE` instead of zero. This behavior is documented in the NatSpec (line 28: "except when `x` is already an integer (headroom would be zero), in which case it returns 1"). This is intentional design -- it ensures headroom is always positive, which is useful for expressions that multiply by headroom to scale a value. Documented and correct.

**Severity**: INFO

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings across all 29 math opcode files.

The math opcodes are thin wrappers around `LibDecimalFloat` / `LibDecimalFloatImplementation` (for float opcodes) and Solidity checked arithmetic (for uint256 opcodes). Each opcode follows a consistent pattern: integrity declares input/output counts, run performs stack manipulation via assembly and delegates arithmetic to the library, referenceFn provides a test oracle using the same library functions.

All assembly is correctly marked `memory-safe` and only operates on the interpreter's stack pointer region. N-ary operand parsing is consistent between integrity and run. Division by zero is handled by the underlying libraries. Overflow/underflow is caught by either the float library's `ExponentOverflow` revert or Solidity 0.8.x checked arithmetic. The `packLossy` precision loss is bounded by the float format and consistently applied.

The only findings are informational: minor NatSpec inconsistencies (bare `///` vs explicit `@notice`) in three files, and documentation of design decisions (avg intermediate packing, headroom returning 1, safe unchecked counters).
