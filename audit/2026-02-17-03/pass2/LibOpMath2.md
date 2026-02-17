# Pass 2: Test Coverage - Math Operations Part 2

Agent: A25
Audit: 2026-02-17-03

## Evidence of Thorough Reading

### Source Files

**LibOpHeadroom.sol** (`src/lib/op/math/LibOpHeadroom.sol`)
- Library: `LibOpHeadroom`
- `integrity` (line 18): returns (1, 1)
- `run` (line 25): loads 1 value, computes ceil(a) - a, if zero sets to FLOAT_ONE
- `referenceFn` (line 42): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpInv.sol** (`src/lib/op/math/LibOpInv.sol`)
- Library: `LibOpInv`
- `integrity` (line 17): returns (1, 1)
- `run` (line 24): loads 1 value, computes a.inv()
- `referenceFn` (line 38): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMax.sol** (`src/lib/op/math/LibOpMax.sol`)
- Library: `LibOpMax`
- `integrity` (line 17): reads input count from operand bits 16-19, minimum 2, returns (inputs, 1)
- `run` (line 26): loads first 2 values, loops for additional inputs, returns max
- `referenceFn` (line 59): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMaxNegativeValue.sol** (`src/lib/op/math/LibOpMaxNegativeValue.sol`)
- Library: `LibOpMaxNegativeValue`
- `integrity` (line 17): returns (0, 1)
- `run` (line 22): pushes FLOAT_MAX_NEGATIVE_VALUE onto stack
- `referenceFn` (line 32): reference using packLossless(-1, type(int32).min)
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMaxPositiveValue.sol** (`src/lib/op/math/LibOpMaxPositiveValue.sol`)
- Library: `LibOpMaxPositiveValue`
- `integrity` (line 17): returns (0, 1)
- `run` (line 22): pushes FLOAT_MAX_POSITIVE_VALUE onto stack
- `referenceFn` (line 32): reference using packLossless(type(int224).max, type(int32).max)
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMin.sol** (`src/lib/op/math/LibOpMin.sol`)
- Library: `LibOpMin`
- `integrity` (line 17): reads input count from operand bits 16-19, minimum 2, returns (inputs, 1)
- `run` (line 26): loads first 2 values, loops for additional inputs, returns min
- `referenceFn` (line 60): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMinNegativeValue.sol** (`src/lib/op/math/LibOpMinNegativeValue.sol`)
- Library: `LibOpMinNegativeValue`
- `integrity` (line 17): returns (0, 1)
- `run` (line 22): pushes FLOAT_MIN_NEGATIVE_VALUE onto stack
- `referenceFn` (line 32): reference using packLossless(type(int224).min, type(int32).max)
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMinPositiveValue.sol** (`src/lib/op/math/LibOpMinPositiveValue.sol`)
- Library: `LibOpMinPositiveValue`
- `integrity` (line 17): returns (0, 1)
- `run` (line 22): pushes FLOAT_MIN_POSITIVE_VALUE onto stack
- `referenceFn` (line 32): reference using packLossless(1, type(int32).min)
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpMul.sol** (`src/lib/op/math/LibOpMul.sol`)
- Library: `LibOpMul`
- `integrity` (line 18): reads input count from operand bits 16-19, minimum 2, returns (inputs, 1)
- `run` (line 26): loads first 2 values, multiplies via LibDecimalFloatImplementation.mul, loops for additional, packLossy result
- `referenceFn` (line 66): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpPow.sol** (`src/lib/op/math/LibOpPow.sol`)
- Library: `LibOpPow`
- `integrity` (line 17): returns (2, 1)
- `run` (line 24): loads 2 values, computes a.pow(b, LOG_TABLES_ADDRESS), `view` function
- `referenceFn` (line 41): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpSqrt.sol** (`src/lib/op/math/LibOpSqrt.sol`)
- Library: `LibOpSqrt`
- `integrity` (line 17): returns (1, 1)
- `run` (line 24): loads 1 value, computes a.sqrt(LOG_TABLES_ADDRESS), `view` function
- `referenceFn` (line 38): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpSub.sol** (`src/lib/op/math/LibOpSub.sol`)
- Library: `LibOpSub`
- `integrity` (line 18): reads input count from operand bits 16-19, minimum 2, returns (inputs, 1)
- `run` (line 26): loads first 2 values, subtracts via LibDecimalFloatImplementation.sub, loops for additional, packLossy result
- `referenceFn` (line 66): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandSingleFull` (not disallowed -- sub accepts operand)

**LibOpExponentialGrowth.sol** (`src/lib/op/math/growth/LibOpExponentialGrowth.sol`)
- Library: `LibOpExponentialGrowth`
- `integrity` (line 18): returns (3, 1)
- `run` (line 24): loads 3 values (base, rate, t), computes base * (rate + 1)^t, `view` function
- `referenceFn` (line 43): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

**LibOpLinearGrowth.sol** (`src/lib/op/math/growth/LibOpLinearGrowth.sol`)
- Library: `LibOpLinearGrowth`
- `integrity` (line 18): returns (3, 1)
- `run` (line 24): loads 3 values (base, rate, t), computes base + rate * t
- `referenceFn` (line 44): reference implementation matching run logic
- No errors/events/structs defined
- Operand handler: `handleOperandDisallowed`

### Test Files

**LibOpHeadroom.t.sol** - Contract: `LibOpHeadroomTest`
- `testOpHeadroomIntegrity` (line 14): fuzz test integrity returns (1,1)
- `testOpHeadroomRun` (line 21): fuzz test runtime via opReferenceCheck
- `testOpHeadroomEval` (line 32): eval tests for various values including negatives
- `testOpHeadroomZeroInputs` (line 48): checkBadInputs 0 inputs
- `testOpHeadroomTwoInputs` (line 52): checkBadInputs 2 inputs
- `testOpHeadroomZeroOutputs` (line 56): checkBadOutputs 0 outputs
- `testOpHeadroomTwoOutputs` (line 60): checkBadOutputs 2 outputs
- `testOpHeadroomEvalOperandDisallowed` (line 65): operand disallowed

**LibOpInv.t.sol** - Contract: `LibOpInvTest`
- `testOpInvIntegrity` (line 14): fuzz test integrity returns (1,1)
- `testOpInvRun` (line 21): fuzz test runtime (excludes zero)
- `testOpInvEval` (line 36): eval tests for inv(1), inv(0.5), inv(2), inv(3)
- `testOpInvZeroInputs` (line 52): checkBadInputs 0 inputs
- `testOpInvTwoInputs` (line 56): checkBadInputs 2 inputs
- `testOpInvZeroOutputs` (line 60): checkBadOutputs 0 outputs
- `testOpInvTwoOutputs` (line 64): checkBadOutputs 2 outputs
- `testOpExpEvalOperandDisallowed` (line 69): operand disallowed (note: misnamed as Exp)

**LibOpMax.t.sol** - Contract: `LibOpMaxTest`
- `testOpMaxIntegrityHappy` (line 16): fuzz test integrity for 2-15 inputs
- `testOpMaxIntegrityUnhappyZeroInputs` (line 26): integrity with 0 inputs
- `testOpMaxIntegrityUnhappyOneInput` (line 35): integrity with 1 input
- `testOpMaxRun` (line 44): fuzz test runtime via opReferenceCheck
- `testOpMaxEvalZeroInputs` (line 53): eval with 0 inputs
- `testOpMaxEvalOneInput` (line 58): eval with 1 input
- `testOpMaxEvalTwoOutputs` (line 65): checkBadOutputs 2 outputs
- `testOpMaxEval2InputsHappy` (line 70): eval 2 inputs including negatives
- `testOpMaxEval3InputsHappy` (line 113): eval 3 inputs comprehensive
- `testOpMaxEvalOperandDisallowed` (line 193): operand disallowed

**LibOpMaxNegativeValue.t.sol** - Contract: `LibOpMaxNegativeValueTest`
- `testOpMaxValueIntegrity` (line 20): fuzz test integrity returns (0,1)
- `testOpMaxNegativeValueRun` (line 35): runtime reference check
- `testOpMaxNegativeValueEval` (line 50): eval produces expected constant
- `testOpMaxNegativeValueEvalFail` (line 55): 1 input fails integrity
- `testOpMaxNegativeValueZeroOutputs` (line 61): checkBadOutputs 0 outputs
- `testOpMaxNegativeValueTwoOutputs` (line 65): checkBadOutputs 2 outputs

**LibOpMaxPositiveValue.t.sol** - Contract: `LibOpMaxPositiveValueTest`
- `testOpMaxPositiveValueIntegrity` (line 20): fuzz test integrity returns (0,1)
- `testOpMaxPositiveValueRun` (line 37): runtime reference check
- `testOpMaxPositiveValueEval` (line 52): eval produces expected constant
- `testOpMaxPositiveValueEvalFail` (line 57): 1 input fails integrity
- `testOpMaxPositiveValueZeroOutputs` (line 63): checkBadOutputs 0 outputs
- `testOpMaxPositiveValueTwoOutputs` (line 67): checkBadOutputs 2 outputs

**LibOpMin.t.sol** - Contract: `LibOpMinTest`
- `testOpMinIntegrityHappy` (line 14): fuzz test integrity for 2-15 inputs
- `testOpMinIntegrityUnhappyZeroInputs` (line 24): integrity with 0 inputs
- `testOpMinIntegrityUnhappyOneInput` (line 33): integrity with 1 input
- `testOpMinRun` (line 42): fuzz test runtime via opReferenceCheck
- `testOpMinEvalZeroInputs` (line 51): eval with 0 inputs
- `testOpMinEvalOneInput` (line 56): eval with 1 input
- `testOpMinEval2InputsHappy` (line 64): eval 2 inputs including negatives
- `testOpMinEval3InputsHappy` (line 103): eval 3 inputs comprehensive
- `testOpMinEvalOperandDisallowed` (line 257): operand disallowed

**LibOpMinNegativeValue.t.sol** - Contract: `LibOpMinNegativeValueTest`
- `testOpMinNegativeValueIntegrity` (line 20): fuzz test integrity returns (0,1)
- `testOpMinNegativeValueRun` (line 37): runtime reference check
- `testOpMinNegativeValueEval` (line 52): eval produces expected constant
- `testOpMinNegativeValueEvalFail` (line 57): 1 input fails integrity
- `testOpMinNegativeValueZeroOutputs` (line 63): checkBadOutputs 0 outputs
- `testOpMinNegativeValueTwoOutputs` (line 67): checkBadOutputs 2 outputs

**LibOpMinPositiveValue.t.sol** - Contract: `LibOpMinPositiveValueTest`
- `testOpMinPositiveValueIntegrity` (line 20): fuzz test integrity returns (0,1)
- `testOpMinPositiveValueRun` (line 37): runtime reference check
- `testOpMinPositiveValueEval` (line 52): eval produces expected constant
- `testOpMinPositiveValueEvalFail` (line 57): 1 input fails integrity
- `testOpMinPositiveValueZeroOutputs` (line 63): checkBadOutputs 0 outputs
- `testOpMinPositiveValueTwoOutputs` (line 67): checkBadOutputs 2 outputs

**LibOpMul.t.sol** - Contract: `LibOpMulTest`
- `testOpMulIntegrityHappy` (line 16): fuzz test integrity for 2-15 inputs
- `testOpMulIntegrityUnhappyZeroInputs` (line 26): integrity with 0 inputs
- `testOpDecimal18MulIntegrityUnhappyOneInput` (line 35): integrity with 1 input (note: misnamed with Decimal18)
- `_testOpMulRun` (line 43): helper for fuzz test
- `testOpMulRun` (line 50): fuzz test runtime, catches CoefficientOverflow/ExponentOverflow
- `testOpMulEvalZeroInputs` (line 67): eval with 0 inputs
- `testOpMulEvalOneInput` (line 72): eval with 1 input
- `testOpMulZeroOutputs` (line 80): checkBadOutputs 0 outputs
- `testOpMulTwoOutputs` (line 84): checkBadOutputs 2 outputs
- `testOpMulEvalTwoInputsHappy` (line 91): eval 2 inputs happy path
- `testOpMulEvalTwoInputsUnhappyOverflow` (line 113): overflow test 2 inputs
- `testOpMulEvalThreeInputsHappy` (line 124): eval 3 inputs happy path
- `testOpMulEvalThreeInputsUnhappyOverflow` (line 149): overflow test 3 inputs
- `testOpMulEvalOperandsDisallowed` (line 159): operand disallowed

**LibOpPow.t.sol** - Contract: `LibOpPowTest`
- `beforeOpTestConstructor` (line 13): forks mainnet for log tables
- `testOpPowIntegrity` (line 19): fuzz test integrity returns (2,1)
- `testOpPowRun` (line 26): fuzz test runtime with bounded inputs
- `testOpPowEval` (line 47): eval tests for various powers
- `testOpPowNegativeBaseError` (line 72): tests PowNegativeBase error
- `testOpPowEvalOneInput` (line 80): checkBadInputs 1 input
- `testOpPowThreeInputs` (line 84): checkBadInputs 3 inputs
- `testOpPowZeroOutputs` (line 88): checkBadOutputs 0 outputs
- `testOpPowTwoOutputs` (line 92): checkBadOutputs 2 outputs
- `testOpPowEvalOperandDisallowed` (line 97): operand disallowed

**LibOpSqrt.t.sol** - Contract: `LibOpSqrtTest`
- `beforeOpTestConstructor` (line 14): forks mainnet for log tables
- `testOpSqrtIntegrity` (line 20): fuzz test integrity returns (1,1)
- `testOpSqrtRun` (line 27): fuzz test runtime (takes abs of input)
- `testOpSqrtEvalExamples` (line 40): eval tests for 0, 1, 0.5, 2, 2.5
- `testOpSqrtEvalBad` (line 55): checkBadInputs 0 and 2 inputs
- `testOpSqrtEvalZeroOutputs` (line 60): checkBadOutputs 0 outputs
- `testOpSqrtEvalTwoOutputs` (line 64): checkBadOutputs 2 outputs
- `testOpSqrtEvalOperandDisallowed` (line 69): operand disallowed

**LibOpSub.t.sol** - Contract: `LibOpSubTest`
- `testOpSubIntegrityHappy` (line 14): fuzz test integrity for 2-15 inputs
- `testOpSubIntegrityUnhappyZeroInputs` (line 24): integrity with 0 inputs
- `testOpSubIntegrityUnhappyOneInput` (line 33): integrity with 1 input
- `testOpSubRun` (line 42): fuzz test runtime via opReferenceCheck
- `testOpSubEvalZeroInputs` (line 62): eval with 0 inputs
- `testOpSubEvalOneInput` (line 67): eval with 1 input
- `testOpSubEvalTwoInputs` (line 75): eval 2 inputs with various values
- `testOpSubEvalThreeInputs` (line 102): eval 3 inputs

**LibOpExponentialGrowth.t.sol** - Contract: `LibOpExponentialGrowthTest`
- `beforeOpTestConstructor` (line 12): forks mainnet for log tables
- `testOpExponentialGrowthIntegrity` (line 18): fuzz test integrity returns (3,1)
- `testOpExponentialGrowthRun` (line 25): fuzz test runtime with bounded inputs
- `testOpExponentialGrowthEval` (line 65): eval tests for various growth scenarios including negative t
- `testOpExponentialGrowthEvalZeroInputs` (line 108): checkBadInputs 0 inputs
- `testOpExponentialGrowthEvalOneInput` (line 112): checkBadInputs 1 input
- `testOpExponentialGrowthEvalTwoInputs` (line 116): checkBadInputs 2 inputs
- `testOpExponentialGrowthEvalFourInputs` (line 120): checkBadInputs 4 inputs
- `testOpExponentialGrowthEvalZeroOutputs` (line 124): checkBadOutputs 0 outputs
- `testOpExponentialGrowthEvalTwoOutputs` (line 128): checkBadOutputs 2 outputs
- `testOpExponentialGrowthEvalOperandDisallowed` (line 133): operand disallowed

**LibOpLinearGrowth.t.sol** - Contract: `LibOpLinearGrowthTest`
- `testOpLinearGrowthIntegrity` (line 14): fuzz test integrity returns (3,1)
- `testOpLinearGrowthRun` (line 21): fuzz test runtime with bounded exponents
- `testOpLinearGrowthEval` (line 53): eval tests for various growth scenarios including negatives
- `testOpLinearGrowthEvalZeroInputs` (line 77): checkBadInputs 0 inputs
- `testOpLinearGrowthEvalOneInput` (line 81): checkBadInputs 1 input
- `testOpLinearGrowthEvalTwoInputs` (line 85): checkBadInputs 2 inputs
- `testOpLinearGrowthEvalFourInputs` (line 89): checkBadInputs 4 inputs
- `testOpLinearGrowthEvalZeroOutputs` (line 93): checkBadOutputs 0 outputs
- `testOpLinearGrowthEvalTwoOutputs` (line 97): checkBadOutputs 2 outputs
- `testOpLinearGrowthEvalOperandDisallowed` (line 102): operand disallowed

---

## Findings

### A25-1: LibOpInv missing test for division by zero (inv(0))

**Severity: LOW**

The fuzz test `testOpInvRun` explicitly excludes zero inputs via `vm.assume(!LibDecimalFloat.isZero(a))`. There is no dedicated test that verifies `inv(0)` reverts with the expected error. The division-by-zero error path in the underlying `Float.inv()` is untested from the opcode level.

**File:** `test/src/lib/op/math/LibOpInv.t.sol`

### A25-2: LibOpSub missing zero outputs and two outputs tests

**Severity: LOW**

LibOpSub test file has no `checkBadOutputs` tests for zero outputs or two outputs. Every other N-ary math op (mul, max, min) and every unary math op (headroom, inv, pow, sqrt) tests these cases. The sub test is missing:
- `testOpSubZeroOutputs` (equivalent to `checkBadOutputs(": sub(1 1);", 2, 1, 0)`)
- `testOpSubTwoOutputs` (equivalent to `checkBadOutputs("_ _: sub(1 1);", 2, 1, 2)`)

**File:** `test/src/lib/op/math/LibOpSub.t.sol`

### A25-3: LibOpSub missing operand handler test

**Severity: LOW**

LibOpSub uses `handleOperandSingleFull` as its operand handler in `LibAllStandardOps.sol` (line 512), meaning it accepts a single operand value. However, the test file has no test exercising or verifying the operand behavior -- it does not test what happens when an operand is provided (e.g., `sub<1>(2 1)`) nor does it test what the operand value controls. This is unlike every other N-ary op in this group which tests `checkDisallowedOperand`.

**File:** `test/src/lib/op/math/LibOpSub.t.sol`

### A25-4: LibOpMin missing zero outputs and two outputs tests

**Severity: LOW**

LibOpMin test file has no `checkBadOutputs` tests for zero or two outputs. The max test has `testOpMaxEvalTwoOutputs` but is also missing a zero-outputs test. The min test has neither.

Missing from LibOpMin:
- `testOpMinZeroOutputs`
- `testOpMinTwoOutputs`

**File:** `test/src/lib/op/math/LibOpMin.t.sol`

### A25-5: LibOpMax missing zero outputs test

**Severity: LOW**

LibOpMax test has `testOpMaxEvalTwoOutputs` (line 65) but is missing a zero-outputs test (`checkBadOutputs(": max(0 0);", 2, 1, 0)`).

**File:** `test/src/lib/op/math/LibOpMax.t.sol`

### A25-6: LibOpSqrt missing test for negative input error path

**Severity: LOW**

The fuzz test `testOpSqrtRun` takes `abs(a)` before testing (line 30), ensuring only non-negative values are tested at runtime. There is no dedicated test that verifies `sqrt(-1)` or other negative inputs properly revert. If the underlying `Float.sqrt()` has a negative-input error path, it is not exercised from the opcode test level.

**File:** `test/src/lib/op/math/LibOpSqrt.t.sol`

### A25-7: LibOpMaxNegativeValue, LibOpMaxPositiveValue, LibOpMinNegativeValue, LibOpMinPositiveValue missing operand-disallowed tests

**Severity: INFO**

All four constant-value opcodes use `handleOperandDisallowed` in `LibAllStandardOps.sol`, but none of their test files include a `checkUnhappyParse` or `checkDisallowedOperand` test verifying that providing an operand (e.g., `max-negative-value<0>()`) is correctly rejected. The operand handler is tested indirectly through the parser, but explicit tests exist for all other ops in this group and are missing here.

**Files:**
- `test/src/lib/op/math/LibOpMaxNegativeValue.t.sol`
- `test/src/lib/op/math/LibOpMaxPositiveValue.t.sol`
- `test/src/lib/op/math/LibOpMinNegativeValue.t.sol`
- `test/src/lib/op/math/LibOpMinPositiveValue.t.sol`

### A25-8: LibOpPow missing test for zero inputs

**Severity: INFO**

LibOpPow has `testOpPowEvalOneInput` and `testOpPowThreeInputs` for bad input counts, but does not test zero inputs (`checkBadInputs("_: power();", 0, 2, 0)`). This is a minor gap as the pattern of testing zero inputs is followed by most other ops.

**File:** `test/src/lib/op/math/LibOpPow.t.sol`
