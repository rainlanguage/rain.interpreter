# Pass 5: Correctness Audit -- Eval, Integrity, State, Parse, Core Ops

**Agent:** A02
**Date:** 2026-03-08

**Files reviewed:**
1. `src/lib/eval/LibEval.sol` (251 lines)
2. `src/lib/integrity/LibIntegrityCheck.sol` (211 lines)
3. `src/lib/state/LibInterpreterState.sol` (144 lines)
4. `src/lib/state/LibInterpreterStateDataContract.sol` (144 lines)
5. `src/lib/parse/LibParse.sol` (459 lines)
6. `src/lib/parse/LibParseState.sol` (1069 lines)
7. `src/lib/op/LibAllStandardOps.sol` (754 lines)
8. `src/lib/op/call/LibOpCall.sol` (172 lines)
9. `src/lib/op/00/LibOpExtern.sol` (125 lines)

---

## Evidence of Thorough Reading

### LibEval.sol

**Library:** `LibEval` (line 15)
**Functions:**
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `evalLoop` | 41 | internal | view |
| `eval4` | 191 | internal | view |

**Constants/Errors:** Uses `InputsLengthMismatch` from ErrEval.sol (line 13).

### LibIntegrityCheck.sol

**Library:** `LibIntegrityCheck` (line 44)
**Struct:** `IntegrityCheckState` (lines 35-42) -- 6 fields: `stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`.
**Functions:**
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `newState` | 56 | internal | pure |
| `integrityCheck2` | 91 | internal | view |

**Errors:** `OpcodeOutOfRange` (line 157), `StackAllocationMismatch` (line 200), `StackOutputsMismatch` (line 205), `StackUnderflow` (line 171), `StackUnderflowHighwater` (line 177), `BadOpInputsLength` (line 164), `BadOpOutputsLength` (line 167).

### LibInterpreterState.sol

**Library:** `LibInterpreterState` (line 55)
**Struct:** `InterpreterState` (lines 42-53) -- 9 fields.
**Constant:** `STACK_TRACER` (line 17) -- deterministic address from keccak hash.
**Functions:**
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `stackBottoms` | 62 | internal | pure |
| `stackTrace` | 126 | internal | view |

### LibInterpreterStateDataContract.sol

**Library:** `LibInterpreterStateDataContract` (line 14)
**Functions:**
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `serializeSize` | 26 | internal | pure |
| `unsafeSerialize` | 39 | internal | pure |
| `unsafeDeserialize` | 69 | internal | pure |

### LibParse.sol

**Library:** `LibParse` (line 75)
**Constants:** `SUB_PARSER_BYTECODE_HEADER_SIZE = 5` (line 59), `MAX_PAREN_OFFSET = 59` (line 66).
**Functions:**
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `parseWord` | 106 | internal | pure |
| `parseLHS` | 142 | internal | pure |
| `parseRHS` | 220 | internal | view |
| `parse` | 435 | internal | view |

### LibParseState.sol

**Library:** `LibParseState` (line 194)
**Struct:** `ParseState` (line 162) -- 18 fields.
**Constants:**
| Name | Line | Value |
|------|------|-------|
| `EMPTY_ACTIVE_SOURCE` | 32 | 0x20 |
| `FSM_YANG_MASK` | 36 | 1 |
| `FSM_WORD_END_MASK` | 39 | 1 << 1 |
| `FSM_ACCEPTING_INPUTS_MASK` | 42 | 1 << 2 |
| `FSM_ACTIVE_SOURCE_MASK` | 46 | 1 << 3 |
| `FSM_DEFAULT` | 52 | FSM_ACCEPTING_INPUTS_MASK |
| `OPERAND_VALUES_LENGTH` | 63 | 4 |
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | 67 | 0x20 |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | 71 | 0x21 |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | 75 | 0x60 |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | 79 | 0xa0 |
| `MAX_STACK_RHS_OFFSET` | 85 | 0x3f |

