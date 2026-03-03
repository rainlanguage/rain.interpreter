# Pass 1 (Security) -- LibInterpreterState.sol & LibInterpreterStateDataContract.sol

**Auditor**: A14/A15
**Date**: 2026-03-01
**Files**:
- `src/lib/state/LibInterpreterState.sol` (143 lines)
- `src/lib/state/LibInterpreterStateDataContract.sol` (143 lines)

## Evidence of Thorough Reading

### LibInterpreterState.sol

**Constant**: `STACK_TRACER` (line 17) -- `address(uint160(uint256(keccak256("rain.interpreter.stack-tracer.0"))))`, deterministic non-contract address used as staticcall target for debug traces.

**Struct**: `InterpreterState` (line 42-53) -- 9 fields:

| Field | Type | Line |
|---|---|---|
| `stackBottoms` | `Pointer[]` | 43 |
| `constants` | `bytes32[]` | 44 |
| `sourceIndex` | `uint256` | 45 |
| `stateKV` | `MemoryKV` | 47 |
| `namespace` | `FullyQualifiedNamespace` | 48 |
| `store` | `IInterpreterStoreV3` | 49 |
| `context` | `bytes32[][]` | 50 |
| `bytecode` | `bytes` | 51 |
| `fs` | `bytes` | 52 |

**Library**: `LibInterpreterState` (line 55)

**Functions**:

| Function | Signature | Visibility | Line |
|---|---|---|---|
| `stackBottoms` | `(StackItem[][] memory) -> (Pointer[] memory)` | internal pure | 62 |
| `stackTrace` | `(uint256, uint256, Pointer, Pointer) -> ()` | internal view | 126 |

### LibInterpreterStateDataContract.sol

**Library**: `LibInterpreterStateDataContract` (line 14)

**Using directive**: `LibBytes for bytes` (line 15)

**Imports**:

| Import | Source | Line |
|---|---|---|
| `MemoryKV` | `rain.lib.memkv/lib/LibMemoryKV.sol` | 5 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 6 |
| `LibMemCpy` | `rain.solmem/lib/LibMemCpy.sol` | 7 |
| `LibBytes` | `rain.solmem/lib/LibBytes.sol` | 8 |
| `FullyQualifiedNamespace` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 9 |
| `IInterpreterStoreV3` | `rain.interpreter.interface/interface/IInterpreterStoreV3.sol` | 10 |
| `InterpreterState` | `./LibInterpreterState.sol` | 12 |

**Functions**:

| Function | Signature | Visibility | Line |
|---|---|---|---|
| `serializeSize` | `(bytes memory, bytes32[] memory) -> (uint256)` | internal pure | 26 |
| `unsafeSerialize` | `(Pointer, bytes memory, bytes32[] memory) -> ()` | internal pure | 39 |
| `unsafeDeserialize` | `(bytes memory, uint256, FullyQualifiedNamespace, IInterpreterStoreV3, bytes32[][] memory, bytes memory) -> (InterpreterState memory)` | internal pure | 69 |

---

## Security Analysis

### 1. `stackBottoms` Assembly Correctness (LibInterpreterState.sol lines 62-79)

The function allocates a `Pointer[]` array of length `stacks.length`, then iterates over each `StackItem[]` in the input array, computing `stackBottom = stack + 0x20 * (length + 1)` for each.

**Loop invariants**:
- `cursor` starts at `stacks + 0x20` (first element pointer), ends at `stacks + 0x20 + stacks.length * 0x20`
- `bottomsCursor` starts at `bottoms + 0x20` (first element slot), advances in lockstep
- For each stack: `mload(cursor)` loads the pointer to the inner `StackItem[]`, then `mload(stack)` reads its length

**Edge case -- empty stacks**: When `stacks.length == 0`, `end == cursor` at init, the loop body never executes, and an empty `Pointer[]` is returned. Correct.

