# Pass 1 (Security) -- LibOpGet.sol and LibOpSet.sol

## Evidence of Thorough Reading

### LibOpGet.sol (`src/lib/op/store/LibOpGet.sol`)

- **Library name:** `LibOpGet` (line 13)
- **Functions:**
  - `integrity` (line 17) -- returns `(1, 1)` for 1 input (key), 1 output (value)
  - `run` (line 29) -- runtime: reads key from stack, attempts memory KV cache lookup, falls back to external store on cache miss, writes value back to stack
  - `referenceFn` (line 62) -- reference implementation for testing; mirrors `run` logic using `StackItem[]` arrays
- **Errors/Events/Structs:** None defined in this file
- **Imports:** `MemoryKVKey`, `MemoryKVVal`, `MemoryKV`, `LibMemoryKV` (rain.lib.memkv), `OperandV2`, `StackItem` (rain.interpreter.interface), `Pointer` (rain.solmem), `InterpreterState` (local), `IntegrityCheckState` (local)

### LibOpSet.sol (`src/lib/op/store/LibOpSet.sol`)

- **Library name:** `LibOpSet` (line 13)
- **Functions:**
  - `integrity` (line 17) -- returns `(2, 0)` for 2 inputs (key, value), 0 outputs
  - `run` (line 24) -- runtime: reads key and value from stack, writes to in-memory `stateKV`, advances stack pointer by 0x40 (consuming 2 items)
  - `referenceFn` (line 40) -- reference implementation for testing; mirrors `run` logic using `StackItem[]` arrays
- **Errors/Events/Structs:** None defined in this file
- **Imports:** `MemoryKV`, `MemoryKVKey`, `MemoryKVVal`, `LibMemoryKV` (rain.lib.memkv), `IntegrityCheckState` (local), `OperandV2`, `StackItem` (rain.interpreter.interface), `InterpreterState` (local), `Pointer` (rain.solmem)

---

## Findings

### INFO-1: Read-only keys are persisted to the store unnecessarily

**File:** `src/lib/op/store/LibOpGet.sol`, lines 40-45

**Description:** When a `get` encounters a cache miss, the value fetched from the external store is written into the in-memory `stateKV` (line 45). This means that at the end of evaluation, when the caller persists all `stateKV` entries to the store via `store.set()`, read-only keys will also be written back, paying an unnecessary `SSTORE`. The code's own comments acknowledge this tradeoff: "this means read-only keys will also be persisted to the store at the end of eval, paying an unnecessary SSTORE."

**Impact:** Gas inefficiency only. No security impact. The value written back is the same value already in storage, so the `SSTORE` goes from non-zero to the same non-zero value (which is relatively cheap post-EIP-2929 warm access). This is a deliberate design tradeoff documented in commit `25c7c56f`.

**Severity:** INFO

---

### INFO-2: `unchecked` block in LibOpSet.run is a no-op

**File:** `src/lib/op/store/LibOpSet.sol`, lines 25-36

**Description:** The `unchecked` block wraps the entire `run` function body. However, all arithmetic operations (`add(stackTop, 0x20)`, `add(stackTop, 0x40)`) are inside an inline `assembly` block, which is always unchecked regardless of the surrounding Solidity context. The only Solidity-level operation is `state.stateKV.set(...)` which does not perform arithmetic at this call site. The `unchecked` block therefore has no effect.

**Impact:** No security impact. The block is harmless but misleading -- it suggests there is intentionally unchecked arithmetic when there is none at this level.

**Severity:** INFO

---

### INFO-3: Namespace is caller-provided and not re-qualified by the interpreter

**File:** `src/lib/op/store/LibOpGet.sol`, line 38

**Description:** The `get` opcode calls `state.store.get(state.namespace, key)` where `state.namespace` is a `FullyQualifiedNamespace` passed directly by the caller through `EvalV4.namespace`. The interpreter does not independently qualify the namespace with `msg.sender` -- it trusts the caller to have already done so. This is by design: `eval4()` is a `view` function and cannot modify storage. Write-side isolation is enforced by `RainterpreterStore.set()`, which qualifies `StateNamespace` with `msg.sender` before writing. For reads, the caller must provide the correct `FullyQualifiedNamespace` to retrieve its own data; providing a different namespace would only let the caller read someone else's already-public on-chain data (which is visible to anyone via `store.get()` anyway since `get` is a public view function).

**Impact:** No security impact. The store's `get` function is public and view-only, so any address can call it with any namespace. Read isolation is not a security property of the store design. Write isolation is enforced at the `store.set()` boundary.

**Severity:** INFO

---

### Checklist of Specific Audit Concerns

| Concern | LibOpGet | LibOpSet | Notes |
|---------|----------|----------|-------|
| Assembly memory safety | PASS | PASS | All assembly blocks are `memory-safe`. `get` reads/writes only at `stackTop` (valid by integrity guarantee). `set` reads at `stackTop` and `stackTop+0x20` (valid since integrity declares 2 inputs), then advances `stackTop` by `0x40`. |
| Stack underflow/overflow | PASS | PASS | `integrity` declarations match `run` behavior. `get`: 1 in, 1 out (reads and writes same slot). `set`: 2 in, 0 out (reads 2 slots, advances pointer past them). |
| Integrity inputs/outputs match run | PASS | PASS | `get` integrity `(1,1)` matches: reads 1 value, writes 1 value to same position, returns same `stackTop`. `set` integrity `(2,0)` matches: reads 2 values, returns `stackTop + 0x40`. |
| Unchecked arithmetic | PASS | PASS | No dangerous unchecked Solidity arithmetic. Assembly arithmetic in `set` (`add stackTop 0x20/0x40`) cannot overflow since stack pointers are memory addresses well within 256-bit range. |
| Namespace isolation | PASS | PASS | `get` uses `state.namespace` (fully qualified, caller-provided) for reads only. `set` writes only to in-memory `stateKV`, not to persistent storage. Persistent write isolation is enforced by `RainterpreterStore.set()`. |
| Reentrancy | N/A | N/A | `get` makes an external call to `store.get()` but the function is `view` and the interpreter's `eval4` is also `view`, so no state mutations are possible. `set` makes no external calls. |
| Custom errors only | PASS | PASS | Neither file contains `revert("...")` or string error messages. Neither file defines custom errors (none needed). |
| Operand validation | PASS | PASS | Both opcodes ignore the `OperandV2` parameter entirely (no operand bytes are expected or parsed). This is correct -- neither opcode uses operand data. |
