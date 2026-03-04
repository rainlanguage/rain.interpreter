# Pass 1 — Security: LibOpConstant (A30)

**File:** `src/lib/op/00/LibOpConstant.sol`

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpConstant` | library | 15 |
| `integrity` | internal pure function | 21 |
| `run` | internal pure function | 37 |
| `referenceFn` | internal pure function | 52 |

**Imports:**
- `OutOfBoundsConstantRead` (custom error from `ErrIntegrity.sol`)
- `IntegrityCheckState` (struct)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `Pointer` (user-defined value type)

## Analysis

### Operand extraction

All three functions extract the constant index identically:
`uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`, masking the low
16 bits. Consistent across integrity, run, and referenceFn.

### Integrity inputs/outputs

Returns `(0, 1)` — zero inputs consumed, one output produced. This matches the
runtime behavior: `run` does not consume any stack items and pushes exactly one
value.

### Bounds checking

`integrity()` validates `constantIndex < state.constants.length` and reverts
with `OutOfBoundsConstantRead` on failure. This is correct.

`run()` deliberately skips the bounds check (comment on line 39) and relies on
the integrity check having been run. The assembly reads
`mload(add(constants, mul(add(and(operand, 0xFFFF), 1), 0x20)))` which is
`constants[operand & 0xFFFF]` — standard memory array indexing
(`constants + 0x20 * (index + 1)`, skipping the length word). Correct.

### Assembly memory safety

The `run()` assembly block (lines 40-44) is marked `memory-safe`. It:
1. Reads from `constants` array (no write).
2. Decrements `stackTop` by 0x20 (grows stack downward into pre-allocated space).
3. Stores the value at the new `stackTop`.

This writes only within the already-allocated stack region. The interpreter
framework pre-allocates the stack based on `stackMaxIndex` from the integrity
check, so the push is within bounds. Memory-safe annotation is correct.

### Stack underflow/overflow

No stack consumption (0 inputs). One output — within the pre-allocated stack
space validated by the integrity check framework. No risk.

## Findings

No findings. The implementation is correct and secure.
