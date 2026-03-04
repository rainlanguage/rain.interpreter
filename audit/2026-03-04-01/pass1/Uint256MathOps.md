# Pass 1 (Security) -- Growth and Uint256 Math Opcodes (A92--A99)

## Files

| ID | File | Lines |
|----|------|-------|
| A92 | `src/lib/op/math/growth/LibOpExponentialGrowth.sol` | 63 |
| A93 | `src/lib/op/math/growth/LibOpLinearGrowth.sol` | 63 |
| A94 | `src/lib/op/math/uint256/LibOpUint256Add.sol` | 81 |
| A95 | `src/lib/op/math/uint256/LibOpUint256Div.sol` | 83 |
| A96 | `src/lib/op/math/uint256/LibOpUint256MaxValue.sol` | 44 |
| A97 | `src/lib/op/math/uint256/LibOpUint256Mul.sol` | 80 |
| A98 | `src/lib/op/math/uint256/LibOpUint256Power.sol` | 82 |
| A99 | `src/lib/op/math/uint256/LibOpUint256Sub.sol` | 82 |

---

## A92 -- LibOpExponentialGrowth

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpExponentialGrowth` | library | 14 |
| `integrity` | internal pure function | 20 |
| `run` | internal view function | 28 |
| `referenceFn` | internal view function | 49 |

**Imports:** `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`.

No custom errors, constants, or types defined.

### Analysis

**Integrity inputs/outputs:** Returns `(3, 1)` -- three inputs (base, rate, t), one output. Matches runtime: `run` reads three stack items via `mload(stackTop)`, `mload(add(stackTop, 0x20))`, and `mload(stackTop)` after advancing by 0x40.

**Stack pointer arithmetic (lines 32--37):** Reads items 1 and 2 at `stackTop` and `stackTop + 0x20`, then sets `stackTop := add(stackTop, 0x40)` before reading item 3 at the new `stackTop`. Net movement is +0x40 from original. The result is written to the same position (line 40--42), so the final `stackTop` is `original + 0x40`. This consumes 3 items and produces 1 (net consumed 2). Correct for `(3, 1)`.

**Assembly memory safety (lines 32--37, 40--42):** Both blocks are marked `memory-safe`. They only read from and write to pre-allocated stack memory. No free memory pointer modification, no new allocations. Correct.

**Arithmetic safety:** The computation `base.mul(rate.add(FLOAT_ONE).pow(t, LOG_TABLES_ADDRESS))` delegates entirely to `LibDecimalFloat`. The `pow` function requires `staticcall` to `LOG_TABLES_ADDRESS`, which is why `run` is `view` not `pure`. Overflow/underflow handling is within the float library. No unchecked arithmetic in this file.

**Operand validation:** The operand is unused in all three functions. No validation needed.

**Reference function consistency (lines 49--61):** Computes the same formula with the same library calls. Consistent.

### Findings

No findings.

---

## A93 -- LibOpLinearGrowth

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpLinearGrowth` | library | 14 |
| `integrity` | internal pure function | 20 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 50 |

**Imports:** `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`.

No custom errors, constants, or types defined.

### Analysis

**Integrity inputs/outputs:** Returns `(3, 1)`. Matches runtime behavior identically to LibOpExponentialGrowth.

**Stack pointer arithmetic (lines 32--37):** Same pattern as A92. Reads 3 items, advances by 0x40, writes result at the third item's position. Net consumed 2. Correct for `(3, 1)`.

**Assembly memory safety (lines 32--37, 41--43):** Same pattern as A92. Only accesses pre-allocated stack memory. Correctly marked `memory-safe`.

**Arithmetic safety:** Computes `base.add(rate.mul(t))` via `LibDecimalFloat`. All pure operations. No unchecked arithmetic in this file.

**Operand validation:** Unused. No validation needed.

**Reference function consistency (lines 50--61):** Same formula. Consistent.

### Findings

No findings.

---

