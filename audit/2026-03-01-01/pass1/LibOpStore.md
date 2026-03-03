# Pass 1: LibOpGet.sol and LibOpSet.sol

## Files Audited

- `src/lib/op/store/LibOpGet.sol` (93 lines)
- `src/lib/op/store/LibOpSet.sol` (56 lines)

## Evidence of Thorough Reading

### LibOpGet.sol

- Lines 1-9: SPDX license (`LicenseRef-DCL-1.0`), pragma `^0.8.25`, five imports: `LibMemoryKV`/`MemoryKVKey`/`MemoryKVVal`/`MemoryKV` from `rain.lib.memkv`, `OperandV2`/`StackItem` from `IInterpreterV4`, `Pointer` from `rain.solmem`, `InterpreterState` from `LibInterpreterState`, `IntegrityCheckState` from `LibIntegrityCheck`.
- Lines 11-14: `library LibOpGet` with `using LibMemoryKV for MemoryKV`.
- Lines 16-23: `integrity()` -- pure, ignores both parameters, returns `(1, 1)` meaning 1 input (key) and 1 output (value).
- Lines 25-62: `run()` -- marked `view` because of the external `state.store.get()` call on cache miss. Assembly block at line 34 reads key from `stackTop`. Line 37 attempts cache lookup via `state.stateKV.get()`. On miss (lines 40-52): fetches from external store, caches fetched value (including zero) into `stateKV`, writes value to `stackTop`. On hit (lines 55-58): writes cached value to `stackTop`. Returns `stackTop` unchanged (1 input consumed, 1 output produced at same location).
- Lines 44-48: Comment documents deliberate design choice: read-only keys are cached and therefore will be persisted to the on-chain store at eval end, paying an unnecessary SSTORE. This is a gas-cost tradeoff, not a correctness issue.
- Lines 64-92: `referenceFn()` -- array-based mirror of `run` used for differential testing. Same cache-miss/hit logic using `StackItem[]` inputs/outputs instead of raw pointers.

### LibOpSet.sol

- Lines 1-9: Same license/pragma pattern, imports `LibMemoryKV`/`MemoryKV`/`MemoryKVKey`/`MemoryKVVal`, `IntegrityCheckState`, `OperandV2`/`StackItem`, `InterpreterState`, `Pointer`.
- Lines 11-14: `library LibOpSet` with `using LibMemoryKV for MemoryKV`.
- Lines 16-23: `integrity()` -- pure, ignores parameters, returns `(2, 0)` meaning 2 inputs (key, value) and 0 outputs.
- Lines 25-40: `run()` -- marked `pure` (no external calls needed). Assembly block reads key from `stackTop`, value from `stackTop + 0x20`, advances `stackTop` by `0x40` (consuming both inputs). Line 38 stores to `stateKV`.
- Lines 42-55: `referenceFn()` -- array-based mirror for testing, returns empty `StackItem[]`.

## Security Analysis

### State KV Caching Safety

The `get` opcode caches every value it reads from the external store into `stateKV`, including cache misses that return zero. The `stateKV` is then exported as a `bytes32[]` by `LibEval.eval2` (line 247) and returned to the caller. The caller (not the interpreter) is responsible for calling `store.set()` with these KV pairs.

Caching zero values on miss means that a `get` on an unset key will produce a `(key, 0)` entry in the final KV writes. When the caller applies these writes, it will call `store.set()` with key=X, value=0. This is semantically a no-op on a fresh store (default is already 0), but it costs an SSTORE. This is documented in the code comments and is a known gas tradeoff, not a correctness bug.

### Assembly Memory Safety

Both files use `assembly ("memory-safe")` blocks. Analysis:

**LibOpGet.run:**
- Line 34-36: `key := mload(stackTop)` -- reads from a pre-validated stack pointer. The integrity check ensures exactly 1 input exists on the stack before `run` is called. Memory-safe: reads only.
- Lines 50-52: `mstore(stackTop, storeValue)` -- writes the fetched value back into the same stack slot that held the key. This is within the stack's allocated memory region. Memory-safe: overwrites own stack slot.
- Lines 56-58: `mstore(stackTop, value)` -- same pattern for cache hit. Memory-safe.

**LibOpSet.run:**
- Lines 32-36: Reads key from `stackTop`, value from `stackTop + 0x20`, advances `stackTop` by `0x40`. Both reads are within the stack's allocated region (integrity ensures 2 inputs exist). The pointer arithmetic is correct: consuming 2 words = advancing by `0x40` bytes.

All assembly blocks are correctly marked `memory-safe` and do not violate their claimed safety: they only read/write within the stack region that is guaranteed to be allocated by the integrity check.

### Namespace Isolation

The `get` opcode reads from the external store using `state.namespace`, which is a `FullyQualifiedNamespace`. This namespace is set during deserialization in `LibInterpreterStateDataContract.unsafeDeserialize` from whatever the caller of `eval4` provides. The `set` opcode only writes to the in-memory `stateKV` and does not interact with the namespace directly.

Namespace qualification is the responsibility of the interpreter's `eval4` caller and the store's `set()` function (which qualifies by `msg.sender`). This is outside the scope of LibOpGet/LibOpSet themselves.

### Can get/set corrupt the KV store?

No. Both opcodes interact with `stateKV` exclusively through `LibMemoryKV.get()` and `LibMemoryKV.set()`, which are the canonical accessor functions for the linked-list-based in-memory KV store. The `MemoryKV` type is a value type (`uint256`) that is reassigned on every `set` (the `stateKV` field on `InterpreterState` is updated with the return value). This prevents stale-pointer issues.

The only path to KV corruption would be through `LibMemoryKV` itself (e.g., the `MemoryKVOverflow` error if a pointer exceeds `0xFFFF`), which is handled by the library and not specific to these opcodes.

## Findings

### A28-1 [INFO] Read-only `get` keys are persisted to on-chain store, paying unnecessary SSTORE gas

**File:** `src/lib/op/store/LibOpGet.sol`, lines 42-48

When a `get` encounters a cache miss, it fetches from the external store and caches the result in `stateKV`. This cached value is then included in the KV writes returned by `eval2`, meaning the caller will call `store.set()` with the read-only value. For keys that are only read and never written, this pays an SSTORE for a value that is already present in storage.

This is documented in the code comments at lines 43-47 as a deliberate design tradeoff. The gas savings from caching repeated reads within a single eval are expected to outweigh the SSTORE cost in practice. No fix needed -- this is informational only, documenting a known design decision.

### A28-2 [INFO] NatSpec for `integrity` functions uses `@return` without parameter names

**File:** `src/lib/op/store/LibOpGet.sol`, lines 16-18; `src/lib/op/store/LibOpSet.sol`, lines 16-18

Both `integrity` functions have `@return` tags that describe inputs/outputs but do not name the return values. The function signatures use unnamed returns `(uint256, uint256)`. This is consistent with the codebase style for integrity functions and is not a defect, but named returns would improve documentation clarity.

No fix needed -- informational only.
