# Pass 1 (Security) -- LibEval.sol

**File:** `src/lib/eval/LibEval.sol`
**Agent:** A05
**Date:** 2026-03-01

## Evidence of Thorough Reading

### Library Name

`library LibEval` -- line 15

### Functions

| Function | Line | Visibility |
|----------|------|------------|
| `evalLoop(InterpreterState memory state, uint256 parentSourceIndex, Pointer stackTop, Pointer stackBottom) returns (Pointer)` | 41 | `internal view` |
| `eval2(InterpreterState memory state, StackItem[] memory inputs, uint256 maxOutputs) returns (StackItem[] memory, bytes32[] memory)` | 191 | `internal view` |

### Imports

| Import | Source | Line |
|--------|--------|------|
| `LibInterpreterState`, `InterpreterState` | `../state/LibInterpreterState.sol` | 5 |
| `LibMemCpy` | `rain.solmem/lib/LibMemCpy.sol` | 7 |
| `LibMemoryKV`, `MemoryKV` | `rain.lib.memkv/lib/LibMemoryKV.sol` | 8 |
| `LibBytecode` | `rain.interpreter.interface/lib/bytecode/LibBytecode.sol` | 9 |
| `Pointer` | `rain.solmem/lib/LibPointer.sol` | 10 |
| `OperandV2`, `StackItem` | `rain.interpreter.interface/interface/IInterpreterV4.sol` | 11 |
| `InputsLengthMismatch` | `../../error/ErrEval.sol` | 13 |

### Using Declarations

- `LibMemoryKV for MemoryKV` -- line 16

### Errors Referenced

- `InputsLengthMismatch(uint256 expected, uint256 actual)` -- used at line 213, defined in `src/error/ErrEval.sol`

### Types Used

- `InterpreterState` (struct) -- parameter to both functions
- `Pointer` -- stack pointer type, parameter and return value
- `StackItem` -- stack value type, used in `eval2` input/output arrays
- `OperandV2` -- opcode operand type, used in eval loop dispatch
- `MemoryKV` -- ephemeral key-value store, accessed via `state.stateKV`

### Constants/Errors Defined in This File

None. All error types and constants are imported.

---

## Security Findings

### A05-1: `sourceIndex` Not Bounds-Checked in `evalLoop`

**Severity: LOW**

In `evalLoop` (lines 46-86), `state.sourceIndex` is masked to 16 bits (line 59) and used to index into the bytecode header to locate the source pointer, ops count, and start position. No bounds check is performed against the actual source count in the bytecode.

The NatSpec at lines 25-33 explicitly documents this trust assumption. The two callers validate `sourceIndex` before calling:

- `eval2` (line 231): Validates via `LibBytecode.sourceInputsOutputsLength` (line 200-201), which calls `sourceRelativeOffset`, which reverts with `SourceIndexOutOfBounds` if `sourceIndex >= sourceCount`.
- `LibOpCall.run` (line 153): Relies on the integrity check at deploy time. `LibOpCall.integrity` calls `LibBytecode.sourceInputsOutputsLength` which reverts for invalid indices.

If `evalLoop` were called from a new code path that omits validation, the assembly at line 67 would compute `sourcesPointer` from whatever bytes happen to be at `cursor + sourceIndex * 2`, causing the cursor to land at an arbitrary position relative to `sourcesStart`. The `mod`-based function pointer lookup (line 100) constrains dispatch to real opcode handlers, but with arbitrary operands and an arbitrary opcode sequence, the result would be unpredictable stack manipulation within the allocated stack region.

This is a documented trust assumption, not a bug in the current code. It becomes a risk only if the code is modified to add new callers without following the documented contract.

### A05-2: Division-By-Zero Risk if `state.fs` is Empty

**Severity: LOW**

At line 53: `uint256 fsCount = state.fs.length / 2;`

If `state.fs` is empty (length 0), `fsCount` is 0. The EVM `MOD` opcode returns 0 when the divisor is 0 (it does not revert). Every `mod(byte(..., word), 0)` in the dispatch assembly (lines 100, 107, 114, 121, 128, 135, 142, 149, 166) would return 0. The function pointer lookup at `fPointersStart + 0` would read 2 bytes starting at `add(fPointers, 0x20)`, which is past the end of the empty `fPointers` bytes array. These 2 bytes would be whatever happens to follow in memory, interpreted as an internal function pointer. This could cause a jump to an arbitrary internal function.

**Mitigating factor:** The `Rainterpreter` constructor (line 39 of `Rainterpreter.sol`) checks `opcodeFunctionPointers().length == 0` and reverts with `ZeroFunctionPointers()`. This prevents the standard interpreter from being deployed with empty function pointers. The `unsafeDeserialize` function passes through the `fs` argument from the caller without validation.

The risk is system-level: `evalLoop` as a library function does not self-protect. Any contract integrating `LibEval` directly (rather than through `Rainterpreter`) must ensure `state.fs` is non-empty.

### A05-3: Modulo-Based Dispatch Wraps Out-of-Range Opcode Indices

**Severity: INFO**

The eval loop uses `mod(byte(..., word), fsCount)` (e.g., line 100) to bound opcode indices into the function pointer table. An opcode byte value exceeding `fsCount` wraps around via modulo rather than reverting. For example, if `fsCount` is 50 and the byte is 200, opcode `200 % 50 = 0` is dispatched.

This is by design. The integrity check (`LibIntegrityCheck.sol`) performs strict bounds checks at deploy time, and the expression deployer verifies bytecode hashes to prevent tampering. The `mod` is a cheaper runtime bound than a conditional revert, and only corrupted bytecode (which cannot pass hash verification) could trigger unintended wraparound.

