# Pass 1 (Security) -- Bitwise Opcodes

**Auditor**: A16
**Date**: 2026-03-01
**Files**:
- `src/lib/op/bitwise/LibOpBitwiseAnd.sol` (45 lines)
- `src/lib/op/bitwise/LibOpBitwiseOr.sol` (45 lines)
- `src/lib/op/bitwise/LibOpCtPop.sol` (55 lines)
- `src/lib/op/bitwise/LibOpDecodeBits.sol` (83 lines)
- `src/lib/op/bitwise/LibOpEncodeBits.sol` (104 lines)
- `src/lib/op/bitwise/LibOpShiftBitsLeft.sol` (58 lines)
- `src/lib/op/bitwise/LibOpShiftBitsRight.sol` (58 lines)

Supporting file: `src/error/ErrBitwise.sol` (23 lines)

---

## Evidence of Thorough Reading

### LibOpBitwiseAnd.sol

**Library**: `LibOpBitwiseAnd` (line 12)

**Imports**:

| Import | Source | Line |
|---|---|---|
| `IntegrityCheckState` | `../../integrity/LibIntegrityCheck.sol` | 5 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 6 |
| `InterpreterState` | `../../state/LibInterpreterState.sol` | 7 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 8 |

**Functions**:

| Function | Signature | Line | Inputs/Outputs |
|---|---|---|---|
| `integrity` | `(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 16 | returns (2, 1) |
| `run` | `(InterpreterState memory, OperandV2, Pointer stackTop) -> (Pointer)` | 24 | assembly: AND of top two stack items |
| `referenceFn` | `(InterpreterState memory, OperandV2, StackItem[] memory) -> (StackItem[] memory)` | 36 | allocates new array, returns `inputs[0] & inputs[1]` |

**Assembly block** (lines 26-29): reads `mload(stackTop)` and `mload(stackTopAfter)` where `stackTopAfter = stackTop + 0x20`, writes AND result to `stackTopAfter`. Consumes 2 items, produces 1. Stack grows upward (higher addresses = deeper). Correctly marked `memory-safe`.

### LibOpBitwiseOr.sol

**Library**: `LibOpBitwiseOr` (line 12)

**Imports**: identical to `LibOpBitwiseAnd`.

**Functions**: structurally identical to `LibOpBitwiseAnd`, using `or` instead of `and` in both assembly (line 28) and Solidity (line 42, `|` operator).

### LibOpCtPop.sol

**Library**: `LibOpCtPop` (line 18)

**Imports**:

| Import | Source | Line |
|---|---|---|
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 5 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 6 |
| `InterpreterState` | `../../state/LibInterpreterState.sol` | 7 |
| `IntegrityCheckState` | `../../integrity/LibIntegrityCheck.sol` | 8 |
| `LibCtPop` | `rain.math.binary/lib/LibCtPop.sol` | 9 |

**Functions**:

| Function | Signature | Line | Inputs/Outputs |
|---|---|---|---|
| `integrity` | `(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 22 | returns (1, 1) |
| `run` | `(InterpreterState memory, OperandV2, Pointer stackTop) -> (Pointer)` | 30 | reads value, calls `LibCtPop.ctpop`, writes back in-place |
| `referenceFn` | `(InterpreterState memory, OperandV2, StackItem[] memory) -> (StackItem[] memory)` | 47 | uses `ctpopSlow`, mutates inputs in-place |

**Assembly blocks** (lines 32-34, 38-40): reads from and writes to `stackTop`. In-place modification. Stack pointer unchanged (1 in, 1 out). Correctly marked `memory-safe`.

**Note**: `run` uses `LibCtPop.ctpop` (optimized) while `referenceFn` uses `LibCtPop.ctpopSlow` (naive loop). This is intentional: the reference implementation uses a trivially-correct slow path to validate the optimized path.

### LibOpDecodeBits.sol

**Library**: `LibOpDecodeBits` (line 14)

**Imports**:

| Import | Source | Line |
|---|---|---|
| `IntegrityCheckState` | `../../integrity/LibIntegrityCheck.sol` | 5 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 6 |
| `InterpreterState` | `../../state/LibInterpreterState.sol` | 7 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 8 |
| `LibOpEncodeBits` | `./LibOpEncodeBits.sol` | 9 |

**Functions**:

| Function | Signature | Line | Inputs/Outputs |
|---|---|---|---|
| `integrity` | `(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 20 | delegates to `LibOpEncodeBits.integrity`, returns (1, 1) |
| `run` | `(InterpreterState memory, OperandV2, Pointer stackTop) -> (Pointer)` | 33 | decodes bits from value using operand-specified start/length |
| `referenceFn` | `(InterpreterState memory, OperandV2, StackItem[] memory) -> (StackItem[] memory)` | 65 | same logic using `2 ** length` |

**Operand layout**: bits [0..7] = `startBit`, bits [8..15] = `length`. Extracted via `& bytes32(uint256(0xFF))` and `>> 8 & bytes32(uint256(0xFF))`.

**Integrity delegation** (lines 20-27): calls `LibOpEncodeBits.integrity(state, operand)` which validates `length != 0` and `startBit + length <= 256`, then discards the return values (encode returns (2,1), decode returns (1,1)). Slither disable comment on line 23 suppresses unused-return warning.

**Run logic** (lines 34-58): inside `unchecked` block. `mask = (1 << length) - 1`. `value = (value >> startBit) & mask`. Assembly reads/writes `stackTop` in-place.

**ReferenceFn logic** (lines 65-82): `mask = (2 ** length) - 1`. Result = `(value >> startBit) & mask`. `2 ** length` and `1 << length` are equivalent for `length` in [1, 255].

### LibOpEncodeBits.sol

**Library**: `LibOpEncodeBits` (line 13)

**Imports**:

| Import | Source | Line |
|---|---|---|
| `ZeroLengthBitwiseEncoding`, `TruncatedBitwiseEncoding` | `../../../error/ErrBitwise.sol` | 5 |
| `IntegrityCheckState` | `../../integrity/LibIntegrityCheck.sol` | 6 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 7 |
| `InterpreterState` | `../../state/LibInterpreterState.sol` | 8 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 9 |

**Functions**:

| Function | Signature | Line | Inputs/Outputs |
|---|---|---|---|
| `integrity` | `(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 19 | validates operand, returns (2, 1) |
| `run` | `(InterpreterState memory, OperandV2, Pointer stackTop) -> (Pointer)` | 36 | encodes source bits into target |
| `referenceFn` | `(InterpreterState memory, OperandV2, StackItem[] memory) -> (StackItem[] memory)` | 76 | same logic, allocates new output array |

**Integrity checks** (lines 19-30):
1. `length == 0` -> reverts `ZeroLengthBitwiseEncoding()` (line 24)
2. `startBit + length > 256` -> reverts `TruncatedBitwiseEncoding(startBit, length)` (line 27)

**Run logic** (lines 36-69): inside `unchecked` block.
1. Reads `source` from `stackTop`, advances to read `target` from `stackTop + 0x20` (lines 40-44)
2. Builds mask: `(1 << length) - 1` (line 57)
3. Clears target bits: `target &= ~(mask << startBit)` (line 60)
4. Inserts source bits: `target |= (source & mask) << startBit` (line 63)
5. Writes result to `stackTop + 0x20` (line 66)

**Assembly blocks** (lines 40-44, 65-67): reads two stack items, writes one. Correctly consumes 2, produces 1. Correctly marked `memory-safe`.

### LibOpShiftBitsLeft.sol

**Library**: `LibOpShiftBitsLeft` (line 14)

**Imports**:

| Import | Source | Line |
|---|---|---|
| `IntegrityCheckState` | `../../integrity/LibIntegrityCheck.sol` | 5 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 6 |
| `InterpreterState` | `../../state/LibInterpreterState.sol` | 7 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 8 |
| `UnsupportedBitwiseShiftAmount` | `../../../error/ErrBitwise.sol` | 9 |

**Functions**:

| Function | Signature | Line | Inputs/Outputs |
|---|---|---|---|
| `integrity` | `(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 19 | validates shift amount, returns (1, 1) |
| `run` | `(InterpreterState memory, OperandV2, Pointer stackTop) -> (Pointer)` | 38 | SHL in assembly |
| `referenceFn` | `(InterpreterState memory, OperandV2, StackItem[] memory) -> (StackItem[] memory)` | 49 | Solidity `<<` operator |

**Operand layout**: bits [0..15] = `shiftAmount`. Extracted via `& bytes32(uint256(0xFFFF))` in integrity (line 20) and `and(operand, 0xFFFF)` in run (line 40).

**Integrity check** (lines 22-28): reverts if `shiftAmount > 255` or `shiftAmount == 0`.

**Run assembly** (line 40): `shl(and(operand, 0xFFFF), mload(stackTop))`. Since integrity guarantees shiftAmount is in [1, 255], the `and(operand, 0xFFFF)` mask is safe. The EVM `SHL` opcode handles shifts >= 256 by returning 0, but integrity prevents this.

### LibOpShiftBitsRight.sol

**Library**: `LibOpShiftBitsRight` (line 14)

Structurally identical to `LibOpShiftBitsLeft`, using `shr` (line 40) and `>>` (line 55) instead of `shl`/`<<`.

### ErrBitwise.sol

**Errors**:

| Error | Parameters | Line |
|---|---|---|
| `UnsupportedBitwiseShiftAmount` | `uint256 shiftAmount` | 13 |
| `TruncatedBitwiseEncoding` | `uint256 startBit, uint256 length` | 19 |
| `ZeroLengthBitwiseEncoding` | (none) | 23 |

---

## Security Analysis

### 1. Operand Validation (startBit + length overflow)

**LibOpEncodeBits.integrity** (line 26): checks `startBit + length > 256`. Since both `startBit` and `length` are masked to `uint8` range (0-255), their sum is at most 510, which cannot overflow `uint256`. The check is correct and sufficient.

**LibOpDecodeBits.integrity** (lines 20-27): delegates to `LibOpEncodeBits.integrity`, which performs the same validation. The delegation pattern is correct -- the return values (2, 1) from encode's integrity are discarded, and decode returns (1, 1).

**Zero-length check**: `LibOpEncodeBits.integrity` line 23 checks `length == 0` before the overflow check. This prevents a zero-length encoding which would produce a zero mask (no-op for decode, or data corruption for encode).

### 2. Shift Amount Bounds

**LibOpShiftBitsLeft.integrity** and **LibOpShiftBitsRight.integrity** (lines 22-28 in both): validate `shiftAmount > type(uint8).max || shiftAmount == 0`. The operand extracts 16 bits (`0xFFFF`), so `shiftAmount` can be 0-65535. The check correctly rejects 0 (no-op) and anything > 255 (always-zero result for shift left, or always-zero for shift right on uint256).

The `run` functions use `and(operand, 0xFFFF)` which matches the integrity extraction. Since integrity restricts to [1, 255], the shift is always valid at runtime.

### 3. Assembly Safety

All 7 libraries use `assembly ("memory-safe")` annotations. Verified each:

- **BitwiseAnd/BitwiseOr**: reads two adjacent stack slots, writes to the higher one (consuming 2, producing 1). Only accesses pre-existing stack memory.
- **CtPop**: reads and writes same stack slot (1 in, 1 out). In-place modification.
- **DecodeBits**: reads and writes same stack slot (1 in, 1 out). In-place modification.
- **EncodeBits**: reads two stack slots, writes to higher one (2 in, 1 out). Same pattern as AND/OR.
- **ShiftBitsLeft/ShiftBitsRight**: reads and writes same stack slot (1 in, 1 out). Single-instruction pattern.

All annotations are correct. No memory allocation occurs in any assembly block. All reads and writes are within the stack bounds guaranteed by the integrity check.

### 4. Integrity/Run Consistency

| Opcode | Integrity I/O | Run stack delta | Consistent |
|---|---|---|---|
| BitwiseAnd | (2, 1) | consumes 2, produces 1 (+0x20 to stackTop) | Yes |
| BitwiseOr | (2, 1) | consumes 2, produces 1 (+0x20 to stackTop) | Yes |
| CtPop | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |
| DecodeBits | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |
| EncodeBits | (2, 1) | consumes 2, produces 1 (+0x20 to stackTop) | Yes |
| ShiftBitsLeft | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |
| ShiftBitsRight | (1, 1) | consumes 1, produces 1 (stackTop unchanged) | Yes |

### 5. Operand Extraction Consistency

For encode/decode bits, the operand extraction uses `& bytes32(uint256(0xFF))` for low byte and `>> 8 & bytes32(uint256(0xFF))` for second byte. This is consistent across `integrity`, `run`, and `referenceFn` in both libraries. The `run` function operates in Solidity (not assembly) for operand extraction, so there is no `bytes32` vs `uint256` representation concern.

For shift ops, integrity uses `uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)))` and run uses `and(operand, 0xFFFF)`. Since `OperandV2` is `type OperandV2 is bytes32`, and `bytes32`/`uint256` have identical EVM stack representation (both are 256-bit words), these are equivalent. The `referenceFn` uses the same Solidity extraction as integrity. Consistent.

### 6. Mask Computation Correctness

**Encode/Decode**: `(1 << length) - 1` where `length` is in [1, 255] (guaranteed by integrity). For `length = 255`: `1 << 255` is a valid `uint256` value, and `(1 << 255) - 1` produces a 255-bit mask. For `length = 1`: produces mask `1`. All values are correct.

The `referenceFn` uses `2 ** length - 1` which is mathematically equivalent. Operator precedence: `**` binds tighter than `-`, so this is `(2 ** length) - 1`. For all valid lengths, `2 ** length` fits in `uint256` (max is `2 ** 255`).

### 7. Unchecked Block Safety

**LibOpDecodeBits.run** (lines 34-58): the entire function body is `unchecked`. The mask computation `(1 << length) - 1` cannot underflow because `length >= 1` (guaranteed by integrity), so `1 << length >= 2`, and `2 - 1 = 1`. The shift and AND operations cannot overflow by nature.

**LibOpEncodeBits.run** (lines 37-69): same `unchecked` block. The mask computation is safe for the same reason. The bitwise operations (`&=`, `|=`, `~`, `<<`) cannot overflow by nature. The `add(stackTop, 0x20)` in assembly (line 42) is an address increment that cannot practically overflow (would require `stackTop` near `2^256 - 32`).

---

## Findings

### A16-5: Missing `@notice` tag on `ZeroLengthBitwiseEncoding` error NatSpec [INFORMATIONAL]

**File**: `src/error/ErrBitwise.sol`, lines 21-23

The `ZeroLengthBitwiseEncoding` error doc block uses bare `///` without a `@notice` tag:

```solidity
/// Thrown during integrity check when the length of a bitwise (en|de)coding
/// would be 0.
error ZeroLengthBitwiseEncoding();
```

The other two errors in the same file (`UnsupportedBitwiseShiftAmount` at line 8, `TruncatedBitwiseEncoding` at line 15) both use explicit `/// @notice`. While bare `///` is implicitly `@notice` when no other tags are present (which is the case here), this is inconsistent with the adjacent error declarations in the same file.

**Severity**: INFORMATIONAL -- no functional or security impact.

---

## Summary

No LOW or higher severity findings were identified. The bitwise opcode implementations are well-structured:

- Operand validation is thorough: `startBit + length` overflow is checked, zero-length is rejected, shift amounts are bounded to [1, 255].
- Assembly blocks are minimal, correctly annotated as `memory-safe`, and only access stack memory within bounds guaranteed by integrity checks.
- Integrity input/output declarations match actual run-time stack behavior in all 7 opcodes.
- Operand extraction is consistent between `integrity`, `run`, and `referenceFn` across all files.
- `unchecked` blocks contain only operations that cannot overflow given the integrity-enforced constraints.
- The `referenceFn` implementations use equivalent but independent computation paths (`2 ** length` vs `1 << length`, `ctpopSlow` vs `ctpop`) which strengthens the testing strategy.