**Memory safety**: The `bottoms` array is allocated via `new Pointer[](stacks.length)` before the assembly block, so Solidity manages the free memory pointer. The assembly only writes within the allocated bounds. Marked `memory-safe` correctly.

**Conclusion**: Correct. No issues found.

### 2. `stackTrace` Memory Mutation (LibInterpreterState.sol lines 126-142)

This function temporarily overwrites memory at `stackTop - 0x20` with the packed `(parentSourceIndex, sourceIndex)` selector, calls `STACK_TRACER` via `staticcall`, then restores the original value.

**Save/restore correctness**: Line 135 saves `mload(sub(stackTop, 0x20))` into `before`. Line 136 overwrites it. Line 140 restores it. The pattern is correct -- the value is always restored regardless of the staticcall outcome.

**Masking**: Both `parentSourceIndex` and `sourceIndex` are masked to 16 bits with `and(..., 0xFFFF)` before being packed. Upper bits are correctly discarded.

**Calldata region**: The staticcall reads from `sub(stackTop, 4)` with length `sub(stackBottom, stackTop) + 4`. This correctly selects the 4-byte packed selector plus the stack data from top to bottom.

**Edge case -- empty stack** (`stackTop == stackBottom`): The staticcall size is `4` (just the selector). The memory at `stackTop - 0x20` is still within valid memory because `stackTop` points to `stackBottom`, which is computed as `stack_array + 0x20 * (length + 1)`. The word at `stackTop - 0x20` is either the last stack slot or, for a zero-length stack, the length prefix of the array. The save/restore ensures no corruption.

**Edge case -- calldata extends into packed selector bytes**: The 4-byte selector is written at `stackTop - 0x20` but the `staticcall` reads from `sub(stackTop, 4)`. Since `mstore` writes a full 32-byte word at the target, the low 4 bytes of the 32-byte word at `stackTop - 0x20` will be at address `stackTop - 4`. The packed `or(shl(0x10, masked_parent), masked_source)` places the two uint16 values in the high 4 bytes of the 32-byte word. But `mstore(beforePtr, ...)` writes the full word, placing the 4-byte value in the high bytes at `beforePtr`. Reading from `sub(stackTop, 4)` reads bytes at `stackTop - 4` through `stackTop - 4 + 31`. The relevant 4 bytes at `stackTop - 4` correspond to bytes 28-31 of the word stored at `stackTop - 0x20`, which would be zeros from the `or(shl(0x10, ...), ...)` because the value is only 4 bytes wide and stored in the high bytes of the word.

Wait -- let me re-check this. The value written is `or(shl(0x10, and(parentSourceIndex, 0xFFFF)), and(sourceIndex, 0xFFFF))`. This is a 32-bit value (4 bytes). `mstore(beforePtr, value)` stores it left-aligned in the 32-byte word at `beforePtr`. So bytes at `beforePtr + 0` through `beforePtr + 3` contain the 4-byte selector. `beforePtr = stackTop - 0x20`. So the selector is at addresses `stackTop - 0x20` through `stackTop - 0x1d`. The `staticcall` reads from `sub(stackTop, 4)` = `stackTop - 4`, which is addresses `stackTop - 4` through `stackTop - 4 + calldata_size - 1`.

These two ranges do not overlap when `stackTop - 0x20 + 3 < stackTop - 4`, i.e., `0x20 - 3 > 4`, i.e., `29 > 4` -- true. So the staticcall reads from a different region than where the selector was written.

This is a potential issue. The selector bytes are written at `stackTop - 0x20`, but the calldata starts at `stackTop - 4`. The 4 bytes of calldata at `stackTop - 4` through `stackTop - 1` are NOT the selector -- they are whatever was in those bytes before the function was called (the low bytes of the overwritten word and/or the high bytes of the first stack item).

Actually, let me re-read the assembly more carefully:

