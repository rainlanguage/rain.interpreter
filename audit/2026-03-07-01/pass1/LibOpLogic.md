# Pass 1: Security Review -- Logic Opcodes

**Agent:** A19
**Date:** 2026-03-07
**Scope:** `src/lib/op/logic/` (12 files)

## Evidence of Reading

### 1. LibOpAny.sol (78 lines)
- **Library:** `LibOpAny`
- `integrity` (line 21): returns `(max(inputs, 1), 1)` where `inputs = operand >> 0x10 & 0x0F`
- `run` (line 33): scans N items from stack, returns first nonzero; if all zero, returns last item (which is zero)
- `referenceFn` (line 60): reference implementation iterating `inputs[]` array

### 2. LibOpBinaryEqualTo.sol (47 lines)
- **Library:** `LibOpBinaryEqualTo`
- `integrity` (line 17): returns `(2, 1)`
- `run` (line 26): EVM `eq` opcode on two raw `bytes32` values (bitwise equality, not float)
- `referenceFn` (line 38): reference using `==` on `StackItem`

### 3. LibOpConditions.sol (107 lines)
- **Library:** `LibOpConditions`
- `integrity` (line 23): returns `(max(inputs, 2), 1)` where `inputs = operand >> 0x10 & 0x0F`
- `run` (line 40): pairwise condition/value scan; odd input count means last item is revert reason; reverts if no condition is nonzero
- `referenceFn` (line 82): reference with same pairwise logic

### 4. LibOpEnsure.sol (61 lines)
- **Library:** `LibOpEnsure`
- `integrity` (line 22): returns `(2, 0)`
- `run` (line 32): reads condition + reason, reverts with reason string if condition is float-zero
- `referenceFn` (line 50): reference using `require()`

### 5. LibOpEqualTo.sol (63 lines)
- **Library:** `LibOpEqualTo`
- `integrity` (line 21): returns `(2, 1)`
- `run` (line 30): decimal float equality via `a.eq(b)`
- `referenceFn` (line 52): reference using `Float.eq()`

### 6. LibOpEvery.sol (76 lines)
- **Library:** `LibOpEvery`
- `integrity` (line 21): returns `(max(inputs, 1), 1)` where `inputs = operand >> 0x10 & 0x0F`
- `run` (line 32): scans N items, returns last item if all nonzero, else 0
- `referenceFn` (line 58): reference iterating `inputs[]` array

### 7. LibOpGreaterThan.sol (57 lines)
- **Library:** `LibOpGreaterThan`
- `integrity` (line 20): returns `(2, 1)`
- `run` (line 28): decimal float greater-than via `a.gt(b)`
- `referenceFn` (line 46): reference using `Float.gt()`

### 8. LibOpGreaterThanOrEqualTo.sol (58 lines)
- **Library:** `LibOpGreaterThanOrEqualTo`
- `integrity` (line 20): returns `(2, 1)`
- `run` (line 29): decimal float greater-than-or-equal via `a.gte(b)`
- `referenceFn` (line 47): reference using `Float.gte()`

### 9. LibOpIf.sol (55 lines)
- **Library:** `LibOpIf`
- `integrity` (line 20): returns `(3, 1)`
- `run` (line 29): reads condition, skips 2 slots, selects value_if_true or value_if_false based on float-zero check
- `referenceFn` (line 47): reference using ternary

### 10. LibOpIsZero.sol (50 lines)
- **Library:** `LibOpIsZero`
- `integrity` (line 19): returns `(1, 1)`
- `run` (line 27): decimal float is-zero check, returns boolean (0 or 1)
- `referenceFn` (line 42): reference using `Float.isZero()`

### 11. LibOpLessThan.sol (57 lines)
- **Library:** `LibOpLessThan`
- `integrity` (line 20): returns `(2, 1)`
- `run` (line 28): decimal float less-than via `a.lt(b)`
- `referenceFn` (line 46): reference using `Float.lt()`