**Functions:**
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `newActiveSourcePointer` | 210 | internal | pure |
| `resetSource` | 231 | internal | pure |
| `newState` | 257 | internal | pure |
| `pushSubParser` | 318 | internal | pure |
| `exportSubParsers` | 338 | internal | pure |
| `snapshotSourceHeadToLineTracker` | 367 | internal | pure |
| `endLine` | 402 | internal | pure |
| `highwater` | 528 | internal | pure |
| `constantValueBloom` | 553 | internal | pure |
| `pushConstantValue` | 561 | internal | pure |
| `pushLiteral` | 591 | internal | view |
| `pushOpToSource` | 666 | internal | pure |
| `endSource` | 773 | internal | pure |
| `buildBytecode` | 915 | internal | pure |
| `buildConstants` | 1009 | internal | pure |
| `checkParseMemoryOverflow` | 1059 | internal | pure |

### LibAllStandardOps.sol

**Library:** `LibAllStandardOps` (line 110)
**Constant:** `ALL_STANDARD_OPS_LENGTH = 72` (line 105)
**Functions:** `authoringMetaV2` (line 120), `literalParserFunctionPointers` (line 344), `operandHandlerFunctionPointers` (line 377), `integrityFunctionPointers` (line 549), `opcodeFunctionPointers` (line 653).

### LibOpCall.sol

**Library:** `LibOpCall` (line 69)
**Functions:** `integrity` (line 85), `run` (line 122).
**Operand layout:** bits [0,16) = sourceIndex, bits [16,20) = inputs (IO byte low nibble), bits [20,24) = outputs (IO byte high nibble).

### LibOpExtern.sol

**Library:** `LibOpExtern` (line 23)
**Functions:** `integrity` (line 29), `run` (line 49), `referenceFn` (line 102).
**Operand layout:** bits [0,16) = encodedExternDispatchIndex, bits [16,20) = inputs, bits [20,24) = outputs.

---

## Correctness Verification

### 1. Eval Loop Opcode Dispatch (LibEval.sol lines 91-155)

**Claim:** Each 4-byte opcode in a 32-byte word is correctly extracted by the unrolled loop.

**Verification:**
- Opcode N (N=0..7) uses `byte(N*4, word)` for the opcode index and `shr(0xe0 - N*0x20, word) & 0xFFFFFF` for the 24-bit operand.
- Verified all 8 iterations: byte offsets [0, 4, 8, 12, 16, 20, 24, 28] and shift amounts [0xe0, 0xc0, 0xa0, 0x80, 0x60, 0x40, 0x20, 0x00]. All correct.
- Remainder loop (lines 157-172): `cursor -= 0x1c` repositions to read via `byte(28, word)` and `and(word, 0xFFFFFF)`. The loop processes `m = opsLength mod 8` remaining opcodes, advancing by 4 bytes each. Correct.
- All opcode indices are bounded by `mod(byte(...), fsCount)`. The `Rainterpreter` constructor prevents `fsCount == 0`.

### 2. Integrity Check IO Extraction (LibIntegrityCheck.sol lines 147-155)

**Claim:** The integrity check extracts the same opcode index, operand, and IO byte that the eval loop will use.

**Verification:**
- Cursor is set to `sourcePointer - 0x18` so that `byte(28, mload(cursor))` reads the first opcode byte. Each `cursor += 4` advances to the next opcode.
- `opcodeIndex = byte(28, word)` = opcode index byte. Matches eval's `byte(28, word)` in the remainder loop.
- `operand = and(word, 0xFFFFFF)` = low 3 bytes = [IO_byte, operand_high, operand_low]. Matches eval's `and(word, 0xFFFFFF)`.
- `ioByte = byte(29, word)` = second byte of the 4-byte opcode = IO byte.
- `bytecodeOpInputs = and(ioByte, 0x0F)` = low nibble (max 15). Correct.
- `bytecodeOpOutputs = shr(4, ioByte)` = high nibble (max 15, since ioByte is a single byte). Correct.

**The operand that is passed to both integrity functions and runtime functions includes the IO byte in bits [16,24).** This is by design: opcodes that need input/output counts read them from those positions (e.g., `LibOpCall.run` extracts `inputs = (operand >> 0x10) & 0x0F` and `outputs = operand >> 0x14`).

### 3. Integrity vs. Runtime Operand Consistency

**Verified for each core opcode:**

