# Pass 1 (Security) -- LibEval.sol

**File:** `src/lib/eval/LibEval.sol`

## Evidence of Thorough Reading

### Contract/Library Name

`library LibEval` (line 15)

### Functions

| Function | Line | Visibility |
|----------|------|------------|
| `evalLoop(InterpreterState memory, uint256, Pointer, Pointer) returns (Pointer)` | 41 | `internal view` |
| `eval2(InterpreterState memory, StackItem[] memory, uint256) returns (StackItem[] memory, bytes32[] memory)` | 191 | `internal view` |

### Errors/Events/Structs Defined

None defined in this file. One error imported:

- `InputsLengthMismatch` (imported from `../../error/ErrEval.sol`, line 13) -- used at line 213

### Imports

- `LibInterpreterState`, `InterpreterState` from `../state/LibInterpreterState.sol` (line 5)
- `LibMemCpy` from `rain.solmem/lib/LibMemCpy.sol` (line 7)
- `LibMemoryKV`, `MemoryKV` from `rain.lib.memkv/lib/LibMemoryKV.sol` (line 8)
- `LibBytecode` from `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` (line 9)
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 10)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 11)
- `InputsLengthMismatch` from `../../error/ErrEval.sol` (line 13)

### Using Declarations

- `LibMemoryKV for MemoryKV` (line 16)

---

## Security Findings

### 1. `sourceIndex` Not Bounds-Checked in `evalLoop`

**Severity: LOW**

In `evalLoop` (line 46-86), `state.sourceIndex` is read and used to index into the bytecode header to locate the source pointer, ops count, etc. The NatSpec at lines 25-33 explicitly documents that `sourceIndex` is NOT bounds-checked in this function and that "All callers MUST validate it before calling."

The two callers are:
- `eval2` (line 231): Validates implicitly via `LibBytecode.sourceInputsOutputsLength` (line 200-201), which internally calls `sourcePointer` -> `sourceRelativeOffset`, which reverts with `SourceIndexOutOfBounds` if the index is out of range.
- `LibOpCall.run` (line 121 of `LibOpCall.sol`): Relies on the integrity check at deploy time to reject invalid source indices in operands.

This is a defense-in-depth concern rather than an exploitable issue: if `evalLoop` is ever called from a new code path that forgets to validate `sourceIndex`, the cursor would land at an arbitrary bytecode position and execute whatever bytes happen to be there as opcodes. The `mod` on function pointer lookup (line 100) prevents jumping to truly arbitrary code -- it can only dispatch to real opcode handlers -- but with arbitrary operands and an arbitrary sequence, the result would still be unpredictable stack manipulation. The existing callers properly validate, so this is documented trust assumption, not a bug.

### 2. Division-By-Zero if `state.fs` is Empty

**Severity: LOW**

At line 53: `uint256 fsCount = state.fs.length / 2;`

If `state.fs` is empty (length 0), then `fsCount = 0`. Every `mod(byte(..., word), fsCount)` in the assembly blocks (lines 100, 107, 114, etc.) would be a division by zero, which in EVM assembly causes a revert (the `mod` opcode returns 0 for mod-by-zero in some contexts, but actually in Solidity EVM, `mod` by zero returns 0 per the EVM spec -- it does NOT revert).

**Correction on EVM behavior:** The EVM `MOD` opcode returns 0 when the divisor is 0. This means if `fsCount` is 0, every `mod(byte(...), 0)` returns 0, and the function pointer lookup would read from `fPointersStart + 0`, which is the first 2 bytes of the (empty) `fs` byte array. Since the array is empty, this reads past the end of the allocated memory for `fs`. The bytes read would be whatever happens to be at that memory location, interpreted as a function pointer. This could cause a jump to an arbitrary internal function.

**Mitigating factor:** The `Rainterpreter` constructor (line 37 of `Rainterpreter.sol`) checks `opcodeFunctionPointers().length == 0` and reverts with `ZeroFunctionPointers()`. This prevents the legitimate interpreter from being deployed with empty function pointers. However, `LibEval.evalLoop` itself has no such guard -- it relies on the caller to ensure `state.fs` is non-empty.

This is protected at the system level by the constructor check, but `evalLoop` as a library function lacks its own defense.

### 3. Modulo-Based Opcode Dispatch Silently Wraps Out-of-Range Opcodes

**Severity: INFO**

The eval loop uses `mod(byte(..., word), fsCount)` (e.g., line 100) to bound opcode indices into the function pointer table, rather than reverting on out-of-range indices. This means a bytecode byte value of, say, 200 when `fsCount` is 50 would silently dispatch to opcode `200 % 50 = 0` rather than reverting.

This is intentional by design -- the integrity check (`LibIntegrityCheck.sol` line 139) performs a strict bounds check (`opcodeIndex >= fsCount` -> revert) at deploy time. By the time `evalLoop` executes, all opcode indices have already been verified to be in range. The `mod` is a cheaper runtime defense than a bounds check, and it cannot cause the wrong opcode to execute for bytecode that passed integrity checks. Only corrupted/tampered bytecode (which would fail the bytecode hash check at the expression deployer level) could trigger the wraparound.

No action required. This is a well-documented design choice.

### 4. `eval2` Runs Entirely Inside `unchecked`

**Severity: INFO**

The entire `eval2` function body (lines 196-248) is wrapped in `unchecked`. Key arithmetic operations:

- Line 222: `stackTop := sub(stackTop, mul(mload(inputs), 0x20))` -- this is assembly, so unchecked regardless. If `inputs.length` were very large, `stackTop` could wrap. However, `inputs.length` is validated against `sourceInputs` (line 212), which is a single byte (max 255) from the bytecode header, and the stack was allocated to accommodate this.
- Line 240: `maxOutputs < sourceOutputs ? maxOutputs : sourceOutputs` -- safe, just a min operation.
- Line 243: `stack := sub(stackTop, 0x20)` -- if `stackTop` were 0, this would underflow. In practice, `stackTop` is always a valid memory pointer well above 0.

The `unchecked` block is appropriate here because all values are constrained by the bytecode structure and integrity checks. No realistic overflow/underflow scenarios exist.

### 5. Output Array Construction Overwrites Stack Length In-Place

**Severity: INFO**

At lines 242-245:
```solidity
assembly ("memory-safe") {
    stack := sub(stackTop, 0x20)
    mstore(stack, outputs)
}
```

This constructs a Solidity `StackItem[]` by pointing `stack` to the 32 bytes before `stackTop` and writing `outputs` as the array length. This reuses the existing stack memory region rather than allocating new memory. The NatSpec at lines 233-239 correctly documents that after this point, both `stack` and the original stack array point to overlapping memory and must be treated as immutable.

This is safe because:
- The stack was pre-allocated with sufficient space during deserialization.
- `stackTop` points into that allocation.
- The word at `sub(stackTop, 0x20)` was previously part of the stack or the stack's length prefix.

However, if any subsequent code were to modify the returned `stack` array or the original stack, it could cause data corruption. The current code immediately returns after this operation, so this is safe.

### 6. `memory-safe` Annotations in Assembly Blocks

**Severity: INFO**

All assembly blocks in `evalLoop` are marked `memory-safe`. These blocks only read from memory (bytecode, function pointers) and do not write. The `mload` operations read from:
- `cursor` -- points within the bytecode
- `fPointersStart + offset` -- points within the function pointer table

Both are read-only accesses within allocated memory regions. The annotations are correct.

In `eval2`, the assembly block at line 220-224 writes to `stackTop` (a local variable) and reads `inputs`. The block at lines 242-244 writes `outputs` into the stack memory region. The `memory-safe` annotation is technically correct because Solidity's definition of memory-safe allows writing to memory allocated by Solidity, and the stack was allocated during deserialization. However, the write at line 244 overwrites data that was part of the stack allocation, which is within bounds.

### 7. `stackTrace` Mutates Memory Transiently

**Severity: INFO**

`LibInterpreterState.stackTrace` (called at line 174) temporarily overwrites the 32-byte word at `sub(stackTop, 0x20)` with the packed source indices, makes a `staticcall` to the non-existent tracer contract, then restores the original value. This is a transient mutation that is safe because:
- It happens in a `view` context (cannot modify state).
- The original value is saved and restored.
- The tracer address is a deterministic hash-derived address with no deployed code.
- The `staticcall` cannot have side effects.

The only risk would be if the `staticcall` consumed all gas and the restoration at line 120 of `LibInterpreterState.sol` never executed, but since `staticcall` only forwards a portion of gas (63/64ths) and the caller retains 1/64th, the restore will execute.

### 8. Remainder Loop Cursor Adjustment

**Severity: INFO**

At line 161: `cursor -= 0x1c;`

After the main 8-opcodes-at-a-time loop, the cursor is adjusted back by 28 bytes (0x1c). This is because the main loop processes 32-byte words starting from the high bytes, but the remainder loop needs to process 4-byte opcodes from the low bytes of a `mload`. Subtracting 28 positions the cursor so that `mload(cursor)` puts the next opcode in bytes [28-31] (the low 4 bytes of the loaded word), which aligns with `byte(28, word)` and `and(word, 0xFFFFFF)`.

The arithmetic is correct: if the main loop processed `(opsLength - m)` opcodes consuming `(opsLength - m) * 4` bytes, cursor is now at the start of the remaining `m` opcodes. After `cursor -= 0x1c`, `mload(cursor)` loads 32 bytes where the opcode of interest is in the last 4 bytes. After processing, `cursor += 4` moves to the next opcode. `end = cursor + m * 4` correctly bounds the loop.

When `m = 0` (opsLength is a multiple of 8), the main loop consumed all opcodes. `cursor -= 0x1c` moves cursor back, but `end = cursor + 0 = cursor`, so the remainder loop body never executes. This is correct.

When the main loop did not execute at all (opsLength < 8, so `end = cursor` initially), `cursor -= 0x1c` adjusts, and `end = cursor + m * 4 = cursor + opsLength * 4`, which correctly iterates over all opcodes one at a time. This is correct because `m = opsLength` when `opsLength < 8`.

---

## Summary

No CRITICAL or HIGH severity findings were identified. `LibEval.sol` relies heavily on upstream validation (integrity checks at deploy time, `sourceInputsOutputsLength` bounds checking at eval time, constructor-level `ZeroFunctionPointers` guard) to ensure that the eval loop operates on well-formed inputs. The modulo-based dispatch, unchecked arithmetic, and in-place memory reuse are all appropriate given these upstream guarantees.

The key security property -- that the eval loop cannot be made to jump to arbitrary code -- holds because:
1. Function pointer indices are bounded by `mod(..., fsCount)`, limiting dispatch to valid table entries.
2. The integrity check at deploy time verifies all opcode indices are in range.
3. The expression deployer verifies bytecode hashes, preventing post-deployment tampering.
4. The `ZeroFunctionPointers` constructor check prevents the mod-by-zero edge case in production.

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH     | 0 |
| MEDIUM   | 0 |
| LOW      | 2 |
| INFO     | 6 |
