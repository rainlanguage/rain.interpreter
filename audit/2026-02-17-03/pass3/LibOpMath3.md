# Pass 3: Documentation Audit - LibOpMath3

Agent: A19

## Files Reviewed

- `src/lib/op/math/LibOpMax.sol`
- `src/lib/op/math/LibOpMaxNegativeValue.sol`
- `src/lib/op/math/LibOpMaxPositiveValue.sol`
- `src/lib/op/math/LibOpMin.sol`
- `src/lib/op/math/LibOpMinNegativeValue.sol`
- `src/lib/op/math/LibOpMinPositiveValue.sol`

---

## Evidence of Thorough Reading

### LibOpMax.sol

- **Library name:** `LibOpMax` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2 operand)` — line 17
  - `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` — line 26
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 59
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpMax` and `@notice Opcode to find the max from N floats.` (lines 11-12)

### LibOpMaxNegativeValue.sol

- **Library name:** `LibOpMaxNegativeValue` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` — line 32
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpMaxNegativeValue` and description (lines 11-12)

### LibOpMaxPositiveValue.sol

- **Library name:** `LibOpMaxPositiveValue` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` — line 32
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpMaxPositiveValue` and description (lines 11-12)

### LibOpMin.sol

- **Library name:** `LibOpMin` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2 operand)` — line 17
  - `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` — line 26
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 60
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpMin` and `@notice Opcode to find the min from N floats.` (lines 11-12)

### LibOpMinNegativeValue.sol

- **Library name:** `LibOpMinNegativeValue` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` — line 32
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpMinNegativeValue` and description (lines 11-12)

### LibOpMinPositiveValue.sol

- **Library name:** `LibOpMinPositiveValue` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` — line 32
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpMinPositiveValue` and description (lines 11-12)

---

## Findings

### A19-1 [LOW] LibOpMax.integrity — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMax.sol`, line 16-17

The NatSpec for `integrity` is:
```
/// `max` integrity check. Requires at least 2 inputs and produces 1 output.
```

It is missing `@param` tags for the `IntegrityCheckState memory` and `OperandV2 operand` parameters, and `@return` tags for the two `uint256` return values (inputs count, outputs count).

---

### A19-2 [LOW] LibOpMax.run — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMax.sol`, lines 24-26

The NatSpec for `run` is:
```
/// max
/// Finds the maximum value from N floats.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2 operand`, and `Pointer stackTop`, and a `@return` tag for the returned `Pointer`.

---

### A19-3 [LOW] LibOpMax.referenceFn — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMax.sol`, line 58-59

The NatSpec for `referenceFn` is:
```
/// Gas intensive reference implementation of maximum for testing.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `StackItem[] memory inputs`, and a `@return` tag for `StackItem[] memory outputs`.

---

### A19-4 [LOW] LibOpMaxNegativeValue.integrity — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMaxNegativeValue.sol`, line 16-17

The NatSpec for `integrity` is:
```
/// `max-negative-value` integrity check. Requires 0 inputs and produces 1 output.
```

It is missing `@param` tags for `IntegrityCheckState memory` and `OperandV2`, and `@return` tags for the two `uint256` return values.

---

### A19-5 [LOW] LibOpMaxNegativeValue.run — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMaxNegativeValue.sol`, line 21-22

The NatSpec for `run` is:
```
/// `max-negative-value` opcode. Pushes the maximum negative float (closest to zero) onto the stack.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `Pointer stackTop`, and a `@return` tag for the returned `Pointer`.

---

### A19-6 [LOW] LibOpMaxNegativeValue.referenceFn — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMaxNegativeValue.sol`, line 31-32

The NatSpec for `referenceFn` is:
```
/// Reference implementation of `max-negative-value` for testing.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `StackItem[] memory`, and a `@return` tag for `StackItem[] memory`.

---

### A19-7 [LOW] LibOpMaxPositiveValue.integrity — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMaxPositiveValue.sol`, line 16-17

The NatSpec for `integrity` is:
```
/// `max-positive-value` integrity check. Requires 0 inputs and produces 1 output.
```

It is missing `@param` tags for `IntegrityCheckState memory` and `OperandV2`, and `@return` tags for the two `uint256` return values.

---

### A19-8 [LOW] LibOpMaxPositiveValue.run — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMaxPositiveValue.sol`, line 21-22

