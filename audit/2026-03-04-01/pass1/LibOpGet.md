# A100 — Pass 1 (Security) — LibOpGet.sol

**File:** `src/lib/op/store/LibOpGet.sol`

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpGet` | library | 13 |
| `integrity` | internal pure function | 19 |
| `run` | internal view function | 32 |
| `referenceFn` | internal view function | 68 |

**Imports:**
- `MemoryKVKey`, `MemoryKVVal`, `MemoryKV`, `LibMemoryKV` (from `rain.lib.memkv`)
- `OperandV2`, `StackItem` (user-defined value types)
- `Pointer` (user-defined value type from `rain.solmem`)
- `InterpreterState` (struct)
- `IntegrityCheckState` (struct)

**Using declarations:**
- `LibMemoryKV for MemoryKV` (line 14)

**No custom errors, events, or constants defined.**

## Analysis

### Integrity inputs/outputs vs run behavior

`integrity()` returns `(1, 1)` -- one input consumed (key), one output produced (value).

`run()` behavior:
- Reads 1 word from `stackTop` (line 35): the key. This consumes 1 input.
- Returns `stackTop` unchanged (line 61): the value is written back in-place at the same location via `mstore(stackTop, ...)` (lines 51, 57).

This is correct for a (1, 1) opcode. The eval loop receives the same `stackTop` back, which now contains the looked-up value where the key was. The stack depth stays the same: -1 input +1 output = net 0 change, consistent with an in-place replacement at `stackTop`.

### Assembly memory safety

Two assembly blocks in `run`:

1. **Lines 34-36** (`key := mload(stackTop)`): Read-only. Reads from the stack, which is within the pre-allocated region. Memory-safe.

2. **Lines 50-52** / **Lines 56-58** (`mstore(stackTop, storeValue)` / `mstore(stackTop, value)`): Writes to `stackTop`, which is within the pre-allocated stack region (stack allocation validated by integrity check). Memory-safe.

Both blocks are correctly annotated as `memory-safe`.

### Stack underflow/overflow

The integrity check framework (LibIntegrityCheck) validates that at least 1 item is on the stack before `get` runs (1 input). The output (1 value) replaces the input in-place, so no additional stack space is needed beyond what the input already occupied. No underflow or overflow risk.

### Cache miss behavior and store interaction

On cache miss (line 40), `run()` calls `state.store.get(state.namespace, key)` as a `view` external call. The `run` function itself is `internal view`, and the eval loop is `view`, so no state-modifying reentrancy is possible through this path.

The fetched value is then cached in `stateKV` (line 48), which means read-only keys will be persisted to storage at end of eval. This is the known false positive documented in `audit/known-false-positives.md` -- a deliberate gas tradeoff.

### Cache hit behavior

On cache hit (line 55), the value from the in-memory KV store is written directly to the stack. No external calls. Correct.

### Namespace isolation

The store read uses `state.namespace` (line 41), which is a `FullyQualifiedNamespace` set by the caller (Rainterpreter). This is constructed from `msg.sender` and the caller-provided `StateNamespace`, ensuring sandboxed access. The namespace isolation is enforced by the store contract, not by this opcode -- which is the correct separation of concerns.

### Operand validation

The operand is unused by both `integrity()` and `run()`. The parser enforces that no operands are provided (tested by `testLibOpGetEvalOperandDisallowed`). No validation needed here.

### referenceFn consistency

`referenceFn()` (lines 68-92) mirrors the `run()` logic using high-level Solidity: reads `inputs[0]` as key, checks stateKV, falls back to store, caches on miss, returns the value. The logic is identical to `run()`.

## Findings

No findings. The implementation is correct and secure. The read-only key persistence behavior is a known false positive (documented in `audit/known-false-positives.md`).
