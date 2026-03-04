# Pass 1 (Security) -- Math Opcodes (A69--A91)

**Files:** `src/lib/op/math/LibOp{Abs,Add,Avg,Ceil,Div,E,Exp,Exp2,Floor,Frac,Gm,Headroom,Inv,Max,MaxNegativeValue,MaxPositiveValue,Min,MinNegativeValue,MinPositiveValue,Mul,Power,Sqrt,Sub}.sol`

## Evidence Inventory

### A69 -- LibOpAbs (`src/lib/op/math/LibOpAbs.sol`, 53 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpAbs` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 44 |

**Imports:** `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`.

### A70 -- LibOpAdd (`src/lib/op/math/LibOpAdd.sol`, 98 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpAdd` | library | 15 |
| `integrity` | internal pure function | 22 |
| `run` | internal pure function | 33 |
| `referenceFn` | internal pure function | 76 |

**Imports:** As A69 plus `LibDecimalFloatImplementation`.

### A71 -- LibOpAvg (`src/lib/op/math/LibOpAvg.sol`, 61 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpAvg` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 47 |

**Imports:** As A69.

### A72 -- LibOpCeil (`src/lib/op/math/LibOpCeil.sol`, 55 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpCeil` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 44 |

**Imports:** As A69.

### A73 -- LibOpDiv (`src/lib/op/math/LibOpDiv.sol`, 107 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpDiv` | library | 14 |
| `integrity` | internal pure function | 21 |
| `run` | internal pure function | 33 |
| `referenceFn` | internal pure function | 74 |

**Imports:** As A69 plus `LibDecimalFloatImplementation`.

### A74 -- LibOpE (`src/lib/op/math/LibOpE.sol`, 44 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpE` | library | 13 |
| `integrity` | internal pure function | 17 |
| `run` | internal pure function | 24 |
| `referenceFn` | internal pure function | 35 |

**Imports:** `Pointer`, `OperandV2`, `StackItem`, `InterpreterState`, `IntegrityCheckState`, `LibDecimalFloat`, `Float`.

### A75 -- LibOpExp (`src/lib/op/math/LibOpExp.sol`, 56 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpExp` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 28 |
| `referenceFn` | internal view function | 44 |

**Imports:** As A69.

### A76 -- LibOpExp2 (`src/lib/op/math/LibOpExp2.sol`, 57 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpExp2` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 28 |
| `referenceFn` | internal view function | 45 |

**Imports:** As A69.

### A77 -- LibOpFloor (`src/lib/op/math/LibOpFloor.sol`, 53 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpFloor` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 44 |

**Imports:** As A69.

### A78 -- LibOpFrac (`src/lib/op/math/LibOpFrac.sol`, 53 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpFrac` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 44 |

**Imports:** As A69.

### A79 -- LibOpGm (`src/lib/op/math/LibOpGm.sol`, 74 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpGm` | library | 15 |
| `integrity` | internal pure function | 21 |
| `run` | internal view function | 31 |
| `referenceFn` | internal view function | 55 |

**Imports:** As A69.

### A80 -- LibOpHeadroom (`src/lib/op/math/LibOpHeadroom.sol`, 65 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpHeadroom` | library | 14 |
| `integrity` | internal pure function | 20 |
| `run` | internal pure function | 30 |
| `referenceFn` | internal pure function | 49 |

**Imports:** As A69.

### A81 -- LibOpInv (`src/lib/op/math/LibOpInv.sol`, 53 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpInv` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 44 |

**Imports:** As A69.

### A82 -- LibOpMax (`src/lib/op/math/LibOpMax.sol`, 79 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMax` | library | 13 |
| `integrity` | internal pure function | 20 |
| `run` | internal pure function | 32 |
| `referenceFn` | internal pure function | 67 |

**Imports:** As A69.

### A83 -- LibOpMaxNegativeValue (`src/lib/op/math/LibOpMaxNegativeValue.sol`, 46 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMaxNegativeValue` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 26 |
| `referenceFn` | internal pure function | 37 |

**Imports:** `IntegrityCheckState`, `OperandV2`, `StackItem`, `InterpreterState`, `Pointer`, `Float`, `LibDecimalFloat`.

### A84 -- LibOpMaxPositiveValue (`src/lib/op/math/LibOpMaxPositiveValue.sol`, 46 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMaxPositiveValue` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 26 |
| `referenceFn` | internal pure function | 37 |

