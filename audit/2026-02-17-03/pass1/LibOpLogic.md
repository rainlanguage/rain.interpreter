# Pass 1 (Security) -- Logic Opcodes

## Files Reviewed

- `src/lib/op/logic/LibOpAny.sol`
- `src/lib/op/logic/LibOpBinaryEqualTo.sol`
- `src/lib/op/logic/LibOpConditions.sol`
- `src/lib/op/logic/LibOpEnsure.sol`
- `src/lib/op/logic/LibOpEqualTo.sol`
- `src/lib/op/logic/LibOpEvery.sol`
- `src/lib/op/logic/LibOpGreaterThan.sol`
- `src/lib/op/logic/LibOpGreaterThanOrEqualTo.sol`
- `src/lib/op/logic/LibOpIf.sol`
- `src/lib/op/logic/LibOpIsZero.sol`
- `src/lib/op/logic/LibOpLessThan.sol`
- `src/lib/op/logic/LibOpLessThanOrEqualTo.sol`

---

## Evidence of Thorough Reading

### LibOpAny.sol
- **Library:** `LibOpAny`
- **Functions:**
  - `integrity` (line 18) -- returns `(inputs, 1)` where inputs is clamped to >= 1
  - `run` (line 27) -- iterates stack items, returns first nonzero or last (zero) value
  - `referenceFn` (line 52) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpBinaryEqualTo.sol
- **Library:** `LibOpBinaryEqualTo`
- **Functions:**
  - `integrity` (line 14) -- returns `(2, 1)`
  - `run` (line 21) -- EVM `eq` on two stack items (bitwise equality)
  - `referenceFn` (line 31) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpConditions.sol
- **Library:** `LibOpConditions`
- **Functions:**
  - `integrity` (line 19) -- returns `(inputs, 1)` where inputs is clamped to >= 2
  - `run` (line 33) -- pairwise condition-value evaluation; reverts if no condition is nonzero
  - `referenceFn` (line 74) -- reference implementation for testing
- **Errors/Events/Structs:** None defined in this file (uses `revert(string)`)

### LibOpEnsure.sol
- **Library:** `LibOpEnsure`
- **Functions:**
  - `integrity` (line 18) -- returns `(2, 0)`
  - `run` (line 27) -- reverts with user-provided reason if condition is zero
  - `referenceFn` (line 43) -- reference implementation for testing
- **Errors/Events/Structs:** None defined in this file (uses `revert(string)`)

### LibOpEqualTo.sol
- **Library:** `LibOpEqualTo`
- **Functions:**
  - `integrity` (line 19) -- returns `(2, 1)`
  - `run` (line 26) -- decimal float equality via `Float.eq()`
  - `referenceFn` (line 46) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpEvery.sol
- **Library:** `LibOpEvery`
- **Functions:**
  - `integrity` (line 18) -- returns `(inputs, 1)` where inputs is clamped to >= 1
  - `run` (line 26) -- iterates stack items, returns 0 if any are zero, else returns last item
  - `referenceFn` (line 50) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpGreaterThan.sol
- **Library:** `LibOpGreaterThan`
- **Functions:**
  - `integrity` (line 18) -- returns `(2, 1)`
  - `run` (line 24) -- decimal float greater-than via `Float.gt()`
  - `referenceFn` (line 40) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpGreaterThanOrEqualTo.sol
- **Library:** `LibOpGreaterThanOrEqualTo`
- **Functions:**
  - `integrity` (line 18) -- returns `(2, 1)`
  - `run` (line 25) -- decimal float >= via `Float.gte()`
  - `referenceFn` (line 41) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpIf.sol
- **Library:** `LibOpIf`
- **Functions:**
  - `integrity` (line 17) -- returns `(3, 1)`
  - `run` (line 24) -- reads condition, selects trueValue or falseValue
  - `referenceFn` (line 40) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpIsZero.sol
- **Library:** `LibOpIsZero`
- **Functions:**
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 23) -- returns 1 if top-of-stack is float-zero, else 0
  - `referenceFn` (line 36) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpLessThan.sol
