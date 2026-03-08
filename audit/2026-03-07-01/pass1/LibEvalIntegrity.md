# Pass 1 (Security) -- LibEval.sol and LibIntegrityCheck.sol

**Files:**
- `src/lib/eval/LibEval.sol` (251 lines)
- `src/lib/integrity/LibIntegrityCheck.sol` (211 lines)

**Agent:** A09
**Date:** 2026-03-07

---

## Evidence of Thorough Reading

### LibEval.sol

**Library name:** `LibEval` (line 15)

**Using declarations:**
- `LibMemoryKV for MemoryKV` (line 16)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `evalLoop(InterpreterState memory state, uint256 parentSourceIndex, Pointer stackTop, Pointer stackBottom) returns (Pointer)` | 41 | internal | view |
| `eval4(InterpreterState memory state, StackItem[] memory inputs, uint256 maxOutputs) returns (StackItem[] memory, bytes32[] memory)` | 191 | internal | view |

**Imports:**

| Import | Source | Line |
|--------|--------|------|
| `LibInterpreterState`, `InterpreterState` | `../state/LibInterpreterState.sol` | 5 |
| `LibMemCpy` | `rain.solmem/lib/LibMemCpy.sol` | 7 |
| `LibMemoryKV`, `MemoryKV` | `rain.lib.memkv/lib/LibMemoryKV.sol` | 8 |
| `LibBytecode` | `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` | 9 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 10 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 11 |
| `InputsLengthMismatch` | `../../error/ErrEval.sol` | 13 |

**Errors referenced:**
- `InputsLengthMismatch(uint256, uint256)` -- used at line 213

**Types/constants/errors defined locally:** None.

### LibIntegrityCheck.sol

**Library name:** `LibIntegrityCheck` (line 44)

**Struct definitions:**
- `IntegrityCheckState` (lines 35-42): fields `stackIndex` (uint256, line 36), `stackMaxIndex` (uint256, line 37), `readHighwater` (uint256, line 38), `constants` (bytes32[], line 39), `opIndex` (uint256, line 40), `bytecode` (bytes, line 41)

**Using declarations:**
- `LibIntegrityCheck for IntegrityCheckState` (line 45)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `newState(bytes memory bytecode, uint256 stackIndex, bytes32[] memory constants) returns (IntegrityCheckState memory)` | 56 | internal | pure |
| `integrityCheck2(bytes memory fPointers, bytes memory bytecode, bytes32[] memory constants) returns (bytes memory io)` | 91 | internal | view |

**Imports:**

| Import | Source | Line |
|--------|--------|------|
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 5 |
| `OpcodeOutOfRange`, `StackAllocationMismatch`, `StackOutputsMismatch`, `StackUnderflow`, `StackUnderflowHighwater` | `../../error/ErrIntegrity.sol` | 7-13 |
| `BadOpInputsLength`, `BadOpOutputsLength` | `rain.interpreter.interface/error/ErrIntegrity.sol` | 14 |
| `LibBytecode` | `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` | 15 |
| `OperandV2` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 16 |

**Errors referenced:**
- `OpcodeOutOfRange(uint256, uint256, uint256)` -- line 157
- `StackAllocationMismatch(uint256, uint256)` -- line 200
- `StackOutputsMismatch(uint256, uint256)` -- line 205
- `StackUnderflow(uint256, uint256, uint256)` -- line 171
- `StackUnderflowHighwater(uint256, uint256, uint256)` -- line 177
- `BadOpInputsLength(uint256, uint256, uint256)` -- line 164
- `BadOpOutputsLength(uint256, uint256, uint256)` -- line 167

**Types/constants/errors defined locally:** `IntegrityCheckState` struct (lines 35-42). No errors or constants defined locally.

---

## Previously Fixed Findings (Not Re-Flagged)

- **A43-1** (endSource ops-count overflow > 255): FIXED.
- **A12-2** (readHighwater NatSpec inaccuracy): FIXED. NatSpec at lines 23-28 now correctly describes readHighwater as a consumption floor, noting that read-only access below the highwater is permitted.

---

## Security Analysis

### Eval Loop Cannot Jump to Arbitrary Code

The eval loop in `evalLoop` (line 41) uses `mod(byte(..., word), fsCount)` to bound opcode indices into the function pointer table (lines 100, 107, 114, 121, 128, 135, 142, 149, 166). This ensures dispatch stays within the table regardless of bytecode content. The `Rainterpreter` constructor (line 39 of `Rainterpreter.sol`) prevents `fsCount == 0` via the `ZeroFunctionPointers` guard. The integrity check at deploy time verifies all opcode indices are within range via an explicit `opcodeIndex >= fsCount` check (line 156 of `LibIntegrityCheck.sol`).

### Stack Underflow/Overflow Protection

The integrity check verifies that no opcode consumes more stack items than are available (`calcOpInputs > state.stackIndex` at line 170) and that the stack never drops below the read highwater (`state.stackIndex < state.readHighwater` at line 176). The final stack depth must match the declared outputs (`state.stackIndex != outputsLength` at line 204), and the peak depth must match the declared allocation (`state.stackMaxIndex != LibBytecode.sourceStackAllocation(...)` at line 199).

In `eval4`, inputs are validated: `inputs.length != sourceInputs` reverts with `InputsLengthMismatch` (line 213). This prevents callers from passing more inputs than the stack allocation can accommodate.

### Memory Safety of Assembly Blocks

All assembly blocks in both files are annotated `("memory-safe")`. Verified:

- **LibEval.sol lines 57-85:** Reads from bytecode to set up cursor, end, m, fPointersStart. No allocation or memory writes.
- **LibEval.sol lines 92-94, 99-102, 106-109, ..., 148-151:** Read from cursor and function pointer table; write to stack variables `f`, `operand`, `word`. No memory writes.
- **LibEval.sol lines 164-169:** Same as above for remainder loop.
- **LibEval.sol lines 220-224:** Moves `stackTop` pointer and reads `inputs` pointer. Stays within allocated memory.
- **LibEval.sol lines 242-245:** Writes output array length at `stackTop - 0x20`, which is within the pre-allocated stack region.
- **LibIntegrityCheck.sol lines 101-104:** Reads `fPointers` length. No writes.
- **LibIntegrityCheck.sol lines 116-118:** Reads `io` data start. No writes.
- **LibIntegrityCheck.sol lines 128-131:** Writes to `io` via `mstore8` within allocated bounds (2 bytes per source, cursor advances by 2 each iteration).
- **LibIntegrityCheck.sol lines 147-155:** Reads opcode from cursor within bytecode bounds. Writes to local variables.
- **LibIntegrityCheck.sol lines 159-161:** Reads from function pointer table within bounds-checked range.

### Arithmetic Safety

Both files use `unchecked` blocks. All operations were verified safe:

- `state.stackIndex -= calcOpInputs` (line 173): guarded by `calcOpInputs > state.stackIndex` check at line 170.
- `state.stackIndex += calcOpOutputs` (line 182): `calcOpOutputs` is at most 15 (high nibble of a byte); maximum theoretical `stackIndex` is `255 + 255*15 = 4080`.
- `cursor -= 0x1c` (line 161): cursor is a memory pointer well above 28.
- `end = cursor + m * 4` (line 162): `m` is at most 7, so `m * 4 = 28` max.
- `sub(stackTop, mul(mload(inputs), 0x20))` (line 222): `inputs.length` is validated equal to `sourceInputs` (a byte), and the stack was allocated with sufficient space.

### Context Array Access

Context arrays are not accessed directly in these two files. The `context` opcode (`LibOpContext`) handles bounds checking separately.

### Error Handling

All error paths use custom errors:
- `InputsLengthMismatch` (LibEval line 213)
- `OpcodeOutOfRange` (LibIntegrityCheck line 157)
- `BadOpInputsLength` (LibIntegrityCheck line 164)
- `BadOpOutputsLength` (LibIntegrityCheck line 167)
- `StackUnderflow` (LibIntegrityCheck line 171)
- `StackUnderflowHighwater` (LibIntegrityCheck line 177)
- `StackAllocationMismatch` (LibIntegrityCheck line 200)
- `StackOutputsMismatch` (LibIntegrityCheck line 205)

No string-based reverts or `require()` with messages.

### Pointer Arithmetic Verification

**evalLoop cursor setup (lines 57-85):**
- `cursor = bytecode + 0x20` (past length prefix)
- `sourcesLength = byte(0, mload(cursor))` (source count)
- `cursor += 1` (past source count byte)
- `sourcesStart = cursor + sourcesLength * 2` (past 2-byte offset table)
- `sourcesPointer = shr(0xf0, mload(cursor + sourceIndex * 2))` (16-bit relative offset)
- `cursor = sourcesStart + sourcesPointer` (at source header)
- `opsLength = byte(0, mload(cursor))` (ops count from header)
- `cursor += 4` (past 4-byte header, at first opcode)
- `end = cursor + (opsLength - m) * 4` (end of full 32-byte chunks)

This arithmetic is consistent with the bytecode layout defined in `LibBytecode`.

**integrityCheck2 cursor setup (line 138):**
- `cursor = Pointer.unwrap(LibBytecode.sourcePointer(bytecode, i)) - 0x18`
- `sourcePointer` returns a pointer to the source header. Subtracting `0x18` (24) positions the cursor so that `byte(28, mload(cursor))` reads the first byte of the first opcode (at header + 4). This is correct since `cursor + 28 = sourcePointer + 4`.
- `end = cursor + sourceOpsCount * 4`

Both cursor setups are verified correct.

### Remainder Loop (evalLoop lines 157-172)

After the main 8-at-a-time loop, `cursor` points past the last full chunk. The adjustment `cursor -= 0x1c` positions cursor so `byte(28, mload(cursor))` reads the next remaining opcode. `end = cursor + m * 4` ensures exactly `m` remaining opcodes are processed. Edge cases verified:
- `opsLength == 0`: both loops skipped.
- `opsLength < 8`: main loop skipped, remainder processes all ops.
- `opsLength` is multiple of 8: main loop processes all, remainder skipped.
- General case: main loop processes `opsLength - m` ops, remainder processes `m`.

### stackTrace Transient Memory Mutation (called from evalLoop line 174)

`LibInterpreterState.stackTrace` temporarily writes to `stackTop - 0x20`, issues a `staticcall` to a non-existent address (deterministic hash-derived, no collision risk), then restores the original value. The `staticcall` has no side effects. The 63/64ths gas rule ensures sufficient gas for the restore `mstore`. Safe.

---

## Findings

No findings.

Both files have been thoroughly audited in prior passes (A05, A12) with findings triaged and fixed. The code is well-structured with a layered trust model: structural integrity (`checkNoOOBPointers`) is verified before per-opcode integrity, deploy-time integrity checks validate all IO and stack accounting, bytecode hash verification prevents post-deployment tampering, and the runtime eval loop uses modulo-bounded dispatch with a constructor guard against empty function pointer tables. No new security issues were identified.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH     | 0 |
| MEDIUM   | 0 |
| LOW      | 0 |
| INFO     | 0 |
