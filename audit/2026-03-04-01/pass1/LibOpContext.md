# Pass 1 — Security: LibOpContext (A31)

**File:** `src/lib/op/00/LibOpContext.sol`

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpContext` | library | 12 |
| `integrity` | internal pure function | 16 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 47 |

**Imports:**
- `Pointer` (user-defined value type)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `IntegrityCheckState` (struct)

## Analysis

### Operand extraction

`run()` and `referenceFn()` both extract:
- `i = operand & 0xFF` (low byte — row index)
- `j = (operand >> 8) & 0xFF` (second byte — column index)

Both use identical extraction logic. Consistent.

### Integrity inputs/outputs

Returns `(0, 1)`. The comment at line 17-20 explains that context shape is
unknown at integrity time, so no operand validation is possible. This is a
design-correct decision — context is caller-provided at eval time.

### Runtime bounds checking

Line 35: `bytes32 v = state.context[i][j];` — this is Solidity array access,
which includes automatic bounds checking. If `i >= context.length` or
`j >= context[i].length`, the EVM will revert with a panic. This is the
intentional design (documented in comments on lines 31-34).

### Assembly memory safety

The assembly block (lines 36-39) is marked `memory-safe`. It:
1. Decrements `stackTop` by 0x20.
2. Stores value `v` at new `stackTop`.

Only writes within pre-allocated stack region. Correct.

### Stack underflow/overflow

Zero inputs, one output. Pre-allocated stack space. No risk.

## Findings

No findings. The runtime Solidity bounds check on context access is the correct
approach given that context shape is unknown at integrity time.