- **Library:** `LibOpLessThan`
- **Functions:**
  - `integrity` (line 18) -- returns `(2, 1)`
  - `run` (line 24) -- decimal float less-than via `Float.lt()`
  - `referenceFn` (line 40) -- reference implementation for testing
- **Errors/Events/Structs:** None

### LibOpLessThanOrEqualTo.sol
- **Library:** `LibOpLessThanOrEqualTo`
- **Functions:**
  - `integrity` (line 18) -- returns `(2, 1)`
  - `run` (line 25) -- decimal float <= via `Float.lte()`
  - `referenceFn` (line 41) -- reference implementation for testing
- **Errors/Events/Structs:** None

---

## Security Findings

### LOGIC-01 [LOW] -- `LibOpConditions.run` and `LibOpEnsure.run` use `revert(string)` instead of custom errors

**Files:** `src/lib/op/logic/LibOpConditions.sol` (line 66), `src/lib/op/logic/LibOpEnsure.sol` (line 37)

**Description:** Both `LibOpConditions.run` and `LibOpEnsure.run` use `revert(reason.toStringV3())` which produces a `revert Error(string)` (the standard Solidity string revert). The project convention (per AUDIT.md) is that all reverts should use custom errors defined in `src/error/`, not string messages.

**Mitigating factors:** These opcodes are *designed* to let Rainlang expression authors specify arbitrary revert reasons at the expression level. The reason string comes from the stack at runtime, not from a hardcoded string in the Solidity source. This is a user-facing feature -- the `ensure` and `conditions` opcodes are the mechanism by which Rainlang authors communicate custom revert reasons to callers. Replacing `revert(string)` with a custom error would change the ABI encoding of the revert data, potentially breaking downstream consumers that expect the standard `Error(string)` selector. This is likely an intentional design choice rather than an oversight.

**Severity rationale:** LOW because the deviation from convention is justified by the use case. No security impact -- the revert still halts execution correctly.

---

### LOGIC-02 [INFO] -- `LibOpBinaryEqualTo` returns 0/1 raw uint256, not decimal float

**File:** `src/lib/op/logic/LibOpBinaryEqualTo.sol` (line 25)

**Description:** `LibOpBinaryEqualTo.run` uses EVM `eq` to compare two values and stores the raw result (0 or 1 as a uint256). All other comparison opcodes (`equal-to`, `greater-than`, `less-than`, etc.) also produce 0 or 1 as their boolean result. However, `LibOpBinaryEqualTo` also *compares* its inputs using raw bitwise equality rather than decimal float equality.

This means two decimal floats that are semantically equal (e.g., `1e0` and `10e-1`) will compare as *not equal* under `binary-equal-to` because their bit representations differ. This is intentional based on the name "binary-equal-to" vs "equal-to", but worth noting as an observation.

Additionally, the boolean output (0 or 1 as raw uint256) is not a valid decimal float encoding of those values. The decimal float encoding of 1 would be `1e0`, not raw `1`. This is the same across all boolean-returning opcodes (equal-to, greater-than, less-than, is-zero, etc.) -- they all output raw 0/1. This means downstream opcodes that expect decimal float inputs may misinterpret these boolean values. However, since `Float.isZero()` checks `iszero(and(a, type(uint224).max))`, a raw `1` is nonzero (true) and raw `0` is zero (false), so truthiness checks work correctly. Float arithmetic on these raw 0/1 values could produce unexpected results.

**Severity rationale:** INFO -- this is a design observation. The boolean output format (raw 0/1 vs decimal float) is consistent across all logic opcodes and appears to be an intentional convention.

---

### LOGIC-03 [INFO] -- `LibOpConditions.referenceFn` uses `require(false, "")` for even-input revert path

**File:** `src/lib/op/logic/LibOpConditions.sol` (line 95)

