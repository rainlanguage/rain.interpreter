# Pass 2: Test Coverage - LibOpStack

## Evidence of Thorough Reading

### Source: `src/lib/op/00/LibOpStack.sol`

- **Library**: `LibOpStack`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 33
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 47
- **Errors used**: `OutOfBoundsStackRead` (imported from `src/error/ErrIntegrity.sol`)
- **Operand handler**: `LibParseOperand.handleOperandSingleFull` (from `LibAllStandardOps.sol` line 374)

### Test: `test/src/lib/op/00/LibOpStack.t.sol`

- **Contract**: `LibOpStackTest is OpTest`
- **Functions**:
  - `integrityExternal(IntegrityCheckState memory, OperandV2)` -- line 25 (wrapper for external call to test reverts)
  - `testOpStackIntegrity(bytes memory, uint256, bytes32[] memory, OperandV2)` -- line 36 (fuzz: happy path integrity)
  - `testOpStackIntegrityOOBStack(bytes memory, uint16, bytes32[] memory, uint16, uint256)` -- line 55 (fuzz: OOB revert)
  - `testOpStackRun(StackItem[][] memory, uint256)` -- line 75 (fuzz: runtime, 100 runs)
  - `testOpStackRunReferenceFnParity(StackItem[][] memory, uint256)` -- line 135 (fuzz: run vs referenceFn parity, 100 runs)
  - `testOpStackEval()` -- line 156 (end-to-end eval via parser)
  - `testOpStackEvalSeveral()` -- line 177 (end-to-end eval with multiple stack refs)
  - `testOpStackMultipleOutputErrorSugared()` -- line 202
  - `testOpStackMultipleOutputErrorUnsugared()` -- line 207
  - `testOpStackZeroOutputErrorSugared()` -- line 212
  - `testOpStackZeroOutputErrorUnsugared()` -- line 217

## Coverage Analysis

### `integrity` function
- **Happy path**: Tested via `testOpStackIntegrity` -- fuzz test confirms `(0, 1)` return. Operand bounded to valid range `[0, stackIndex-1]`.
- **OOB revert**: Tested via `testOpStackIntegrityOOBStack` -- confirms `OutOfBoundsStackRead` is triggered when `readIndex >= stackIndex`.
- **readHighwater update**: The `integrity` function at line 25-27 updates `state.readHighwater` when `readIndex > state.readHighwater`. This path is not directly asserted in any test. The fuzz test `testOpStackIntegrity` does not check the resulting `readHighwater` value on the state.

### `run` function
- **Tested via `testOpStackRun`**: Fuzz test verifying correct stack value is copied and stack pointer is moved correctly.
- **Memory boundary checks**: Test uses PRE/POST sentinel values to verify no memory corruption.
- **State immutability**: Test checks state fingerprint before/after to ensure no state mutation.

### `referenceFn` function
- **Tested via `testOpStackRunReferenceFnParity`**: Fuzz test confirms parity between `run()` and `referenceFn()`.

### Operand handler
- Operand handler is `handleOperandSingleFull`. Output count validation is tested:
  - `testOpStackMultipleOutputErrorSugared` / `testOpStackMultipleOutputErrorUnsugared` -- multiple outputs rejected
  - `testOpStackZeroOutputErrorSugared` / `testOpStackZeroOutputErrorUnsugared` -- zero outputs rejected

### End-to-end eval
- `testOpStackEval` and `testOpStackEvalSeveral` test parsing and evaluation through the full interpreter stack.

## Findings

### A27-1: readHighwater update not directly tested in integrity (INFO)

**Source**: `src/lib/op/00/LibOpStack.sol` lines 25-27
**Details**: The `integrity` function updates `state.readHighwater` when `readIndex > state.readHighwater`. No test directly asserts the value of `readHighwater` after calling `integrity`. While this logic path is exercised by the fuzz test (the code executes), the test does not verify the state mutation is correct. The `readHighwater` mechanism is critical for the integrity check system to track which stack positions are read, which affects highwater enforcement in `LibIntegrityCheck`. An incorrect highwater could allow reading from stack positions that are later overwritten.

### A27-2: Reduced fuzz run count for runtime tests (INFO)

**Source**: `test/src/lib/op/00/LibOpStack.t.sol` lines 74, 134
**Details**: `testOpStackRun` and `testOpStackRunReferenceFnParity` are annotated with `forge-config: default.fuzz.runs = 100`, reducing coverage from the default 2048 fuzz runs to 100. The comment format suggests this is intentional for performance, but it reduces the thoroughness of fuzz testing for this security-critical opcode. The `stack` opcode is deeply integrated into the parser and is one of the most frequently used opcodes.

### A27-3: No test for operand bits beyond the 16-bit mask (INFO)

**Source**: `src/lib/op/00/LibOpStack.sol` lines 18, 37
**Details**: Both `integrity` and `run` mask the operand with `0xFFFF` (bottom 16 bits). This means bits above position 15 in the operand are silently ignored. No test verifies that an operand with high bits set behaves identically to one without. While `handleOperandSingleFull` likely constrains operand construction, a direct unit test confirming that extra bits in the operand are ignored would strengthen confidence.
