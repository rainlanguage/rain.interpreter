# Pass 2 (Test Coverage) -- LibEval.sol

## Evidence of Thorough Reading

### Source File: `src/lib/eval/LibEval.sol`

**Library name:** `LibEval`

**Functions:**
- `evalLoop(InterpreterState memory state, uint256 parentSourceIndex, Pointer stackTop, Pointer stackBottom) internal view returns (Pointer)` -- line 41
- `eval2(InterpreterState memory state, StackItem[] memory inputs, uint256 maxOutputs) internal view returns (StackItem[] memory, bytes32[] memory)` -- line 191

**Errors referenced (defined in `src/error/ErrEval.sol`):**
- `InputsLengthMismatch(uint256 expected, uint256 actual)` -- used at line 213
- `ZeroFunctionPointers()` -- used in `Rainterpreter.sol` constructor

### Test File: `test/src/lib/eval/LibEval.fBounds.t.sol`

**Test functions:**
- `testEvalFBoundsModConstant(bytes32 c)` -- line 21

### Indirect Test Files:
- `test/src/concrete/Rainterpreter.eval.t.sol` -- tests `InputsLengthMismatch` for too-many-inputs
- `test/src/concrete/Rainterpreter.zeroFunctionPointers.t.sol` -- tests `ZeroFunctionPointers`

## Findings

### A05-1: No direct unit test for `evalLoop` function
**Severity:** LOW

The `evalLoop` function (line 41) is only tested indirectly through `eval2`. There is no direct unit test that constructs an `InterpreterState` and calls `evalLoop` in isolation to verify correct opcode dispatch for each of the 8 unrolled positions within a 32-byte word, correct cursor advancement, and correct interaction between the main loop and the remainder loop.

### A05-2: `InputsLengthMismatch` only tested for too-many-inputs direction
**Severity:** MEDIUM

The `InputsLengthMismatch` error (line 213) is only tested where the source expects 0 inputs and excess inputs are provided. There is no test for a source that declares N > 0 inputs receiving fewer than N inputs. The too-few-inputs case is the more dangerous direction -- it could cause `stackTop` to be set above `stackBottom`, potentially reading uninitialized memory.

### A05-3: No test for `maxOutputs` truncation behavior in `eval2`
**Severity:** MEDIUM

The `eval2` function accepts a `maxOutputs` parameter and computes `outputs = maxOutputs < sourceOutputs ? maxOutputs : sourceOutputs` at line 240. All existing tests pass `type(uint256).max` as `maxOutputs`. There is no test that passes `maxOutputs = 0` or `maxOutputs` less than `sourceOutputs` to verify truncation works correctly.

### A05-4: No test for zero-opcode source in `evalLoop`
**Severity:** LOW

There is no test exercising `evalLoop` with a source containing zero opcodes. When `opsLength` is 0, neither the main loop nor the remainder loop executes.

### A05-5: No test for multiple sources exercised through `eval2`
**Severity:** LOW

There is no direct test of `eval2` with `state.sourceIndex > 0` to verify correct stack bottom selection and input/output handling for non-primary sources.

### A05-6: No test for `eval2` with non-zero inputs that match source expectation
**Severity:** LOW

The input copy path (lines 216-226) where `inputs.length > 0` is never directly unit-tested for `eval2`.

### A05-7: No test for exact multiple-of-8 opcode count (zero remainder)
**Severity:** LOW

The existing test uses 37 opcodes (remainder = 5). There is no test with exactly 8, 16, 24, or 32 opcodes where the remainder `m` is 0 and only the main unrolled loop runs.