```solidity
mstore(beforePtr, or(shl(0x10, and(parentSourceIndex, 0xFFFF)), and(sourceIndex, 0xFFFF)))
```

`beforePtr = sub(stackTop, 0x20)`. This stores: the value `(parentSourceIndex & 0xFFFF) << 16 | (sourceIndex & 0xFFFF)` is a uint256 with only the top 32 bits set (since shl(0x10, ...) shifts left by 16 bits, not bytes). Wait, no. `shl` operates on the full 256-bit value. `shl(0x10, x)` shifts x left by 16 bits. If x is `0xABCD`, the result is `0xABCD0000`. Then `or` with `sourceIndex & 0xFFFF`. So the result is a value like `0xABCD1234` (32 bits, fitting in the high bytes of the 256-bit word when stored).

When `mstore(beforePtr, value)` stores this 256-bit value, the big-endian representation places the most significant bytes first. So the byte at `beforePtr + 0` would be `0x00`, `beforePtr + 1` = `0x00`, ..., up to `beforePtr + 28` = `0xAB`, `beforePtr + 29` = `0xCD`, `beforePtr + 30` = `0x12`, `beforePtr + 31` = `0x34`.

The `staticcall` reads from `sub(stackTop, 4)`. Since `beforePtr = stackTop - 0x20`, `sub(stackTop, 4) = beforePtr + 0x1c = beforePtr + 28`.

So the staticcall reads bytes starting at `beforePtr + 28`, which is exactly `0xAB, 0xCD, 0x12, 0x34` -- the 4-byte selector!

OK, so the encoding IS correct. The 4-byte packed value lands in the low 4 bytes of the 256-bit word, and the staticcall reads exactly those 4 bytes as the start of its calldata, followed by the stack data.

**Conclusion**: `stackTrace` is correct. The memory mutation pattern is safe.

### 3. `serializeSize` Unchecked Overflow (LibInterpreterStateDataContract.sol lines 26-31)

```solidity
unchecked {
    size = bytecode.length + constants.length * 0x20 + 0x40;
}
```

The `constants.length * 0x20` can overflow if `constants.length >= 2^251` (producing a length field that, when multiplied by 32, wraps around). The addition can also overflow. The NatSpec explicitly documents this: "the caller MUST ensure the in-memory length fields of bytecode and constants are not corrupt."

In practice, the only caller (`RainterpreterExpressionDeployer.parse2`) receives these from the parser, which produces Solidity-allocated arrays. Solidity's `new` operator bounds array sizes by available memory/gas, making overflow impossible in practice.

**Conclusion**: The unchecked arithmetic is safe given the documented precondition and the actual calling context. The NatSpec correctly warns callers.

### 4. `unsafeSerialize` Assembly Cursor Mutation (LibInterpreterStateDataContract.sol lines 39-54)

The assembly block modifies the `cursor` parameter (a stack variable of type `Pointer`) in-place. After the loop completes, `cursor` has been advanced past the constants data (length prefix + all elements). The subsequent Solidity call on line 52 uses this updated `cursor` value for the bytecode copy.

**Correctness of cursor advancement**:
- Initial: `constantsCursor = constants` (length prefix), `cursor` = destination start
- Loop iterates `constants.length + 1` times (length word + each element)
- Post-loop: `cursor = initial_cursor + 0x20 * (constants.length + 1)` = exactly past constants region
- Line 52 copies `bytecode.length + 0x20` bytes (length prefix + data) starting at the new cursor position

**Memory safety**: The caller (`RainterpreterExpressionDeployer.parse2`) allocates `serializeSize` bytes before calling `unsafeSerialize`. The total bytes written are `0x20 * (constants.length + 1) + bytecode.length + 0x20 = constants.length * 0x20 + 0x40 + bytecode.length`, which equals `serializeSize`. Correct.

**Conclusion**: Correct. No issues found.

### 5. `unsafeDeserialize` Memory Safety (LibInterpreterStateDataContract.sol lines 69-142)

