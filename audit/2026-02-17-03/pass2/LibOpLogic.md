# Pass 2 (Test Coverage) -- Logic Operations

## Evidence of Thorough Reading

### Source Files

#### LibOpAny.sol (`src/lib/op/logic/LibOpAny.sol`)
- Library: `LibOpAny`
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 18
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 27
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 52
- No errors/events/structs defined

#### LibOpBinaryEqualTo.sol (`src/lib/op/logic/LibOpBinaryEqualTo.sol`)
- Library: `LibOpBinaryEqualTo`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 14
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 21
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 31
- No errors/events/structs defined

#### LibOpConditions.sol (`src/lib/op/logic/LibOpConditions.sol`)
- Library: `LibOpConditions`
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 19
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 33
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 74
- No errors/events/structs defined (uses `revert(reason.toStringV3())` which is a dynamic string revert at line 66)

#### LibOpEnsure.sol (`src/lib/op/logic/LibOpEnsure.sol`)
- Library: `LibOpEnsure`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 27
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 43
- No errors/events/structs defined (uses `revert(reason.toStringV3())` at line 37)

#### LibOpEqualTo.sol (`src/lib/op/logic/LibOpEqualTo.sol`)
- Library: `LibOpEqualTo`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 19
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 26
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 46
- No errors/events/structs defined

#### LibOpEvery.sol (`src/lib/op/logic/LibOpEvery.sol`)
- Library: `LibOpEvery`
- `integrity(IntegrityCheckState memory, OperandV2 operand)` -- line 18
- `run(InterpreterState memory, OperandV2 operand, Pointer stackTop)` -- line 26
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 50
- No errors/events/structs defined

#### LibOpGreaterThan.sol (`src/lib/op/logic/LibOpGreaterThan.sol`)
- Library: `LibOpGreaterThan`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 40
- No errors/events/structs defined

#### LibOpGreaterThanOrEqualTo.sol (`src/lib/op/logic/LibOpGreaterThanOrEqualTo.sol`)
- Library: `LibOpGreaterThanOrEqualTo`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 25
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 41
- No errors/events/structs defined

#### LibOpIf.sol (`src/lib/op/logic/LibOpIf.sol`)
- Library: `LibOpIf`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 40
- No errors/events/structs defined

#### LibOpIsZero.sol (`src/lib/op/logic/LibOpIsZero.sol`)
- Library: `LibOpIsZero`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 17
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 23
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 36
- No errors/events/structs defined

#### LibOpLessThan.sol (`src/lib/op/logic/LibOpLessThan.sol`)
- Library: `LibOpLessThan`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 24
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 40
- No errors/events/structs defined

#### LibOpLessThanOrEqualTo.sol (`src/lib/op/logic/LibOpLessThanOrEqualTo.sol`)
- Library: `LibOpLessThanOrEqualTo`
- `integrity(IntegrityCheckState memory, OperandV2)` -- line 18
- `run(InterpreterState memory, OperandV2, Pointer stackTop)` -- line 25
- `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs)` -- line 41
- No errors/events/structs defined

### Test Files

#### LibOpAny.t.sol
- Contract: `LibOpAnyTest is OpTest`
- `testOpAnyIntegrityHappy(uint8 inputs, uint16 operandData)` -- line 26
- `testOpAnyIntegrityGas0()` -- line 36
- `testOpAnyIntegrityUnhappyZeroInputs()` -- line 49
- `_testOpAnyRun(OperandV2 operand, StackItem[] memory inputs)` -- line 57
- `testOpAnyRun(StackItem[] memory inputs, uint16 operandData)` -- line 63
- `testOpAnyRunGas0()` -- line 71
- `testOpAnyEval1TrueInput()` -- line 97
- `testOpAnyEval1FalseInput()` -- line 102
- `testOpAnyEval2TrueInputs()` -- line 108
- `testOpAnyEval2FalseInputs()` -- line 113
- `testOpAnyEval2MixedInputs()` -- line 120
- `testOpAnyEval2MixedInputs2()` -- line 127
- `testOpAnyEval2MixedInputsZeroExponent()` -- line 133
- `testOpAnyEvalFail()` -- line 138
- `testOpAnyZeroOutputs()` -- line 144
- `testOpAnyTwoOutputs()` -- line 148

