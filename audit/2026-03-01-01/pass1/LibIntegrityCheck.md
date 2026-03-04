# A12 -- Pass 1 (Security) -- LibIntegrityCheck.sol

**File:** `src/lib/integrity/LibIntegrityCheck.sol` (207 lines)
**Agent:** A12
**Date:** 2026-03-01

---

## Evidence of Thorough Reading

### Library Name

- `LibIntegrityCheck` (library, line 40)

### Struct Definitions

- `IntegrityCheckState` (lines 31-38): fields `stackIndex` (uint256), `stackMaxIndex` (uint256), `readHighwater` (uint256), `constants` (bytes32[]), `opIndex` (uint256), `bytecode` (bytes)

### Function Names and Line Numbers

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `newState` | 52 | internal | pure |
| `integrityCheck2` | 87 | internal | view |

### Errors Used (all imported, none defined locally)

From `src/error/ErrIntegrity.sol`:
- `OpcodeOutOfRange` (used line 153)
- `StackAllocationMismatch` (used line 196)
- `StackOutputsMismatch` (used line 201)
- `StackUnderflow` (used line 167)
- `StackUnderflowHighwater` (used line 173)

From `rain.interpreter.interface/error/ErrIntegrity.sol`:
- `BadOpInputsLength` (used line 160)
- `BadOpOutputsLength` (used line 163)

### Imports

- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 5)
- `LibBytecode` from `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` (line 15)
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 16)

### Constants/Events Defined

None.

### Using-for Directives

- `LibIntegrityCheck for IntegrityCheckState` (line 41)

---

## Analysis

### Structural Integrity Delegation

`integrityCheck2` delegates structural validation to `LibBytecode.checkNoOOBPointers` (line 108) before iterating over opcodes. This call validates source count, relative offsets, ops count per source, contiguity, and that `inputs <= outputs <= stackAllocation`. This is the correct ordering -- structural integrity is confirmed before any per-opcode iteration.

### Assembly Block Analysis

1. **Lines 97-100** -- Reads `fPointers` length and computes data start. Read-only, memory-safe. Correct.

2. **Lines 112-114** -- Reads `io` array data pointer. The `io` array was just allocated at line 110 with length `sourceCount * 2`. Reading its data start at `io + 0x20` is correct.

3. **Lines 124-128** -- Writes `inputsLength` and `outputsLength` into `io` via `mstore8`. Each source writes exactly 2 bytes. The cursor starts at `io + 0x20` and advances by 2 for each of the `sourceCount` iterations, so writes stay within the `sourceCount * 2` allocation. Both `inputsLength` and `outputsLength` come from `LibBytecode.sourceInputsOutputsLength` which reads single bytes from bytecode headers, so they fit in a byte. Correct.

4. **Lines 143-151** -- Reads opcode fields from `cursor`. The `mload(cursor)` reads 32 bytes. The opcode fields are extracted using `byte(28, word)` for opcodeIndex, `byte(29, word)` for ioByte, and `and(word, 0xFFFFFF)` for the 3-byte operand. Since `cursor = sourcePointer - 0x18` and `sourcePointer` points to the 4-byte header, `cursor + 28 = sourcePointer + 4` which is the first byte of the first opcode. Each subsequent `cursor += 4` correctly advances to the next opcode. The bounds are validated by `checkNoOOBPointers`. Correct.

5. **Lines 155-157** -- Reads a 2-byte function pointer from the function pointer table. `opcodeIndex < fsCount` is enforced at line 152. The maximum byte offset is `(fsCount - 1) * 2`, within the `fPointers` data region. `shr(0xf0, mload(...))` shifts the loaded 32-byte word right by 240 bits, isolating the top 2 bytes. Correct.

### Stack Tracking Correctness

The stack tracking logic in `integrityCheck2` follows this sequence per opcode:

1. Call integrity function `f(state, operand)` to get `calcOpInputs, calcOpOutputs` (line 158)
2. Verify `calcOpInputs == bytecodeOpInputs` and `calcOpOutputs == bytecodeOpOutputs` (lines 159-164)
3. Check `calcOpInputs <= state.stackIndex` (underflow check, line 166)
4. Subtract inputs from stack: `state.stackIndex -= calcOpInputs` (line 169)
5. Check `state.stackIndex >= state.readHighwater` (highwater check, line 172)
6. Add outputs to stack: `state.stackIndex += calcOpOutputs` (line 178)
7. Update `stackMaxIndex` if needed (lines 181-183)
8. Advance highwater for multi-output opcodes (lines 186-188)

This sequence is correct. The underflow check precedes the subtraction, and the highwater check occurs after subtraction but before addition, which is the right point to verify the stack hasn't been consumed below the protected region.

### Operand Encoding Verification

The operand is extracted as `and(word, 0xFFFFFF)` (line 147), giving a 3-byte value stored in the low bytes of a `bytes32` (since `OperandV2` is `bytes32`). This encoding means:
- Low 16 bits (bits 0-15): operand data field (e.g., stack index, constant index)
- Bits 16-19: input count for call/extern opcodes
- Bits 20-23: output count for call/extern opcodes

The ioByte is separately extracted at `byte(29, word)` (line 148), which is the second byte of the 4-byte opcode. The inputs are `and(ioByte, 0x0F)` (low nibble, max 15) and outputs are `shr(4, ioByte)` (high nibble, max 15).

### Post-Loop Validations

After processing all opcodes in a source:
- `stackMaxIndex` must equal the bytecode's declared `stackAllocation` (line 195)
- `stackIndex` must equal the declared `outputsLength` (line 200)