### 12. LibOpLessThanOrEqualTo.sol (58 lines)
- **Library:** `LibOpLessThanOrEqualTo`
- `integrity` (line 20): returns `(2, 1)`
- `run` (line 29): decimal float less-than-or-equal via `a.lte(b)`
- `referenceFn` (line 47): reference using `Float.lte()`

## Security Analysis

### Memory Safety

All 12 files use `assembly ("memory-safe")` blocks. Every block operates strictly within the stack region bounded by `stackTop` and `stackTop + inputs * 0x20`. No block allocates new memory, reads beyond declared input bounds, or writes beyond the declared output position. The `memory-safe` annotations are valid.

### Stack Consistency (integrity vs run)

For each opcode, the integrity function's declared `(inputs, outputs)` was verified against the `run` function's actual stack movement (`stackTop` delta = `(inputs - outputs) * 0x20`):

| Opcode | Integrity | stackTop delta | Match |
|---|---|---|---|
| any | (N, 1) | +(N-1)*0x20 | Yes |
| binary-equal-to | (2, 1) | +0x20 | Yes |
| conditions | (N, 1) | +(N-1)*0x20 | Yes |
| ensure | (2, 0) | +0x40 | Yes |
| equal-to | (2, 1) | +0x20 | Yes |
| every | (N, 1) | +(N-1)*0x20 | Yes |
| greater-than | (2, 1) | +0x20 | Yes |
| greater-than-or-equal-to | (2, 1) | +0x20 | Yes |
| if | (3, 1) | +0x40 | Yes |
| is-zero | (1, 1) | 0 | Yes |
| less-than | (2, 1) | +0x20 | Yes |
| less-than-or-equal-to | (2, 1) | +0x20 | Yes |

### Operand Validation

`LibOpAny`, `LibOpEvery`, and `LibOpConditions` extract input counts from `operand >> 0x10 & 0x0F`. All three use `handleOperandDisallowed` as their operand handler (verified in `LibAllStandardOps.sol`), meaning the low 16 bits of the operand are always 0. The high nibble (bits 16-19) is set by the parser based on the number of parenthesized arguments.

The integrity functions clamp minimum inputs (any/every: 1, conditions: 2). The integrity checker in `LibIntegrityCheck.sol` (line 163-164) enforces that the integrity-computed inputs/outputs match the bytecode-encoded io byte. This means a bytecode with an input count that would be clamped (e.g., 0 inputs for `any`) would fail integrity with `BadOpInputsLength`, preventing execution of `run()` with the clamped value.

### Custom Errors

`LibOpConditions` and `LibOpEnsure` use `revert(string)` rather than custom error types. These are intentional: they surface user-authored revert messages from Rainlang expressions (the `ensure` opcode and `conditions` fallback). The string content comes from the expression's stack (`IntOrAString` encoding). This is a deliberate design choice for the expression runtime and not a violation of the custom-error convention for library/contract-level errors.

### Edge Cases Verified

- **LibOpAny with all-zero inputs:** Loop exits without writing to `stackTop`. The value at `stackTop` (`end - 0x20`) is the last input item, which is zero. Output is correctly 0.
- **LibOpEvery with all-nonzero inputs:** Loop exits without writing 0. The value at `stackTop` (`end - 0x20`) is the last input, which is nonzero. Output is correctly the last value.
- **LibOpConditions with even inputs and no match:** Reverts with `IntOrAString.wrap(0).toStringV3()`, which produces an empty string. Matches reference `revert("")`.
- **LibOpConditions with odd inputs and no match:** Reverts with user-provided reason string from the last stack item.
- **LibOpIf self-write:** When condition is zero, the code does `mstore(stackTop, mload(stackTop))` -- a harmless self-write that preserves the value_if_false already at that position.

## Findings

No findings. All 12 logic opcode libraries have correct memory access patterns, consistent integrity/run stack behavior, proper operand validation (delegated to parser and integrity checker), and valid `memory-safe` annotations.
