# Pass 2: Test Coverage - LibOpGet and LibOpSet

## Evidence of Thorough Reading

### Source: `src/lib/op/store/LibOpGet.sol`

- **Library**: `LibOpGet`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 29
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 62
- **Errors used**: None defined locally; relies on external store and memkv behavior
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 514)

### Source: `src/lib/op/store/LibOpSet.sol`

- **Library**: `LibOpSet`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 40
- **Errors used**: None defined locally
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 516)

### Test: `test/src/lib/op/store/LibOpGet.t.sol`

- **Contract**: `LibOpGetTest is OpTest`
- **Functions**:
  - `testLibOpGetIntegrity(IntegrityCheckState memory, uint8, uint8, uint16)` -- line 23 (fuzz: integrity returns (1,1))
  - `testLibOpGetEvalZeroInputs()` -- line 36 (bad inputs: 0)
  - `testLibOpGetRunUnset(bytes32, uint16)` -- line 42 (fuzz: key not in store or state, returns 0)
  - `testLibOpGetRunStore(bytes32, bytes32, uint16)` -- line 72 (fuzz: key in store, returns value)
  - `testLibOpGetRunState(bytes32, bytes32, uint16)` -- line 105 (fuzz: key in memory KV, returns value)
  - `testLibOpGetRunStateAndStore(bytes32, bytes32, bytes32, uint16)` -- line 139 (fuzz: key in both, state wins)
  - `testLibOpGetRunStoreDifferentNamespace(bytes32, bytes32, uint16)` -- line 176 (fuzz: different namespace isolation)
  - `testLibOpGetEvalKeyNotSet()` -- line 208 (eval: multiple key-not-set scenarios)
  - `testLibOpGetEvalSetThenGet()` -- line 260 (eval: set then get, various combos)
  - `testLibOpGetEvalStoreThenGet()` -- line 335 (eval: store then get, various edge cases)
  - `testLibOpGetEvalStoreAndSetAndGet()` -- line 441 (eval: store + set + get combinations)
  - `testLibOpGetEvalTwoInputs()` -- line 484 (bad inputs: 2)
  - `testLibOpGetEvalThreeInputs()` -- line 489 (bad inputs: 3)
  - `testLibOpGetEvalZeroOutputs()` -- line 493 (bad outputs: 0)
  - `testLibOpGetEvalTwoOutputs()` -- line 497 (bad outputs: 2)
  - `testLibOpGetEvalOperandDisallowed()` -- line 503 (operand disallowed)

### Test: `test/src/lib/op/store/LibOpSet.t.sol`

- **Contract**: `LibOpSetTest is OpTest`
- **Functions**:
  - `testLibOpSetIntegrity(IntegrityCheckState memory, uint8, uint8, uint16)` -- line 19 (fuzz: integrity returns (2,0))
  - `testLibOpSet(bytes32, bytes32)` -- line 32 (fuzz: runtime set + reference check)
  - `testLibOpSetEvalZeroInputs()` -- line 59 (bad inputs: 0)
  - `testLibOpSetEvalTwoInputs()` -- line 64 (eval: happy path with various key/value combos)
  - `testLibOpSetEvalSetTwice()` -- line 89 (eval: set two different keys)
  - `testLibOpSetEvalOneInput()` -- line 101 (bad inputs: 1)
  - `testLibOpSetEvalThreeInputs()` -- line 106 (bad inputs: 3)
  - `testLibOpSetEvalOneOutput()` -- line 110 (bad outputs: 1)
  - `testLibOpSetEvalTwoOutputs()` -- line 114 (bad outputs: 2)
  - `testLibOpSetEvalOperandsDisallowed()` -- line 120 (operand disallowed)

## Coverage Analysis

### LibOpGet

#### `integrity` function
- **Tested**: `testLibOpGetIntegrity` fuzz tests that inputs/outputs are always `(1, 1)` regardless of operand values.
- **Coverage**: Good. The function body is trivial (returns constant pair).