**Imports:** As A83.

### A85 -- LibOpMin (`src/lib/op/math/LibOpMin.sol`, 84 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMin` | library | 13 |
| `integrity` | internal pure function | 20 |
| `run` | internal pure function | 32 |
| `referenceFn` | internal pure function | 68 |

**Imports:** As A69.

### A86 -- LibOpMinNegativeValue (`src/lib/op/math/LibOpMinNegativeValue.sol`, 46 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMinNegativeValue` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 26 |
| `referenceFn` | internal pure function | 37 |

**Imports:** As A83.

### A87 -- LibOpMinPositiveValue (`src/lib/op/math/LibOpMinPositiveValue.sol`, 46 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMinPositiveValue` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 26 |
| `referenceFn` | internal pure function | 37 |

**Imports:** As A83.

### A88 -- LibOpMul (`src/lib/op/math/LibOpMul.sol`, 101 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpMul` | library | 14 |
| `integrity` | internal pure function | 21 |
| `run` | internal pure function | 32 |
| `referenceFn` | internal pure function | 74 |

**Imports:** As A69 plus `LibDecimalFloatImplementation`.

### A89 -- LibOpPower (`src/lib/op/math/LibOpPower.sol`, 60 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpPower` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 28 |
| `referenceFn` | internal view function | 47 |

**Imports:** As A69.

### A90 -- LibOpSqrt (`src/lib/op/math/LibOpSqrt.sol`, 56 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpSqrt` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 28 |
| `referenceFn` | internal view function | 44 |

**Imports:** As A69.

### A91 -- LibOpSub (`src/lib/op/math/LibOpSub.sol`, 101 lines)

| Item | Kind | Line |
|------|------|------|
| `LibOpSub` | library | 14 |
| `integrity` | internal pure function | 21 |
| `run` | internal pure function | 33 |
| `referenceFn` | internal pure function | 75 |

**Imports:** As A69 plus `LibDecimalFloatImplementation`.

---

## Analysis

### Structural Classification

The 23 opcodes fall into four categories:

1. **Unary in-place** (9 ops: abs, ceil, exp, exp2, floor, frac, headroom, inv, sqrt): Read one value from `stackTop`, compute, write result back to same location. Stack pointer unchanged. Integrity: `(1, 1)`.

2. **Binary** (3 ops: avg, gm, power): Read two values from stack, consume both, write one result. Stack pointer advances by `0x20`. Integrity: `(2, 1)`.

3. **Constants** (5 ops: e, max-negative-value, max-positive-value, min-negative-value, min-positive-value): Push a constant. Stack pointer decremented by `0x20`. Integrity: `(0, 1)`.

4. **N-ary** (6 ops: add, div, max, min, mul, sub): Read input count from `operand >> 0x10 & 0x0F`. Consume N inputs, produce 1 output. Integrity reads the same operand bits and clamps to minimum 2.

### Integrity inputs/outputs consistency

**Unary ops (abs, ceil, exp, exp2, floor, frac, headroom, inv, sqrt):** All return `(1, 1)`. All `run` functions read one word from `stackTop` and write one word back at the same `stackTop`. Consistent.

**Binary ops (avg, gm, power):** All return `(2, 1)`. All `run` functions read two words, advance `stackTop` by `0x20`, and write one word. Net stack consumption: 2 in, 1 out. Consistent.

**Constants (e, max-negative-value, max-positive-value, min-negative-value, min-positive-value):** All return `(0, 1)`. All `run` functions decrement `stackTop` by `0x20` and write one word. Consistent.

**N-ary ops (add, div, max, min, mul, sub):** All extract `inputs = (operand >> 0x10) & 0x0F` then clamp `inputs = inputs > 1 ? inputs : 2`. Run functions: pop first two items (`stackTop += 0x40`), then loop `(inputs - 2)` more pops (`stackTop += 0x20` each), then push result (`stackTop -= 0x20`). Net: `0x40 + (inputs - 2) * 0x20 - 0x20 = inputs * 0x20 - 0x20`, meaning `inputs` consumed and 1 produced. Matches integrity. Consistent.

### Assembly memory safety

All assembly blocks are marked `"memory-safe"`. The operations performed are:

