# Pass 2: Test Coverage -- Math Operations Part 1

Agent: A24

## Evidence of Thorough Reading

### Source Files

**LibOpAbs.sol** (`src/lib/op/math/LibOpAbs.sol`)
- Library: `LibOpAbs`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 38
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 468 of LibAllStandardOps.sol)

**LibOpAdd.sol** (`src/lib/op/math/LibOpAdd.sol`)
- Library: `LibOpAdd`
- `integrity(IntegrityCheckState, OperandV2 operand) returns (uint256, uint256)` -- line 19
- `run(InterpreterState, OperandV2 operand, Pointer stackTop) returns (Pointer)` -- line 27
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 68
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 470 of LibAllStandardOps.sol)

**LibOpAvg.sol** (`src/lib/op/math/LibOpAvg.sol`)
- Library: `LibOpAvg`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 41
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 472 of LibAllStandardOps.sol)

**LibOpCeil.sol** (`src/lib/op/math/LibOpCeil.sol`)
- Library: `LibOpCeil`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 38
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 474 of LibAllStandardOps.sol)

**LibOpDiv.sol** (`src/lib/op/math/LibOpDiv.sol`)
- Library: `LibOpDiv`
- `integrity(IntegrityCheckState, OperandV2 operand) returns (uint256, uint256)` -- line 18
- `run(InterpreterState, OperandV2 operand, Pointer stackTop) returns (Pointer)` -- line 27
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 66
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 476 of LibAllStandardOps.sol)

**LibOpE.sol** (`src/lib/op/math/LibOpE.sol`)
- Library: `LibOpE`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 15
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 20
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 30
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 478 of LibAllStandardOps.sol)

**LibOpExp.sol** (`src/lib/op/math/LibOpExp.sol`)
- Library: `LibOpExp`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 38
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 480 of LibAllStandardOps.sol)

**LibOpExp2.sol** (`src/lib/op/math/LibOpExp2.sol`)
- Library: `LibOpExp2`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 39
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 482 of LibAllStandardOps.sol)

**LibOpFloor.sol** (`src/lib/op/math/LibOpFloor.sol`)
- Library: `LibOpFloor`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 38
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 484 of LibAllStandardOps.sol)

**LibOpFrac.sol** (`src/lib/op/math/LibOpFrac.sol`)
- Library: `LibOpFrac`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 17
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 24
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 38
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 486 of LibAllStandardOps.sol)