This is the most complex function. It deserializes a flat byte array into an `InterpreterState` struct by creating in-place references and allocating stacks.

**Constants reference** (lines 84-88): `constants := cursor` makes `constants` point directly into the serialized data. `cursor` advances by `0x20 * (mload(cursor) + 1)`, correctly skipping the length prefix and all elements.

**Bytecode reference** (lines 91-93): `bytecode := cursor` makes `bytecode` point directly into the serialized data at the position after constants.

**Stack allocation** (lines 98-135):
- `cursor` advances past bytecode's length word (`add(cursor, 0x20)`)
- `stacksLength = byte(0, mload(cursor))` reads first byte of bytecode data (source count)
- `cursor` advances by 1
- `sourcesStart = cursor + stacksLength * 2` -- start of source data, past the relative pointer table
- `stackBottoms` is allocated at free memory pointer with length `stacksLength`
- Free memory pointer is advanced by `(stacksLength + 1) * 0x20`

**Per-source stack allocation loop**:
- `sourcePointer = sourcesStart + (mload(cursor) >> 0xf0)` -- reads 2-byte relative offset from cursor, shifts right by 240 bits to extract the uint16
- `stackSize = byte(1, mload(sourcePointer))` -- reads second byte of source prefix (stack allocation)
- Allocates a new array at free memory pointer with length `stackSize`
- Sets `stackBottom = stack + (stackSize + 1) * 0x20` -- just past last element
- Advances free memory pointer to `stackBottom`
- Stores `stackBottom` in the `stackBottoms` array

**Zero stackSize edge case**: If `stackSize == 0`, the array has length 0 and `stackBottom = stack + 0x20`. Only the length word is allocated. This is valid.

**Memory safety annotation**: The large assembly block at lines 98-136 is marked `memory-safe`. It allocates memory by reading and writing `mload(0x40)` / `mstore(0x40, ...)` correctly. Each allocation advances the free memory pointer past the allocated region. No memory is read or written outside allocated regions.

**Conclusion**: The assembly is correct for well-formed serialized input. No memory corruption occurs.

### 6. Malformed Serialized Input to `unsafeDeserialize`

The function name contains `unsafe`, indicating no validation of the serialized data. If a caller passes crafted data:

- A corrupt `constants.length` (first word of serialized data) could cause `cursor` to advance past the end of the serialized byte array, causing `bytecode` and subsequent reads to reference zeroed or unrelated memory.
- A corrupt source relative offset could make `sourcePointer` reference arbitrary memory, reading a garbage `stackSize`, potentially allocating an enormous stack (bounded only by gas).
- A corrupt `stacksLength` could cause the loop to allocate many stacks, consuming all available gas.

**Mitigating factors**:
1. The only production caller is `Rainterpreter.eval4`, which is `view` -- no state changes are possible regardless of what happens in memory.
2. The caller provides the bytecode -- a malicious caller can only affect their own call's return value.
3. Memory is bounded by gas -- excessive allocations simply run out of gas and revert.
4. The expression deployer runs integrity checks before producing serialized bytecode, so well-behaved callers always provide valid data.

**Conclusion**: The lack of validation is by design. The `unsafe` prefix correctly signals the precondition. No exploitable vulnerability exists because the function runs in a `view` context and callers provide their own data.

### 7. `stackTrace` Memory Region for Empty or Single-Element Stack

When `stackTop == stackBottom - 0x20` (single stack item): `beforePtr = stackTop - 0x20 = stackBottom - 0x40`. This is within the stack array allocation (the length prefix or a prior stack slot). The save/restore is safe.

When `stackTop > stackBottom` (underflow -- more consumed than allocated): This would be a logic error elsewhere (integrity check failure). The function would read `beforePtr` below the stack allocation. However, this scenario is prevented by the integrity check at deploy time, which ensures stack balance.

