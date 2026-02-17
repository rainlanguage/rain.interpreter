# Pass 2 (Test Coverage) -- LibOpCall.sol

## Evidence of Thorough Reading

**Library:** `LibOpCall`
**Functions:**
- `integrity` -- line 87
- `run` -- line 119

**Test file:** `test/src/lib/op/call/LibOpCall.t.sol` (346 lines, 12 test functions)

## Findings

### A17-1: No referenceFn or direct unit test for `run` function assembly logic
**Severity:** MEDIUM

Unlike most opcode libraries, `LibOpCall` does not provide a `referenceFn` and cannot be tested via `opReferenceCheck`. The `run` function contains two assembly blocks for copying inputs in reverse order and copying outputs back. These are only tested via end-to-end `eval4` calls. A bug in pointer arithmetic could go undetected if E2E tests don't hit that specific edge.

### A17-2: No test for `run` with maximum inputs (15) and maximum outputs simultaneously
**Severity:** LOW

The operand allows up to 15 inputs (4 bits). E2E tests cover 0-2 inputs/outputs only. The assembly copy loops are not exercised at upper bounds.

### A17-3: No isolated test for operand field extraction consistency between `integrity` and `run`
**Severity:** LOW

Both functions extract fields from the operand with separate bit masks. No test validates these extractions are consistent.

### A17-4: `run` assembly `stackBottoms` access relies entirely on integrity check
**Severity:** INFO

The `run` function accesses `stackBottoms[sourceIndex]` via raw pointer arithmetic with no bounds check. This is by design (integrity validates first).