#### LibOpBinaryEqualTo.t.sol
- Contract: `LibOpBinaryEqualToTest is OpTest`
- `testOpBinaryEqualToIntegrityHappy(...)` -- line 16
- `testOpBinaryEqualToRun(StackItem input1, StackItem input2)` -- line 33
- `testOpBinaryEqualToEval2ZeroInputs()` -- line 46
- `testOpBinaryEqualToEval2InputsFirstZeroSecondOne()` -- line 52
- `testOpBinaryEqualToEval2InputsFirstOneSecondZero()` -- line 58
- `testOpBinaryEqualToEval2InputsBothOne()` -- line 64
- `testOpBinaryEqualToEval2()` -- line 69
- `testOpBinaryEqualToEvalFail0Inputs()` -- line 77
- `testOpBinaryEqualToEvalFail1Input()` -- line 84
- `testOpBinaryEqualToEvalFail3Inputs()` -- line 91
- `testOpBinaryEqualToZeroOutputs()` -- line 97
- `testOpBinaryEqualToTwoOutputs()` -- line 101

#### LibOpConditions.t.sol
- Contract: `LibOpConditionsTest is OpTest`
- `testOpConditionsIntegrityHappy(...)` -- line 22
- `testOpConditionsRun(StackItem[] memory inputs, Float finalNonZero)` -- line 43
- `_testOpConditionsRunNoConditionsMet(StackItem[] memory inputs, OperandV2 operand)` -- line 67
- `testOpConditionsRunNoConditionsMet(StackItem[] memory inputs, string memory reason)` -- line 76
- `testOpConditionsEval1TrueInputZeroOutput()` -- line 107
- `testOpConditionsEval2MixedInputs()` -- line 113
- `testOpConditionsEval1FalseInputRevert()` -- line 118
- `testOpConditionsEvalErrorCode()` -- line 123
- `testOpConditionsEval1FalseInput1TrueInput()` -- line 129
- `testOpConditionsEval2TrueInputs()` -- line 135
- `testOpConditionsEval1TrueInput1FalseInput()` -- line 141
- `testOpConditionsEvalFail0Inputs()` -- line 146
- `testOpConditionsEvalFail1Inputs()` -- line 153
- `testOpConditionsEvalUnhappyOperand()` -- line 161
- `testOpConditionsZeroOutputs()` -- line 165
- `testOpConditionsTwoOutputs()` -- line 169

#### LibOpEnsure.t.sol
- Contract: `LibOpEnsureTest is OpTest`
- `testOpEnsureIntegrityHappy(...)` -- line 20
- `testOpEnsureIntegrityUnhappy(IntegrityCheckState memory state)` -- line 36
- `testOpEnsureRun(StackItem condition, string memory reason)` -- line 43
- `internalTestOpEnsureRun(StackItem condition, string memory reason)` -- line 52
- `testOpEnsureEvalZero()` -- line 63
- `testOpEnsureEvalOne()` -- line 68
- `testOpEnsureEvalThree()` -- line 73
- `testOpEnsureEvalBadOutputs()` -- line 80
- `testOpEnsureEvalBadOutputs2()` -- line 90
- `testOpEnsureEvalHappy()` -- line 101
- `testOpEnsureEvalUnhappy()` -- line 111
- `testOpEnsureEvalUnhappyOperand()` -- line 123
- `testOpEnsureOneOutput()` -- line 127

#### LibOpEqualTo.t.sol
- Contract: `LibOpEqualToTest is OpTest`
- `testOpEqualToIntegrityHappy(...)` -- line 16
- `testOpEqualToRun(StackItem input1, StackItem input2)` -- line 33
- `testOpEqualToEval2ZeroInputs()` -- line 44
- `testOpEqualToEval2InputsFirstZeroSecondOne()` -- line 50
- `testOpEqualToEval2InputsFirstOneSecondZero()` -- line 56
- `testOpEqualToEval2InputsBothOne()` -- line 62
- `testOpEqualToEval2Inputs()` -- line 67
- `testOpEqualToEvalFail0Inputs()` -- line 78
- `testOpEqualToEvalFail1Input()` -- line 85
- `testOpEqualToEvalFail3Inputs()` -- line 92
- `testOpEqualToZeroOutputs()` -- line 98
- `testOpEqualToTwoOutputs()` -- line 102

#### LibOpEvery.t.sol
- Contract: `LibOpEveryTest is OpTest`
- `testOpEveryIntegrityHappy(...)` -- line 16
- `testOpEveryIntegrityUnhappyZeroInputs(IntegrityCheckState memory state)` -- line 34
- `testOpEveryRun(StackItem[] memory inputs)` -- line 42
- `testOpEveryEval1TrueInput()` -- line 51
- `testOpEveryEval1FalseInput()` -- line 56
- `testOpEveryEval2TrueInputs()` -- line 62
- `testOpEveryEval2FalseInputs()` -- line 67
- `testOpEveryEval2MixedInputs()` -- line 73
- `testOpEveryEval2MixedInputs2()` -- line 79
- `testOpEveryEvalZeroWithExponent()` -- line 84
- `testOpEveryEvalFail()` -- line 89
- `testOpEveryZeroOutputs()` -- line 95
- `testOpEveryTwoOutputs()` -- line 99