The NatSpec for `run` is:
```
/// `max-positive-value` opcode. Pushes the maximum representable positive float onto the stack.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `Pointer stackTop`, and a `@return` tag for the returned `Pointer`.

---

### A19-9 [LOW] LibOpMaxPositiveValue.referenceFn — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMaxPositiveValue.sol`, line 31-32

The NatSpec for `referenceFn` is:
```
/// Reference implementation of `max-positive-value` for testing.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `StackItem[] memory`, and a `@return` tag for `StackItem[] memory`.

---

### A19-10 [LOW] LibOpMin.integrity — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMin.sol`, line 16-17

The NatSpec for `integrity` is:
```
/// `min` integrity check. Requires at least 2 inputs and produces 1 output.
```

It is missing `@param` tags for `IntegrityCheckState memory` and `OperandV2 operand`, and `@return` tags for the two `uint256` return values.

---

### A19-11 [LOW] LibOpMin.run — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMin.sol`, lines 24-26

The NatSpec for `run` is:
```
/// min
/// Finds the minimum value from N floats.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2 operand`, and `Pointer stackTop`, and a `@return` tag for the returned `Pointer`.

---

### A19-12 [LOW] LibOpMin.referenceFn — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMin.sol`, line 59-60

The NatSpec for `referenceFn` is:
```
/// Gas intensive reference implementation of minimum for testing.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `StackItem[] memory inputs`, and a `@return` tag for `StackItem[] memory outputs`.

---

### A19-13 [LOW] LibOpMinNegativeValue.integrity — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMinNegativeValue.sol`, line 16-17

The NatSpec for `integrity` is:
```
/// `min-negative-value` integrity check. Requires 0 inputs and produces 1 output.
```

It is missing `@param` tags for `IntegrityCheckState memory` and `OperandV2`, and `@return` tags for the two `uint256` return values.

---

### A19-14 [LOW] LibOpMinNegativeValue.run — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMinNegativeValue.sol`, line 21-22

The NatSpec for `run` is:
```
/// `min-negative-value` opcode. Pushes the minimum representable negative float onto the stack.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `Pointer stackTop`, and a `@return` tag for the returned `Pointer`.

---

### A19-15 [LOW] LibOpMinNegativeValue.referenceFn — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMinNegativeValue.sol`, line 31-32

The NatSpec for `referenceFn` is:
```
/// Reference implementation of `min-negative-value` for testing.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `StackItem[] memory`, and a `@return` tag for `StackItem[] memory`.

---

### A19-16 [LOW] LibOpMinPositiveValue.integrity — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMinPositiveValue.sol`, line 16-17

The NatSpec for `integrity` is:
```
/// `min-positive-value` integrity check. Requires 0 inputs and produces 1 output.
```

It is missing `@param` tags for `IntegrityCheckState memory` and `OperandV2`, and `@return` tags for the two `uint256` return values.

---

### A19-17 [LOW] LibOpMinPositiveValue.run — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMinPositiveValue.sol`, line 21-22

The NatSpec for `run` is:
```
/// `min-positive-value` opcode. Pushes the minimum representable positive float onto the stack.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `Pointer stackTop`, and a `@return` tag for the returned `Pointer`.

---

### A19-18 [LOW] LibOpMinPositiveValue.referenceFn — Missing `@param` and `@return` NatSpec

**File:** `src/lib/op/math/LibOpMinPositiveValue.sol`, line 31-32

The NatSpec for `referenceFn` is:
```
/// Reference implementation of `min-positive-value` for testing.
```

It is missing `@param` tags for `InterpreterState memory`, `OperandV2`, and `StackItem[] memory`, and a `@return` tag for `StackItem[] memory`.

---

### A19-19 [INFO] LibOpMax and LibOpMin use `@notice` in library-level NatSpec

**Files:** `src/lib/op/math/LibOpMax.sol` line 12, `src/lib/op/math/LibOpMin.sol` line 12

Both files use `@notice` in their library-level doc comment:
```
/// @notice Opcode to find the max from N floats.
/// @notice Opcode to find the min from N floats.
```

Per project conventions, `@notice` should not be used; just use `///` directly for descriptions. The other four files in this batch already follow the convention correctly.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0     |
| HIGH     | 0     |
| MEDIUM   | 0     |
| LOW      | 18    |
| INFO     | 1     |
| **Total**| **19**|

All 18 functions across the 6 files have descriptive NatSpec comments, but all are uniformly missing `@param` and `@return` tags. Two files (LibOpMax.sol and LibOpMin.sol) additionally use the `@notice` tag contrary to project conventions.