**LibOpGm.sol** (`src/lib/op/math/LibOpGm.sol`)
- Library: `LibOpGm`
- `integrity(IntegrityCheckState, OperandV2) returns (uint256, uint256)` -- line 18
- `run(InterpreterState, OperandV2, Pointer stackTop) returns (Pointer)` -- line 25
- `referenceFn(InterpreterState, OperandV2, StackItem[]) returns (StackItem[])` -- line 42
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed` (line 488 of LibAllStandardOps.sol)

### Test Files

**LibOpAbs.t.sol** (`test/src/lib/op/math/LibOpAbs.t.sol`)
- Contract: `LibOpAbsTest is OpTest`
- `testOpAbsIntegrity(IntegrityCheckState, OperandV2)` -- line 14
- `testOpAbsRun(Float, uint16)` -- line 21
- `testOpAbsEval()` -- line 36
- `testOpAbsZeroInputs()` -- line 47
- `testOpAbsTwoInputs()` -- line 51
- `testOpAbsZeroOutputs()` -- line 55
- `testOpAbsTwoOutputs()` -- line 59
- `testOpAbsEvalOperandDisallowed()` -- line 64

**LibOpAdd.t.sol** (`test/src/lib/op/math/LibOpAdd.t.sol`)
- Contract: `LibOpAddTest is OpTest`
- `testOpAddIntegrityHappy(IntegrityCheckState, uint8, uint16)` -- line 14
- `testOpAddIntegrityUnhappyZeroInputs(IntegrityCheckState)` -- line 24
- `testOpAddIntegrityUnhappyOneInput(IntegrityCheckState)` -- line 33
- `testOpAddRun(StackItem[])` -- line 42
- `testOpAddEvalZeroInputs()` -- line 62
- `testOpAddEvalOneInput()` -- line 67
- `testOpAddEvalZeroOutputs()` -- line 71
- `testOpAddEvalTwoOutput()` -- line 75
- `testOpAddEval2InputsHappyExamples()` -- line 80
- `testOpAddEval2InputsHappyZero()` -- line 97
- `testOpAddEval2InputsHappyZeroOne()` -- line 103
- `testOpAddEval2InputsHappyZeroMax()` -- line 112
- `testOpAddEval3InputsHappy()` -- line 127
- `testOpAddEval3InputsUnhappy()` -- line 138
- `testOpAddEvalOperandDisallowed()` -- line 178

**LibOpAvg.t.sol** (`test/src/lib/op/math/LibOpAvg.t.sol`)
- Contract: `LibOpAvgTest is OpTest`
- `testOpAvgIntegrity(IntegrityCheckState, OperandV2)` -- line 14
- `testOpAvgRun(int256, int256, int256, int256, uint16)` -- line 21
- `testOpAvgEvalExamples()` -- line 46
- `testOpAvgEvalOneInput()` -- line 59
- `testOpAvgEvalThreeInputs()` -- line 63
- `testOpAvgEvalZeroOutputs()` -- line 67
- `testOpAvgEvalTwoOutputs()` -- line 71
- `testOpAvgEvalOperandDisallowed()` -- line 76

**LibOpCeil.t.sol** (`test/src/lib/op/math/LibOpCeil.t.sol`)
- Contract: `LibOpCeilTest is OpTest`
- `testOpCeilIntegrity(IntegrityCheckState, OperandV2)` -- line 14
- `testOpCeilRun(Float, uint16)` -- line 21
- `testOpCeilEval()` -- line 32
- `testOpCeilZeroInputs()` -- line 59
- `testOpCeilTwoInputs()` -- line 63
- `testOpCeilZeroOutputs()` -- line 67
- `testOpCeilTwoOutputs()` -- line 71
- `testOpCeilEvalOperandDisallowed()` -- line 76

**LibOpDiv.t.sol** (`test/src/lib/op/math/LibOpDiv.t.sol`)
- Contract: `LibOpDivTest is OpTest`
- `testOpDivIntegrityHappy(IntegrityCheckState, uint8, uint16)` -- line 20
- `testOpDivIntegrityUnhappyZeroInputs(IntegrityCheckState)` -- line 30
- `testOpDivIntegrityUnhappyOneInput(IntegrityCheckState)` -- line 39
- `_testOpDivRun(OperandV2, StackItem[])` -- line 47
- `testOpDivRun(StackItem[])` -- line 53
- `testDebugOpDivRun()` -- line 82
- `testOpDivEvalZeroInputs()` -- line 90
- `testOpDivEvalOneInput()` -- line 96
- `testOpDivEvalTwoInputsHappy()` -- line 106
- `testOpDivEvalTwoInputsUnhappyDivZero()` -- line 123
- `testOpDivEvalTwoInputsUnhappyOverflow()` -- line 135
- `testOpDivEvalThreeInputsHappy()` -- line 146
- `testOpDivEvalThreeInputsUnhappyExamples()` -- line 163
- `testOpDivEvalThreeInputsUnhappyOverflow()` -- line 176
- `testOpDivEvalOperandsDisallowed()` -- line 188
- `testOpDivEvalZeroOutputs()` -- line 197
- `testOpDivEvalTwoOutputs()` -- line 201

**LibOpE.t.sol** (`test/src/lib/op/math/LibOpE.t.sol`)
- Contract: `LibOpETest is OpTest`
- `testOpEIntegrity(IntegrityCheckState, uint8, uint8, uint16)` -- line 23
- `testOpERun(uint16)` -- line 38
- `testOpEEval()` -- line 46
- `testOpEEvalOneInput()` -- line 65
- `testOpEEvalZeroOutputs()` -- line 69
- `testOpEEvalTwoOutputs()` -- line 73

**LibOpExp.t.sol** (`test/src/lib/op/math/LibOpExp.t.sol`)
- Contract: `LibOpExpTest is OpTest`
- `beforeOpTestConstructor()` -- line 12
- `testOpExpIntegrity(IntegrityCheckState, OperandV2)` -- line 18
- `testOpExpRun(int224, int32, uint16)` -- line 25
- `testOpExpEvalExample()` -- line 41
- `testOpExpEvalZeroInputs()` -- line 82
- `testOpExpEvalTwoInputs()` -- line 86
- `testOpExpZeroOutputs()` -- line 90
- `testOpExpTwoOutputs()` -- line 94
- `testOpExpEvalOperandDisallowed()` -- line 99

**LibOpExp2.t.sol** (`test/src/lib/op/math/LibOpExp2.t.sol`)
- Contract: `LibOpExp2Test is OpTest`
- `beforeOpTestConstructor()` -- line 12
- `testOpExp2Integrity(IntegrityCheckState, OperandV2)` -- line 18
- `testOpExp2Run(int224, int32, uint16)` -- line 25
- `testOpExp2EvalExample()` -- line 39
- `testOpExp2EvalBad()` -- line 48
- `testOpExp2EvalOperandDisallowed()` -- line 54
- `testOpExp2ZeroOutputs()` -- line 58
- `testOpExp2TwoOutputs()` -- line 62

**LibOpFloor.t.sol** (`test/src/lib/op/math/LibOpFloor.t.sol`)
- Contract: `LibOpFloorTest is OpTest`
- `testOpFloorIntegrity(IntegrityCheckState, OperandV2)` -- line 14
- `testOpFloorRun(Float, uint16)` -- line 21
- `testOpFloorEval()` -- line 32
- `testOpFloorZeroInputs()` -- line 42
- `testOpFloorTwoInputs()` -- line 46
- `testOpFloorZeroOutputs()` -- line 50
- `testOpFloorTwoOutputs()` -- line 54
- `testOpFloorEvalOperandDisallowed()` -- line 59

**LibOpFrac.t.sol** (`test/src/lib/op/math/LibOpFrac.t.sol`)
- Contract: `LibOpFracTest is OpTest`
- `testOpFracIntegrity(IntegrityCheckState, OperandV2)` -- line 14
- `testOpFracRun(Float, uint16)` -- line 21
- `testOpFracEval()` -- line 32
- `testOpFracZeroInputs()` -- line 44
- `testOpFracTwoInputs()` -- line 48
- `testOpFracZeroOutputs()` -- line 52
- `testOpFracTwoOutputs()` -- line 56
- `testOpFracEvalOperandDisallowed()` -- line 61

**LibOpGm.t.sol** (`test/src/lib/op/math/LibOpGm.t.sol`)
- Contract: `LibOpGmTest is OpTest`
- `beforeOpTestConstructor()` -- line 12
- `testOpGmIntegrity(IntegrityCheckState, OperandV2)` -- line 18
- `testOpGmRun(int224, int32, int224, int32, uint16)` -- line 25
- `testOpGmEval()` -- line 51
- `testOpGmOneInput()` -- line 64
- `testOpGmThreeInputs()` -- line 68
- `testOpGmZeroOutputs()` -- line 72
- `testOpGmTwoOutputs()` -- line 76
- `testOpGmEvalOperandDisallowed()` -- line 81

---

## Coverage Summary per Opcode

| Opcode | integrity tested | run tested | operand handler tested | eval tested | bad inputs tested | bad outputs tested |
|--------|-----------------|------------|----------------------|-------------|-------------------|--------------------|
| abs    | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 2) | Yes (0, 2) |
| add    | Yes (happy + unhappy) | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 1) | Yes (0, 2) |
| avg    | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (1, 3) | Yes (0, 2) |
| ceil   | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 2) | Yes (0, 2) |
| div    | Yes (happy + unhappy) | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 1) | Yes (0, 2) |
| e      | Yes | Yes (fuzz) | **NO** | Yes | Yes (1) | Yes (0, 2) |
| exp    | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 2) | Yes (0, 2) |
| exp2   | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 2) | Yes (0, 2) |
| floor  | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 2) | Yes (0, 2) |
| frac   | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (0, 2) | Yes (0, 2) |
| gm     | Yes | Yes (fuzz) | Yes (disallowed) | Yes | Yes (1, 3) | Yes (0, 2) |

---

## Findings

### A24-1: LibOpE missing operand disallowed test

**Severity: LOW**

**File:** `test/src/lib/op/math/LibOpE.t.sol`

`LibOpE` uses `handleOperandDisallowed` as its operand handler (line 478 of `LibAllStandardOps.sol`), but `LibOpETest` has no test verifying that providing an operand to `e` is rejected. Every other opcode in this group has such a test (e.g., `testOpAbsEvalOperandDisallowed`, `testOpAddEvalOperandDisallowed`, etc.). The `e` test file has no call to `checkDisallowedOperand` or `checkUnhappyParse` with `UnexpectedOperand`.

### A24-2: LibOpExp and LibOpExp2 fuzz tests restrict inputs to non-negative small values only

**Severity: LOW**

**File:** `test/src/lib/op/math/LibOpExp.t.sol` (line 26), `test/src/lib/op/math/LibOpExp2.t.sol` (line 26)

Both `testOpExpRun` and `testOpExp2Run` bound the fuzz input coefficient to `(0, 10000)` and exponent to `(-10, 5)`. This means fuzz testing never exercises negative inputs (e.g., `exp(-1)` or `exp2(-3)`) or large-magnitude inputs. While there are explicit eval tests for small positive values like 0, 0.5, 1, 2, 3, there are no eval tests for negative inputs at all. The `exp` and `exp2` functions should produce valid results for negative inputs (e.g., `exp(-1) = 1/e`), but this behavior is never tested.

### A24-3: LibOpGm fuzz test restricts inputs to non-negative small values only

**Severity: LOW**

**File:** `test/src/lib/op/math/LibOpGm.t.sol` (lines 32-35)

`testOpGmRun` bounds both coefficients to `(0, 10000)` and both exponents to `(-10, 5)`. This means fuzz testing never exercises negative inputs. The geometric mean of two negative numbers is a real number (sqrt of a positive product), but this path is never fuzz tested. The eval tests at line 51 only test non-negative values. The behavior of `gm` with negative inputs is uncovered -- `a.mul(b).pow(FLOAT_HALF, ...)` where `a*b < 0` would attempt `sqrt(negative)` which should fail, but no test verifies this error path.

### A24-4: LibOpFloor eval tests missing negative value coverage

**Severity: LOW**

**File:** `test/src/lib/op/math/LibOpFloor.t.sol` (lines 32-39)

`testOpFloorEval` only tests positive values (0, 1, 0.5, 2, 3, 3.8). For a `floor` operation, negative fractional values have important behavior: `floor(-0.5)` should be `-1`, `floor(-1.5)` should be `-2`. The fuzz test `testOpFloorRun` covers arbitrary values via `opReferenceCheck`, but the explicit eval tests (which exercise the full parse-eval pipeline) do not cover negative fractional inputs. By contrast, `LibOpCeil.t.sol` explicitly tests negative values (`-1`, `-1.1`, `-0.5`, `-1.5`, `-2`, `-2.5`) in its eval tests.

### A24-5: LibOpAvg eval tests missing zero-input test

**Severity: INFO**

**File:** `test/src/lib/op/math/LibOpAvg.t.sol`

`LibOpAvgTest` tests one-input (line 59) and three-input (line 63) as bad inputs, but does not test zero inputs. The `avg` opcode requires exactly 2 inputs, so zero inputs should also be rejected. This is a minor gap since the parser/integrity system would catch this, and the fuzz test covers the happy path comprehensively.

### A24-6: LibOpAdd and LibOpDiv eval tests missing negative input examples

**Severity: INFO**

**File:** `test/src/lib/op/math/LibOpAdd.t.sol`, `test/src/lib/op/math/LibOpDiv.t.sol`

Both `add` and `div` test files have thorough coverage of the happy path for 2 and 3 inputs, including edge cases with `max-positive-value()` and zero. However, neither has explicit eval tests using `min-negative-value()` as an input. The fuzz tests cover arbitrary values, so this is a minor documentation gap rather than a coverage gap.

### A24-7: LibOpAbs fuzz test excludes `type(int224).min` coefficient

**Severity: INFO**

**File:** `test/src/lib/op/math/LibOpAbs.t.sol` (line 25)

`testOpAbsRun` uses `vm.assume(signedCoefficient > type(int224).min)` to exclude the minimum int224 value. This is likely intentional (abs of `int224.min` overflows since the positive range of int224 cannot represent it), but the exclusion means there is no test verifying that `abs(min-negative-value())` actually reverts. If the underlying `LibDecimalFloat.abs()` silently wraps for this input instead of reverting, the bug would go undetected.
