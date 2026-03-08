# Pass 1 (Security) -- Bitwise Opcodes

**Auditor**: A18
**Date**: 2026-03-07
**Files**:
- `src/lib/op/bitwise/LibOpBitwiseAnd.sol` (45 lines)
- `src/lib/op/bitwise/LibOpBitwiseCountOnes.sol` (52 lines)
- `src/lib/op/bitwise/LibOpBitwiseDecode.sol` (83 lines)
- `src/lib/op/bitwise/LibOpBitwiseEncode.sol` (104 lines)
- `src/lib/op/bitwise/LibOpBitwiseOr.sol` (45 lines)
- `src/lib/op/bitwise/LibOpBitwiseShiftLeft.sol` (58 lines)
- `src/lib/op/bitwise/LibOpBitwiseShiftRight.sol` (58 lines)

Supporting file: `src/error/ErrBitwise.sol` (23 lines)

---

## Evidence of Thorough Reading

### LibOpBitwiseAnd.sol

**Library**: `LibOpBitwiseAnd` (line 12)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 16 | Returns (2, 1). No operand validation needed. |
| `run` | 24 | Assembly: reads `mload(stackTop)` and `mload(stackTop + 0x20)`, writes AND result to `stackTop + 0x20`, returns `stackTop + 0x20`. |
| `referenceFn` | 36 | Allocates new 1-element array, returns `inputs[0] & inputs[1]`. |

**Assembly block** (lines 26-29): `stackTopAfter := add(stackTop, 0x20)`, `mstore(stackTopAfter, and(mload(stackTop), mload(stackTopAfter)))`. Marked `memory-safe`. Consumes 2 stack items, produces 1. Stack pointer advances by 0x20 (pops one item net).

### LibOpBitwiseCountOnes.sol

**Library**: `LibOpBitwiseCountOnes` (line 15)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 19 | Returns (1, 1). No operand validation needed. |
| `run` | 27 | Reads value from `stackTop`, calls `LibCtPop.ctpop` in `unchecked` block, writes result back to `stackTop`. |
| `referenceFn` | 44 | Uses `LibCtPop.ctpopSlow` on `inputs[0]`, mutates in-place, returns `inputs`. |

**Assembly blocks** (lines 29-31, 35-37): First block reads `mload(stackTop)` into `value`. Second block writes `value` back with `mstore(stackTop, value)`. Both marked `memory-safe`. In-place modification, stack pointer unchanged (1 in, 1 out).

### LibOpBitwiseDecode.sol

**Library**: `LibOpBitwiseDecode` (line 14)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 20 | Delegates to `LibOpBitwiseEncode.integrity(state, operand)` for validation (zero-length, truncation checks), then returns (1, 1). |
| `run` | 33 | Extracts `startBit` (bits 0-7) and `length` (bits 8-15) from operand. Builds mask `(1 << length) - 1`. Computes `(value >> startBit) & mask`. In-place stack modification. |
| `referenceFn` | 65 | Same logic using `2 ** length - 1` for mask. Mutates `inputs[0]` in-place, returns `inputs`. |

**Operand extraction** (lines 43-44): `startBit = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFF)))`, `length = uint256((OperandV2.unwrap(operand) >> 8) & bytes32(uint256(0xFF)))`.

**Assembly blocks** (lines 36-38, 54-56): First reads `mload(stackTop)`, second writes `mstore(stackTop, value)`. Both marked `memory-safe`. Stack pointer unchanged.

**Unchecked block** (lines 34-58): wraps entire function body. Mask computation `(1 << length) - 1` is safe because integrity guarantees `length >= 1`, so `1 << length >= 2`.

### LibOpBitwiseEncode.sol

**Library**: `LibOpBitwiseEncode` (line 13)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 19 | Extracts `startBit` and `length` from operand. Reverts `ZeroLengthBitwiseEncoding` if `length == 0` (line 24). Reverts `TruncatedBitwiseEncoding` if `startBit + length > 256` (line 27). Returns (2, 1). |
| `run` | 36 | Reads `source` from `stackTop`, `target` from `stackTop + 0x20`. Builds mask, clears target bits with `target &= ~(mask << startBit)`, inserts source bits with `target \|= (source & mask) << startBit`. Writes result to `stackTop + 0x20`, returns `stackTop + 0x20`. |
| `referenceFn` | 76 | Same encode logic using `2 ** length - 1` for mask. Allocates new output array. |

**Integrity checks** (lines 20-28):
- `startBit`: masked to low 8 bits -> range [0, 255]
- `length`: masked to bits 8-15 -> range [0, 255]
- `length == 0` -> revert (line 23-25)
- `startBit + length > 256` -> revert (line 26-28)
- Sum of two uint8 values: max 510, no uint256 overflow risk

