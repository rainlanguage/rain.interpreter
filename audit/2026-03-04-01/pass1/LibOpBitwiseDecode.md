# Pass 1 (Security) -- LibOpBitwiseDecode (A37)

**File:** `src/lib/op/bitwise/LibOpBitwiseDecode.sol` (83 lines)

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBitwiseDecode` | library | 14 |
| `integrity` | internal pure function | 20 |
| `run` | internal pure function | 33 |
| `referenceFn` | internal pure function | 65 |

**Imports:**
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 5)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 6)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 7)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 8)
- `LibOpBitwiseEncode` from `./LibOpBitwiseEncode.sol` (line 9)

No custom errors defined locally (uses errors from `LibOpBitwiseEncode`'s integrity delegation).

## Analysis

### Integrity inputs/outputs and operand validation

Returns `(1, 1)`. Before returning, delegates to `LibOpBitwiseEncode.integrity(state, operand)` (line 24) which validates:
1. `length != 0` -- reverts `ZeroLengthBitwiseEncoding()`
2. `startBit + length <= 256` -- reverts `TruncatedBitwiseEncoding(startBit, length)`

The return values from the encode integrity call `(2, 1)` are intentionally discarded (slither suppression on line 23). Decode correctly returns `(1, 1)` since it only takes one input (the value to decode from) vs encode's two (source + target).

### Operand extraction consistency

All three functions extract operand bits identically:
- `startBit`: `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFF)))` -- low 8 bits
- `length`: `uint256((OperandV2.unwrap(operand) >> 8) & bytes32(uint256(0xFF)))` -- bits 8-15

Consistent across `integrity` (via encode delegation), `run` (lines 43-44), and `referenceFn` (lines 73-74).

### Run logic (lines 33-58)

Inside `unchecked` block:
1. Reads value from `mload(stackTop)` (line 37)
2. Extracts `startBit` and `length` from operand (lines 43-44)
3. Builds mask: `(1 << length) - 1` (line 51)
4. Computes: `value = (value >> startBit) & mask` (line 52)
5. Writes result back to `mstore(stackTop, value)` (line 55)

**Mask computation safety:** `length` is in [1, 255] (guaranteed by integrity). `1 << length` is valid for all these values -- max is `1 << 255` which fits in `uint256`. The subtraction `- 1` cannot underflow since `1 << length >= 2`.

**Shift safety:** `startBit` is in [0, 255]. `value >> startBit` is always valid. Even if `startBit = 0`, the shift is a no-op (correct behavior for decoding from bit 0).

### Assembly memory safety

**Block 1 (lines 36-38):** Reads `mload(stackTop)`. Read-only.
**Block 2 (lines 54-56):** Writes `mstore(stackTop, value)`. In-place modification.

Both correctly marked `memory-safe`.

### Unchecked block safety (lines 34-58)

All arithmetic is bitwise operations (shift, AND) and the mask computation which cannot underflow as analyzed above. Safe.

### Reference function consistency

`referenceFn` uses `2 ** length - 1` for the mask vs `(1 << length) - 1` in `run`. These are mathematically equivalent for `length` in [1, 255]. Both `2 ** 255` and `1 << 255` are the same `uint256` value.

## Findings

No findings.
