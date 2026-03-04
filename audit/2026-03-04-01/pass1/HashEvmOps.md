# Pass 1 — Security: LibOpHash (A43), LibOpBlockNumber (A54), LibOpBlockTimestamp (A55), LibOpChainId (A56)

**Files:**
- `src/lib/op/crypto/LibOpHash.sol` (A43)
- `src/lib/op/evm/LibOpBlockNumber.sol` (A54)
- `src/lib/op/evm/LibOpBlockTimestamp.sol` (A55)
- `src/lib/op/evm/LibOpChainId.sol` (A56)

---

## A43 — LibOpHash

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpHash` | library | 12 |
| `integrity` | internal pure function | 17 |
| `run` | internal pure function | 28 |
| `referenceFn` | internal pure function | 41 |

**Imports:**
- `Pointer` (user-defined value type from `rain.solmem`)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `IntegrityCheckState` (struct)

**No custom errors, events, or constants defined.**

### Analysis

#### Operand extraction

Both `integrity` and `run` extract the input count identically:
- `integrity` (line 20): `uint256(OperandV2.unwrap(operand) >> 0x10) & 0x0F`
- `run` (line 30): `and(shr(0x10, operand), 0x0F)`

These are equivalent operations. The mask `0x0F` limits the input count to 0-15. Consistent.

#### Integrity inputs/outputs vs run behavior

`integrity` returns `(inputs, 1)` where `inputs` is 0-15 from the operand.

`run` behavior:
- `length = inputs * 0x20` — byte length of the input region.
- `keccak256(stackTop, length)` — hashes `inputs` words starting at `stackTop`.
- `stackTop = stackTop + length - 0x20` — net effect: pops `inputs` items, pushes 1.

For inputs = N (N >= 1): `stackTop` moves up by `(N-1) * 0x20`, replacing N items with 1. Correct.

For inputs = 0: `length = 0`, `keccak256(stackTop, 0)` produces the keccak256 of empty bytes, `stackTop = stackTop - 0x20` (pushes 1 item, consumes 0). Integrity returns `(0, 1)`. Correct.

#### Assembly memory safety

The `run()` assembly block (lines 29-34) is marked `memory-safe`. It:
1. Reads from the stack region (`keccak256(stackTop, length)`) — within pre-allocated space.
2. Computes new `stackTop` within the stack region (the result position is between the original `stackTop` and `stackTop + length`, both within pre-allocated stack).
3. Writes one word at the new `stackTop` (`mstore(stackTop, value)`).

All accesses are within the pre-allocated stack region validated by the integrity check framework. Memory-safe annotation is correct.

#### Stack underflow/overflow

The integrity check framework validates that at least `inputs` items are on the stack before `hash` runs. The output (1 value) replaces `inputs` items, so net stack change is `-(inputs - 1)` for inputs >= 1, or `+1` for inputs = 0. Both are within bounds given integrity validation. No risk.

#### referenceFn consistency

`referenceFn` (lines 41-48) uses `keccak256(abi.encodePacked(inputs))` on the `StackItem[]` array. Since `StackItem` is a `bytes32` user-defined value type, `abi.encodePacked` on an array of `bytes32` produces a tightly-packed concatenation of 32-byte values — identical to reading consecutive 32-byte words from memory. This matches the `run()` behavior of hashing `inputs` consecutive words from the stack.

---

## A54 — LibOpBlockNumber

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBlockNumber` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 26 |
| `referenceFn` | internal view function | 39 |

**Imports:**
- `Pointer` (user-defined value type from `rain.solmem`)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `IntegrityCheckState` (struct)
- `Float`, `LibDecimalFloat` (from `rain.math.float`)

**Using declarations:**
- `LibDecimalFloat for Float` (line 14)

**No custom errors, events, or constants defined.**

### Analysis

#### Integrity inputs/outputs vs run behavior

`integrity` returns `(0, 1)` — zero inputs, one output.

`run` decrements `stackTop` by `0x20` (pushes one value) and stores `number()`. No items consumed. Consistent with `(0, 1)`.

#### Assembly memory safety

The `run()` assembly block (lines 27-30) is marked `memory-safe`. It writes one word below the current `stackTop`, which is within the pre-allocated stack region. Correct.

#### Operand validation

The operand is unused by both `integrity()` and `run()`. No validation needed.

#### referenceFn — raw value vs float identity

`run()` stores `number()` as a raw uint256. `referenceFn()` stores `Float.unwrap(fromFixedDecimalLosslessPacked(block.number, 0))`. The packed float format stores the exponent (int32) in the high 32 bits and the coefficient (int224) in the low 224 bits. With exponent = 0 and coefficient = block.number (which fits comfortably in int224 for any realistic block number), `Float.unwrap(...)` yields the same bytes32 as the raw block number. The comment on lines 34-37 documents this identity. Correct.

---

## A55 — LibOpBlockTimestamp

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBlockTimestamp` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 26 |
| `referenceFn` | internal view function | 39 |

**Imports:**
- `IntegrityCheckState` (struct)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `Pointer` (user-defined value type from `rain.solmem`)
- `Float`, `LibDecimalFloat` (from `rain.math.float`)

**Using declarations:**
- `LibDecimalFloat for Float` (line 14)

**No custom errors, events, or constants defined.**

### Analysis

Structurally identical to LibOpBlockNumber. All analysis applies symmetrically:

- `integrity` returns `(0, 1)`. `run` pushes 1, consumes 0. Consistent.
- Assembly writes one word below `stackTop` into pre-allocated space. Memory-safe.
- Operand unused by both functions. No validation needed.
- `referenceFn` uses `fromFixedDecimalLosslessPacked(block.timestamp, 0)`. The identity between raw value and packed float with exponent 0 holds for any timestamp that fits in int224 (all realistic timestamps). Correct.

---

## A56 — LibOpChainId

### Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpChainId` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 26 |
| `referenceFn` | internal view function | 39 |

**Imports:**
- `Pointer` (user-defined value type from `rain.solmem`)
- `OperandV2`, `StackItem` (user-defined value types)
- `InterpreterState` (struct)
- `IntegrityCheckState` (struct)
- `Float`, `LibDecimalFloat` (from `rain.math.float`)

**Using declarations:**
- `LibDecimalFloat for Float` (line 14)

**No custom errors, events, or constants defined.**

### Analysis

Structurally identical to LibOpBlockNumber and LibOpBlockTimestamp. All analysis applies symmetrically:

- `integrity` returns `(0, 1)`. `run` pushes 1, consumes 0. Consistent.
- Assembly writes one word below `stackTop` into pre-allocated space. Memory-safe.
- Operand unused by both functions. No validation needed.
- `referenceFn` uses `fromFixedDecimalLosslessPacked(block.chainid, 0)`. The identity holds for any chain ID that fits in int224 (all realistic chain IDs). Correct.

---

## Findings

No findings. All four implementations are correct and secure:

- **LibOpHash**: Operand extraction is consistent between integrity and run. The variable-input keccak256 hashing with assembly pointer arithmetic is correct for all input counts 0-15. Memory accesses are within pre-allocated stack bounds.
- **LibOpBlockNumber, LibOpBlockTimestamp, LibOpChainId**: Trivially correct push-one-value opcodes. The raw-value-as-float optimization is sound because `fromFixedDecimalLosslessPacked(value, 0)` is identity for non-negative integers fitting in int224.
