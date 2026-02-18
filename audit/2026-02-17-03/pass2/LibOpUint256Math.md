# Pass 2: Test Coverage - Uint256 Math Operations

## Evidence of Thorough Reading

### Source: `src/lib/op/math/uint256/LibOpMaxUint256.sol`

- **Library**: `LibOpMaxUint256`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 14
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 19
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 29
- **Errors used**: None
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 456)

### Source: `src/lib/op/math/uint256/LibOpUint256Add.sol`

- **Library**: `LibOpUint256Add`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 14
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 56
- **Errors used**: None (relies on Solidity 0.8.x overflow revert)
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 458)

### Source: `src/lib/op/math/uint256/LibOpUint256Div.sol`

- **Library**: `LibOpUint256Div`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 15
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 57
- **Errors used**: None (relies on Solidity 0.8.x division-by-zero revert)
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 460)

### Source: `src/lib/op/math/uint256/LibOpUint256Mul.sol`

- **Library**: `LibOpUint256Mul`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 14
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 56
- **Errors used**: None (relies on Solidity 0.8.x overflow revert)
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 462)

### Source: `src/lib/op/math/uint256/LibOpUint256Pow.sol`

- **Library**: `LibOpUint256Pow`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 14
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 56
- **Errors used**: None (relies on Solidity 0.8.x overflow revert)
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 464)

### Source: `src/lib/op/math/uint256/LibOpUint256Sub.sol`

- **Library**: `LibOpUint256Sub`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` -- line 14
  - `run(InterpreterState memory, OperandV2, Pointer)` -- line 24
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` -- line 57
- **Errors used**: None (relies on Solidity 0.8.x underflow revert)
- **Operand handler**: `LibParseOperand.handleOperandDisallowed` (from `LibAllStandardOps.sol` line 466)

### Test: `test/src/lib/op/math/uint256/LibOpMaxUint256.t.sol`

- **Contract**: `LibOpMaxUint256Test is OpTest`
- **Functions**:
  - `testOpMaxUint256Integrity(IntegrityCheckState memory, uint8, uint8, uint16)` -- line 18 (fuzz: integrity returns (0,1))
  - `testOpMaxUint256Run()` -- line 35 (runtime reference check)
  - `testOpMaxUint256Eval()` -- line 45 (eval: pushes type(uint256).max)
  - `testOpMaxUint256EvalFail()` -- line 50 (eval: rejects inputs)
  - `testOpMaxUint256ZeroOutputs()` -- line 56 (bad outputs: 0)
  - `testOpMaxUint256TwoOutputs()` -- line 60 (bad outputs: 2)

### Test: `test/src/lib/op/math/uint256/LibOpUint256Add.t.sol`

- **Contract**: `LibOpUint256AddTest is OpTest`
- **Functions**:
  - `testOpUint256AddIntegrityHappy(IntegrityCheckState memory, uint8, uint16)` -- line 13 (fuzz: integrity with 2-15 inputs)
  - `testOpUint256AddIntegrityUnhappyZeroInputs(IntegrityCheckState memory)` -- line 27 (integrity: 0 inputs -> 2)
  - `testOpUint256AddIntegrityUnhappyOneInput(IntegrityCheckState memory)` -- line 36 (integrity: 1 input -> 2)
  - `_testOpUint256AddRun(OperandV2, StackItem[] memory)` -- line 44 (external wrapper)
  - `testOpUint256AddRun(StackItem[] memory)` -- line 52 (fuzz: runtime with overflow detection)
  - `testOpUint256AddEvalZeroInputs()` -- line 74 (bad inputs: 0)
  - `testOpUint256AddEvalOneInput()` -- line 78 (bad inputs: 1)
  - `testOpUint256AddEvalZeroOutputs()` -- line 85 (bad outputs: 0)
  - `testOpUint256AddEvalTwoOutputs()` -- line 89 (bad outputs: 2)
  - `testOpUint256AddEvalTwoInputsHappy()` -- line 93 (eval: 2-input happy)
  - `testOpUint256AddEvalThreeInputsHappy()` -- line 102 (eval: 3-input happy)
  - `testOpUint256AddEvalThreeInputsUnhappy()` -- line 109 (eval: overflow cases)
  - `testOpUint256AddEvalOperandsDisallowed()` -- line 114 (operand disallowed)

