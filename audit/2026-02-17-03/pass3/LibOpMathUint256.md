# Pass 3: Documentation Audit - Math Uint256 Opcodes

**Agent:** A21
**Date:** 2026-02-17
**Files:**
- `src/lib/op/math/growth/LibOpExponentialGrowth.sol`
- `src/lib/op/math/growth/LibOpLinearGrowth.sol`
- `src/lib/op/math/uint256/LibOpMaxUint256.sol`
- `src/lib/op/math/uint256/LibOpUint256Add.sol`
- `src/lib/op/math/uint256/LibOpUint256Div.sol`
- `src/lib/op/math/uint256/LibOpUint256Mul.sol`
- `src/lib/op/math/uint256/LibOpUint256Pow.sol`
- `src/lib/op/math/uint256/LibOpUint256Sub.sol`

---

## Evidence of Thorough Reading

### LibOpExponentialGrowth.sol (57 lines)
- Library: `LibOpExponentialGrowth` (line 14)
- Functions: `integrity` (line 18), `run` (line 24), `referenceFn` (line 43)
- No errors, events, or structs defined

### LibOpLinearGrowth.sol (57 lines)
- Library: `LibOpLinearGrowth` (line 14)
- Functions: `integrity` (line 18), `run` (line 24), `referenceFn` (line 44)
- No errors, events, or structs defined

### LibOpMaxUint256.sol (39 lines)
- Library: `LibOpMaxUint256` (line 12)
- Functions: `integrity` (line 14), `run` (line 19), `referenceFn` (line 29)
- No errors, events, or structs defined

### LibOpUint256Add.sol (73 lines)
- Library: `LibOpUint256Add` (line 12)
- Functions: `integrity` (line 14), `run` (line 24), `referenceFn` (line 56)
- No errors, events, or structs defined

### LibOpUint256Div.sol (74 lines)
- Library: `LibOpUint256Div` (line 13)
- Functions: `integrity` (line 15), `run` (line 24), `referenceFn` (line 57)
- No errors, events, or structs defined

### LibOpUint256Mul.sol (73 lines)
- Library: `LibOpUint256Mul` (line 12)
- Functions: `integrity` (line 14), `run` (line 24), `referenceFn` (line 56)
- No errors, events, or structs defined

### LibOpUint256Pow.sol (73 lines)
- Library: `LibOpUint256Pow` (line 12)
- Functions: `integrity` (line 14), `run` (line 24), `referenceFn` (line 56)
- No errors, events, or structs defined

### LibOpUint256Sub.sol (73 lines)
- Library: `LibOpUint256Sub` (line 12)
- Functions: `integrity` (line 14), `run` (line 24), `referenceFn` (line 56)
- No errors, events, or structs defined

---

## Findings

### A21-1 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpExponentialGrowth.sol

**File:** `src/lib/op/math/growth/LibOpExponentialGrowth.sol`, line 17-18

The `integrity` function has a brief NatSpec description but is missing `@param` tags for both parameters (`IntegrityCheckState memory`, `OperandV2`) and `@return` tags for the two return values `(uint256, uint256)`.

```solidity
/// `exponential-growth` integrity check. Requires exactly 3 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
```

### A21-2 [LOW] Missing `@param` and `@return` tags on `run` in LibOpExponentialGrowth.sol

**File:** `src/lib/op/math/growth/LibOpExponentialGrowth.sol`, line 23-24

The `run` function has only a one-word NatSpec (`/// exponential-growth`) with no description of behavior, and is missing `@param` tags for all three parameters (`InterpreterState memory`, `OperandV2`, `Pointer stackTop`) and `@return` for the returned `Pointer`.

```solidity
/// exponential-growth
function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
```

### A21-3 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpExponentialGrowth.sol

**File:** `src/lib/op/math/growth/LibOpExponentialGrowth.sol`, line 42-43

The `referenceFn` function has a brief description but is missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-4 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpLinearGrowth.sol

**File:** `src/lib/op/math/growth/LibOpLinearGrowth.sol`, line 17-18

Same as A21-1 but for `LibOpLinearGrowth`. Missing `@param` and `@return` tags.

```solidity
/// `linear-growth` integrity check. Requires exactly 3 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
```

### A21-5 [LOW] Missing `@param` and `@return` tags on `run` in LibOpLinearGrowth.sol

**File:** `src/lib/op/math/growth/LibOpLinearGrowth.sol`, line 23-24

Same as A21-2 but for `LibOpLinearGrowth`. Minimal NatSpec (`/// linear-growth`) with no `@param` or `@return` tags.

```solidity
/// linear-growth
function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-6 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpLinearGrowth.sol

**File:** `src/lib/op/math/growth/LibOpLinearGrowth.sol`, line 43-44

Same as A21-3. Missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-7 [INFO] NatSpec description refers to variables `a` and `r` instead of `base` and `rate` in LibOpLinearGrowth.sol

**File:** `src/lib/op/math/growth/LibOpLinearGrowth.sol`, line 12

The `@notice` on the library says "...where a is the initial value, r is the growth rate..." but the formula uses `base` and `rate`, and the actual code variables are named `base` and `rate`. This inconsistency could confuse readers.

```solidity
/// @notice Linear growth is base + rate * t where a is the initial value, r is
/// the growth rate, and t is time.
```

Should say "where base is the initial value, rate is the growth rate, and t is time" (matching the formula and the code).

### A21-8 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpMaxUint256.sol

**File:** `src/lib/op/math/uint256/LibOpMaxUint256.sol`, line 13-14

Missing `@param` tags for both parameters and `@return` tags for both return values.

```solidity
/// `max-uint256` integrity check. Requires 0 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
```

### A21-9 [LOW] Missing `@param` and `@return` tags on `run` in LibOpMaxUint256.sol

**File:** `src/lib/op/math/uint256/LibOpMaxUint256.sol`, line 18-19

Missing `@param` and `@return` tags.

```solidity
/// `max-uint256` opcode. Pushes type(uint256).max onto the stack.
function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-10 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpMaxUint256.sol