## A94 -- LibOpUint256Add

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpUint256Add` | library | 12 |
| `integrity` | internal pure function | 17 |
| `run` | internal pure function | 30 |
| `referenceFn` | internal pure function | 64 |

**Imports:** `IntegrityCheckState`, `InterpreterState`, `OperandV2`, `StackItem`, `Pointer`.

No custom errors, constants, or types defined.

### Analysis

**Operand extraction:** Both `integrity` (line 19) and `run` (line 41) extract `(operand >> 0x10) & 0x0F` -- the low 4 bits of the high byte, giving a range of 0--15. Consistent extraction.

**Integrity inputs/outputs (lines 19--21):** `inputs = max(operandBits, 2)`, returns `(inputs, 1)`. Clamps minimum to 2 inputs. When operand encodes 0 or 1, integrity declares 2 inputs. For 2--15, it declares the encoded value.

**Run input count consistency:** `run` extracts the same bits (line 41) but does not clamp. When operand encodes 0 or 1, the while loop condition `2 < inputs` is false, so the loop does not execute. The function still processes exactly 2 items (the unconditional read of `a` and `b` on lines 34--35), matching the clamped integrity declaration. For values 2--15, the loop reads `inputs - 2` additional items, matching integrity. Correct.

**Stack pointer arithmetic (lines 33--57):** For N inputs: reads 2 items at `stackTop` and `stackTop + 0x20`, advances by 0x40. Loop reads N-2 additional items each advancing by 0x20. Then `sub(stackTop, 0x20)` and writes result. Net movement: `0x40 + (N-2)*0x20 - 0x20 = N*0x20 - 0x20`. This consumes N items and produces 1 (net consumed N-1). Correct for `(N, 1)`.

**Assembly memory safety:** All four assembly blocks (lines 33--37, 44--47, 54--57) only read from and write to pre-allocated stack memory. Correctly marked `memory-safe`.

**Arithmetic safety:** `a += b` on lines 38, 48 use checked addition (Solidity 0.8.x). Overflow reverts with a Panic. The loop counter increment on line 50 is `unchecked { i++; }` which is safe because `i` is bounded by `inputs <= 15`.

**Reference function consistency (lines 64--79):** Uses `unchecked` addition deliberately -- the comment explains this is so overflow tests see the revert from the real function, not the reference. The test framework (opReferenceCheck) catches discrepancies. This is an intentional testing pattern.

### Findings

No findings.

---

## A95 -- LibOpUint256Div

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpUint256Div` | library | 13 |
| `integrity` | internal pure function | 18 |
| `run` | internal pure function | 30 |
| `referenceFn` | internal pure function | 65 |

**Imports:** `OperandV2`, `StackItem`, `Pointer`, `IntegrityCheckState`, `InterpreterState`.

No custom errors, constants, or types defined.

### Analysis

**Operand extraction:** Same pattern as A94 -- `(operand >> 0x10) & 0x0F`. Consistent between `integrity` (line 20) and `run` (line 41).

**Integrity inputs/outputs (lines 20--22):** Same clamping logic as A94: `max(operandBits, 2)` inputs, 1 output.

**Run input count consistency:** Same logic as A94. Loop does not execute for operand values 0 or 1. Correct.

**Stack pointer arithmetic:** Identical pattern to A94. Net movement is `N*0x20 - 0x20` for N inputs. Correct.

**Assembly memory safety:** All assembly blocks read/write only to pre-allocated stack memory. Correctly marked `memory-safe`.

**Arithmetic safety:** `a /= b` on lines 38, 48 use checked division (Solidity 0.8.x). Division by zero reverts with a Panic. The loop counter uses `unchecked { i++; }` which is safe (bounded by 15).

**Reference function consistency (lines 65--81):** Uses `unchecked` division deliberately for the same reason as A94 (testing pattern).

### Findings

No findings.

---

## A96 -- LibOpUint256MaxValue

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpUint256MaxValue` | library | 12 |
| `integrity` | internal pure function | 16 |
| `run` | internal pure function | 23 |
| `referenceFn` | internal pure function | 34 |

**Imports:** `IntegrityCheckState`, `OperandV2`, `StackItem`, `InterpreterState`, `Pointer`.

No custom errors, constants, or types defined.

### Analysis

**Integrity inputs/outputs (line 17):** Returns `(0, 1)`. Zero inputs consumed, one output produced. Correct for a constant-pushing opcode.

**Stack pointer arithmetic (lines 25--28):** `stackTop := sub(stackTop, 0x20)` then `mstore(stackTop, value)`. Pushes one item onto the stack by moving the pointer down. Correct for 0 inputs, 1 output.

**Assembly memory safety (lines 25--28):** Writes to the slot immediately below the current stack top, which is within pre-allocated stack memory (the integrity check ensures stack capacity). Correctly marked `memory-safe`.

**Operand validation:** Unused. No validation needed.

**Reference function consistency (lines 34--42):** Returns `type(uint256).max` as a `StackItem`. Consistent.

### Findings

No findings.

---

## A97 -- LibOpUint256Mul

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpUint256Mul` | library | 12 |
| `integrity` | internal pure function | 17 |
| `run` | internal pure function | 30 |
| `referenceFn` | internal pure function | 64 |

