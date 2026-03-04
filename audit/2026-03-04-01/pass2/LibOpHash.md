# Pass 2 -- LibOpHash

**Source file:** `src/lib/op/crypto/LibOpHash.sol`
**Test file:** `test/src/lib/op/crypto/LibOpHash.t.sol`

## Source inventory

| Function | Line | Description |
|---|---|---|
| `integrity` | 17 | Reads input count from operand (4-bit field, 0-15), returns (inputs, 1) |
| `run` | 28 | Computes keccak256 over operand-specified number of stack items |
| `referenceFn` | 41 | Pure reference implementation using abi.encodePacked |

## Test coverage summary

- `testOpHashIntegrityHappy` -- fuzz integrity with random inputs/outputs/operandData
- `testOpHashRun` -- fuzz run vs. referenceFn (inputs.length <= 15)
- `testOpHashEval0Inputs` -- explicit eval with 0 inputs
- `testOpHashEval1Input` -- explicit eval with 1 input
- `testOpHashEval2Inputs` -- explicit eval with 2 identical inputs
- `testOpHashEval2InputsDifferent` -- explicit eval with 2 different inputs
- `testOpHashEval2InputsOtherStack` -- eval with 2 inputs and surrounding stack items
- Output count tests (0, 2 outputs)
- Operand disallowed test

## Findings

### A43-1 (LOW): No explicit eval test for maximum inputs (15)

The input count is extracted from a 4-bit operand field (`and(shr(0x10, operand), 0x0F)`), making 15 the maximum. Explicit eval tests only go up to 2 inputs. The fuzz test `testOpHashRun` covers lengths up to 15 probabilistically, but there is no deterministic eval test at the boundary.

The `run` function performs stack pointer arithmetic (`stackTop := sub(add(stackTop, length), 0x20)`) that depends on the input count. An off-by-one at the maximum would silently produce incorrect results or corrupt the stack. An explicit test at 15 inputs through the full eval path would provide deterministic boundary coverage, consistent with the approach taken in `LibOpCall` (`testOpCallRunMaxInputsMaxOutputs`).
