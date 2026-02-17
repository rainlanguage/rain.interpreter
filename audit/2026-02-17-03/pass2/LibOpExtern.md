# Pass 2 (Test Coverage) -- LibOpExtern.sol

## Evidence of Thorough Reading

### Source: `src/lib/op/00/LibOpExtern.sol`

- **Library:** `LibOpExtern`
- **Functions:**
  - `integrity(IntegrityCheckState memory state, OperandV2 operand)` -- line 25
  - `run(InterpreterState memory state, OperandV2 operand, Pointer stackTop)` -- line 41
  - `referenceFn(InterpreterState memory state, OperandV2 operand, StackItem[] memory inputs)` -- line 90
- **Errors used (imported from `src/error/ErrExtern.sol` and `rain.interpreter.interface`):**
  - `NotAnExternContract(address)` -- reverted at line 32
  - `BadOutputsLength(uint256, uint256)` -- reverted at line 65 (run) and line 103 (referenceFn)

### Test: `test/src/lib/op/00/LibOpExtern.t.sol`

- **Contract:** `LibOpExternTest` (extends `OpTest`)
- **Helper functions:**
  - `mockImplementsERC165IInterpreterExternV4(IInterpreterExternV4 extern)` -- line 30
  - `externalIntegrity(IntegrityCheckState memory state, OperandV2 operand)` -- line 132
  - `externalRun(InterpreterState memory state, OperandV2 operand, StackItem[] memory inputs)` -- line 292
- **Test functions:**
  - `testOpExternIntegrityHappy` -- line 49 (fuzz: integrity happy path)
  - `testOpExternIntegrityNotAnExternContract` -- line 88 (fuzz: NotAnExternContract revert)
  - `testOpExternRunBadOutputsLength` -- line 142 (fuzz: BadOutputsLength with too few outputs)
  - `testOpExternRunBadOutputsLengthTooMany` -- line 200 (fuzz: BadOutputsLength with too many outputs)
  - `testOpExternRunZeroInputsZeroOutputs` -- line 257 (fuzz: zero inputs/outputs)
  - `testOpExternRunHappy` -- line 302 (fuzz: run with opReferenceCheck)
  - `testOpExternEvalHappy` -- line 365 (integration: parsed eval with 2 inputs, 1 output)
  - `testOpExternEvalMultipleInputsOutputsHappy` -- line 418 (integration: parsed eval with 3 inputs, 3 outputs)

## Findings

### A21-1: No test for `referenceFn` `BadOutputsLength` revert path

**Severity:** LOW

The `referenceFn` function at line 102 contains its own `BadOutputsLength` revert check (independent from the one in `run` at line 64). While the `run` function's `BadOutputsLength` revert is tested by `testOpExternRunBadOutputsLength` and `testOpExternRunBadOutputsLengthTooMany`, the `referenceFn`'s `BadOutputsLength` revert path at line 102-104 is never independently tested. In `testOpExternRunHappy`, the mock is set up so outputs match, meaning `referenceFn` never hits this revert. If the `referenceFn` logic were wrong (e.g., comparing incorrectly), no test would catch it.

### A21-2: No test for `run` with maximum inputs and outputs (0x0F each)

**Severity:** INFO

The operand encodes inputs and outputs as 4-bit values (max 0x0F = 15). While `testOpExternRunHappy` is a fuzz test that bounds inputs/outputs to `[0, 0x0F]`, there is no explicit edge case test that exercises the maximum of 15 inputs and 15 outputs simultaneously. The fuzz test may or may not generate this boundary case. A dedicated test for `inputs = 0x0F, outputs = 0x0F` would confirm the assembly loop handles the maximum correctly.

### A21-3: No test for `run` with inputs > 0 and outputs = 0

**Severity:** INFO

The test `testOpExternRunZeroInputsZeroOutputs` covers the (0, 0) case. The fuzz test `testOpExternRunHappy` covers the general case. However, there is no explicit test for the asymmetric case of `inputs > 0, outputs = 0`, which exercises the assembly path where `stackTop` is advanced by `inputsLength` words (line 72) but no output copying occurs (the loop body at lines 81-83 never executes because `sourceCursor == end`). The fuzz test could cover this but it is not guaranteed.

### A21-4: No test verifying memory head restoration in `run`

**Severity:** INFO

The `run` function at lines 59-61 saves and at line 71 restores the word at `sub(stackTop, 0x20)` (the `head` variable). This is documented as critical because it may be overwriting the stack array length. No test specifically verifies that the memory word is correctly restored after `run` completes. The `opReferenceCheck` in `testOpExternRunHappy` validates outputs but does not inspect memory state around the stack.
