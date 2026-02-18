# Pass 3: Documentation — LibOpMath2

Agent: A18

## Files Reviewed

- `src/lib/op/math/LibOpFloor.sol`
- `src/lib/op/math/LibOpFrac.sol`
- `src/lib/op/math/LibOpGm.sol`
- `src/lib/op/math/LibOpHeadroom.sol`
- `src/lib/op/math/LibOpInv.sol`

---

## Evidence of Thorough Reading

### LibOpFloor.sol

- **Library name:** `LibOpFloor` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 38
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpFloor` plus description (lines 11-12). No `@notice`.

### LibOpFrac.sol

- **Library name:** `LibOpFrac` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 38
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpFrac` and `@notice` (lines 11-12).

### LibOpGm.sol

- **Library name:** `LibOpGm` (line 14)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 25
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 42
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpGm` and `@notice` (lines 11-13).

### LibOpHeadroom.sol

- **Library name:** `LibOpHeadroom` (line 14)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 25
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 42
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpHeadroom` plus description (lines 11-13). No `@notice`.

### LibOpInv.sol

- **Library name:** `LibOpInv` (line 13)
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
  - `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 38
- **Errors/Events/Structs:** None
- **Library-level NatSpec:** `@title LibOpInv` and `@notice` (lines 11-12).

---

## Findings

### A18-1 [LOW] LibOpFrac: Library-level NatSpec uses `@notice`

**File:** `src/lib/op/math/LibOpFrac.sol`, line 12

The library-level doc uses `@notice Opcode for the frac of a decimal floating point number.` Per project conventions, `@notice` should not be used -- use bare `///` instead.

### A18-2 [LOW] LibOpGm: Library-level NatSpec uses `@notice`

**File:** `src/lib/op/math/LibOpGm.sol`, line 12

The library-level doc uses `@notice Opcode for the geometric average of two decimal floating point numbers.` Per project conventions, `@notice` should not be used -- use bare `///` instead.

### A18-3 [LOW] LibOpInv: Library-level NatSpec uses `@notice`

**File:** `src/lib/op/math/LibOpInv.sol`, line 12

The library-level doc uses `@notice Opcode for the inverse 1 / x of a floating point number.` Per project conventions, `@notice` should not be used -- use bare `///` instead.

### A18-4 [INFO] All `integrity` functions across all 5 files: Missing `@param` and `@return` tags

**Files:** All five files

Every `integrity` function has a NatSpec comment describing what it does (e.g., `` `floor` integrity check. Requires exactly 1 input and produces 1 output. ``), but none include `@param` tags for the two parameters (`IntegrityCheckState memory`, `OperandV2`) or `@return` tags for the two return values (`uint256, uint256`).

While the parameters are unnamed (and thus somewhat self-documenting through their types), the two unnamed `uint256` return values would benefit from `@return` tags explaining they represent `(inputs, outputs)`.

Affected lines:
- `LibOpFloor.sol` line 16-17
- `LibOpFrac.sol` line 16-17
- `LibOpGm.sol` line 17-18
- `LibOpHeadroom.sol` line 17-18
- `LibOpInv.sol` line 16-17

### A18-5 [INFO] All `run` functions across all 5 files: Missing `@param` and `@return` tags

**Files:** All five files

Every `run` function has a brief NatSpec comment (e.g., `/// floor` / `/// decimal floating point floor of a number.`), but none include `@param` tags for the three parameters (`InterpreterState memory`, `OperandV2`, `Pointer stackTop`) or `@return` tags for the return value (`Pointer`).

Affected lines:
- `LibOpFloor.sol` lines 22-24
- `LibOpFrac.sol` lines 22-24
- `LibOpGm.sol` lines 23-25
- `LibOpHeadroom.sol` lines 23-25
- `LibOpInv.sol` lines 22-24

### A18-6 [INFO] All `referenceFn` functions across all 5 files: Missing `@param` and `@return` tags

**Files:** All five files

Every `referenceFn` has a NatSpec comment (e.g., `/// Gas intensive reference implementation of floor for testing.`), but none include `@param` tags for the three parameters (`InterpreterState memory`, `OperandV2`, `StackItem[] memory inputs`) or `@return` tags for the return value (`StackItem[] memory`).

Affected lines:
- `LibOpFloor.sol` lines 37-38
- `LibOpFrac.sol` lines 37-38
- `LibOpGm.sol` lines 41-42
- `LibOpHeadroom.sol` lines 41-42
- `LibOpInv.sol` lines 37-38

### A18-7 [LOW] LibOpHeadroom `run` NatSpec is inaccurate/incomplete

**File:** `src/lib/op/math/LibOpHeadroom.sol`, line 24

The NatSpec for `run` says `/// decimal floating headroom of a number.` which is missing the word "point" (should be "decimal floating point headroom"). More importantly, the documentation does not describe the special behavior: when the fractional part is zero (i.e., the number is already an integer), the headroom returns `1` instead of `0`. This is a meaningful behavioral detail that should be documented, as it is not what a naive reading of "distance to ceil" would suggest. Lines 31-33 show:

```solidity
if (a.isZero()) {
    a = LibDecimalFloat.FLOAT_ONE;
}
```

### A18-8 [INFO] LibOpGm `run` NatSpec does not explain the computation

**File:** `src/lib/op/math/LibOpGm.sol`, lines 23-24

The NatSpec for `run` says `/// decimal floating point geometric average of two numbers.` The `referenceFn` has a comment `// The geometric mean is sqrt(a * b).` (line 47) explaining the formula, but the `run` NatSpec lacks this. The implementation computes `a.mul(b).pow(FLOAT_HALF, ...)` which is `(a * b) ^ 0.5` -- this mathematical identity should be mentioned in the `run` NatSpec too, since the implementation uses `pow` rather than a more obvious `sqrt`.

### A18-9 [INFO] LibOpHeadroom `referenceFn` comment says "1 - frac(x)" but implementation uses `ceil(x) - x`

**File:** `src/lib/op/math/LibOpHeadroom.sol`, line 47

The comment says `// The headroom is 1 - frac(x).` but the actual implementation on line 49 computes `a.ceil().sub(a)` which is `ceil(x) - x`. While these are mathematically equivalent for non-integer values, the comment does not match the code. Additionally, neither the comment nor the NatSpec mentions the special-case behavior where integer inputs return 1 instead of 0.
