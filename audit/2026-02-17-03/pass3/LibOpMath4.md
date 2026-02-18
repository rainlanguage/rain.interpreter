# Pass 3: Documentation — LibOpMul, LibOpPow, LibOpSqrt, LibOpSub

Agent: A20

## Evidence of Thorough Reading

### LibOpMul.sol (`src/lib/op/math/LibOpMul.sol`)

- **Library name:** `LibOpMul` (line 14)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2 operand)` — line 18
  - `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` — line 26
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 66
- **Errors/Events/Structs:** None defined
- **Library-level NatSpec:** `@title LibOpMul` plus description "Opcode to multiply N decimal floating point values." (lines 12-13)

### LibOpPow.sol (`src/lib/op/math/LibOpPow.sol`)

- **Library name:** `LibOpPow` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 41
- **Errors/Events/Structs:** None defined
- **Library-level NatSpec:** `@title LibOpPow` plus `@notice Opcode to pow a decimal floating point value to a float decimal power.` (lines 11-12)

### LibOpSqrt.sol (`src/lib/op/math/LibOpSqrt.sol`)

- **Library name:** `LibOpSqrt` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` — line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` — line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 38
- **Errors/Events/Structs:** None defined
- **Library-level NatSpec:** `@title LibOpSqrt` plus `@notice Opcode for the square root of a decimal floating point number.` (lines 11-12)

### LibOpSub.sol (`src/lib/op/math/LibOpSub.sol`)

- **Library name:** `LibOpSub` (line 14)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2 operand)` — line 18
  - `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` — line 26
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` — line 66
- **Errors/Events/Structs:** None defined
- **Library-level NatSpec:** `@title LibOpSub` plus description "Opcode to subtract N decimal floating point values." (lines 12-13)

---

## Findings

### A20-1 [LOW] LibOpPow: `@notice` tag used in library-level NatSpec

**File:** `src/lib/op/math/LibOpPow.sol`, line 12

The library-level NatSpec uses `@notice`:
```solidity
/// @notice Opcode to pow a decimal floating point value to a float decimal power.
```

Per project conventions, `@notice` should not be used. The description should use plain `///` without the tag, as done in `LibOpMul.sol` and `LibOpSub.sol`:
```solidity
/// Opcode to multiply N decimal floating point values.
```

### A20-2 [LOW] LibOpSqrt: `@notice` tag used in library-level NatSpec

**File:** `src/lib/op/math/LibOpSqrt.sol`, line 12

Same issue as A20-1. The library-level NatSpec uses `@notice`:
```solidity
/// @notice Opcode for the square root of a decimal floating point number.
```

Should be:
```solidity
/// Opcode for the square root of a decimal floating point number.
```

### A20-3 [MEDIUM] LibOpMul `integrity`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpMul.sol`, line 17-18

The `integrity` function has a brief description but no `@param` or `@return` tags:
```solidity
/// `mul` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

Missing:
- `@param` for `IntegrityCheckState memory` (unnamed but still a parameter)
- `@param operand` describing the operand encoding (bits 16-19 encode input count)
- `@return` for the first `uint256` (number of inputs)
- `@return` for the second `uint256` (number of outputs)

### A20-4 [MEDIUM] LibOpMul `run`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpMul.sol`, lines 25-26

The `run` function has only a single-word NatSpec (`/// mul`) with no parameter or return documentation:
```solidity
/// mul
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

Missing:
- `@param` for `InterpreterState memory` (unused but present)
- `@param operand` describing the operand encoding (bits 16-19 encode input count for N-ary multiplication)
- `@param stackTop` describing the stack pointer
- `@return` describing the new stack pointer position

The description is also minimal -- it should describe the behavior (multiplies N decimal float values from the stack, writing the result back).

### A20-5 [MEDIUM] LibOpMul `referenceFn`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpMul.sol`, lines 65-66

```solidity
/// Gas intensive reference implementation of multiplication for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

Missing:
- `@param` for `InterpreterState memory` (unused)
- `@param` for `OperandV2` (unnamed, unused)
- `@param inputs` describing the input stack items
- `@return outputs` describing the output stack items

### A20-6 [MEDIUM] LibOpPow `integrity`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpPow.sol`, lines 16-17

```solidity
/// `pow` integrity check. Requires exactly 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
```

Missing:
- `@param` for `IntegrityCheckState memory`
- `@param` for `OperandV2` (unnamed)
- `@return` for each `uint256` return value

### A20-7 [MEDIUM] LibOpPow `run`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpPow.sol`, lines 22-24

```solidity
/// pow
/// decimal floating point exponentiation.
function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
```

Missing:
- `@param` for `InterpreterState memory`
- `@param` for `OperandV2` (unnamed)
- `@param stackTop` describing the stack pointer
- `@return` describing the new stack pointer position

### A20-8 [MEDIUM] LibOpPow `referenceFn`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpPow.sol`, lines 40-41

```solidity
/// Gas intensive reference implementation of pow for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

Missing:
- `@param` for `InterpreterState memory`
- `@param` for `OperandV2` (unnamed)
- `@param inputs`
- `@return` (unnamed `StackItem[] memory`)

### A20-9 [MEDIUM] LibOpSqrt `integrity`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpSqrt.sol`, lines 16-17

