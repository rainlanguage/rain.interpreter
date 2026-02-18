# Pass 1 (Security) -- Float Math Opcodes Part 1

Audit date: 2026-02-17
Audit namespace: 2026-02-17-03

## Evidence of Thorough Reading

### LibOpAbs.sol (`src/lib/op/math/LibOpAbs.sol`)
- **Library**: `LibOpAbs`
- **Functions**:
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 24) -- reads 1 float, applies `abs()`, writes back in place
  - `referenceFn` (line 38) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`

### LibOpAdd.sol (`src/lib/op/math/LibOpAdd.sol`)
- **Library**: `LibOpAdd`
- **Functions**:
  - `integrity` (line 19) -- extracts input count from operand bits `[19:16]`, clamps to min 2, returns `(inputs, 1)`
  - `run` (line 27) -- reads N floats, adds via `LibDecimalFloatImplementation.add`, repacks with `packLossy`, writes result
  - `referenceFn` (line 68) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`, `LibDecimalFloatImplementation`

### LibOpAvg.sol (`src/lib/op/math/LibOpAvg.sol`)
- **Library**: `LibOpAvg`
- **Functions**:
  - `integrity` (line 17) -- returns `(2, 1)`
  - `run` (line 24) -- reads 2 floats, computes `(a + b) / 2`, writes result
  - `referenceFn` (line 41) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`

### LibOpCeil.sol (`src/lib/op/math/LibOpCeil.sol`)
- **Library**: `LibOpCeil`
- **Functions**:
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 24) -- reads 1 float, applies `ceil()`, writes back in place
  - `referenceFn` (line 38) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`

### LibOpDiv.sol (`src/lib/op/math/LibOpDiv.sol`)
- **Library**: `LibOpDiv`
- **Functions**:
  - `integrity` (line 18) -- extracts input count from operand bits `[19:16]`, clamps to min 2, returns `(inputs, 1)`
  - `run` (line 27) -- reads N floats, divides via `LibDecimalFloatImplementation.div`, repacks with `packLossy`, writes result
  - `referenceFn` (line 66) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`, `LibDecimalFloatImplementation`

### LibOpE.sol (`src/lib/op/math/LibOpE.sol`)
- **Library**: `LibOpE`
- **Functions**:
  - `integrity` (line 15) -- returns `(0, 1)`
  - `run` (line 20) -- pushes `FLOAT_E` constant onto stack (decrements stackTop by 0x20)
  - `referenceFn` (line 30) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `Pointer`, `OperandV2`, `StackItem`, `InterpreterState`, `IntegrityCheckState`, `LibDecimalFloat`, `Float`

### LibOpExp.sol (`src/lib/op/math/LibOpExp.sol`)
- **Library**: `LibOpExp`
- **Functions**:
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 24) -- reads 1 float, computes `e^x` via `FLOAT_E.pow(a, LOG_TABLES_ADDRESS)`, writes back; mutability is `view` (reads log tables contract)
  - `referenceFn` (line 38) -- reference implementation for testing; also `view`
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `LibDecimalFloat`, `Float`

### LibOpExp2.sol (`src/lib/op/math/LibOpExp2.sol`)
- **Library**: `LibOpExp2`
- **Functions**:
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 24) -- reads 1 float, computes `2^x` via `FLOAT_TWO.pow(a, LOG_TABLES_ADDRESS)`, writes back; mutability is `view`
  - `referenceFn` (line 39) -- reference implementation for testing; also `view`
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `LibDecimalFloat`, `Float`

### LibOpFloor.sol (`src/lib/op/math/LibOpFloor.sol`)
- **Library**: `LibOpFloor`
- **Functions**:
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 24) -- reads 1 float, applies `floor()`, writes back in place
  - `referenceFn` (line 38) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`

### LibOpFrac.sol (`src/lib/op/math/LibOpFrac.sol`)
- **Library**: `LibOpFrac`
- **Functions**:
  - `integrity` (line 17) -- returns `(1, 1)`
  - `run` (line 24) -- reads 1 float, applies `frac()`, writes back in place
  - `referenceFn` (line 38) -- reference implementation for testing
- **Errors/Events/Structs**: None defined locally
- **Imports**: `OperandV2`, `StackItem`, `Pointer`, `InterpreterState`, `IntegrityCheckState`, `Float`, `LibDecimalFloat`

---

## Security Findings

### No findings at CRITICAL, HIGH, or MEDIUM severity.

All ten files were reviewed for the following concerns with no issues found in those categories:
- Assembly memory safety
- Stack underflow/overflow
- Integrity inputs/outputs matching run behavior
- Unchecked arithmetic
- Custom error usage (no string reverts)
- Reentrancy risks
- Operand parsing correctness

---

### LOW-01: `packLossy` silently discards precision in LibOpAdd and LibOpDiv