### Test: `test/src/lib/op/math/uint256/LibOpUint256Div.t.sol`

- **Contract**: `LibOpUint256DivTest is OpTest`
- **Functions**:
  - `testOpUint256DivIntegrityHappy(IntegrityCheckState memory, uint8, uint16)` -- line 13 (fuzz)
  - `testOpUint256DivIntegrityUnhappyZeroInputs(IntegrityCheckState memory)` -- line 27
  - `testOpUint256DivIntegrityUnhappyOneInput(IntegrityCheckState memory)` -- line 36
  - `_testOpUint256DivRun(OperandV2, StackItem[] memory)` -- line 44 (external wrapper)
  - `testOpUint256DivRun(StackItem[] memory)` -- line 52 (fuzz: runtime with div-by-zero detection)
  - `testOpUint256DivEvalZeroInputs()` -- line 70 (bad inputs: 0)
  - `testOpUint256DivEvalOneInput()` -- line 75 (bad inputs: 1)
  - `testOpUint256DivEvalZeroOutputs()` -- line 82 (bad outputs: 0)
  - `testOpUint256DivEvalTwoOutputs()` -- line 86 (bad outputs: 2)
  - `testOpUint256DivEval2InputsHappy()` -- line 93 (eval: extensive 2-input cases)
  - `testOpUint256DivEval2InputsUnhappy()` -- line 124 (eval: div-by-zero)
  - `testOpUint256DivEval3InputsHappy()` -- line 132 (eval: extensive 3-input cases)
  - `testOpUint256DivEval3InputsUnhappy()` -- line 180 (eval: div-by-zero with 3 inputs)
  - `testOpUint256DivEvalOperandDisallowed()` -- line 194 (operand disallowed)

### Test: `test/src/lib/op/math/uint256/LibOpUint256Mul.t.sol`

- **Contract**: `LibOpUint256MulTest is OpTest`
- **Functions**:
  - `testOpUint256MulIntegrityHappy(IntegrityCheckState memory, uint8, uint16)` -- line 13 (fuzz)
  - `testOpUint256MulIntegrityUnhappyZeroInputs(IntegrityCheckState memory)` -- line 27
  - `testOpUint256MulIntegrityUnhappyOneInput(IntegrityCheckState memory)` -- line 36
  - `_testOpUint256MulRun(OperandV2, StackItem[] memory)` -- line 44 (external wrapper)
  - `testOpUint256MulRun(StackItem[] memory)` -- line 52 (fuzz: runtime with overflow detection)
  - `testOpUint256MulEvalZeroInputs()` -- line 78 (bad inputs: 0)
  - `testOpUint256MulEvalOneInput()` -- line 83 (bad inputs: 1)
  - `testOpUint256MulEvalZeroOutputs()` -- line 90 (bad outputs: 0)
  - `testOpUint256MulEvalTwoOutputs()` -- line 94 (bad outputs: 2)
  - `testOpUint256MulEvalTwoInputsHappy()` -- line 100 (eval: 2-input happy)
  - `testOpUint256MulEvalTwoInputsUnhappy()` -- line 114 (eval: overflow cases)
  - `testOpUint256MulEvalThreeInputsHappy()` -- line 122 (eval: 3-input happy)
  - `testOpUint256MulEvalThreeInputsUnhappy()` -- line 149 (eval: 3 and 4 input overflow cases)
  - `testOpUint256MulEvalOperandsDisallowed()` -- line 170 (operand disallowed)

### Test: `test/src/lib/op/math/uint256/LibOpUint256Pow.t.sol`