#### LibOpGreaterThan.t.sol
- Contract: `LibOpGreaterThanTest is OpTest`
- `testOpGreaterThanIntegrityHappy(...)` -- line 16
- `testOpGreaterThanRun(StackItem input1, StackItem input2)` -- line 33
- `testOpGreaterThanEval2ZeroInputs()` -- line 46
- `testOpGreaterThanEval2InputsFirstZeroSecondOne()` -- line 52
- `testOpGreaterThanEval2InputsFirstOneSecondZero()` -- line 58
- `testOpGreaterThanEval2InputsBothOne()` -- line 64
- `testOpGreaterThanEval1_1Gt1_2()` -- line 69
- `testOpGreaterThanEval1_0Gt1()` -- line 74
- `testOpGreaterThanEvalNeg1_1GtNeg1_2()` -- line 79
- `testOpGreaterThanEvalNeg1Gt0()` -- line 84
- `testOpGreaterThanEvalFail0Inputs()` -- line 89
- `testOpGreaterThanEvalFail1Input()` -- line 96
- `testOpGreaterThanEvalFail3Inputs()` -- line 103
- `testOpGreaterThanZeroOutputs()` -- line 109
- `testOpGreaterThanTwoOutputs()` -- line 113

#### LibOpGreaterThanOrEqualTo.t.sol
- Contract: `LibOpGreaterThanOrEqualToTest is OpTest`
- `testOpGreaterThanOrEqualToIntegrityHappy(IntegrityCheckState memory state, uint8 inputs)` -- line 16
- `testOpGreaterThanOrEqualToRun(StackItem input1, StackItem input2)` -- line 26
- `testOpGreaterThanOrEqualToEval2ZeroInputs()` -- line 44
- `testOpGreaterThanOrEqualToEval2InputsFirstZeroSecondOne()` -- line 50
- `testOpGreaterThanOrEqualToEval2InputsFirstOneSecondZero()` -- line 56
- `testOpGreaterThanOrEqualToEval2InputsBothOne()` -- line 62
- `testOpGreaterThanOrEqualToEvalFail0Inputs()` -- line 67
- `testOpGreaterThanOrEqualToEvalFail1Input()` -- line 74
- `testOpGreaterThanOrEqualToEvalFail3Inputs()` -- line 81
- `testOpGreaterThanOrEqualToZeroOutputs()` -- line 87
- `testOpGreaterThanOrEqualToTwoOutputs()` -- line 91

#### LibOpIf.t.sol
- Contract: `LibOpIfTest is OpTest`
- `testOpIfIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint8 outputs, uint16 operandData)` -- line 17
- `testOpIfRun(StackItem a, StackItem b, StackItem c)` -- line 32
- `testOpIfEval3InputsFirstZeroSecondOneThirdTwo()` -- line 44
- `testOpIfEval3InputsFirstOneSecondTwoThirdThree()` -- line 50
- `testOpIfEval3InputsFirstZeroSecondZeroThirdThree()` -- line 56
- `testOpIfEval3InputsFirstOneSecondZeroThirdThree()` -- line 62
- `testOpIfEval3InputsFirstZeroSecondOneThirdZero()` -- line 68
- `testOpIfEval3InputsFirstZeroSecondZeroThirdOne()` -- line 74
- `testOpIfEval3InputsFirstTwoSecondThreeThirdFour()` -- line 80
- `testOpIfEval3InputsFirstTwoSecondZeroThirdFour()` -- line 86
- `testOpIfEvalZeroExponent()` -- line 91
- `testOpIfEvalEmptyStringTruthy()` -- line 98
- `testOpIfEvalFail0Inputs()` -- line 108
- `testOpIfEvalFail1Input()` -- line 115
- `testOpIfEvalFail2Inputs()` -- line 122
- `testOpIfEvalFail4Inputs()` -- line 129
- `testOpIfEvalZeroOutputs()` -- line 135
- `testOpIfEvalTwoOutputs()` -- line 139

