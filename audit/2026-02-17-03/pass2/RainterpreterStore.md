# A50 — RainterpreterStore Test Coverage

## Evidence of Thorough Reading

### Source File: `src/concrete/RainterpreterStore.sol`

**Contract name:** `RainterpreterStore` (line 25) — implements `IInterpreterStoreV3`, inherits `ERC165`

**Functions:**
- `supportsInterface(bytes4)` — line 43 (public view virtual override)
- `set(StateNamespace, bytes32[] calldata)` — line 48 (external virtual)
- `get(FullyQualifiedNamespace, bytes32)` — line 66 (external view virtual)

**State variables:**
- `sStore` — line 40: `mapping(FullyQualifiedNamespace => mapping(bytes32 => bytes32))` (internal)

**Errors used:**
- `OddSetLength(uint256)` — imported from `src/error/ErrStore.sol`, used at line 52

**Events used (inherited from IInterpreterStoreV3):**
- `Set(FullyQualifiedNamespace, bytes32, bytes32)` — emitted at line 59

**Imports/exports:**
- `STORE_BYTECODE_HASH` exported from generated pointers (line 16)

### Test File: `test/src/concrete/RainterpreterStore.t.sol`

**Contract name:** `RainterpreterStoreTest` (line 16)

**Structs:**
- `Set` — line 56 (namespace, kvs)
- `Set11` — line 98 (namespace, bytes32[11] kvs)

**Tests:**
- `testRainterpreterStoreSetOddLength(StateNamespace, bytes32[])` — line 24 (fuzz, 100 runs)
- `testRainterpreterStoreSetGetNoDupesSingle(StateNamespace, bytes32[])` — line 35 (fuzz, 100 runs)
- `testRainterpreterStoreSetGetNoDupesMany(Set[])` — line 63 (fuzz, 100 runs)
- `testRainterpreterStoreSetGetDupes(Set11[])` — line 108 (fuzz, 100 runs)

### Test File: `test/src/concrete/RainterpreterStore.ierc165.t.sol`

**Contract name:** `RainterpreterStoreIERC165Test` (line 11)

**Tests:**
- `testRainterpreterStoreIERC165(bytes4)` — line 14 (fuzz)

### Additional coverage found elsewhere:
- `test/src/concrete/Rainterpreter.stateOverlay.t.sol` — Tests `OddSetLength` through the interpreter's `eval4` with odd-length `stateOverlay` arrays (line 16), plus get/set overlay behavior.

---

## Findings

### A50-1 [MEDIUM] — No test for namespace isolation across different `msg.sender` values

The `RainterpreterStore.set()` function qualifies the namespace with `msg.sender` (line 55: `namespace.qualifyNamespace(msg.sender)`). This is the primary security mechanism preventing callers from reading/writing each other's data. However, no test in the suite verifies this isolation. All tests call `set` and `get` from the same address (`address(this)`). A test should:
1. Call `set` from address A with some key-value pair
2. Call `get` from address B with the same `StateNamespace` and key
3. Assert the value is zero (not A's value)

This is the core security invariant of the store and should have explicit test coverage.

### A50-2 [LOW] — `Set` event emission never tested

The `set()` function emits `Set(fullyQualifiedNamespace, key, value)` on line 59 for every key-value pair stored. No test in the suite uses `vm.expectEmit` to verify that the event is emitted with correct parameters. While event emission is straightforward, it is part of the `IInterpreterStoreV3` interface contract and should be tested to ensure:
- The event is emitted for every pair (not just the first/last)
- The `fullyQualifiedNamespace` in the event matches what `qualifyNamespace` produces
- The key and value in the event match the stored values

### A50-3 [LOW] — No test for `set` with empty array (zero-length `kvs`)

The `set()` function with `kvs.length == 0` is a valid call (0 % 2 == 0, the loop body never executes). No test verifies this edge case. The `testRainterpreterStoreSetOddLength` fuzzer only runs with odd-length arrays (`vm.assume(kvs.length % 2 != 0)`), and the other tests do not constrain to include the zero-length case explicitly.

### A50-4 [LOW] — No test for `get` on uninitialized key (default value)

No test explicitly verifies that `get()` returns `bytes32(0)` for a key that has never been set. While this follows from Solidity's default mapping behavior, it is a user-facing behavioral guarantee worth testing explicitly, especially since the store is the persistence layer for the interpreter.

### A50-5 [LOW] — No test for overwriting a key with a different value in a single `set` call

The NatSpec states "if the same key appears twice it will be set twice" (line 24). The `testRainterpreterStoreSetGetDupes` test relies on the fuzzer randomly generating duplicate keys, which is probabilistic. There is no deterministic test that explicitly passes duplicate keys in a single `kvs` array and verifies that the last value wins. A deterministic test would be more reliable for this documented behavior.

### A50-6 [INFO] — No test for very large `kvs` arrays

All fuzz tests either truncate to small arrays (10 elements in `testRainterpreterStoreSetGetNoDupesMany` and `testRainterpreterStoreSetGetDupes`) or rely on the fuzzer to generate sizes. There is no test that exercises `set` with a deliberately large array (e.g., hundreds of pairs) to verify gas behavior and correctness at scale.