**Files**: `LibOpAdd.sol` (line 58), `LibOpDiv.sol` (line 57)
**Severity**: LOW

Both `LibOpAdd.run()` and `LibOpDiv.run()` call `LibDecimalFloat.packLossy(signedCoefficient, exponent)` to re-pack intermediate results back into a `Float`. The second return value (`bool lossless`) is intentionally discarded (as annotated by the slither-disable comment). If intermediate computation produces a coefficient wider than `int224`, the result will be silently truncated.

This is a deliberate design choice -- the float system uses 224-bit signed coefficients and `packLossy` normalizes by dividing the coefficient and incrementing the exponent until it fits. However, this means that chaining many additions or divisions in a single multi-input opcode can accumulate precision loss differently than doing them pairwise, since intermediate results are NOT repacked between iterations (they remain as full `int256` coefficient + `int256` exponent pairs until the final `packLossy` call). This is actually **better** than packing between each step, but callers should be aware that the final result may not be bit-identical to a sequence of binary-add operations.

No action needed -- this is by design and the intermediate precision is actually higher than step-by-step evaluation.

---

### LOW-02: LibOpExp and LibOpExp2 depend on externally deployed log tables contract

**Files**: `LibOpExp.sol` (line 29), `LibOpExp2.sol` (line 30)
**Severity**: LOW

Both opcodes call `pow()` with `LibDecimalFloat.LOG_TABLES_ADDRESS` (a hardcoded address `0x6421E8a23cdEe2E6E579b2cDebc8C2A514843593`). If the log tables data contract is not deployed on the target chain, these opcodes will revert at runtime. The `pow` function uses `view` (it reads from this external contract via `extcodecopy` or similar).

This is mitigated by the deployment scripts (`Deploy.sol`) which list the log tables address as a dependency, ensuring it is deployed before the interpreter. Additionally, the `pow` function in `LibDecimalFloat` validates the external call internally. However, there is no check at the opcode level that the tables contract has code -- a missing tables contract would simply cause a revert during `eval4()`.

No action needed beyond noting the external dependency. The deployment pipeline handles this correctly.

---

### INFO-01: Consistent and correct assembly patterns across all 10 files

All assembly blocks are correctly annotated as `("memory-safe")`. The patterns are:

1. **Unary in-place ops** (abs, ceil, floor, frac): `mload(stackTop)` to read, compute, `mstore(stackTop, result)` to write back. Stack pointer unchanged. Integrity: `(1, 1)`. Correct.

2. **Binary consuming ops** (avg): `mload(stackTop)` for first value, `add(stackTop, 0x20)` then `mload` for second, store result at the advanced position. Net stack movement: +0x20 (one slot consumed). Integrity: `(2, 1)`. Correct.

3. **N-ary consuming ops** (add, div): Read 2 values initially (`stackTop += 0x40`), loop reads additional values (`stackTop += 0x20` each), then `stackTop -= 0x20` to write result. Net: `(inputs-1) * 0x20`. Integrity: `(inputs, 1)`. Correct.

4. **Push ops** (e): `sub(stackTop, 0x20)` then `mstore`. Net: -0x20 (one slot pushed). Integrity: `(0, 1)`. Correct.

5. **Unary transform ops with view** (exp, exp2): Same as unary in-place pattern, but with `view` mutability for external log table reads. Integrity: `(1, 1)`. Correct.

No memory safety violations found.

---

### INFO-02: Operand input count consistency in multi-input ops

In `LibOpAdd` and `LibOpDiv`, the operand input count is extracted identically in both `integrity()` and `run()` as `(OperandV2.unwrap(operand) >> 0x10) & 0x0F`. The `integrity()` function clamps the value to a minimum of 2, while `run()` does not need to because:

1. It unconditionally reads 2 values from the stack before checking the input count.
2. If the operand says 0 or 1, the while loop body never executes (since `i=2` is already >= `inputs`).
3. The integrity function already declared 2 inputs minimum, so the stack is guaranteed to have at least 2 items.

This is consistent and safe. No mismatch between integrity and run behavior.

---

### INFO-03: No string revert errors found

None of the 10 files contain any `revert("...")` or `require(..., "...")` patterns. All error handling is delegated to the underlying `LibDecimalFloat` / `LibDecimalFloatImplementation` libraries which use custom error types (`ExponentOverflow`, `CoefficientOverflow`, `ZeroNegativePower`, `PowNegativeBase`, etc.).

---

### INFO-04: `unchecked` blocks in LibOpAdd and LibOpDiv loop counters are safe

Both `LibOpAdd.run()` (line 51-53) and `LibOpDiv.run()` (line 51-53) use `unchecked { i++; }` for the loop counter. Since `i` starts at 2 and the maximum value of `inputs` is 15 (4-bit mask `0x0F`), overflow of `uint256` is impossible. This is safe.
