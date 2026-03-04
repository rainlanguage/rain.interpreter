# Pass 1 — Security: LibOpStack (A33)

**File:** `src/lib/op/00/LibOpStack.sol`

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpStack` | library | 15 |
| `integrity` | internal pure function | 21 |
| `run` | internal pure function | 41 |
| `referenceFn` | internal pure function | 58 |

**Imports:**
- `Pointer` (user-defined value type)
- `InterpreterState` (struct)
- `IntegrityCheckState` (struct)
- `OperandV2`, `StackItem` (user-defined value types)
- `OutOfBoundsStackRead` (custom error)

## Analysis

### Operand extraction

All three functions extract `readIndex = operand & 0xFFFF` (low 16 bits).
`integrity()` uses `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`.
`run()` uses `and(operand, 0xFFFF)` in assembly. `referenceFn()` uses the same
Solidity expression as `integrity()`. Consistent.

### Integrity inputs/outputs

Returns `(0, 1)` — zero inputs consumed, one output produced. This is correct:
the `stack` opcode copies a value from a previous stack position without
consuming any inputs.

### Bounds checking

Line 24: `if (readIndex >= state.stackIndex)` — validates the read index is
within the current logical stack depth. Reverts with `OutOfBoundsStackRead`.
This prevents reading beyond the stack's current extent.

### Read highwater update

Lines 29-31: `if (readIndex > state.readHighwater) { state.readHighwater = readIndex; }`.

This updates the read highwater to track the deepest stack position that has been
read by copy. The integrity check framework (LibIntegrityCheck.sol line 176)
prevents subsequent opcodes from consuming below this highwater via
`StackUnderflowHighwater`. This prevents a scenario where a copied value is
consumed by a later opcode, leaving the original stack position as a dangling
reference.

Note: `readHighwater` in the `IntegrityCheckState` struct tracks the highest
index that has been read (or the region below which consumption is disallowed).
The framework sets `state.readHighwater = state.stackIndex` when an opcode
produces multiple outputs (line 191). The `stack` opcode sets it to `readIndex`
when that index exceeds the current highwater. Both uses prevent consumption
below read points. This is correct.

### Assembly in run()

Lines 43-48:
```
let stackBottom := mload(add(mload(state), mul(0x20, add(sourceIndex, 1))))
let stackValue := mload(sub(stackBottom, mul(0x20, add(and(operand, 0xFFFF), 1))))
stackTop := sub(stackTop, 0x20)
mstore(stackTop, stackValue)
```

1. `mload(state)` — first field of `InterpreterState` struct, which is
   `stackBottoms` (a `Pointer[]`).
2. `mload(add(mload(state), mul(0x20, add(sourceIndex, 1))))` — reads
   `stackBottoms[sourceIndex]`. The `+1` skips the array length word.
3. `sub(stackBottom, mul(0x20, add(and(operand, 0xFFFF), 1)))` — reads the
   value at position `readIndex` below the stack bottom. Stack grows downward,
   so `stackBottom - 0x20 * (readIndex + 1)` is the address of the value at
   logical index `readIndex`.
4. Pushes the value onto the stack top.

This relies on the integrity check having validated that `readIndex` is within
bounds. The assembly does no bounds checking itself. Correct by design.

### Assembly memory safety

The assembly block (lines 43-48) is marked `memory-safe`. It:
1. Reads from the `state` struct and `stackBottoms` array (no write).
2. Reads from the stack at a validated position (no write).
3. Writes one value to the stack at the new `stackTop` position.

All writes are within pre-allocated stack space. Correct.

### referenceFn bounds checking

Line 66: `state.stackBottoms[state.sourceIndex]` — Solidity bounds-checked
array access. Line 67: `stackBottom - (readIndex + 1) * 0x20` — arithmetic on
raw pointer values, then assembly read at line 70. The `readIndex` was validated
by integrity before runtime, so this is consistent with `run()`.

## Findings

No findings. The implementation correctly validates stack read bounds at
integrity time, properly updates the read highwater to prevent consumption of
copied values, and uses safe assembly patterns.
