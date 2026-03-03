# Pass 1 Audit: Logic Opcodes

**Agent**: A23
**Date**: 2026-03-01
**Scope**: `src/lib/op/logic/` (12 files)

## Files Reviewed

| File | Lines | Assembly Blocks | Operand-Driven Inputs |
|------|-------|-----------------|----------------------|
| `LibOpAny.sol` | 77 | 2 (run) | Yes (4-bit, clamped >= 1 in integrity) |
| `LibOpBinaryEqualTo.sol` | 47 | 1 (run) | No (fixed 2 inputs) |
| `LibOpConditions.sol` | 107 | 3 (run) | Yes (4-bit, clamped >= 2 in integrity) |
| `LibOpEnsure.sol` | 60 | 1 (run) | No (fixed 2 inputs) |
| `LibOpEqualTo.sol` | 63 | 2 (run) | No (fixed 2 inputs) |
| `LibOpEvery.sol` | 76 | 2 (run) | Yes (4-bit, clamped >= 1 in integrity) |
| `LibOpGreaterThan.sol` | 57 | 2 (run) | No (fixed 2 inputs) |
| `LibOpGreaterThanOrEqualTo.sol` | 58 | 2 (run) | No (fixed 2 inputs) |
| `LibOpIf.sol` | 55 | 2 (run) | No (fixed 3 inputs) |
| `LibOpIsZero.sol` | 50 | 2 (run) | No (fixed 1 input) |
| `LibOpLessThan.sol` | 57 | 2 (run) | No (fixed 2 inputs) |
| `LibOpLessThanOrEqualTo.sol` | 58 | 2 (run) | No (fixed 2 inputs) |

## Evidence of Thorough Reading

### Operand Decoding
- `LibOpAny`, `LibOpEvery`, `LibOpConditions` all extract input count from operand bits `[16:19]` via `(OperandV2.unwrap(operand) >> 0x10) & 0x0F`, yielding 0-15.
- Integrity clamps: Any/Every >= 1, Conditions >= 2. The `run()` functions read the raw operand without clamping.
- Verified via `LibIntegrityCheck.integrityCheck2` (line 159) that the bytecode IO byte must match the integrity function's return value. Since integrity clamps the operand but the IO byte must match the clamped value, the parser must produce a consistent operand+IO byte pair or integrity rejects at deploy time.

### Stack Pointer Arithmetic
- Fixed-input ops (2-input comparisons): read `mload(stackTop)`, advance `stackTop += 0x20`, read/write second slot. Net: 2 in, 1 out. Verified for all 6 comparison ops.
- `LibOpIf`: reads condition at `stackTop`, advances by `0x40` (skipping condition and then-value), then conditionally reads from `stackTop` (else) or `stackTop - 0x20` (then). Net: 3 in, 1 out.
- `LibOpEnsure`: reads 2 items, advances by `0x40`. Net: 2 in, 0 out.
- `LibOpIsZero`: reads 1 item, overwrites in-place. Net: 1 in, 1 out.
- `LibOpAny`/`LibOpEvery`: `length = 0x20 * inputs`, `end = stackTop + length`, `stackTop = end - 0x20`. Loop iterates `[stackTop, end)`. Net: N in, 1 out.
- `LibOpConditions`: pairs iteration from cursor to end, with optional odd trailing reason. Stacktop computed as `end - 0x20` (even) or `end` (odd). Net: N in, 1 out.

### Assembly `memory-safe` Annotations
- All assembly blocks are annotated `memory-safe`. Verified that each block only reads/writes within the stack region bounded by `stackTop` through `stackTop + inputs * 0x20`. The stack is Solidity-allocated memory (via `LibInterpreterState`), so these annotations are correct.

### Float vs. Binary Equality
- `LibOpBinaryEqualTo` uses EVM `eq()` (bitwise). `LibOpEqualTo` uses `Float.eq()` (semantic float equality, handling different representations of the same value). Both are intentional per their naming and NatSpec.

### Boolean Output Encoding
- All comparison and boolean ops (`equal-to`, `binary-equal-to`, `greater-than`, `greater-than-or-equal-to`, `less-than`, `less-than-or-equal-to`, `is-zero`) output raw `0` or `1` (not float-encoded). This is consistent across all ops. Conditional ops (`any`, `every`, `if`, `conditions`, `ensure`) use `Float.isZero()` to check truthiness, which checks whether the lower 224 bits are zero. Raw `1` has nonzero lower 224 bits, so it is correctly treated as truthy.

### String Reverts
- `LibOpConditions` and `LibOpEnsure` use `revert(string)` -- confirmed these are documented exceptions (user-facing revert reason feature). No other logic ops use string reverts.

### Reference Functions
- Each op has a `referenceFn` for testing. Verified these match the `run()` semantics for each op. `LibOpConditions.referenceFn` has both even and odd input handling matching `run()`.

### `LibOpIf` Conditional Selection Logic
- Traced the expression `mload(sub(stackTop, mul(0x20, iszero(isZero))))`:
  - Condition nonzero: `isZero = false (0)`, `iszero(0) = 1`, reads `stackTop - 0x20` = then-value. Correct.
  - Condition zero: `isZero = true (1)`, `iszero(1) = 0`, reads `stackTop` = else-value. Correct.

### `LibOpConditions` Default Variable Initialization
- `conditionIsZero` declared as `bool` without initializer, defaults to `false`. With the integrity minimum of 2 inputs, the loop always executes at least once, so `conditionIsZero` is always explicitly set before the line-72 check. No issue with the default value.

## Findings

No findings at LOW or above.

The logic opcode implementations are correct. The integrity/run operand-clamping divergence (integrity clamps minimum inputs, `run()` reads raw operand) is structurally unreachable because the bytecode integrity check at deploy time ensures the IO byte matches the clamped value, and the parser produces consistent operand+IO byte pairs. The eval loop dispatches `run()` with the same operand that integrity validated, so the clamped minimum is always respected at runtime.