```solidity
/// `sqrt` integrity check. Requires exactly 1 input and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
```

Missing:
- `@param` for `IntegrityCheckState memory`
- `@param` for `OperandV2` (unnamed)
- `@return` for each `uint256` return value

### A20-10 [MEDIUM] LibOpSqrt `run`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpSqrt.sol`, lines 22-24

```solidity
/// sqrt
/// decimal floating point square root of a number.
function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
```

Missing:
- `@param` for `InterpreterState memory`
- `@param` for `OperandV2` (unnamed)
- `@param stackTop`
- `@return`

### A20-11 [MEDIUM] LibOpSqrt `referenceFn`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpSqrt.sol`, lines 37-38

```solidity
/// Gas intensive reference implementation of sqrt for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

Missing:
- `@param` for `InterpreterState memory`
- `@param` for `OperandV2` (unnamed)
- `@param inputs`
- `@return` (unnamed `StackItem[] memory`)

### A20-12 [MEDIUM] LibOpSub `integrity`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpSub.sol`, lines 17-18

```solidity
/// `sub` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

Missing:
- `@param` for `IntegrityCheckState memory`
- `@param operand` describing the operand encoding (bits 16-19 encode input count)
- `@return` for each `uint256` return value

### A20-13 [MEDIUM] LibOpSub `run`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpSub.sol`, lines 25-26

```solidity
/// sub
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

Minimal description. Missing:
- `@param` for `InterpreterState memory`
- `@param operand` describing the operand encoding
- `@param stackTop`
- `@return`

### A20-14 [MEDIUM] LibOpSub `referenceFn`: Missing `@param` and `@return` tags

**File:** `src/lib/op/math/LibOpSub.sol`, lines 65-66

```solidity
/// Gas intensive reference implementation of subtraction for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

Missing:
- `@param` for `InterpreterState memory`
- `@param` for `OperandV2` (unnamed)
- `@param inputs`
- `@return outputs`

### A20-15 [LOW] LibOpMul `run` and LibOpSub `run`: NatSpec is a single word with no behavioral description

**File:** `src/lib/op/math/LibOpMul.sol`, line 25; `src/lib/op/math/LibOpSub.sol`, line 25

Both `run` functions have NatSpec that is just the opcode name (`/// mul` and `/// sub` respectively) with no description of behavior. Compare to `LibOpPow.run` and `LibOpSqrt.run` which at least have a second line describing the operation. All four should have descriptions explaining their N-ary behavior (for mul/sub) or fixed-arity behavior (for pow/sqrt), including how the operand encodes the input count where applicable.

### A20-16 [INFO] Inconsistent NatSpec style across the four libraries

Across the four files, the NatSpec style varies:
- **LibOpMul/LibOpSub** library-level: use plain `///` without `@notice` (correct)
- **LibOpPow/LibOpSqrt** library-level: use `@notice` (incorrect per project convention)
- **LibOpMul/LibOpSub** `run`: single-word NatSpec only
- **LibOpPow/LibOpSqrt** `run`: have a second line with a description

These should be normalized to a consistent style across all math opcode libraries.

---

## Summary

| ID | Severity | File | Finding |
|----|----------|------|---------|
| A20-1 | LOW | LibOpPow.sol:12 | `@notice` tag used in library-level NatSpec |
| A20-2 | LOW | LibOpSqrt.sol:12 | `@notice` tag used in library-level NatSpec |
| A20-3 | MEDIUM | LibOpMul.sol:17-18 | `integrity` missing `@param`/`@return` tags |
| A20-4 | MEDIUM | LibOpMul.sol:25-26 | `run` missing `@param`/`@return` tags |
| A20-5 | MEDIUM | LibOpMul.sol:65-66 | `referenceFn` missing `@param`/`@return` tags |
| A20-6 | MEDIUM | LibOpPow.sol:16-17 | `integrity` missing `@param`/`@return` tags |
| A20-7 | MEDIUM | LibOpPow.sol:22-24 | `run` missing `@param`/`@return` tags |
| A20-8 | MEDIUM | LibOpPow.sol:40-41 | `referenceFn` missing `@param`/`@return` tags |
| A20-9 | MEDIUM | LibOpSqrt.sol:16-17 | `integrity` missing `@param`/`@return` tags |
| A20-10 | MEDIUM | LibOpSqrt.sol:22-24 | `run` missing `@param`/`@return` tags |
| A20-11 | MEDIUM | LibOpSqrt.sol:37-38 | `referenceFn` missing `@param`/`@return` tags |
| A20-12 | MEDIUM | LibOpSub.sol:17-18 | `integrity` missing `@param`/`@return` tags |
| A20-13 | MEDIUM | LibOpSub.sol:25-26 | `run` missing `@param`/`@return` tags |
| A20-14 | MEDIUM | LibOpSub.sol:65-66 | `referenceFn` missing `@param`/`@return` tags |
| A20-15 | LOW | LibOpMul.sol:25, LibOpSub.sol:25 | `run` NatSpec is a single word with no behavioral description |
| A20-16 | INFO | All four files | Inconsistent NatSpec style across the four libraries |