- **Contract**: `LibOpUint256PowTest is OpTest`
- **Functions**:
  - `testOpUint256ExpIntegrityHappy(IntegrityCheckState memory, uint8, uint16)` -- line 16 (fuzz)
  - `testOpUint256PowIntegrityUnhappyZeroInputs(IntegrityCheckState memory)` -- line 30
  - `testOpUint256PowIntegrityUnhappyOneInput(IntegrityCheckState memory)` -- line 39
  - `_testOpUint256PowRun(OperandV2, StackItem[] memory)` -- line 47 (external wrapper)
  - `testOpUint256PowRun(StackItem[] memory)` -- line 55 (fuzz: runtime with overflow detection)
  - `testOpUint256PowEvalZeroInputs()` -- line 92 (bad inputs: 0)
  - `testOpUint256PowEvalOneInput()` -- line 97 (bad inputs: 1)
  - `testOpUint256PowEvalZeroOutputs()` -- line 104 (bad outputs: 0)
  - `testOpUint256PowEvalTwoOutputs()` -- line 108 (bad outputs: 2)
  - `testOpUint256PowEval2InputsHappy()` -- line 114 (eval: 2-input happy, extensive)
  - `testOpUint256PowEval2InputsUnhappy()` -- line 149 (eval: overflow cases)
  - `testOpUint256PowEval3InputsHappy()` -- line 157 (eval: 3-input happy, very extensive)
  - `testOpUint256PowEval3InputsUnhappy()` -- line 220 (eval: 3-input overflow cases)
  - `testOpUint256PowEvalOperandDisallowed()` -- line 237 (operand disallowed)

### Test: `test/src/lib/op/math/uint256/LibOpUint256Sub.t.sol`

- **Contract**: `LibOpUint256SubTest is OpTest`
- **Functions**:
  - `testOpUint256SubIntegrityHappy(IntegrityCheckState memory, uint8, uint16)` -- line 13 (fuzz)
  - `testOpUint256SubIntegrityUnhappyZeroInputs(IntegrityCheckState memory)` -- line 27
  - `testOpUint256SubIntegrityUnhappyOneInput(IntegrityCheckState memory)` -- line 36
  - `_testOpUint256SubRun(OperandV2, StackItem[] memory)` -- line 44 (external wrapper)
  - `testOpUint256SubRun(StackItem[] memory)` -- line 52 (fuzz: runtime with underflow detection)
  - `testOpUint256SubEvalZeroInputs()` -- line 74 (bad inputs: 0)
  - `testOpUint256SubEvalOneInput()` -- line 78 (bad inputs: 1)
  - `testOpUint256SubEvalZeroOutputs()` -- line 85 (bad outputs: 0)
  - `testOpUint256SubEvalTwoOutputs()` -- line 89 (bad outputs: 2)
  - `testOpUint256SubEvalTwoInputsHappy()` -- line 93 (eval: 2-input happy)
  - `testOpUint256SubEvalThreeInputsHappy()` -- line 102 (eval: 3-input happy)
  - `testOpUint256SubEvalThreeInputsUnhappy()` -- line 109 (eval: underflow cases)
  - `testOpUint256SubEvalOperandsDisallowed()` -- line 114 (operand disallowed)

## Coverage Analysis

### Common Pattern for All Multi-Input Math Ops (Add, Div, Mul, Pow, Sub)

All five multi-input math opcodes share an identical structure:
1. `integrity`: Reads input count from operand bits 16-19 (4-bit field), clamps to minimum 2, returns `(inputs, 1)`.
2. `run`: Reads first two values from stack, applies operation, then loops for additional inputs.
3. `referenceFn`: Unchecked Solidity implementation for testing.

Each has the same test pattern:
- Fuzz test for integrity happy path (inputs 2-15)
- Unit test for integrity with 0 inputs (clamps to 2)
- Unit test for integrity with 1 input (clamps to 2)
- Fuzz test for runtime behavior with error path detection
- Eval tests for zero/one inputs (rejected), zero/two outputs (rejected)
- Eval tests for happy and unhappy (overflow/underflow/div-by-zero) paths
- Operand disallowed test

### LibOpMaxUint256

- **All three functions tested**: `integrity`, `run`, `referenceFn` (via `opReferenceCheck`).
- **Input rejection**: `testOpMaxUint256EvalFail` confirms inputs cause `BadOpInputsLength` revert.
- **Output validation**: Zero outputs and two outputs both tested.
- **Operand handler**: Not separately tested for disallowed operand, but `LibOpMaxUint256` uses `handleOperandDisallowed`. No explicit `checkDisallowedOperand` test exists in this test file.

### LibOpUint256Add

- **All functions tested**: Good coverage across integrity, run, and eval paths.
- **Overflow**: Fuzz test detects overflow and expects revert. Eval tests confirm specific overflow cases.