- **LibOpStack:** Both `integrity` and `run` extract `readIndex = operand & 0xFFFF`. Integrity validates `readIndex < stackIndex`. `run` uses unchecked assembly. Consistent.
- **LibOpConstant:** Both extract `constantIndex = operand & 0xFFFF`. Integrity validates `constantIndex < constants.length`. `run` uses unchecked assembly. Consistent.
- **LibOpContext:** Integrity returns (0, 1). `run` extracts `i = operand & 0xFF`, `j = (operand >> 8) & 0xFF`. Uses Solidity bounds-checked access for context matrix (unknown shape at deploy time). Consistent.
- **LibOpExtern:** Both `integrity` and `run` extract `index = operand & 0xFFFF`, `inputs = (operand >> 0x10) & 0x0F`, `outputs = (operand >> 0x14) & 0x0F`. Both mask outputs to 4 bits. Consistent.
- **LibOpCall:** Integrity extracts `sourceIndex = operand & 0xFFFF`, `outputs = operand >> 0x14` (no mask). `run` extracts `sourceIndex = operand & 0xFFFF`, `inputs = (operand >> 0x10) & 0x0F`, `outputs = operand >> 0x14` (no mask). The missing `& 0x0F` mask on `outputs` is harmless because the operand is already limited to 24 bits (masked by eval loop), so `>> 0x14` produces at most 4 bits. Consistent.

### 4. Serialization/Deserialization Round-Trip (LibInterpreterStateDataContract.sol)

**Serialized layout:**
```
[constants_length (32 bytes)][constants_data (N * 32 bytes)][bytecode_length (32 bytes)][bytecode_data]
```

**`serializeSize`** (line 29): `bytecode.length + constants.length * 0x20 + 0x40`. Correct (32 for constants length + N*32 for constants data + 32 for bytecode length + bytecode.length for bytecode data).

**`unsafeSerialize`** (lines 39-53):
- Copies constants with length prefix (loop copies `length + 1` words).
- Copies bytecode with length prefix via `unsafeCopyBytesTo(startPointer, cursor, length + 0x20)`.
- Correct.

**`unsafeDeserialize`** (lines 69-141):
- `constants := cursor` at serialized data start, advances past.
- `bytecode := cursor` at bytecode start, references in-place.
- Stack allocation reads bytecode structure (source count, relative pointers, stack allocation per source).
- `stackBottom = stack + (stackSize + 1) * 0x20` -- consistent with `LibInterpreterState.stackBottoms`.
- Round-trip correct.

### 5. Stack Trace Memory Safety (LibInterpreterState.sol lines 126-142)

- Saves value at `stackTop - 0x20` before overwriting.
- Writes packed `(parentSourceIndex << 16) | sourceIndex` into that slot.
- Calldata: 4 bytes from `stackTop - 4` (the low 4 bytes of the overwritten word), length = `(stackBottom - stackTop) + 4`.
- Restores original value after `staticcall`.
- The `staticcall` target is a deterministic hash-derived address with no deployed code. No side effects.
- Correct.

### 6. Parse State Struct Offset Constants (LibParseState.sol)

**ParseState** struct field order (lines 162-190):
1. `activeSourcePtr` (uint256) -> offset 0x00
2. `topLevel0` (uint256) -> offset 0x20
3. `topLevel1` (uint256) -> offset 0x40
4. `parenTracker0` (uint256) -> offset 0x60
5. `parenTracker1` (uint256) -> offset 0x80
6. `lineTracker` (uint256) -> offset 0xa0
7. `subParsers` (bytes32) -> offset 0xc0

| Constant | Value | Matches field? |
|----------|-------|----------------|
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | 0x20 | Yes (field 2) |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | 0x21 | Yes (field 2 + 1 byte) |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | 0x60 | Yes (field 4) |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | 0xa0 | Yes (field 6) |

All offsets correct.

### 7. Parser IO Byte Construction and Integrity Cross-Check

**Parser (`endLine`, line 511):**
```solidity
mstore8(add(itemSourceHead, 1), or(shl(4, opOutputs), opInputs))
```
High nibble = outputs (max 15), low nibble = inputs (max 15). Guarded by `opOutputs > 0x0F || opInputs > 0x0F` revert (line 507).

**Integrity (`integrityCheck2`, line 152-154):**
```solidity
let ioByte := byte(29, word)
bytecodeOpInputs := and(ioByte, 0x0F)
bytecodeOpOutputs := shr(4, ioByte)
```

These extract the same nibbles. `shr(4, ioByte)` on a single byte gives the high nibble. Consistent.