- `mload(stackTop)` and `mload(add(stackTop, 0x20))` -- reading pre-existing stack slots.
- `mstore(stackTop, value)` -- writing to pre-existing stack slots.
- `stackTop := add(stackTop, 0x20)` / `stackTop := sub(stackTop, 0x20)` -- pointer arithmetic on the stack pointer (a local variable, not memory).

These operations only touch the interpreter's pre-allocated stack region. No memory allocation, no free memory pointer modification. The `memory-safe` annotation is correct for all 23 files.

### Stack underflow / overflow

The integrity check framework (`LibIntegrityCheck.integrityCheck2`) verifies that the stack has sufficient depth before each opcode executes. Unary ops require at least 1, binary ops at least 2, constants require 0, and N-ary ops require at least the declared input count (minimum 2). The integrity framework enforces this statically. No runtime stack underflow is possible for well-formed bytecode.

For N-ary ops, the operand's high byte bits are written by the parser from the actual input count of the paren group. The parser limits this to 4 bits (0..15), and integrity clamps to a minimum of 2. The integrity framework verifies sufficient stack depth. No risk.

### Operand validation

**Unary, binary, and constant ops:** The operand is unused (ignored in all three functions). The parser registers `handleOperandDisallowed` for all math ops, meaning the operand will always be zero at parse time. No validation needed.

**N-ary ops:** These read `(operand >> 0x10) & 0x0F` which extracts the input count written by the parser. The parser writes the actual count of child expressions into this field. The mask `0x0F` limits the value to 0..15. Integrity clamps to minimum 2. No additional validation needed.

### Arithmetic safety

All arithmetic is delegated to `LibDecimalFloat` / `LibDecimalFloatImplementation`:

- **Overflow/underflow:** The float library uses 224-bit signed coefficients and 32-bit signed exponents. Overflow conditions (coefficient too large, exponent out of range) revert with `CoefficientOverflow` or `ExponentOverflow`. These reverts propagate through the opcodes.
- **Division by zero:** `LibDecimalFloatImplementation.div` reverts on zero divisor. `LibOpInv.run` calls `a.inv()` which also reverts on zero. This is correct behavior per the library's design (no NaN/Infinity).
- **Negative sqrt:** `Float.sqrt` reverts on negative inputs. This is correct.
- **Negative base in pow:** `Float.pow` reverts on negative base (`PowNegativeBase`). This is correct and affects LibOpPower, LibOpExp, LibOpExp2, LibOpGm (which uses `abs()` to avoid this).
- **packLossy:** N-ary ops (add, div, mul, sub) call `LibDecimalFloat.packLossy` after accumulating results in unpacked form. The `_lossy` suffix indicates precision loss is possible. The second return value (`lossless`) is intentionally discarded (annotated with `//slither-disable-next-line unused-return`). This is a deliberate design choice: the float system accepts lossy packing as part of its precision model.
- **unchecked i++:** The loop counter `i` in N-ary ops uses `unchecked { i++; }`. Since `i` is bounded by the 4-bit input count (max 15), this cannot overflow. Safe.

### Reference function consistency

All 23 files have `referenceFn` implementations that mirror the `run` logic using equivalent high-level Solidity calls. The N-ary `referenceFn` functions iterate over the `inputs` array using a for loop, which is semantically equivalent to the assembly-optimized `run`. The reference functions in add, div, mul, sub, and min use `unchecked` blocks to avoid shadowing overflow reverts from the real implementation. LibOpDiv's `referenceFn` includes a sentinel value for divide-by-zero to avoid interfering with the real implementation's revert.

### Custom errors

No custom errors are defined in any of the 23 files. All error conditions originate from the imported libraries (`LibDecimalFloat`, `LibDecimalFloatImplementation`). This is correct -- the opcode wrappers are thin and delegate error handling to the math library.

---

## Findings

No findings.

All 23 math opcode files follow a consistent, correct pattern:
- Integrity declarations match runtime stack behavior exactly.
- Assembly blocks only access pre-allocated stack memory and are correctly marked `memory-safe`.
- Arithmetic safety is delegated to `LibDecimalFloat` which handles overflow, underflow, division by zero, and domain errors with appropriate reverts.
- N-ary operand extraction uses a 4-bit mask ensuring bounded iteration.
- The `unchecked` loop counter increments are safe due to the 4-bit bound.
- No custom errors, constants, or types are defined that could introduce issues.