#### LibOpIsZero.t.sol
- Contract: `LibOpIsZeroTest is OpTest`
- `testOpIsZeroIntegrityHappy(...)` -- line 15
- `testOpIsZeroRun(StackItem input)` -- line 32
- `testOpIsZeroEval1NonZeroInput()` -- line 41
- `testOpIsZeroEval1ZeroInput()` -- line 46
- `testOpIsZeroEval0e20Input()` -- line 51
- `testOpIsZeroEvalFail0Inputs()` -- line 56
- `testOpIsZeroEvalFail2Inputs()` -- line 63
- `testOpIsZeroZeroOutputs()` -- line 69
- `testOpIsZeroTwoOutputs()` -- line 73

#### LibOpLessThan.t.sol
- Contract: `LibOpLessThanTest is OpTest`
- `testOpLessThanIntegrityHappy(...)` -- line 16
- `testOpLessThanRun(StackItem input1, StackItem input2)` -- line 33
- `testOpLessThanEval2ZeroInputs()` -- line 44
- `testOpLessThanEval2InputsFirstZeroSecondOne()` -- line 50
- `testOpLessThanEval2InputsFirstOneSecondZero()` -- line 56
- `testOpLessThanEval2InputsBothOne()` -- line 62
- `testOpLessThan1_1Lt1_2()` -- line 67
- `testOpLessThan1_0Lt1()` -- line 72
- `testOpLessThanMinus1_1LtMinus1_2()` -- line 77
- `testOpLessThanMinus1Lt0()` -- line 82
- `testOpLessThanToEvalFail0Inputs()` -- line 87
- `testOpLessThanToEvalFail1Input()` -- line 94
- `testOpLessThanToEvalFail3Inputs()` -- line 101
- `testOpLessThanZeroOutputs()` -- line 107
- `testOpLessThanTwoOutputs()` -- line 111

#### LibOpLessThanOrEqualTo.t.sol
- Contract: `LibOpLessThanOrEqualToTest is OpTest`
- `testOpLessThanOrEqualToIntegrityHappy(...)` -- line 24
- `testOpLessThanOrEqualToRun(StackItem input1, StackItem input2)` -- line 41
- `testOpLessThanOrEqualToEval2ZeroInputs()` -- line 59
- `testOpLessThanOrEqualToEval2InputsFirstZeroSecondOne()` -- line 80
- `testOpLessThanOrEqualToEval2InputsFirstOneSecondZero()` -- line 101
- `testOpLessThanOrEqualToEval2InputsBothOne()` -- line 122
- `testOpLessThanOrEqualToEvalFail0Inputs()` -- line 142
- `testOpLessThanOrEqualToEvalFail1Input()` -- line 149
- `testOpLessThanOrEqualToEvalFail3Inputs()` -- line 156
- `testOpLessThanOrEqualToZeroOutputs()` -- line 163
- `testOpLessThanOrEqualToTwoOutputs()` -- line 167

## Coverage Summary

All 12 logic op libraries follow the standard pattern: `integrity`, `run`, and `referenceFn`. Operand handlers are all `handleOperandDisallowed` (registered in `LibAllStandardOps.sol`), meaning they have no custom operand parsing logic to test independently.

For each library, the test coverage pattern is:
- **integrity**: Tested via fuzz test with varying operand values. Covered for all 12.
- **run**: Tested via `opReferenceCheck` which compares `run` output against `referenceFn` with fuzz inputs. Covered for all 12.
- **referenceFn**: Exercised indirectly through `opReferenceCheck`. Covered for all 12.
- **Eval integration tests**: Parse-from-string eval tests covering basic cases. Present for all 12.
- **Bad input counts**: Tests that wrong number of inputs fails integrity. Present for all 12.
- **Bad output counts**: Tests that wrong number of outputs fails. Present for all 12.

## Findings

### A23-1: LibOpGreaterThanOrEqualTo missing negative number and float equality eval tests
**Severity:** LOW

`LibOpGreaterThanOrEqualTo.t.sol` tests only four basic eval cases (0,0), (0,1), (1,0), (1,1). It lacks eval-level tests for:
- Negative numbers (e.g., `greater-than-or-equal-to(-1 0)`, `greater-than-or-equal-to(-1.1 -1.2)`)
- Float equivalence across representations (e.g., `greater-than-or-equal-to(1.0 1)`)

By contrast, `LibOpGreaterThan.t.sol` includes `testOpGreaterThanEval1_1Gt1_2`, `testOpGreaterThanEvalNeg1_1GtNeg1_2`, `testOpGreaterThanEvalNeg1Gt0`, and `testOpGreaterThanEval1_0Gt1`. The fuzz test via `opReferenceCheck` does exercise these paths with random inputs, but explicit named test cases for negative numbers and float-representation equality are missing for GTE.

