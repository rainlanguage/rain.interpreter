# Pass 2 (Test Coverage) -- LibOpConstant.sol

**Audit:** 2026-03-04-01
**Agent ID:** A30

## Evidence

**Library:** `LibOpConstant`
**Source:** `src/lib/op/00/LibOpConstant.sol`
**Functions:**
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 21
- `run(InterpreterState memory, OperandV2, Pointer)` -- line 37
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 52

**Test file:** `test/src/lib/op/00/LibOpConstant.t.sol` (158 lines, 10 test functions)

### Coverage summary

| Path | Test | Status |
|------|------|--------|
| `integrity` happy path | `testOpConstantIntegrity` (fuzz) | Covered |
| `integrity` OOB revert | `testOpConstantIntegrityOOBConstants` (fuzz) | Covered |
| `integrity` max index boundary (65535) | `testOpConstantIntegrityMaxIndex` | Covered |
| `run` via reference check | `testOpConstantRun` (fuzz) | Covered |
| `referenceFn` via reference check | `testOpConstantRun` (fuzz) | Covered |
| End-to-end eval | `testOpConstantEval` | Covered |
| End-to-end zero constants revert | `testOpConstantEvalZeroConstants` | Covered |
| Multiple outputs (sugared/unsugared) | `testOpConstantMultipleOutputError*` | Covered |
| Zero outputs (sugared/unsugared) | `testOpConstantZeroOutputError*` | Covered |
| Bad inputs (unsugared syntax) | -- | **Not covered** |

## Findings

### P2-A30-1 (LOW) Missing bad-inputs test for constant opcode

**Source:** `src/lib/op/00/LibOpConstant.sol` line 21
**Test file:** `test/src/lib/op/00/LibOpConstant.t.sol`

The `constant` opcode declares 0 inputs and 1 output in its integrity function. The test file verifies that zero and multiple outputs are rejected, but does not test that providing inputs via unsugared syntax (e.g., `_: constant<0>(1);`) is correctly rejected by the integrity check. The `LibOpContext` test file includes analogous tests (`testOpContextOneInput`, `testOpContextTwoInputs`) using `checkBadInputs`. This is a minor completeness gap.
