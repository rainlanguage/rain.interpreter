# Pass 2 (Test Coverage) -- LibOpStack.sol

**Audit:** 2026-03-04-01
**Agent ID:** A33

## Evidence

**Library:** `LibOpStack`
**Source:** `src/lib/op/00/LibOpStack.sol`
**Functions:**
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 21
- `run(InterpreterState memory, OperandV2, Pointer)` -- line 41
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 58

**Test file:** `test/src/lib/op/00/LibOpStack.t.sol` (223 lines, 11 test functions)

### Coverage summary

| Path | Test | Status |
|------|------|--------|
| `integrity` happy path | `testOpStackIntegrity` (fuzz) | Covered |
| `integrity` OOB revert | `testOpStackIntegrityOOBStack` (fuzz) | Covered |
| `integrity` readHighwater update | -- | Not directly asserted |
| `run` via manual stack test | `testOpStackRun` (fuzz, 100 runs) | Covered |
| `run`/`referenceFn` parity | `testOpStackRunReferenceFnParity` (fuzz, 100 runs) | Covered |
| End-to-end eval | `testOpStackEval`, `testOpStackEvalSeveral` | Covered |
| Multiple outputs (sugared/unsugared) | `testOpStackMultipleOutputError*` | Covered |
| Zero outputs (sugared/unsugared) | `testOpStackZeroOutputError*` | Covered |
| Bad inputs (unsugared syntax) | -- | **Not covered** |

## Findings

### P2-A33-1 (LOW) Missing bad-inputs test for stack opcode

**Source:** `src/lib/op/00/LibOpStack.sol` line 21
**Test file:** `test/src/lib/op/00/LibOpStack.t.sol`

The `stack` opcode declares 0 inputs and 1 output in its integrity function. The test file verifies that zero and multiple outputs are rejected, but does not test that providing inputs via unsugared syntax (e.g., `foo: 1, _: stack<0>(foo);`) is correctly rejected by the integrity check. The `LibOpContext` test file includes analogous tests (`testOpContextOneInput`, `testOpContextTwoInputs`) using `checkBadInputs`. This is a minor completeness gap.

### P2-A33-2 (INFO) readHighwater update not directly asserted in integrity test

**Source:** `src/lib/op/00/LibOpStack.sol` lines 29-31
**Test file:** `test/src/lib/op/00/LibOpStack.t.sol`

The `integrity` function updates `state.readHighwater` when `readIndex > state.readHighwater`. The fuzz test `testOpStackIntegrity` calls the function but only asserts the return values `(inputs, outputs)`, not the resulting `readHighwater` value on the state. The highwater mechanism is tested at the `LibIntegrityCheck` level (`test/src/lib/integrity/LibIntegrityCheck.highwater.t.sol`), which provides indirect coverage. Previously flagged as A27-1 in audit 2026-02-17-03.
