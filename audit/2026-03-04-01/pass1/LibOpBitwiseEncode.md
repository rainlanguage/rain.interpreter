# Pass 1 (Security) -- LibOpBitwiseEncode (A38)

**File:** `src/lib/op/bitwise/LibOpBitwiseEncode.sol` (104 lines)

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBitwiseEncode` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 36 |
| `referenceFn` | internal pure function | 76 |

**Imports:**
- `ZeroLengthBitwiseEncoding`, `TruncatedBitwiseEncoding` from `../../../error/ErrBitwise.sol` (line 5)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 6)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 7)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 8)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 9)

**Errors used:**
- `ZeroLengthBitwiseEncoding()` (line 24)
- `TruncatedBitwiseEncoding(uint256 startBit, uint256 length)` (line 27)

## Analysis

### Integrity inputs/outputs and operand validation (lines 19-30)

Returns `(2, 1)` -- two inputs (source, target), one output (modified target).

Operand validation:
1. `startBit = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFF)))` -- low 8 bits, range [0, 255]
2. `length = uint256((OperandV2.unwrap(operand) >> 8) & bytes32(uint256(0xFF)))` -- bits 8-15, range [0, 255]
3. `length == 0` -> reverts `ZeroLengthBitwiseEncoding()` (line 24)
4. `startBit + length > 256` -> reverts `TruncatedBitwiseEncoding(startBit, length)` (line 27)

**Overflow check:** `startBit` max is 255, `length` max is 255, so `startBit + length` max is 510. No `uint256` overflow. The check `> 256` correctly prevents encoding past the 256-bit boundary.

### Operand extraction consistency

All three functions extract `startBit` and `length` identically using `& bytes32(uint256(0xFF))` and `>> 8 & bytes32(uint256(0xFF))`. Consistent.

### Run logic (lines 36-69)

Inside `unchecked` block:
1. Reads `source` from `mload(stackTop)`, then advances `stackTop += 0x20` and reads `target` from the new position (lines 40-44)
2. Extracts `startBit` and `length` from operand (lines 49-50)
3. Builds mask: `(1 << length) - 1` (line 57)
4. Clears target bits: `target &= ~(mask << startBit)` (line 60)
5. Fills with source bits: `target |= (source & mask) << startBit` (line 63)
6. Writes result to `mstore(stackTop, target)` (line 66)

**Mask computation safety:** `length` in [1, 255] (guaranteed by integrity). `1 << length` is valid. `- 1` cannot underflow.

**Shift safety:** `mask << startBit` -- `startBit` in [0, 255]. Since integrity guarantees `startBit + length <= 256`, the mask shifted left by `startBit` stays within 256 bits. No truncation occurs at the high end.

**Source masking:** `source & mask` ensures only the low `length` bits of source are used. Any high bits in source beyond the mask are discarded. This is correct -- it prevents the source from corrupting bits outside the encoded region.

### Assembly memory safety

**Block 1 (lines 40-44):** Reads two stack items, advances `stackTop`. Reads only.
**Block 2 (lines 65-67):** Writes `target` to `stackTop`. Writes to pre-existing stack memory.

Both correctly marked `memory-safe`. The pattern consumes 2 items and produces 1 (stackTop moves up by 0x20 from the original position).

### Unchecked block safety (lines 37-69)

All operations are bitwise (AND, OR, NOT, shift) or the mask computation analyzed above. The `add(stackTop, 0x20)` in assembly cannot practically overflow. Safe.

### Reference function consistency

`referenceFn` uses `2 ** length - 1` for the mask. Operator precedence: `**` binds tighter than `-`, so this is `(2 ** length) - 1`, equivalent to `(1 << length) - 1`. The rest of the logic (clear + fill) is identical. Consistent.

## Findings

No findings.
