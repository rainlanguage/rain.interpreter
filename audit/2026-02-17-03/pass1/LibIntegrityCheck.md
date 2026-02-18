# Pass 1 (Security) -- LibIntegrityCheck.sol

**File:** `src/lib/integrity/LibIntegrityCheck.sol`

## Evidence of Thorough Reading

### Contract/Library Name

- `LibIntegrityCheck` (library, line 27)

### Struct Definitions

- `IntegrityCheckState` (lines 18-25): fields `stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`

### Function Names and Line Numbers

| Function | Line | Visibility |
|---|---|---|
| `newState` | 39 | internal pure |
| `integrityCheck2` | 74 | internal view |

### Errors Used (all imported, none defined locally)

From `src/error/ErrIntegrity.sol`:
- `OpcodeOutOfRange` (used line 140)
- `StackAllocationMismatch` (used line 183)
- `StackOutputsMismatch` (used line 188)
- `StackUnderflow` (used line 154)
- `StackUnderflowHighwater` (used line 160)

From `rain.interpreter.interface/error/ErrIntegrity.sol`:
- `BadOpInputsLength` (used line 147)
- `BadOpOutputsLength` (used line 150)

### Events

None.

---

## Findings

### 1. Potential uint256 Overflow on `state.stackIndex += calcOpOutputs` (Line 165)

**Severity: LOW**

The entire `integrityCheck2` function body is wrapped in `unchecked` (line 79). The comment on line 163-164 says "Let's assume that sane opcode implementations don't overflow uint256 due to their outputs." While a single opcode output count fits in 4 bits (0-15, since `bytecodeOpOutputs` is extracted via `shr(4, ioByte)` which gives at most 15), the accumulation `state.stackIndex += calcOpOutputs` is checked against `bytecodeOpOutputs` but the actual addition is unchecked. Since `stackIndex` starts at `inputsLength` (a byte, max 255) and each opcode can add at most 15, and there can be at most 255 opcodes per source (byte-sized ops count), the theoretical max is `255 + 255 * 15 = 4080`, which is well within uint256 range. The overflow is practically impossible.

However, the `calcOpOutputs` value comes from the integrity function `f` (line 145), which could theoretically return any uint256. The check on line 149-151 compares `calcOpOutputs != bytecodeOpOutputs`, and `bytecodeOpOutputs` is at most 15 (4 bits). If a buggy integrity function returns a value > 15 that also happens to not equal `bytecodeOpOutputs`, it will revert. If it returns a value > 15 that happens to equal `bytecodeOpOutputs` (impossible since `bytecodeOpOutputs` is 4-bit masked), so the check is actually safe. The assumption in the comment holds given the surrounding constraints.

No action needed, but the comment on lines 163-164 could be made more precise about why the assumption holds.

### 2. Assembly Memory Safety -- All Blocks Verified

**Severity: INFO**

All assembly blocks in this file are annotated `("memory-safe")`. Analysis of each:

- **Lines 84-87:** Reads from `fPointers` memory (length + data start). This is a read-only operation on a `bytes memory` parameter, safe.
- **Lines 99-101:** Reads `io` array data pointer. This is a freshly allocated `bytes` array, reading its data start, safe.
- **Lines 111-115:** Writes to `ioCursor` using `mstore8`. The cursor advances within the bounds of the `io` array (which was allocated as `sourceCount * 2` bytes). Each source writes exactly 2 bytes and `ioCursor` starts at `io + 0x20`, so the writes stay in bounds as long as the loop iterates exactly `sourceCount` times, which it does.
- **Lines 130-138:** Reads from `cursor` which points into the bytecode memory. The bounds were validated by `checkNoOOBPointers` (line 95). This reads opcode data fields from a 32-byte `mload`, safe because the bytecode was previously validated.
- **Lines 142-144:** Reads a 2-byte function pointer from `fPointersStart + opcodeIndex * 2`. The bounds check on line 139 (`opcodeIndex >= fsCount`) ensures this does not read beyond the function pointer table.

No issues found.

### 3. Function Pointer Table Bounds Check Is Correct

**Severity: INFO**

Line 139 checks `opcodeIndex >= fsCount` before using `opcodeIndex` to index into the function pointer table at line 143. The `fsCount` is computed as `mload(fPointers) / 2` (line 86), representing the number of 2-byte entries. The index into the table is `fPointersStart + opcodeIndex * 2` (line 143). Since `opcodeIndex < fsCount` is guaranteed, the maximum byte offset is `(fsCount - 1) * 2`, which is within the `fPointers` data region of length `fsCount * 2`. Correct.

### 4. Cursor Arithmetic and Loop Bounds

**Severity: INFO**

Line 121: `cursor = Pointer.unwrap(LibBytecode.sourcePointer(bytecode, i)) - 0x18`

`sourcePointer` returns a pointer to the 4-byte source header. Subtracting `0x18` (24 bytes) means the cursor points 24 bytes before the header. The opcode data starts at header + 4 bytes. When `mload(cursor)` is executed at line 131, it reads 32 bytes starting at cursor. Since cursor = header - 24, `mload(cursor)` reads bytes from header-24 to header+8. The byte extraction uses `byte(28, word)` for `opcodeIndex` and `byte(29, word)` for `ioByte`, which reads bytes at offset 28 and 29 from the loaded word. Offset 28 from cursor = cursor + 28 = header - 24 + 28 = header + 4. This is the first byte of the first opcode (after the 4-byte header). Similarly byte 29 is header + 5. The operand is `and(word, 0xFFFFFF)` which is the last 3 bytes of the loaded 32-byte word, corresponding to offsets 29-31 from cursor = header+5 to header+7. Wait -- let me recheck.