**File:** `src/lib/op/math/uint256/LibOpMaxUint256.sol`, line 28-29

Missing `@param` and `@return` tags.

```solidity
/// Reference implementation of `max-uint256` for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)
```

### A21-11 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpUint256Add.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Add.sol`, line 13-14

Missing `@param` tags for `IntegrityCheckState memory` and `OperandV2 operand`, and `@return` tags for both return values.

```solidity
/// `uint256-add` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

### A21-12 [LOW] Missing `@param` and `@return` tags on `run` in LibOpUint256Add.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Add.sol`, line 21-24

Missing `@param` and `@return` tags.

```solidity
/// uint256-add
/// Addition with implied overflow checks from the Solidity 0.8.x
/// compiler.
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-13 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpUint256Add.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Add.sol`, line 55-56

Missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation of addition for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-14 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpUint256Div.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Div.sol`, line 14-15

Missing `@param` and `@return` tags.

```solidity
/// `uint256-div` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

### A21-15 [LOW] Missing `@param` and `@return` tags on `run` in LibOpUint256Div.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Div.sol`, line 22-24

Missing `@param` and `@return` tags.

```solidity
/// uint256-div
/// Division with implied checks from the Solidity 0.8.x compiler.
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-16 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpUint256Div.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Div.sol`, line 56-57

Missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation of division for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-17 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpUint256Mul.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Mul.sol`, line 13-14

Missing `@param` and `@return` tags.

```solidity
/// `uint256-mul` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

### A21-18 [LOW] Missing `@param` and `@return` tags on `run` in LibOpUint256Mul.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Mul.sol`, line 21-24

Missing `@param` and `@return` tags.

```solidity
/// uint256-mul
/// Multiplication with implied overflow checks from the Solidity 0.8.x
/// compiler.
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-19 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpUint256Mul.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Mul.sol`, line 55-56

Missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation of multiplication for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-20 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpUint256Pow.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Pow.sol`, line 13-14

Missing `@param` and `@return` tags.

```solidity
/// `uint256-pow` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

### A21-21 [LOW] Missing `@param` and `@return` tags on `run` in LibOpUint256Pow.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Pow.sol`, line 21-24

Missing `@param` and `@return` tags.

```solidity
/// uint256-power
/// Exponentiation with implied overflow checks from the Solidity 0.8.x
/// compiler.
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-22 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpUint256Pow.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Pow.sol`, line 55-56

Missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation of exponentiation for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-23 [LOW] Missing `@param` and `@return` tags on `integrity` in LibOpUint256Sub.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Sub.sol`, line 13-14

Missing `@param` and `@return` tags.

```solidity
/// `uint256-sub` integrity check. Requires at least 2 inputs and produces 1 output.
function integrity(IntegrityCheckState memory, OperandV2 operand) internal pure returns (uint256, uint256) {
```

### A21-24 [LOW] Missing `@param` and `@return` tags on `run` in LibOpUint256Sub.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Sub.sol`, line 21-24

Missing `@param` and `@return` tags.

```solidity
/// uint256-sub
/// Subtraction with implied underflow checks from the Solidity 0.8.x
/// compiler.
function run(InterpreterState memory, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
```

### A21-25 [LOW] Missing `@param` and `@return` tags on `referenceFn` in LibOpUint256Sub.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Sub.sol`, line 55-56

Missing `@param` and `@return` tags.

```solidity
/// Gas intensive reference implementation of subtraction for testing.
function referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)
```

### A21-26 [INFO] `run` NatSpec says "uint256-power" but opcode name is "uint256-pow" in LibOpUint256Pow.sol

**File:** `src/lib/op/math/uint256/LibOpUint256Pow.sol`, line 21

The NatSpec comment says `/// uint256-power` but the opcode/integrity NatSpec on line 13 says `uint256-pow`, and the library is named `LibOpUint256Pow`. The `run` function comment should say `uint256-pow` for consistency.

```solidity
/// uint256-power
```

### A21-27 [INFO] Div `referenceFn` comment says "overflow error" but div produces divide-by-zero not overflow

**File:** `src/lib/op/math/uint256/LibOpUint256Div.sol`, line 62

The comment in `referenceFn` says "Unchecked so that when we assert that an overflow error is thrown" but division does not overflow -- it reverts on divide-by-zero. The comment was presumably copied from the addition template but is inaccurate for division.

```solidity
// Unchecked so that when we assert that an overflow error is thrown, we
// see the revert from the real function and not the reference function.
```

### A21-28 [INFO] Sub `referenceFn` comment says "overflow error" but sub produces underflow

**File:** `src/lib/op/math/uint256/LibOpUint256Sub.sol`, line 62

Same issue as A21-27. The comment says "overflow error" but subtraction reverts on underflow, not overflow.

```solidity
// Unchecked so that when we assert that an overflow error is thrown, we
// see the revert from the real function and not the reference function.
```

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0     |
| HIGH     | 0     |
| MEDIUM   | 0     |
| LOW      | 22    |
| INFO     | 3     |
| **Total**| **25**|

All 8 files share the same documentation pattern: each function has a brief `///` description but none include `@param` or `@return` tags. This is a systematic gap across the opcode library files. Three additional INFO-level findings relate to inaccurate comments (variable name mismatch in LibOpLinearGrowth, opcode name mismatch in LibOpUint256Pow, and copy-paste error comment in Div and Sub referenceFn).