#### `run` function
- **Cache MISS path** (lines 37-49): Tested by `testLibOpGetRunUnset` (key not in store or state) and `testLibOpGetRunStore` (key in store).
- **Cache HIT path** (lines 52-55): Tested by `testLibOpGetRunState` (key pre-loaded in stateKV).
- **State priority over store**: Tested by `testLibOpGetRunStateAndStore` (both set, state wins).
- **Namespace isolation**: Tested by `testLibOpGetRunStoreDifferentNamespace`.
- **Reference function parity**: Each runtime test calls `opReferenceCheckExpectations` to compare against `referenceFn`.

#### `referenceFn` function
- **Tested**: Indirectly via `opReferenceCheckExpectations` calls in runtime tests.

#### Operand handler
- **Tested**: `testLibOpGetEvalOperandDisallowed` confirms operands are rejected.

#### Input/output validation
- **Zero inputs**: `testLibOpGetEvalZeroInputs`
- **Two inputs**: `testLibOpGetEvalTwoInputs`
- **Three inputs**: `testLibOpGetEvalThreeInputs`
- **Zero outputs**: `testLibOpGetEvalZeroOutputs`
- **Two outputs**: `testLibOpGetEvalTwoOutputs`

### LibOpSet

#### `integrity` function
- **Tested**: `testLibOpSetIntegrity` fuzz tests that inputs/outputs are always `(2, 0)` regardless of operand values.

#### `run` function
- **Tested**: `testLibOpSet` fuzz tests runtime behavior with reference check.
- **Key/value storage**: Verified via `stateKV.get()` assertions and `toBytes32Array()` checks.
- **unchecked block** (line 25): The `run` function wraps the entire body in `unchecked`. The stack pointer arithmetic `add(stackTop, 0x40)` is in assembly and unaffected by `unchecked`. The `unchecked` block only affects the Solidity-level code which is just the `stateKV.set` call and return. This is fine.

#### `referenceFn` function
- **Tested**: Indirectly via `opReferenceCheckExpectations` in `testLibOpSet`.

#### Operand handler
- **Tested**: `testLibOpSetEvalOperandsDisallowed` confirms operands are rejected.

#### Input/output validation
- **Zero inputs**: `testLibOpSetEvalZeroInputs`
- **One input**: `testLibOpSetEvalOneInput`
- **Three inputs**: `testLibOpSetEvalThreeInputs`
- **One output**: `testLibOpSetEvalOneOutput`
- **Two outputs**: `testLibOpSetEvalTwoOutputs`

## Findings

### A28-1: No test for get() caching side effect on read-only keys (LOW)

**Source**: `src/lib/op/store/LibOpGet.sol` lines 42-45
**Details**: When `get` encounters a cache MISS, it writes the fetched value back into `stateKV` (line 45). The source code comment (lines 42-44) acknowledges this means "read-only keys will also be persisted to the store at the end of eval, paying an unnecessary SSTORE." While `testLibOpGetRunUnset` does verify that `stateKV` is populated after a miss (assertions at lines 59-64 of test), there is no end-to-end test that verifies the behavioral consequence: that a `get`-only eval still produces KV pairs in the output (which are then written to storage). The `testLibOpGetEvalKeyNotSet` test does check `kvs.length == 2` which implicitly confirms this, but the test doesn't verify these KVs would actually result in an SSTORE. This is by design but has gas implications users should be aware of.

### A28-2: No test for set() overwrite with same key same value (INFO)

**Source**: `src/lib/op/store/LibOpSet.sol` line 34
**Details**: While `testLibOpSetEvalTwoInputs` tests overwriting a key with a different value (line 85: `set(0x1234 0x5678), set(0x1234 0x9abc)`), there is no test that sets the same key to the same value twice. This is a trivial case but would confirm idempotency of the memkv set operation.

### A28-3: No test for get() interaction with stateOverlay (INFO)

**Source**: `src/lib/op/store/LibOpGet.sol` lines 29-58
**Details**: The `run` function reads from `state.stateKV` and falls back to `state.store`. The `stateOverlay` field in `EvalV4` can pre-populate the KV store before eval begins. No test specifically exercises `get` with a pre-populated `stateOverlay` to verify the overlay values are visible to `get`. The eval tests all use `stateOverlay: new bytes32[](0)`.
