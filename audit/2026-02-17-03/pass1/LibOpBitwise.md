# Pass 1 (Security) -- Bitwise Opcodes

Audit date: 2026-02-17

## Files Reviewed

- `src/lib/op/bitwise/LibOpBitwiseAnd.sol`
- `src/lib/op/bitwise/LibOpBitwiseOr.sol`
- `src/lib/op/bitwise/LibOpCtPop.sol`
- `src/lib/op/bitwise/LibOpDecodeBits.sol`
- `src/lib/op/bitwise/LibOpEncodeBits.sol`
- `src/lib/op/bitwise/LibOpShiftBitsLeft.sol`
- `src/lib/op/bitwise/LibOpShiftBitsRight.sol`
- `src/error/ErrBitwise.sol` (supporting error definitions)

---

## Evidence of Thorough Reading

### LibOpBitwiseAnd.sol

- **Library name:** `LibOpBitwiseAnd`
- **Functions:**
  - `integrity` (line 14) -- returns (2, 1)
  - `run` (line 20) -- assembly AND of top two stack items
  - `referenceFn` (line 30) -- reference implementation using Solidity `&`
- **Errors/Events/Structs:** None defined

### LibOpBitwiseOr.sol

- **Library name:** `LibOpBitwiseOr`
- **Functions:**
  - `integrity` (line 14) -- returns (2, 1)
  - `run` (line 20) -- assembly OR of top two stack items
  - `referenceFn` (line 30) -- reference implementation using Solidity `|`
- **Errors/Events/Structs:** None defined

### LibOpCtPop.sol

- **Library name:** `LibOpCtPop`
- **Functions:**
  - `integrity` (line 20) -- returns (1, 1)
  - `run` (line 26) -- delegates to `LibCtPop.ctpop`
  - `referenceFn` (line 41) -- uses `LibCtPop.ctpopSlow` for comparison
- **Errors/Events/Structs:** None defined

### LibOpDecodeBits.sol

- **Library name:** `LibOpDecodeBits`
- **Functions:**
  - `integrity` (line 16) -- delegates to `LibOpEncodeBits.integrity` for validation, returns (1, 1)
  - `run` (line 26) -- decodes bits using operand-specified startBit and length
  - `referenceFn` (line 55) -- reference implementation using `2 ** length`
- **Errors/Events/Structs:** None defined locally; uses `ZeroLengthBitwiseEncoding` and `TruncatedBitwiseEncoding` via `LibOpEncodeBits.integrity`

### LibOpEncodeBits.sol

- **Library name:** `LibOpEncodeBits`
- **Functions:**
  - `integrity` (line 16) -- validates operand (startBit, length), returns (2, 1)
  - `run` (line 30) -- encodes source bits into target at specified position
  - `referenceFn` (line 66) -- reference implementation
- **Errors/Events/Structs:** Uses imported errors:
  - `ZeroLengthBitwiseEncoding` (line 21)
  - `TruncatedBitwiseEncoding` (line 24)

### LibOpShiftBitsLeft.sol

- **Library name:** `LibOpShiftBitsLeft`
- **Functions:**
  - `integrity` (line 16) -- validates shift amount from operand (1-255), returns (1, 1)
  - `run` (line 32) -- assembly `shl` with operand-specified amount
  - `referenceFn` (line 40) -- reference implementation using Solidity `<<`
- **Errors/Events/Structs:** Uses imported error:
  - `UnsupportedBitwiseShiftAmount` (line 24)

### LibOpShiftBitsRight.sol

- **Library name:** `LibOpShiftBitsRight`
- **Functions:**
  - `integrity` (line 16) -- validates shift amount from operand (1-255), returns (1, 1)
  - `run` (line 32) -- assembly `shr` with operand-specified amount
  - `referenceFn` (line 40) -- reference implementation using Solidity `>>`
- **Errors/Events/Structs:** Uses imported error:
  - `UnsupportedBitwiseShiftAmount` (line 24)

### ErrBitwise.sol

