# Pass 2 (Test Coverage) -- LibOpHash.sol

## Evidence of Thorough Reading

### Source: `src/lib/op/crypto/LibOpHash.sol`

- **Library:** `LibOpHash`
- **Functions:**
  - `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 14
  - `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 22
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 33
- **Errors used:** None (no revert paths in this library)

### Test: `test/src/lib/op/crypto/LibOpHash.t.sol`

- **Contract:** `LibOpHashTest` (extends `OpTest`)
- **Test functions:**
  - `testOpHashIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint8 outputs, uint16 operandData)` -- line 30 (fuzz: integrity happy path)
  - `testOpHashRun(StackItem[] memory inputs)` -- line 44 (fuzz: run with opReferenceCheck)
  - `testOpHashEval0Inputs()` -- line 52 (integration: 0 inputs)
  - `testOpHashEval1Input()` -- line 57 (integration: 1 input)
  - `testOpHashEval2Inputs()` -- line 63 (integration: 2 identical inputs)
  - `testOpHashEval2InputsDifferent()` -- line 73 (integration: 2 different inputs)
  - `testOpHashEval2InputsOtherStack()` -- line 83 (integration: 2 inputs with surrounding stack items)
  - `testOpHashZeroOutputs()` -- line 106 (integration: bad outputs check, 0 outputs)
  - `testOpHashTwoOutputs()` -- line 110 (integration: bad outputs check, 2 outputs)

## Findings

### A22-1: No explicit test for maximum inputs (0x0F = 15)

**Severity:** INFO

The `run` function uses `and(shr(0x10, operand), 0x0F)` to extract the input count, capping at 15. The fuzz test `testOpHashRun` bounds `inputs.length` to `<= 0x0F` and the reference check validates correctness, but there is no explicit edge case test that exercises exactly 15 inputs. A dedicated test with 15 inputs would confirm the boundary is handled correctly in the assembly (particularly the `stackTop := sub(add(stackTop, length), 0x20)` arithmetic at line 26 when `length = 15 * 0x20 = 0x1E0`).

### A22-2: No integration test for inputs > 2

**Severity:** INFO

The integration tests (eval from parsed string) cover 0, 1, and 2 inputs. There is no integration test exercising 3+ inputs through the full parse-and-eval pipeline. While the fuzz test `testOpHashRun` exercises up to 15 inputs at the library level via `opReferenceCheck`, it does not go through the parser. A test with, for example, `hash(a b c)` would exercise the parser's handling of higher input counts for this opcode.
