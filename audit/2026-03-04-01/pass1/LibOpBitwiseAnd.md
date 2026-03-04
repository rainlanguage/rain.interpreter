# Pass 1 (Security) -- LibOpBitwiseAnd (A35)

**File:** `src/lib/op/bitwise/LibOpBitwiseAnd.sol` (45 lines)

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBitwiseAnd` | library | 12 |
| `integrity` | internal pure function | 16 |
| `run` | internal pure function | 24 |
| `referenceFn` | internal pure function | 36 |

**Imports:**
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 5)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 6)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 7)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 8)

No custom errors, constants, or types defined.

## Analysis

### Integrity inputs/outputs

Returns `(2, 1)` -- two inputs consumed, one output produced. Matches the runtime behavior: `run` reads two stack items and writes one.

### Assembly memory safety (lines 26-29)

```solidity
assembly ("memory-safe") {
    stackTopAfter := add(stackTop, 0x20)
    mstore(stackTopAfter, and(mload(stackTop), mload(stackTopAfter)))
}
```

Reads `mload(stackTop)` (top item) and `mload(stackTopAfter)` (second item, at stackTop + 0x20). Writes the AND result to `stackTopAfter`. This consumes 2 items and produces 1 by moving the stack pointer up by 0x20. Only accesses pre-existing stack memory. Correctly marked `memory-safe`.

### Stack underflow/overflow

Integrity declares (2, 1). Run consumes 2 and produces 1. The integrity check framework ensures at least 2 items are on the stack before this opcode executes. No risk.

### Operand validation

The operand is unused -- ignored in all three functions. No validation needed.

### Reference function consistency

`referenceFn` computes `inputs[0] & inputs[1]` using Solidity's `&` operator on `bytes32` values, which is equivalent to the assembly `and()`. Consistent.

## Findings

No findings.