**Assembly blocks** (lines 40-44, 65-67): First reads two stack items (source at `stackTop`, target at `stackTop + 0x20`). Second writes result to `stackTop` (which has been advanced by 0x20). Both marked `memory-safe`. Consumes 2 items, produces 1.

**Unchecked block** (lines 37-69): wraps entire function body. Mask computation safe for same reason as decode. Bitwise operations (`&=`, `|=`, `~`, `<<`) cannot overflow.

### LibOpBitwiseOr.sol

**Library**: `LibOpBitwiseOr` (line 12)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 16 | Returns (2, 1). No operand validation needed. |
| `run` | 24 | Assembly: reads `mload(stackTop)` and `mload(stackTop + 0x20)`, writes OR result to `stackTop + 0x20`, returns `stackTop + 0x20`. |
| `referenceFn` | 36 | Allocates new 1-element array, returns `inputs[0] \| inputs[1]`. |

**Assembly block** (lines 26-29): identical structure to LibOpBitwiseAnd, using `or` instead of `and`. Marked `memory-safe`. Consumes 2, produces 1.

### LibOpBitwiseShiftLeft.sol

**Library**: `LibOpBitwiseShiftLeft` (line 14)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 19 | Extracts `shiftAmount` from operand low 16 bits. Reverts `UnsupportedBitwiseShiftAmount` if `shiftAmount > 255` or `shiftAmount == 0` (lines 22-28). Returns (1, 1). |
| `run` | 38 | Assembly: `mstore(stackTop, shl(and(operand, 0xFFFF), mload(stackTop)))`. In-place, stack pointer unchanged. |
| `referenceFn` | 49 | Extracts `shiftAmount` the same way, applies Solidity `<<` operator. Mutates `inputs[0]` in-place, returns `inputs`. |

**Operand extraction**: integrity uses `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`, run uses `and(operand, 0xFFFF)`. Since `OperandV2` is `type OperandV2 is bytes32`, these are equivalent (both extract low 16 bits of the underlying 256-bit word).

**Assembly block** (lines 39-41): single instruction pattern, reads and writes same stack slot. Marked `memory-safe`. Stack pointer unchanged (1 in, 1 out).

### LibOpBitwiseShiftRight.sol

**Library**: `LibOpBitwiseShiftRight` (line 14)

**Constants**: None.

**Functions**:

| Function | Line | Description |
|---|---|---|
| `integrity` | 19 | Identical to ShiftLeft: extracts `shiftAmount` from operand low 16 bits. Reverts if `> 255` or `== 0` (lines 22-28). Returns (1, 1). |
| `run` | 38 | Assembly: `mstore(stackTop, shr(and(operand, 0xFFFF), mload(stackTop)))`. In-place, stack pointer unchanged. |
| `referenceFn` | 49 | Same extraction, applies Solidity `>>` operator. Mutates `inputs[0]` in-place, returns `inputs`. |

Structurally identical to LibOpBitwiseShiftLeft, using `shr`/`>>` instead of `shl`/`<<`.

### ErrBitwise.sol

**Errors**:

| Error | Parameters | Line |
|---|---|---|
| `UnsupportedBitwiseShiftAmount` | `uint256 shiftAmount` | 13 |
| `TruncatedBitwiseEncoding` | `uint256 startBit, uint256 length` | 19 |
| `ZeroLengthBitwiseEncoding` | (none) | 23 |

All three use custom error types (no string reverts). All have explicit `@notice` tags.

---

## Security Analysis

### 1. Memory Safety of Assembly Blocks

All assembly blocks across all 7 files are marked `memory-safe`. Verified each:

- **BitwiseAnd/BitwiseOr** (lines 26-29): reads two adjacent stack slots (`stackTop` and `stackTop + 0x20`), writes result to the higher address. Only accesses pre-existing stack memory. No allocation.
- **BitwiseCountOnes** (lines 29-31, 35-37): reads and writes the same slot at `stackTop`. No allocation.
- **BitwiseDecode** (lines 36-38, 54-56): reads and writes the same slot at `stackTop`. No allocation.
- **BitwiseEncode** (lines 40-44, 65-67): reads two stack slots, writes to the higher one. Identical pattern to AND/OR.
- **BitwiseShiftLeft/BitwiseShiftRight** (lines 39-41): reads and writes the same slot. Single-instruction pattern.

All annotations are correct. No memory expansion or free-pointer manipulation occurs.

### 2. Stack Underflow/Overflow -- Integrity vs Run Consistency

| Opcode | Integrity I/O | Run stack delta | Match |
|---|---|---|---|
| BitwiseAnd | (2, 1) | consumes 2, produces 1 (stackTop += 0x20) | Yes |
| BitwiseCountOnes | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |
| BitwiseDecode | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |
| BitwiseEncode | (2, 1) | consumes 2, produces 1 (stackTop += 0x20) | Yes |
| BitwiseOr | (2, 1) | consumes 2, produces 1 (stackTop += 0x20) | Yes |
| BitwiseShiftLeft | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |
| BitwiseShiftRight | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |

All consistent. The integrity check declares the correct number of inputs and outputs matching the actual stack behavior in `run()`.

### 3. Operand Validation

**Encode/Decode**: `startBit` and `length` are both masked to 8 bits (range 0-255). Integrity validates:
- `length != 0` (rejects zero-length encoding)
- `startBit + length <= 256` (rejects truncation)

The sum `startBit + length` has a maximum value of 510 (255 + 255), which cannot overflow uint256.

**Shift Left/Right**: `shiftAmount` extracted from low 16 bits of operand (range 0-65535). Integrity validates:
- `shiftAmount != 0` (rejects no-op)
- `shiftAmount <= 255` (rejects always-zero result)

The `run()` functions use `and(operand, 0xFFFF)` which matches the integrity extraction. Since integrity restricts to [1, 255], the EVM `SHL`/`SHR` opcodes behave correctly.

### 4. Operand Extraction Consistency

**Encode/Decode operand**: All three functions (integrity, run, referenceFn) extract `startBit` and `length` identically using `OperandV2.unwrap(operand) & bytes32(uint256(0xFF))` and `(OperandV2.unwrap(operand) >> 8) & bytes32(uint256(0xFF))`. Consistent.

**Shift operand**: Integrity and referenceFn use `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))`. Run uses `and(operand, 0xFFFF)` in assembly. Since `OperandV2` is `type OperandV2 is bytes32`, the raw stack word is the same in both cases. Consistent.

### 5. Mask Computation Correctness

**Encode/Decode run()**: `(1 << length) - 1` where `length` is in [1, 255] (guaranteed by integrity).
- `length = 1`: mask = `(1 << 1) - 1 = 1` (correct: 1-bit mask)
- `length = 255`: mask = `(1 << 255) - 1` (correct: 255-bit mask)
- EVM `SHL` for shift amounts < 256 is well-defined.

**Encode/Decode referenceFn()**: `(2 ** length) - 1`. Mathematically equivalent. For `length` in [1, 255], `2 ** length` fits in uint256 (max `2 ** 255`). In the referenceFn of encode (line 93), the expression is `(2 ** length - 1)` -- operator precedence: `**` binds tighter than `-`, so this is `(2**length) - 1`. Correct.

### 6. Unchecked Block Safety

**BitwiseCountOnes** (lines 32-34): `LibCtPop.ctpop(value)` wrapped in `unchecked`. The ctpop function performs only bitwise operations and additions that cannot overflow (population count of a 256-bit word is at most 256).

**BitwiseDecode** (lines 34-58): entire function body. `(1 << length) - 1` cannot underflow because `length >= 1` guarantees `1 << length >= 2`. The subsequent shift and AND cannot overflow.

**BitwiseEncode** (lines 37-69): entire function body. Same mask computation safety. Bitwise `&=`, `|=`, `~`, `<<` cannot overflow. The `add(stackTop, 0x20)` in assembly is a pointer increment that cannot practically overflow.

### 7. Error Handling

All errors are custom error types (no string reverts):
- `ZeroLengthBitwiseEncoding()` -- no parameters
- `TruncatedBitwiseEncoding(uint256, uint256)` -- includes startBit and length for debugging
- `UnsupportedBitwiseShiftAmount(uint256)` -- includes the rejected shift amount

All error types are defined in `src/error/ErrBitwise.sol` and properly imported where used.

### 8. ReferenceFn Correctness

Each `referenceFn` uses an independent but mathematically equivalent computation path:
- BitwiseCountOnes: `ctpopSlow` (naive bit-counting loop) vs `ctpop` (optimized bit manipulation)
- BitwiseDecode/Encode: `2 ** length` vs `1 << length` for mask computation
- BitwiseAnd/Or: Solidity `&`/`|` vs assembly `and`/`or`
- BitwiseShiftLeft/Right: Solidity `<<`/`>>` vs assembly `shl`/`shr`

This dual-path approach strengthens fuzz testing by comparing optimized implementations against trivially-correct reference implementations.

---

## Findings

No findings.

All seven bitwise opcode implementations are correct:

- Operand validation is thorough and catches zero-length, truncation, and out-of-range shift amounts at integrity-check time.
- Assembly blocks are minimal, correctly annotated as `memory-safe`, and only access stack memory within bounds guaranteed by integrity checks.
- Integrity input/output declarations match actual runtime stack behavior in all 7 opcodes.
- Operand extraction is consistent between `integrity`, `run`, and `referenceFn` in all files.
- `unchecked` blocks contain only operations that cannot overflow or underflow given integrity-enforced constraints.
- All errors use custom error types with appropriate parameters.
- Reference implementations use independent computation paths for robust fuzz testing.