Actually, the operand mask is the low 3 bytes: bytes at positions 29, 30, 31 of the loaded word. Position 29 from cursor = header + 5. But the ioByte is `byte(29, word)` = header + 5 as well. That seems like the operand overlaps with the ioByte.

Let me re-examine. An opcode is 4 bytes: `[opcodeIndex(1), ioByte(1), operand(2)]` or possibly `[opcodeIndex(1), ioByte(1), operand_hi(1), operand_lo(1)]`. But the mask `0xFFFFFF` is 3 bytes, not 2. Let me look more carefully at the structure.

Correction: OperandV2 is `bytes32`. The mask `and(word, 0xFFFFFF)` extracts 3 bytes (24 bits). Each opcode is 4 bytes: byte 0 = opcodeIndex, byte 1 = ioByte, bytes 2-3 = 2-byte operand portion. But the 3-byte mask takes bytes 29-31 of the word, which corresponds to bytes 5-7 from the header pointer, i.e., bytes 1-3 of the first opcode (ioByte + 2 operand bytes). This means the operand includes the ioByte in its low bits.

Actually, since `OperandV2 is bytes32`, the masking puts the 3 bytes into the low 3 bytes of a bytes32. The integrity functions receiving this operand would need to know which bits are meaningful. This is the designed encoding -- the operand is a 3-byte value containing the IO byte and 2 operand bytes. This is the expected format per the architecture.

Line 122: `end = cursor + sourceOpsCount(bytecode, i) * 4`. This sets the end after all opcodes (each 4 bytes). The `cursor += 4` at line 178 advances to the next opcode. Since `checkNoOOBPointers` validated that `opsCount * 4` bytes exist after the header, and cursor starts at `header - 0x18`, the end is `header - 0x18 + opsCount * 4`. The mload at each cursor position reads 32 bytes, which always covers the current opcode's 4 relevant bytes (at offsets 28-31 of the loaded word). This is safe because the bytecode is in allocated memory.

No issues found.

### 5. Highwater Update Logic -- Multi-Output Opcodes

**Severity: INFO**

Lines 173-175: `if (calcOpOutputs > 1) { state.readHighwater = state.stackIndex; }`. When an opcode produces more than one output, the read highwater advances to the current stack top. This prevents subsequent opcodes from reading below the multi-output region through the underflow-highwater check (lines 159-161). This correctly enforces that multi-output values cannot be partially consumed and then have their remaining slots read by a different opcode, which would be a stack aliasing issue.

Note: single-output opcodes (calcOpOutputs == 1) do NOT advance the highwater. This is intentional -- single outputs can be consumed by later opcodes without restriction.

### 6. `unchecked` Block Scope and Subtraction Safety

**Severity: LOW**

Line 156: `state.stackIndex -= calcOpInputs` is inside the `unchecked` block. However, line 153 checks `calcOpInputs > state.stackIndex` and reverts if so, guaranteeing the subtraction does not underflow. This is correct.

Line 121: `Pointer.unwrap(LibBytecode.sourcePointer(bytecode, i)) - 0x18` is also unchecked. If `sourcePointer` returns a pointer less than `0x18`, this would underflow. However, `sourcePointer` returns `bytecode + 0x20 + sourcesStartOffset + relativeOffset`, where `bytecode` is a memory pointer (at least `0x80` in practice), `0x20` is the length prefix, and `sourcesStartOffset >= 1`. So the minimum value is approximately `0x80 + 0x20 + 1 = 0xA1`, far greater than `0x18`. Safe in practice.

### 7. `integrityCheck2` Does Not Validate `fPointers` Length Is Even

**Severity: LOW**

Line 86: `fsCount := div(mload(fPointers), 2)` computes the number of function pointers by dividing the byte length by 2. If `fPointers` has odd length, the division truncates (rounds down), meaning the last byte is ignored. This is not a security vulnerability per se, since `fPointers` is constructed internally by the expression deployer and is not user-controlled. However, an odd-length `fPointers` would silently ignore the trailing byte. The caller is responsible for providing correctly-formed function pointer data.

### 8. `opIndex` Used Only for Error Reporting, Not for Bounds Enforcement

**Severity: INFO**

`state.opIndex` (incremented at line 177) is used only in error messages (lines 140, 147, 150, 154, 160). The actual loop bounds are controlled by `cursor < end` (line 124), which is based on the validated `sourceOpsCount`. This is correct -- `opIndex` is informational and does not affect control flow.

### 9. All Reverts Use Custom Errors

**Severity: INFO**

Confirmed: all 7 revert statements in the file use custom errors. No string revert messages are present.

- Line 140: `OpcodeOutOfRange`
- Line 147: `BadOpInputsLength`
- Line 150: `BadOpOutputsLength`
- Line 154: `StackUnderflow`
- Line 160: `StackUnderflowHighwater`
- Line 183: `StackAllocationMismatch`
- Line 188: `StackOutputsMismatch`

---

## Summary

| # | Severity | Title |
|---|----------|-------|
| 1 | LOW | Unchecked `stackIndex += calcOpOutputs` relies on assumption about opcode output bounds |
| 2 | INFO | All assembly blocks verified memory-safe |
| 3 | INFO | Function pointer table bounds check is correct |
| 4 | INFO | Cursor arithmetic and loop bounds verified correct |
| 5 | INFO | Highwater update logic for multi-output opcodes is sound |
| 6 | LOW | Unchecked subtractions are guarded by preceding checks |
| 7 | LOW | `fPointers` odd-length silently truncated (not user-controlled) |
| 8 | INFO | `opIndex` is informational only, no control flow impact |
| 9 | INFO | All reverts use custom errors, no string messages |

No CRITICAL or HIGH severity issues found.