### LibOpUint256Div

- **All functions tested**: Good coverage.
- **Division by zero**: Fuzz test detects div-by-zero. Eval tests confirm specific div-by-zero cases with 2 and 3 inputs.
- **Truncation**: Eval tests specifically verify truncation behavior.

### LibOpUint256Mul

- **All functions tested**: Good coverage.
- **Overflow**: Fuzz test detects overflow. Eval tests include 4-input overflow case and mid-calculation overflow.

### LibOpUint256Pow

- **All functions tested**: Good coverage.
- **Overflow**: Fuzz test has custom overflow detection logic. Very extensive eval tests for 2 and 3 inputs.

### LibOpUint256Sub

- **All functions tested**: Good coverage.
- **Underflow**: Fuzz test detects underflow. Eval tests confirm specific underflow cases.

## Findings

### A29-1: LibOpMaxUint256 missing operand disallowed test (LOW)

**Source**: `test/src/lib/op/math/uint256/LibOpMaxUint256.t.sol`
**Details**: Unlike all other uint256 math opcodes (`Add`, `Div`, `Mul`, `Pow`, `Sub`) which each have explicit `checkDisallowedOperand` tests, `LibOpMaxUint256Test` does not have a `testOpMaxUint256EvalOperandDisallowed` test. The operand handler for `uint256-max-value` is `handleOperandDisallowed` (confirmed in `LibAllStandardOps.sol` line 456), so providing an operand should be rejected. This gap means there is no test confirming that `uint256-max-value<N>()` is rejected at parse time.

### A29-2: No test for maximum input count boundary (15 inputs) via eval (INFO)

**Source**: All multi-input ops (`Add`, `Div`, `Mul`, `Pow`, `Sub`)
**Details**: The operand encodes the input count in a 4-bit field (bits 16-19), supporting 0-15 inputs. While the fuzz tests do exercise up to 15 inputs (`vm.assume(inputs.length <= 0x0F)`), there are no eval-based tests that parse and evaluate expressions with more than 4 inputs. The eval tests max out at 3-4 inputs. A test with 15 inputs parsed from a string would confirm end-to-end behavior at the operand boundary. This is mitigated by the fuzz tests which do cover up to 15.

### A29-3: Fuzz overflow detection in testOpUint256PowRun may have false negatives (INFO)

**Source**: `test/src/lib/op/math/uint256/LibOpUint256Pow.t.sol` lines 55-89
**Details**: The overflow detection logic in `testOpUint256PowRun` (lines 60-84) uses an iterative multiplication approach to detect overflow in the test harness. However, this logic contains a `break` at line 78 (`if (d == a) { break; }`) which exits the inner loop when `d == a`, which occurs when `a == 1`. This is correct for detecting non-overflow (1 raised to any power is 1), but the overall overflow detection is inherently complex for exponentiation. The fuzz test delegates actual correctness to the `opReferenceCheck` which compares `run` against `referenceFn`, so this is only about whether `vm.expectRevert` is correctly set. A false negative here would cause the test to fail (unexpected revert), not pass silently, so the risk is test fragility rather than missed bugs.

### A29-4: referenceFn uses unchecked arithmetic intentionally (INFO)

**Source**: All multi-input ops in `src/lib/op/math/uint256/`
**Details**: All `referenceFn` implementations use `unchecked` blocks with the comment "Unchecked so that when we assert that an overflow error is thrown, we see the revert from the real function and not the reference function." This is intentional and correct -- the reference function must not revert on overflow so that the test harness can compare behavior. The `opReferenceCheck` framework handles the comparison logic. This is noted for completeness; no action needed.

### A29-5: No test for two-input overflow in testOpUint256AddEvalThreeInputsUnhappy (INFO)

**Source**: `test/src/lib/op/math/uint256/LibOpUint256Add.t.sol` lines 109-112
**Details**: `testOpUint256AddEvalThreeInputsUnhappy` has only 2 test cases, neither of which tests the case where the first two inputs overflow but the third would not change the result. For example, `uint256-add(uint256-max-value() 0x01 0x00)` would overflow at the first addition. This is covered by the fuzz test, but a targeted eval test would be more explicit. Minor gap.