- **Contract name:** `ErrBitwise` (line 6, workaround for Foundry issue)
- **Errors:**
  - `UnsupportedBitwiseShiftAmount(uint256 shiftAmount)` (line 13)
  - `TruncatedBitwiseEncoding(uint256 startBit, uint256 length)` (line 19)
  - `ZeroLengthBitwiseEncoding()` (line 23)

---

## Security Findings

### Finding 1: Operand mask width inconsistency in shift opcodes (integrity vs documentation)

**Severity:** INFO

**Files:** `LibOpShiftBitsLeft.sol` (lines 17, 34), `LibOpShiftBitsRight.sol` (lines 17, 34)

**Description:** The shift opcodes extract the shift amount using a 16-bit mask (`0xFFFF`) in both `integrity` and `run`. However, `integrity` then rejects any value > 255 (uint8 max). This means the upper 8 bits of the 16-bit mask are effectively unused -- any nonzero value in bits 8-15 would be rejected by the `shiftAmount > type(uint8).max` check.

While not a security vulnerability (the integrity check is correct and the runtime mask is consistent), the 16-bit mask is wider than necessary. An 8-bit mask (`0xFF`) would be sufficient and would make the intent clearer.

**Impact:** None. The integrity check correctly bounds the shift amount to 1-255, and the EVM `SHL`/`SHR` opcodes handle any 256-bit shift amount correctly (producing 0 for amounts >= 256). Since integrity runs before `run`, the runtime shift amount is always valid.

---

### Finding 2: Assembly blocks correctly marked `memory-safe`

**Severity:** INFO

**Files:** All seven bitwise opcode files

**Description:** All assembly blocks are annotated `"memory-safe"`. Reviewing each:

- **LibOpBitwiseAnd.sol / LibOpBitwiseOr.sol** (lines 22-25): Read from `stackTop` and `stackTop + 0x20`, write to `stackTop + 0x20`. These operate within the existing stack region (memory already allocated by the interpreter). The stack grows downward, and the `run` function is given a valid `stackTop` pointer by the eval loop. The function consumes 2 slots and returns 1 (net: stack shrinks by 1 slot). The pointer arithmetic is correct. Memory-safe: **YES**.

- **LibOpCtPop.sol** (lines 28-29, 34-36): Read from and write to `stackTop` only. No pointer arithmetic. Memory-safe: **YES**.

- **LibOpDecodeBits.sol** (lines 29-31, 47-49): Read from and write to `stackTop` only. Memory-safe: **YES**.

- **LibOpEncodeBits.sol** (lines 34-38, 58-60): Read from `stackTop` and `stackTop + 0x20`, write to `stackTop + 0x20`. Same pattern as AND/OR. Memory-safe: **YES**.

- **LibOpShiftBitsLeft.sol / LibOpShiftBitsRight.sol** (lines 33-35): Read from and write to `stackTop`. No pointer arithmetic. Memory-safe: **YES**.

**Impact:** None. All assembly blocks are correctly annotated.

---

### Finding 3: Integrity inputs/outputs match `run` behavior

**Severity:** INFO

**Files:** All seven bitwise opcode files

**Description:** Verified that each `integrity` function's declared (inputs, outputs) matches what `run` actually consumes and produces:

| Opcode | integrity returns | run consumes | run produces | Match |
|--------|------------------|-------------|-------------|-------|
| BitwiseAnd | (2, 1) | 2 stack slots | 1 stack slot | YES |
| BitwiseOr | (2, 1) | 2 stack slots | 1 stack slot | YES |
| CtPop | (1, 1) | 1 stack slot | 1 stack slot | YES |
| DecodeBits | (1, 1) | 1 stack slot | 1 stack slot | YES |
| EncodeBits | (2, 1) | 2 stack slots | 1 stack slot | YES |
| ShiftBitsLeft | (1, 1) | 1 stack slot | 1 stack slot | YES |
| ShiftBitsRight | (1, 1) | 1 stack slot | 1 stack slot | YES |

**Impact:** None. All declarations are consistent with runtime behavior.

---

