# Pass 1 (Security) -- LibOpBitwiseShiftLeft (A40)

**File:** `src/lib/op/bitwise/LibOpBitwiseShiftLeft.sol` (58 lines)

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBitwiseShiftLeft` | library | 14 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 38 |
| `referenceFn` | internal pure function | 49 |

**Imports:**
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 5)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 6)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 7)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 8)
- `UnsupportedBitwiseShiftAmount` from `../../../error/ErrBitwise.sol` (line 9)

**Errors used:**
- `UnsupportedBitwiseShiftAmount(uint256 shiftAmount)` (line 27)

## Analysis

### Integrity inputs/outputs and operand validation (lines 19-32)

Returns `(1, 1)` -- one input, one output (in-place modification).

Operand extraction: `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))` -- low 16 bits, range [0, 65535].

Validation (lines 22-28):
- `shiftAmount > type(uint8).max` (> 255) -> reverts. Prevents always-zero result.
- `shiftAmount == 0` -> reverts. Prevents no-op.

Valid range after integrity: [1, 255].

### Operand extraction consistency

- `integrity` (line 20): `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`
- `run` (line 40): `and(operand, 0xFFFF)` in assembly
- `referenceFn` (line 54): `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`

Since `OperandV2` is `type OperandV2 is bytes32`, in assembly the raw `bytes32` value has its low 16 bits extracted identically by `and(operand, 0xFFFF)`. The Solidity and assembly extractions are equivalent. Consistent.

### Assembly memory safety (lines 39-41)

```solidity
assembly ("memory-safe") {
    mstore(stackTop, shl(and(operand, 0xFFFF), mload(stackTop)))
}
```

Reads `mload(stackTop)`, shifts left by `shiftAmount`, writes back to `mstore(stackTop, ...)`. In-place modification of a single stack slot. Correctly marked `memory-safe`.

**EVM `SHL` semantics:** `SHL(shift, value)` -- shift amount is the first argument. For shifts >= 256, EVM returns 0. Since integrity constrains shift to [1, 255], this is always a valid shift.

### Stack underflow/overflow

Integrity declares (1, 1). Run consumes 1 and produces 1 in-place. No risk.

### Reference function consistency

`referenceFn` uses Solidity's `<<` operator with the same shift amount. `uint256(StackItem.unwrap(inputs[0])) << shiftAmount` is equivalent to EVM `SHL(shiftAmount, value)`. Consistent.

## Findings

No findings.