**Imports:** `OperandV2`, `StackItem`, `Pointer`, `IntegrityCheckState`, `InterpreterState`.

No custom errors, constants, or types defined.

### Analysis

Structurally identical to A94 (LibOpUint256Add) with `*=` instead of `+=`.

**Operand extraction:** Same pattern. Consistent.

**Integrity inputs/outputs:** Same clamping logic. Correct.

**Run input count consistency:** Same logic. Correct.

**Stack pointer arithmetic:** Identical pattern. Correct.

**Assembly memory safety:** All blocks access only pre-allocated stack memory. Correctly marked `memory-safe`.

**Arithmetic safety:** `a *= b` uses checked multiplication (Solidity 0.8.x). Overflow reverts with a Panic. Loop counter `unchecked { i++; }` bounded by 15.

**Reference function consistency:** Uses `unchecked` multiplication deliberately (testing pattern). Consistent.

### Findings

No findings.

---

## A98 -- LibOpUint256Power

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpUint256Power` | library | 13 |
| `integrity` | internal pure function | 18 |
| `run` | internal pure function | 31 |
| `referenceFn` | internal pure function | 65 |

**Imports:** `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`.

No custom errors, constants, or types defined.

### Analysis

Structurally identical to A94 (LibOpUint256Add) with `**` instead of `+`.

**Operand extraction:** Same pattern. Consistent.

**Integrity inputs/outputs:** Same clamping logic. Correct.

**Run input count consistency:** Same logic. Correct.

**Stack pointer arithmetic:** Identical pattern. Correct.

**Assembly memory safety:** All blocks access only pre-allocated stack memory. Correctly marked `memory-safe`.

**Arithmetic safety:** `a = a ** b` uses checked exponentiation (Solidity 0.8.x). Overflow reverts with a Panic. Loop counter `unchecked { i++; }` bounded by 15.

**Reference function consistency:** Uses `unchecked` exponentiation deliberately (testing pattern). Consistent.

### Findings

No findings.

---

## A99 -- LibOpUint256Sub

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpUint256Sub` | library | 12 |
| `integrity` | internal pure function | 17 |
| `run` | internal pure function | 30 |
| `referenceFn` | internal pure function | 64 |

**Imports:** `IntegrityCheckState`, `InterpreterState`, `OperandV2`, `StackItem`, `Pointer`.

No custom errors, constants, or types defined.

### Analysis

Structurally identical to A94 (LibOpUint256Add) with `-=` instead of `+=`.

**Operand extraction:** Same pattern. Consistent.

**Integrity inputs/outputs:** Same clamping logic. Correct.

**Run input count consistency:** Same logic. Correct.

**Stack pointer arithmetic:** Identical pattern. Correct.

**Assembly memory safety:** All blocks access only pre-allocated stack memory. Correctly marked `memory-safe`.

**Arithmetic safety:** `a -= b` uses checked subtraction (Solidity 0.8.x). Underflow reverts with a Panic. Loop counter `unchecked { i++; }` bounded by 15.

**Reference function consistency:** Uses `unchecked` subtraction deliberately (testing pattern). Consistent.

### Findings

No findings.

---

## Summary

All 8 files reviewed. No security findings across any file. The common patterns are sound:

1. **Growth opcodes (A92, A93):** Fixed 3-input, 1-output operations with correct stack pointer arithmetic. Float arithmetic delegated to `LibDecimalFloat` which handles its own overflow/precision guarantees.

2. **N-ary uint256 opcodes (A94, A95, A97--A99):** Variable-input (2--15) operations with consistent operand extraction between `integrity` and `run`. The integrity function clamps the minimum to 2 inputs; the run function's loop naturally handles this case by not executing when the raw operand value is below 2. All arithmetic operations use Solidity 0.8.x checked math (overflow/underflow/division-by-zero revert with Panic).

3. **MaxValue opcode (A96):** Simple constant-pushing opcode with correct (0, 1) integrity and stack handling.

4. **Assembly safety:** All `memory-safe` annotations are correct -- every assembly block only reads from and writes to pre-allocated stack memory within bounds guaranteed by the integrity check.

5. **Reference functions:** All reference implementations use `unchecked` arithmetic deliberately so that error-path tests observe the revert from the real implementation rather than the reference. This is a documented testing pattern.