### Finding 4: `unchecked` blocks in bitwise operations are safe

**Severity:** INFO

**Files:** `LibOpCtPop.sol` (line 31), `LibOpDecodeBits.sol` (line 27), `LibOpEncodeBits.sol` (line 31)

**Description:** Three files use `unchecked` blocks:

- **LibOpCtPop.sol:** The `unchecked` wraps a call to `LibCtPop.ctpop()`, which itself uses an internal `unchecked` block for its Hamming weight algorithm. The outer `unchecked` is redundant but harmless. The ctpop algorithm uses only bitwise operations, shifts, and a multiply-shift that cannot produce values exceeding 256.

- **LibOpDecodeBits.sol:** The `unchecked` wraps `(1 << length) - 1` mask construction and `(value >> startBit) & mask`. Since `length` is bounded to 0-255 by the operand mask and `startBit + length <= 256` is enforced by integrity, `1 << length` can produce at most `2^255`. The subtraction of 1 from `2^255` cannot underflow. For `length == 0`, the mask would be 0 (since `(1 << 0) - 1 = 0`), but integrity rejects `length == 0` via the delegation to `LibOpEncodeBits.integrity`.

- **LibOpEncodeBits.sol:** Same mask construction pattern. The additional operations `target &= ~(mask << startBit)` and `target |= (source & mask) << startBit` are purely bitwise and cannot overflow.

**Impact:** None. All arithmetic within `unchecked` blocks is safe from overflow/underflow.

---

### Finding 5: Operand validation covers all edge cases in encode/decode

**Severity:** INFO

**Files:** `LibOpEncodeBits.sol` (lines 17-25), `LibOpDecodeBits.sol` (lines 16-22)

**Description:** `LibOpEncodeBits.integrity` validates two conditions:
1. `length == 0` reverts with `ZeroLengthBitwiseEncoding` -- prevents degenerate no-op encoding
2. `startBit + length > 256` reverts with `TruncatedBitwiseEncoding` -- prevents encoding beyond the 256-bit word boundary

`LibOpDecodeBits.integrity` delegates to `LibOpEncodeBits.integrity` to reuse these same checks. This is correct since the operand format is identical for both operations.

Note: The `startBit + length` addition in integrity (line 23 of EncodeBits) uses checked arithmetic (no `unchecked` block), so if `startBit + length` were to overflow `uint256`, it would revert. Since both values are at most 255 (masked to 8 bits each), their sum is at most 510, so overflow is impossible.

**Impact:** None. Edge cases are properly handled.

---

### Finding 6: Custom errors used correctly -- no string reverts

**Severity:** INFO

**Files:** All bitwise opcode files and `ErrBitwise.sol`

**Description:** All revert paths use custom error types defined in `src/error/ErrBitwise.sol`:
- `UnsupportedBitwiseShiftAmount(uint256)` -- used by both shift opcodes
- `TruncatedBitwiseEncoding(uint256, uint256)` -- used by encode/decode integrity
- `ZeroLengthBitwiseEncoding()` -- used by encode/decode integrity

No string revert messages are used anywhere in the bitwise opcode files. This is consistent with the project convention.

**Impact:** None. Follows project conventions correctly.

---

### Finding 7: No reentrancy concerns

**Severity:** INFO

**Files:** All seven bitwise opcode files

**Description:** All bitwise opcode functions are marked `pure` -- they make no external calls, no storage reads/writes, and no state modifications. There is zero reentrancy risk in any of these opcodes.

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW severity findings were identified in the bitwise opcode libraries. All seven files follow consistent, correct patterns for:

- Assembly memory safety
- Stack consumption/production matching integrity declarations
- Operand validation rejecting invalid values at integrity-check time
- Safe use of `unchecked` arithmetic for bitwise operations
- Custom error types (no string reverts)
- No external calls or reentrancy risk

The only observation (INFO-level, Finding 1) is that the shift opcodes use a 16-bit operand mask where an 8-bit mask would suffice, since integrity already bounds the shift amount to 1-255. This has no security impact.