**Conclusion**: Safe under the documented precondition that integrity checks pass.

---

## Findings

### A14-1 -- INFO: `stackTrace` temporarily overwrites memory outside allocated stack bounds

**Location**: `src/lib/state/LibInterpreterState.sol` lines 131-140

**Description**: The `stackTrace` function writes to `sub(stackTop, 0x20)`, which is always 32 bytes below the current stack top. When the stack is empty (`stackTop == stackBottom`), this writes to the word immediately before the stack's data region -- typically the stack array's length prefix. The value is correctly saved and restored, so no corruption occurs. The `memory-safe` annotation is technically correct because the mutation is transient and fully reversed.

**Severity**: INFO

### A15-1 -- INFO: `serializeSize` unchecked arithmetic relies on caller precondition

**Location**: `src/lib/state/LibInterpreterStateDataContract.sol` lines 26-31

**Description**: The `unchecked` block in `serializeSize` can overflow if `constants.length * 0x20` wraps around a 256-bit boundary. This is documented in the NatSpec ("the caller MUST ensure the in-memory length fields of bytecode and constants are not corrupt"). The sole production caller (`RainterpreterExpressionDeployer.parse2`) always provides Solidity-allocated arrays, making overflow impossible in practice.

**Severity**: INFO

### A15-2 -- INFO: `unsafeDeserialize` performs no validation of serialized data structure

**Location**: `src/lib/state/LibInterpreterStateDataContract.sol` lines 69-142

**Description**: The function trusts that the serialized byte array has the correct internal structure (valid constants length, valid bytecode format, valid source count and offsets). Malformed data would cause reads from arbitrary memory positions and potentially allocate extremely large stacks. This is by design (the `unsafe` prefix documents the precondition), and the production caller (`Rainterpreter.eval4`) is a `view` function, so no state corruption is possible. Callers provide their own bytecode, so they can only affect their own return values.

**Severity**: INFO

### A15-3 -- LOW: `unsafeDeserialize` free memory pointer gap when `stacksLength` is 0

**Location**: `src/lib/state/LibInterpreterStateDataContract.sol` lines 106-108

**Description**: When `stacksLength` is 0 (no sources in bytecode), the code allocates a `stackBottoms` array:

```solidity
stackBottoms := mload(0x40)
mstore(stackBottoms, stacksLength)           // writes 0
mstore(0x40, add(stackBottoms, mul(add(stacksLength, 1), 0x20)))  // advances by 0x20
```

This allocates a `Pointer[]` of length 0 (just the length prefix word). The loop body never executes, so no stacks are allocated. This is correct behavior, but the resulting `InterpreterState` has an empty `stackBottoms` array. If `eval2` is subsequently called with `state.sourceIndex >= 0` (which it always is), the array access `state.stackBottoms[state.sourceIndex]` at `LibEval.sol` line 206 will revert with an out-of-bounds panic. This means zero-source bytecode always reverts at eval time, which is correct but the revert path is indirect -- the failure occurs during eval rather than at deserialization.

**Severity**: LOW -- The behavior is correct (zero-source bytecode is invalid), but the error path is indirect. A defensive check at deserialization time would provide a clearer revert reason.

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. Both files implement low-level memory operations using inline assembly with correct patterns:

- `stackBottoms` correctly computes array bottom pointers with proper loop bounds
- `stackTrace` correctly saves/restores memory during its transient mutation
- `unsafeSerialize` correctly advances the cursor through constants and bytecode
- `unsafeDeserialize` correctly creates in-place references and allocates stacks with proper free memory pointer management

The `unsafe` prefix on serialize/deserialize functions correctly documents that callers must provide valid data. The production calling context (`view` function, caller-provided data) means malformed input cannot cause state corruption or cross-user impact.

One LOW finding (A15-3) identifies an indirect error path for zero-source bytecode that could benefit from an explicit check, though the current behavior is not exploitable.
