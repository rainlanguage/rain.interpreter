# A116 — LibInterpreterState.sol — Pass 1 (Security)

## Evidence

**Library:** `LibInterpreterState`

**Constants:**
- `STACK_TRACER` (line 17): `address(uint160(uint256(keccak256("rain.interpreter.stack-tracer.0"))))` — Deterministic address for stack trace emissions via staticcall.

**Struct:**
- `InterpreterState` (line 42): 9-field struct containing stackBottoms, constants, sourceIndex, stateKV, namespace, store, context, bytecode, fs.

**Functions:**
- `stackBottoms(StackItem[][] memory stacks) -> Pointer[] memory` (line 62): Converts pre-allocated stack arrays into bottom pointers.
- `stackTrace(uint256 parentSourceIndex, uint256 sourceIndex, Pointer stackTop, Pointer stackBottom)` (line 126): Emits a stack trace via staticcall to the tracer address.

**Custom errors:** None.

## Security Review

### stackBottoms (line 62-79)

Assembly loop iterates `stacks` and computes `stackBottom = stack + 0x20 * (stack.length + 1)` for each stack. The loop bounds are correct:
- `cursor` starts at `stacks + 0x20` (first element pointer).
- `end = stacks + 0x20 + stacks.length * 0x20` (one past last element pointer).
- `bottomsCursor` advances in lockstep with `cursor`.
- The output array `bottoms` is allocated with `stacks.length` slots, matching the loop iteration count.

The `memory-safe` annotation is valid: the assembly only reads from the input array and writes to the freshly allocated output array, both within Solidity-managed memory.

No issues found.

### stackTrace (line 126-142)

This function temporarily mutates memory at `sub(stackTop, 0x20)` to write a 4-byte function selector (packed parentSourceIndex and sourceIndex), issues a `staticcall` to the STACK_TRACER address, then restores the original value.

**Memory mutation safety:** The word at `sub(stackTop, 0x20)` is saved before mutation and restored immediately after the staticcall. The staticcall target has no code, so it cannot re-enter or observe the temporary mutation. Net memory effect is zero.

**Pointer arithmetic:** `sub(stackTop, 4)` is used as calldata start. This reads the bottom 4 bytes of the word written at `sub(stackTop, 0x20)` plus the stack data from `stackTop` to `stackBottom`. The calldata size is `add(sub(stackBottom, stackTop), 4)`. When the stack is empty (stackTop == stackBottom), this correctly produces 4 bytes of calldata.

**Source index masking:** Both `parentSourceIndex` and `sourceIndex` are masked to 16 bits via `and(..., 0xFFFF)`. Upper bits cannot leak into the trace encoding.

**`memory-safe` annotation:** Technically, the assembly mutates memory that was not allocated in this scope. However, the save-and-restore pattern ensures the net effect is zero, and the mutation window is confined to a `staticcall` that cannot cause re-entry. The Solidity compiler's optimizer treats `memory-safe` as a promise that the free memory pointer and zero slot are preserved, which they are. Acceptable.

No issues found.

## Findings

No findings.