Both are strict equality checks, meaning the bytecode cannot over-allocate or under-report outputs.

---

## Findings

### A12-2 | LOW | `readHighwater` NatSpec describes it as "Lowest stack index that opcodes are allowed to read from" but it is not enforced as a read floor

**File:** `src/lib/integrity/LibIntegrityCheck.sol`, lines 23-24, 172-174, 186-188

The `IntegrityCheckState.readHighwater` field's NatSpec (lines 23-24) states: "Lowest stack index that opcodes are allowed to read from. Advances past multi-output regions to prevent aliasing reads."

However, `readHighwater` is not enforced as a read floor. It is enforced only as a *consumption floor* via the check at line 172: `state.stackIndex < state.readHighwater`. The `LibOpStack.integrity` function (in `src/lib/op/00/LibOpStack.sol` line 24) checks `readIndex >= state.stackIndex` for bounds but does NOT check `readIndex` against `readHighwater`. It only *advances* the highwater (line 29-31), never enforces it as a constraint on reads.

This means an opcode like `stack` can read values below the highwater -- values produced by a multi-output opcode that have since been "protected" by the highwater. This may be intentional (stack reads are copies, not consumptions, so aliasing doesn't apply), but the NatSpec is misleading.

If the intent is that reads below the highwater should be allowed (since copying doesn't create aliasing), the NatSpec should say "Lowest stack index that the stack pointer is allowed to drop to after consuming inputs" rather than "Lowest stack index that opcodes are allowed to read from."

### A12-3 | INFO | Assembly memory safety annotations are correct

All five assembly blocks in this file are annotated `("memory-safe")`. Each block was verified:
- Lines 97-100: read-only access to `fPointers` length field
- Lines 112-114: read-only access to freshly allocated `io` array
- Lines 124-128: writes to `io` via `mstore8`, within allocated bounds
- Lines 143-151: read-only access to bytecode via `mload`, within validated bounds
- Lines 155-157: read-only access to function pointer table, within bounds-checked range

No issues found.

### A12-4 | INFO | Unchecked arithmetic is safe due to preceding guards

The entire `integrityCheck2` body is wrapped in `unchecked` (line 92). All arithmetic operations are protected:

- **Line 169** (`state.stackIndex -= calcOpInputs`): guarded by the `calcOpInputs > state.stackIndex` check at line 166.
- **Line 134** (`Pointer.unwrap(...) - 0x18`): `sourcePointer` returns at minimum `bytecode + 0x20 + 3 + 0` (for a single source with offset 0), which is always >> `0x18`.
- **Line 135** (`cursor + sourceOpsCount * 4`): ops count is a byte (max 255), so `255 * 4 = 1020`, which cannot overflow when added to a memory pointer.
- **Line 178** (`state.stackIndex += calcOpOutputs`): `calcOpOutputs` is verified equal to `bytecodeOpOutputs` which is at most 15 (4-bit). With max 255 opcodes and max 15 outputs each, theoretical max is `255 + 255 * 15 = 4080`, well within uint256 range.
- **Line 110** (`sourceCount * 2`): `sourceCount` is a byte (max 255), so `255 * 2 = 510`, safe.

### A12-5 | INFO | Function pointer table bounds check is correct

Line 152 checks `opcodeIndex >= fsCount` before using `opcodeIndex` at line 156. The `fsCount` is `mload(fPointers) / 2` (number of 2-byte entries). The table access at `fPointersStart + opcodeIndex * 2` stays within bounds since `opcodeIndex < fsCount` is guaranteed. The `shr(0xf0, ...)` isolates the correct 2-byte pointer from the 32-byte word.

### A12-6 | INFO | Integrity-calculated IO vs bytecode-declared IO comparison prevents bypass

The checks at lines 159-164 compare the values returned by each opcode's integrity function against the bytecode-declared IO byte. Since both must match, a malicious integrity function cannot cause the stack tracker to use different values than what the bytecode declares. The bytecode IO values are 4-bit packed (max 15 each), so any integrity function returning values > 15 will necessarily fail the equality check. This prevents integrity bypass via fabricated IO values.

### A12-7 | INFO | `opIndex` is informational only

`state.opIndex` (incremented at line 190) is used exclusively in error messages (lines 153, 160, 163, 167, 173). Loop control is via `cursor < end` (line 137), which derives from `checkNoOOBPointers`-validated source boundaries. No control flow dependency on `opIndex`.

### A12-8 | INFO | Zero source count is handled correctly

When `sourceCount` is 0, the loop at line 120 does not execute, and `io` is allocated as `new bytes(0)` (line 110). `checkNoOOBPointers` handles the zero-source case by checking for trailing bytes (lines 169-176 in `LibBytecode.sol`). The function returns an empty `io` byte array, which is correct.

---

## Summary

| ID | Severity | Title |
|----|----------|-------|
| A12-2 | LOW | `readHighwater` NatSpec is misleading -- describes read floor but only enforced as consumption floor |
| A12-3 | INFO | Assembly memory safety annotations verified correct |
| A12-4 | INFO | Unchecked arithmetic is safe due to preceding guards |
| A12-5 | INFO | Function pointer table bounds check is correct |
| A12-6 | INFO | Integrity IO comparison prevents bypass |
| A12-7 | INFO | `opIndex` is informational only |
| A12-8 | INFO | Zero source count handled correctly |

**Total findings: 7** (0 CRITICAL, 0 HIGH, 0 MEDIUM, 1 LOW, 6 INFO)