### A23-2: LibOpLessThanOrEqualTo missing negative number and float equality eval tests
**Severity:** LOW

`LibOpLessThanOrEqualTo.t.sol` tests only four basic eval cases (0,0), (0,1), (1,0), (1,1). It lacks eval-level tests for:
- Negative numbers (e.g., `less-than-or-equal-to(-1 0)`, `less-than-or-equal-to(-1.1 -1.2)`)
- Float equivalence across representations (e.g., `less-than-or-equal-to(1.0 1)`)

By contrast, `LibOpLessThan.t.sol` includes `testOpLessThan1_1Lt1_2`, `testOpLessThanMinus1_1LtMinus1_2`, `testOpLessThanMinus1Lt0`, and `testOpLessThan1_0Lt1`. The fuzz test via `opReferenceCheck` does exercise these paths with random inputs, but explicit named test cases for negative numbers and float-representation equality are missing for LTE.

### A23-3: LibOpConditions no test for exactly 2 inputs (minimum case)
**Severity:** LOW

`LibOpConditions.integrity` enforces a minimum of 2 inputs (line 22: `inputs = inputs > 2 ? inputs : 2`). The test `testOpConditionsIntegrityHappy` covers all operand values 0-15 via fuzzing, but the `testOpConditionsRun` fuzz test filters out arrays shorter than 2 (`vm.assume(inputs.length > 1)`) and then truncates odd-length arrays to even length. This means the minimum case of exactly 2 inputs is covered only when the fuzzer happens to produce length 2.

The eval tests do exercise 2 inputs explicitly (e.g., `testOpConditionsEval1TrueInputZeroOutput` with `conditions(5 0)`), so the basic case is covered. However, there is no fuzz test that directly targets the 2-input boundary via `opReferenceCheck` with a guaranteed 2-element array.

### A23-4: LibOpConditions odd-input revert path with reason string not tested via opReferenceCheck
**Severity:** LOW

In `LibOpConditions.run` (line 33-70), when the input count is odd, the last item is treated as a reason string for the revert message. The `testOpConditionsRunNoConditionsMet` test does exercise this path with random reason strings. However, the `testOpConditionsRun` test forces the final condition to be nonzero to avoid errors, meaning the odd-input + revert path is only tested in `testOpConditionsRunNoConditionsMet` and the eval test `testOpConditionsEvalErrorCode`. This is adequate coverage for the revert path but could be more systematic.

### A23-5: LibOpAny and LibOpEvery missing operand disallowed test
**Severity:** INFO

`LibOpAny.t.sol` and `LibOpEvery.t.sol` do not include a test verifying that providing an operand (e.g., `any<1>(5)` or `every<1>(5)`) causes parsing to fail. Other logic ops like `LibOpConditions` and `LibOpEnsure` include `testOpConditionsEvalUnhappyOperand` / `testOpEnsureEvalUnhappyOperand` which verify `UnexpectedOperand` is reverted. `LibOpAny` and `LibOpEvery` use `handleOperandDisallowed` in `LibAllStandardOps`, but no test explicitly verifies this reject behavior for these two ops.

The remaining logic ops (`LibOpBinaryEqualTo`, `LibOpEqualTo`, `LibOpGreaterThan`, `LibOpGreaterThanOrEqualTo`, `LibOpIf`, `LibOpIsZero`, `LibOpLessThan`, `LibOpLessThanOrEqualTo`) also lack this explicit operand-disallowed test, making this a general pattern gap across most logic ops. Only `LibOpConditions` and `LibOpEnsure` test it.

### A23-6: LibOpAny no test for max inputs (15)
**Severity:** INFO

`LibOpAny.run` uses a 4-bit operand field (`& 0x0F`) to determine the number of inputs, capping at 15. There are no eval-level tests exercising the maximum 15-input boundary. The fuzz test `testOpAnyRun` bounds `inputs.length` to `<= 0x0F` so it may randomly hit 15, but there is no deterministic test for this boundary. The same applies to `LibOpEvery` and `LibOpConditions` which also use the 4-bit input field.

### A23-7: LibOpLessThanOrEqualTo uses verbose inline eval pattern instead of checkHappy
**Severity:** INFO

`LibOpLessThanOrEqualTo.t.sol` uses a verbose manual `I_DEPLOYER.parse2` + `I_INTERPRETER.eval4` pattern for its eval tests (lines 59-138) while all other logic op tests use the concise `checkHappy` helper. This is a consistency observation rather than a coverage gap -- the tests cover the same scenarios. However, the verbose pattern is harder to maintain and review compared to the one-liner `checkHappy` calls.