No action required.

### A05-4: `eval2` Entire Body in `unchecked` Block

**Severity: INFO**

The entire `eval2` function body (lines 196-248) is in an `unchecked` block. Arithmetic operations:

- Line 222: `stackTop := sub(stackTop, mul(mload(inputs), 0x20))` -- assembly, unchecked regardless. `inputs.length` is validated against `sourceInputs` (a single byte, max 255) at line 212, and the stack was allocated with `sourceInputs` slots. No underflow risk.
- Line 240: `maxOutputs < sourceOutputs ? maxOutputs : sourceOutputs` -- min operation, no overflow.
- Line 243: `stack := sub(stackTop, 0x20)` -- `stackTop` is a valid memory pointer well above 0.

All values are constrained by bytecode structure and integrity checks. The `unchecked` block is appropriate.

### A05-5: In-Place Output Array Construction Shares Memory With Stack

**Severity: INFO**

At lines 242-245:
```solidity
assembly ("memory-safe") {
    stack := sub(stackTop, 0x20)
    mstore(stack, outputs)
}
```

This constructs a `StackItem[]` by pointing `stack` to 32 bytes before `stackTop` and writing `outputs` as the array length. The returned array aliases the stack's memory region. The NatSpec at lines 233-239 correctly documents that both `stack` and the original stack array must be treated as immutable after this point.

This is safe because `eval2` returns immediately after this construction. The returned array is a read-only view of the stack. If any future modification to the code wrote to the returned array or the stack after this point, it would corrupt both.

### A05-6: `stackTrace` Transient Memory Mutation

**Severity: INFO**

`LibInterpreterState.stackTrace` (called at line 174 from `evalLoop`) temporarily writes to `sub(stackTop, 0x20)` -- the 32-byte word immediately before the stack top. It saves the original value, overwrites it with packed source indices, makes a `staticcall` to a non-existent address, then restores the original value.

This is safe because:
1. The `staticcall` to a codeless address cannot have side effects.
2. The 63/64ths gas rule ensures the caller retains sufficient gas for the `mstore` restore.
3. The address is derived from `keccak256("rain.interpreter.stack-tracer.0")`, making collision with a real contract address infeasible.

The only subtlety: `sub(stackTop, 0x20)` points to memory that was either part of the stack allocation or (if `stackTop == stackBottom`, i.e., no values were pushed) the word immediately before the stack allocation. In the `stackBottom == stackTop` case, this reads/writes the stack's length prefix word, which is safely restored. In the `LibOpCall.run` path, `stackTop == stackBottom` when a called source pushes no values beyond its inputs. The length prefix or a previously pushed value is transiently overwritten and restored.

### A05-7: `memory-safe` Annotations Are Correct

**Severity: INFO**

All assembly blocks in `evalLoop` (lines 57, 92, 99, 106, 113, 120, 127, 134, 141, 148, 164) are marked `memory-safe`. These blocks only:
- Read from `cursor` (within bytecode), `fPointersStart` (within function pointer table), and `word` (a stack variable).
- Write to stack variables (`cursor`, `end`, `m`, `fPointersStart`, `sourceIndex`, `f`, `operand`, `word`).

No memory allocation or modification occurs in these blocks.

In `eval2`, assembly blocks at lines 220-224 and 242-244 write to memory that was allocated by Solidity (stack arrays), which satisfies the `memory-safe` definition.

### A05-8: Remainder Loop Cursor Arithmetic

**Severity: INFO**

At line 161: `cursor -= 0x1c;` (28 bytes back)

After the main 8-at-a-time loop, the cursor is adjusted backwards so that `mload(cursor)` places the next opcode in bytes [28-31] of the loaded 32-byte word, aligning with `byte(28, word)` and `and(word, 0xFFFFFF)` used in the remainder loop (lines 165-168).

Edge cases verified:
- **`opsLength == 0`:** `m = 0`, `end == cursor` after main loop (which doesn't execute). `cursor -= 0x1c` adjusts back, but `end = cursor + 0 = cursor` for the remainder loop, so it doesn't execute. Correct.
- **`opsLength < 8`:** Main loop doesn't execute (`end == cursor`). `cursor -= 0x1c`, then `end = cursor + opsLength * 4`. Remainder loop processes all opcodes one by one. Correct.
- **`opsLength` is exact multiple of 8:** Main loop processes all opcodes. `m = 0`, so `end = cursor + 0 = cursor` for remainder loop. Doesn't execute. Correct.
- **General case:** Main loop processes `opsLength - m` opcodes. Remainder processes the last `m` opcodes (1-7). Cursor positions are consistent.

---

## Summary

No CRITICAL or HIGH severity findings. `LibEval.sol` relies on a layered trust model where upstream components (integrity checks at deploy time, `sourceInputsOutputsLength` at eval time, `ZeroFunctionPointers` constructor guard) ensure the eval loop operates on well-formed inputs. The key security property -- that the eval loop cannot jump to arbitrary code -- is maintained by:

1. Function pointer indices bounded by `mod(..., fsCount)`, limiting dispatch to real opcode handlers.
2. Integrity checks at deploy time verify all opcode indices are in range.
3. Expression deployer verifies bytecode hashes, preventing post-deployment tampering.
4. `ZeroFunctionPointers` constructor check prevents mod-by-zero in the standard interpreter.

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH     | 0 |
| MEDIUM   | 0 |
| LOW      | 2 |
| INFO     | 6 |