### 8. Constants Builder Linked List (LibParseState.sol)

**`pushLiteral`** (line 640): New constants get index `constantsHeight`. Duplicates at position `t` from head get index `constantsHeight - t`.

**`buildConstants`** (lines 1009-1045): Traverses LL from head to tail, writing at array indices from `constantsHeight - 1` down to `0`. The most recently added constant (head) goes to the highest index; the oldest (tail) goes to index 0.

**Verified:** First constant added (tail) -> array index 0. N-th constant -> index N-1. New constant at height N -> index N (before incrementing height). Duplicate at position t from head -> index `height - t`. Correct.

### 9. LibOpCall Input/Output Copy Directions (lines 138-166)

**Inputs (lines 138-142):** Iterates forward through caller stack (from top toward bottom), writing to callee stack from bottom upward. First caller input (stack top = last pushed = rightmost argument) goes to callee bottom. Last caller input (deepest = first pushed = leftmost argument) goes to callee top. This reverses the order, matching the NatSpec: "first input to call becomes the bottom of the callee's stack."

**Outputs (lines 159-166):** Copies forward from callee stack top to caller's new output area. Preserves the callee's output ordering. Correct.

### 10. LibAllStandardOps Parallel Array Alignment

Verified all four arrays (authoringMetaV2, operandHandlers, integrityPointers, opcodePointers) have exactly 72 entries each, with matching ordering. The `now` alias at index 25 correctly maps to `LibOpBlockTimestamp` in all arrays. Each array validates its length against `ALL_STANDARD_OPS_LENGTH` via `BadDynamicLength`.

### 11. MAX_PAREN_OFFSET Constant (LibParse.sol line 66)

**Claim:** Maximum paren offset is 59 to prevent overflow.

**Verification:** The paren tracker has 62 bytes of group data (2 * 32 - 2 reserved bytes). Each group uses 3 bytes, fitting 20 groups (3 * 20 = 60 bytes). The first group is at offset 0 (root level). New groups start at offset 3, 6, 9, ..., 57. At offset 57, `pushOpToSource` writes a phantom counter at `parenOffset + 4 = 61`, which is within bounds. At offset 60, `parenOffset + 4 = 64` would exceed the 62-byte region. The check at line 351 (`newParenOffset > MAX_PAREN_OFFSET` where `MAX_PAREN_OFFSET = 59`) rejects `newParenOffset = 60`. Since `newParenOffset` is always a multiple of 3 starting from 3, the largest accepted value is 57. Correct.

### 12. endSource totalOpsOverflow Guard (LibParseState.sol line 877)

```solidity
totalOpsOverflow := gt(sub(div(length, 4), 1), 0xFF)
```
`length` includes the 4-byte prefix, so `div(length, 4) - 1` is the opcode count. Reverts if >255, which is the byte limit for the source prefix. Correct.

### 13. Line Tracker Overflow Guard (LibParseState.sol line 386)

```solidity
didOverflow := gt(offset, 0xF0)
```
The line tracker stores up to 14 source head pointers in 16-bit slots at bit offsets 0x20, 0x30, ..., 0xF0 within the 256-bit word. Offset 0xF0 is the last valid slot. At offset 0x100, `shl(0x100, sourceHead)` would shift past 256 bits, silently discarding the pointer. The check catches this. Correct.

### 14. LHS Item Count Overflow Guard (LibParse.sol line 182)

```solidity
if ((state.topLevel1 & 0xFF) == 0xFF || (state.lineTracker & 0xFF) == 0xFF) {
    revert LHSItemCountOverflow(state.parseErrorOffset(cursor));
}
```
Both counters are in the low byte of their respective uint256 fields. Incrementing from 0xFF would carry into the adjacent byte, silently corrupting parser state. The check prevents this. Correct.

---

## Findings

No findings.

All algorithms implement what their NatSpec describes. Constants and bitmask widths are correct. Error conditions match their triggers. Serialization/deserialization round-trips correctly. Integrity declarations match runtime behavior. The four parallel arrays in LibAllStandardOps are correctly aligned. The eval loop's unrolled opcode dispatch uses correct byte offsets and shift amounts across all 8 positions plus the remainder loop.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH     | 0 |
| MEDIUM   | 0 |
| LOW      | 0 |
| INFO     | 0 |