**Description:** In the reference function, when all conditions are zero and the number of inputs is even, the code reverts with `require(false, "")`. This is a string revert in the reference implementation. This is only used in tests and has no production impact, but it is inconsistent with the custom error convention.

**Severity rationale:** INFO -- test-only code, no production impact.

---

### LOGIC-04 [INFO] -- Assembly blocks are correctly annotated as `memory-safe`

**All files**

**Description:** All assembly blocks in the logic opcodes are correctly annotated with `("memory-safe")`. Each block only reads from and writes to the interpreter stack, which is pre-allocated memory managed by the eval loop. No block modifies the free memory pointer (`mstore(0x40, ...)`) or accesses memory outside the stack bounds. The `memory-safe` annotation is appropriate for all cases.

---

### LOGIC-05 [INFO] -- Integrity/run input count consistency is sound

**Files:** `LibOpAny.sol`, `LibOpEvery.sol`, `LibOpConditions.sol`

**Description:** The integrity functions in `LibOpAny`, `LibOpEvery`, and `LibOpConditions` clamp the operand-derived input count to a minimum value (1 for any/every, 2 for conditions). A potential concern would be if `run` could see a different input count than what integrity validated. However, analysis of the bytecode format confirms this cannot happen: the `bytecodeOpInputs` field (checked against integrity's return value at `LibIntegrityCheck.sol:146`) is derived from `byte(29, word)` low nibble, and the operand field used by `run` to read `(operand >> 0x10) & 0x0F` is the same bits (the operand's top byte IS byte 29). Therefore, if integrity clamps 0 to 1 but the operand actually encodes 0, integrity returns 1 which mismatches `bytecodeOpInputs = 0`, causing a revert. Only bytecode where the operand field matches integrity's expectation can pass the check.

---

### LOGIC-06 [INFO] -- No stack underflow/overflow risk in fixed-arity opcodes

**Files:** `LibOpBinaryEqualTo.sol`, `LibOpEqualTo.sol`, `LibOpGreaterThan.sol`, `LibOpGreaterThanOrEqualTo.sol`, `LibOpIf.sol`, `LibOpIsZero.sol`, `LibOpLessThan.sol`, `LibOpLessThanOrEqualTo.sol`, `LibOpEnsure.sol`

**Description:** All fixed-arity opcodes (those that don't read input count from the operand) have integrity functions that return constant `(inputs, outputs)` values. The integrity checker enforces that the stack has sufficient items before each opcode executes (`LibIntegrityCheck.sol:153-155`). The `run` functions consume exactly the number of items declared by integrity and produce exactly the declared outputs. No stack underflow or overflow is possible for these opcodes given a passing integrity check.

---

### LOGIC-07 [INFO] -- No unchecked arithmetic risks

**All files**

**Description:** The `unchecked` blocks in `LibOpAny.run`, `LibOpEvery.run`, and `LibOpConditions.run` contain only pointer arithmetic (adding/subtracting small constants like 0x20 or 0x40 to realistic memory addresses). The maximum input count is 15 (4-bit field), so the maximum offset is `15 * 0x20 = 0x1E0` (480 bytes). Overflow of pointer arithmetic at these scales is impossible on practical EVM memory addresses. No silent wrapping risk.

---

### LOGIC-08 [INFO] -- No reentrancy risks

**All files**

**Description:** All logic opcodes are `internal pure` functions. None make external calls, read storage, or interact with other contracts. There is zero reentrancy risk.

---

## Summary

The logic opcodes are well-implemented with consistent patterns. The integrity/run contract is sound: the bytecode format guarantees that the operand fields seen by `run` are the same bits validated by integrity. Assembly blocks are correctly annotated as memory-safe and operate only within the pre-allocated interpreter stack. All fixed-arity opcodes correctly declare their inputs/outputs. No critical, high, or medium severity issues were found.

The only notable observation is the use of `revert(string)` in `ensure` and `conditions` opcodes (LOGIC-01), which deviates from the custom-error convention but is justified by the design intent of letting Rainlang authors specify runtime revert reasons.
