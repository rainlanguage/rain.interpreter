# Pass 2: Math Opcodes Test Coverage

Audit namespace: `audit/2026-03-04-01`

## Summary

Reviewed 23 math opcode source files (`src/lib/op/math/LibOp*.sol`) and their
corresponding test files (`test/src/lib/op/math/LibOp*.t.sol`).

Each source exposes three functions: `integrity`, `run`, `referenceFn`.
Every test file covers all three via `opReferenceCheck` (fuzz), `checkHappy`
(eval examples), `checkBadInputs`/`checkBadOutputs` (integrity rejects), and
`checkUnhappyParse`/`checkDisallowedOperand` (operand rejection).

All 23 opcodes have complete structural coverage (integrity, run/reference fuzz,
eval examples, bad inputs/outputs, operand disallowed). The gaps below are
missing edge-case eval examples in specific opcodes.

---

## A69 LibOpAbs

**Source:** `src/lib/op/math/LibOpAbs.sol` (lines 13-53)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): absolute value via `a.abs()`
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpAbs.t.sol`
- `testOpAbsIntegrity`: fuzz integrity check
- `testOpAbsRun`: fuzz run vs reference (bounds coefficient > int224.min)
- `testOpAbsEval`: examples for 0, 1, -1, 0.5, -0.5, 2, -2
- `testOpAbsZeroInputs`, `testOpAbsTwoInputs`: bad inputs
- `testOpAbsZeroOutputs`, `testOpAbsTwoOutputs`: bad outputs
- `testOpAbsEvalOperandDisallowed`: operand rejection

**Gaps:** None.

---

## A70 LibOpAdd

**Source:** `src/lib/op/math/LibOpAdd.sol` (lines 15-98)
- `integrity` (line 22): n-ary, minimum 2 inputs, 1 output
- `run` (line 33): iterative add with unpacked intermediates
- `referenceFn` (line 76): reference implementation

**Test:** `test/src/lib/op/math/LibOpAdd.t.sol`
- `testOpAddIntegrityHappy`: fuzz 2-15 inputs
- `testOpAddIntegrityUnhappyZeroInputs`, `testOpAddIntegrityUnhappyOneInput`: min-clamp
- `testOpAddRun`: fuzz run vs reference
- `testOpAddEval2InputsHappyExamples`: positive, negative, mixed-sign, cancellation
- `testOpAddEval2InputsHappyZero`, `testOpAddEval2InputsHappyZeroOne`, `testOpAddEval2InputsHappyZeroMax`: edge values
- `testOpAddEval3InputsHappy`, `testOpAddEval3InputsUnhappy`: 3-input happy/overflow
- `testOpAddEvalZeroInputs`, `testOpAddEvalOneInput`: bad inputs
- `testOpAddEvalZeroOutputs`, `testOpAddEvalTwoOutput`: bad outputs
- `testOpAddEvalOperandDisallowed`: operand rejection

**Gaps:** None.

---

## A71 LibOpAvg

**Source:** `src/lib/op/math/LibOpAvg.sol` (lines 13-61)
- `integrity` (line 19): 2 inputs, 1 output
- `run` (line 28): `(a + b) / 2`
- `referenceFn` (line 47): reference implementation

**Test:** `test/src/lib/op/math/LibOpAvg.t.sol`
- `testOpAvgIntegrity`: fuzz integrity
- `testOpAvgRun`: fuzz run vs reference (bounded exponents)
- `testOpAvgEvalExamples`: (0,0), (0,1), (1,0), (1,1), (1,2), (2,2), (2,3), (2,4), (4,0.5)
- `testOpAvgEvalOneInput`, `testOpAvgEvalThreeInputs`: bad inputs
- `testOpAvgEvalZeroOutputs`, `testOpAvgEvalTwoOutputs`: bad outputs
- `testOpAvgEvalOperandDisallowed`: operand rejection

### Finding A71-1 (LOW): No negative-value eval examples for avg

The fuzz test covers negative values via random coefficients, but there are no
deterministic eval examples with negative inputs. Avg of negative values
exercises a different code path in the underlying float add. Examples like
`avg(-2 -4) = -3` and `avg(-1 1) = 0` would provide deterministic coverage.

---

## A72 LibOpCeil

**Source:** `src/lib/op/math/LibOpCeil.sol` (lines 13-55)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `a.ceil()`
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpCeil.t.sol`
- `testOpCeilIntegrity`: fuzz integrity
- `testOpCeilRun`: fuzz run vs reference
- `testOpCeilEval`: 0, 1, 0.5, 2, 2.5 (positive); -1, -1.1, -0.5, -1.5, -2, -2.5 (negative); max-positive-value, min-negative-value
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A73 LibOpDiv

**Source:** `src/lib/op/math/LibOpDiv.sol` (lines 14-107)
- `integrity` (line 21): n-ary, minimum 2 inputs, 1 output
- `run` (line 33): iterative div with unpacked intermediates
- `referenceFn` (line 74): reference with division-by-zero sentinel

**Test:** `test/src/lib/op/math/LibOpDiv.t.sol`
- `testOpDivIntegrityHappy`, `testOpDivIntegrityUnhappyZeroInputs`, `testOpDivIntegrityUnhappyOneInput`: integrity
- `testOpDivRun`: fuzz run vs reference with overflow/div-by-zero detection
- `testOpDivEvalTwoInputsHappy`: 0/1, 1/1, 1/2, 2/1, 2/2, 2/0.1, max/1
- `testOpDivEvalTwoInputsUnhappyDivZero`: 0/0, 1/0, max/0
- `testOpDivEvalTwoInputsUnhappyOverflow`: max/1e-18
- `testOpDivEvalThreeInputsHappy`, `testOpDivEvalThreeInputsUnhappyExamples`, `testOpDivEvalThreeInputsUnhappyOverflow`: 3-input
- Bad inputs/outputs/operand tests present

### Finding A73-1 (LOW): No negative-value eval examples for div

No deterministic eval examples exercise `div` with negative operands. The fuzz
test covers this path probabilistically, but examples like `div(-6 3) = -2` and
`div(6 -3) = -2` would provide deterministic coverage of sign handling.

---

## A74 LibOpE

**Source:** `src/lib/op/math/LibOpE.sol` (lines 13-44)
- `integrity` (line 17): 0 inputs, 1 output
- `run` (line 24): pushes `FLOAT_E` constant
- `referenceFn` (line 35): reference implementation

**Test:** `test/src/lib/op/math/LibOpE.t.sol`
- `testOpEIntegrity`: fuzz integrity
- `testOpERun`: fuzz run vs reference
- `testOpEEval`: full eval check, value matches `FLOAT_E`
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A75 LibOpExp

**Source:** `src/lib/op/math/LibOpExp.sol` (lines 13-56)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `e.pow(a, LOG_TABLES_ADDRESS)`
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpExp.t.sol`
- `testOpExpIntegrity`: fuzz integrity
- `testOpExpRun`: fuzz run vs reference (bounded [0..10000], exponent [-10..5])
- `testOpExpEvalExample`: e^0=1, e^1, e^0.5, e^2, e^3
- `testOpExpEvalNegativeInput`: e^(-1) = 1/e
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A76 LibOpExp2

**Source:** `src/lib/op/math/LibOpExp2.sol` (lines 13-57)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `2.pow(a, LOG_TABLES_ADDRESS)`
- `referenceFn` (line 45): reference implementation

**Test:** `test/src/lib/op/math/LibOpExp2.t.sol`
- `testOpExp2Integrity`: fuzz integrity
- `testOpExp2Run`: fuzz run vs reference (bounded [0..10000], exponent [-10..5])
- `testOpExp2EvalExample`: 2^0=1, 2^1=2, 2^0.5, 2^2=4, 2^3=8
- `testOpExp2EvalNegativeInput`: 2^(-1) = 0.5
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A77 LibOpFloor

**Source:** `src/lib/op/math/LibOpFloor.sol` (lines 13-53)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `a.floor()`
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpFloor.t.sol`
- `testOpFloorIntegrity`: fuzz integrity
- `testOpFloorRun`: fuzz run vs reference
- `testOpFloorEval`: 0, 1, 0.5, 2, 3, 3.8
- `testOpFloorEvalNegative`: -1, -1.1, -0.5, -1.5, -2, -2.5
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A78 LibOpFrac

**Source:** `src/lib/op/math/LibOpFrac.sol` (lines 13-53)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `a.frac()`
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpFrac.t.sol`
- `testOpFracIntegrity`: fuzz integrity
- `testOpFracRun`: fuzz run vs reference
- `testOpFracEval`: 0, 1, 0.5, 2, 3, 3.8, -0.5, 1.5e10
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A79 LibOpGm

**Source:** `src/lib/op/math/LibOpGm.sol` (lines 15-74)
- `integrity` (line 21): 2 inputs, 1 output
- `run` (line 31): `sign * sqrt(|a| * |b|)`
- `referenceFn` (line 55): reference implementation

**Test:** `test/src/lib/op/math/LibOpGm.t.sol`
- `testOpGmIntegrity`: fuzz integrity
- `testOpGmRun`: fuzz run vs reference (bounded [-10000..10000])
- `testOpGmEval`: (0,0), (0,1), (1,0), (1,1), (1,2), (2,2), (2,3), (2,4), (4,0.5)
- `testOpGmEvalMixedSignsNegativeFirst`: gm(-1, 1) = -1
- `testOpGmEvalMixedSignsNegativeSecond`: gm(1, -1) = -1
- `testOpGmEvalMixedSignsNonUnit`: gm(-2, 3) = -sqrt(6)
- `testOpGmEvalBothNegativeEqual`: gm(-1, -1) = 1
- `testOpGmEvalBothNegativeUnequal`: gm(-2, -3) = sqrt(6)
- `testOpGmEvalZeroWithNegative`, `testOpGmEvalNegativeWithZero`: zero with negative
- `testOpGmEvalZeroBytesIdentical`: canonical zero bytes
- Bad inputs/outputs/operand tests present

**Gaps:** None. Excellent coverage of all sign combinations.

---

## A80 LibOpHeadroom

**Source:** `src/lib/op/math/LibOpHeadroom.sol` (lines 14-65)
- `integrity` (line 20): 1 input, 1 output
- `run` (line 30): `ceil(x) - x`, returns 1 when x is integer
- `referenceFn` (line 49): reference implementation

**Test:** `test/src/lib/op/math/LibOpHeadroom.t.sol`
- `testOpHeadroomIntegrity`: fuzz integrity
- `testOpHeadroomRun`: fuzz run vs reference
- `testOpHeadroomEval`: 0, 1, 0.5, 2, 3, 3.8 (positive); -1, -0.5, -2, -3, -3.8 (negative)
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A81 LibOpInv

**Source:** `src/lib/op/math/LibOpInv.sol` (lines 13-53)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `a.inv()` (1/a)
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpInv.t.sol`
- `testOpInvIntegrity`: fuzz integrity
- `testOpInvRun`: fuzz run vs reference (excludes zero)
- `testOpInvEval`: inv(1), inv(0.5), inv(2), inv(3)
- `testOpInvEvalNegative`: inv(-1), inv(-2)
- `testOpInvEvalDivisionByZero`: inv(0) reverts
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A82 LibOpMax

**Source:** `src/lib/op/math/LibOpMax.sol` (lines 13-79)
- `integrity` (line 20): n-ary, minimum 2 inputs, 1 output
- `run` (line 32): iterative `a.max(b)`
- `referenceFn` (line 67): reference implementation

**Test:** `test/src/lib/op/math/LibOpMax.t.sol`
- `testOpMaxIntegrityHappy`, `testOpMaxIntegrityUnhappyZeroInputs`, `testOpMaxIntegrityUnhappyOneInput`: integrity
- `testOpMaxRun`: fuzz run vs reference
- `testOpMaxEval2InputsHappy`: extensive 2-input examples including negatives
- `testOpMaxEval3InputsHappy`: exhaustive 3-input combinations including negatives
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A83 LibOpMaxNegativeValue

**Source:** `src/lib/op/math/LibOpMaxNegativeValue.sol` (lines 13-46)
- `integrity` (line 19): 0 inputs, 1 output
- `run` (line 26): pushes `FLOAT_MAX_NEGATIVE_VALUE`
- `referenceFn` (line 37): reference using `packLossless(-1, int32.min)`

**Test:** `test/src/lib/op/math/LibOpMaxNegativeValue.t.sol`
- `testOpMaxValueIntegrity`: fuzz integrity
- `testOpMaxNegativeValueRun`: run vs reference
- `testOpMaxNegativeValueEval`: eval check vs constant
- `testOpMaxNegativeValueEvalFail`: bad inputs (1 input)
- Bad outputs/operand tests present

**Gaps:** None.

---

## A84 LibOpMaxPositiveValue

**Source:** `src/lib/op/math/LibOpMaxPositiveValue.sol` (lines 13-46)
- `integrity` (line 19): 0 inputs, 1 output
- `run` (line 26): pushes `FLOAT_MAX_POSITIVE_VALUE`
- `referenceFn` (line 37): reference using `packLossless(int224.max, int32.max)`

**Test:** `test/src/lib/op/math/LibOpMaxPositiveValue.t.sol`
- `testOpMaxPositiveValueIntegrity`: fuzz integrity
- `testOpMaxPositiveValueRun`: run vs reference
- `testOpMaxPositiveValueEval`: eval check vs constant
- `testOpMaxPositiveValueEvalFail`: bad inputs (1 input)
- Bad outputs/operand tests present

**Gaps:** None.

---

## A85 LibOpMin

**Source:** `src/lib/op/math/LibOpMin.sol` (lines 13-84)
- `integrity` (line 20): n-ary, minimum 2 inputs, 1 output
- `run` (line 32): iterative `a.min(b)`
- `referenceFn` (line 68): reference implementation

**Test:** `test/src/lib/op/math/LibOpMin.t.sol`
- `testOpMinIntegrityHappy`, `testOpMinIntegrityUnhappyZeroInputs`, `testOpMinIntegrityUnhappyOneInput`: integrity
- `testOpMinRun`: fuzz run vs reference
- `testOpMinEval2InputsHappy`: extensive 2-input examples including negatives
- `testOpMinEval3InputsHappy`: exhaustive 3-input combinations including negatives
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A86 LibOpMinNegativeValue

**Source:** `src/lib/op/math/LibOpMinNegativeValue.sol` (lines 13-46)
- `integrity` (line 19): 0 inputs, 1 output
- `run` (line 26): pushes `FLOAT_MIN_NEGATIVE_VALUE`
- `referenceFn` (line 37): reference using `packLossless(int224.min, int32.max)`

**Test:** `test/src/lib/op/math/LibOpMinNegativeValue.t.sol`
- `testOpMinNegativeValueIntegrity`: fuzz integrity
- `testOpMinNegativeValueRun`: run vs reference
- `testOpMinNegativeValueEval`: eval check vs constant
- `testOpMinNegativeValueEvalFail`: bad inputs (1 input)
- Bad outputs/operand tests present

**Gaps:** None.

---

## A87 LibOpMinPositiveValue

**Source:** `src/lib/op/math/LibOpMinPositiveValue.sol` (lines 13-46)
- `integrity` (line 19): 0 inputs, 1 output
- `run` (line 26): pushes `FLOAT_MIN_POSITIVE_VALUE`
- `referenceFn` (line 37): reference using `packLossless(1, int32.min)`

**Test:** `test/src/lib/op/math/LibOpMinPositiveValue.t.sol`
- `testOpMinPositiveValueIntegrity`: fuzz integrity
- `testOpMinPositiveValueRun`: run vs reference
- `testOpMinPositiveValueEval`: eval check vs constant
- `testOpMinPositiveValueEvalFail`: bad inputs (1 input)
- Bad outputs/operand tests present

**Gaps:** None.

---

## A88 LibOpMul

**Source:** `src/lib/op/math/LibOpMul.sol` (lines 14-101)
- `integrity` (line 21): n-ary, minimum 2 inputs, 1 output
- `run` (line 32): iterative mul with unpacked intermediates
- `referenceFn` (line 74): reference implementation

**Test:** `test/src/lib/op/math/LibOpMul.t.sol`
- `testOpMulIntegrityHappy`, `testOpMulIntegrityUnhappyZeroInputs`, `testOpDecimal18MulIntegrityUnhappyOneInput`: integrity
- `testOpMulRun`: fuzz run vs reference (catches overflow errors)
- `testOpMulEvalTwoInputsHappy`: 0*1, 1*1, 1*2, 2*1, 2*2, 2*0.1, etc.
- `testOpMulEvalTwoInputsUnhappyOverflow`: max*10
- `testOpMulEvalThreeInputsHappy`, `testOpMulEvalThreeInputsUnhappyOverflow`: 3-input
- Bad inputs/outputs/operand tests present

### Finding A88-1 (LOW): No negative-value eval examples for mul

All deterministic eval examples use non-negative operands. No test exercises
`mul(-2 3)`, `mul(-2 -3)`, or `mul(0 -1)` as eval checks. The fuzz test
covers negative values probabilistically, but deterministic examples for sign
preservation (`negative * positive = negative`, `negative * negative = positive`)
would catch regressions in sign handling logic.

---

## A89 LibOpPower

**Source:** `src/lib/op/math/LibOpPower.sol` (lines 13-60)
- `integrity` (line 19): 2 inputs, 1 output
- `run` (line 28): `a.pow(b, LOG_TABLES_ADDRESS)`
- `referenceFn` (line 47): reference implementation

**Test:** `test/src/lib/op/math/LibOpPower.t.sol`
- `testOpPowIntegrity`: fuzz integrity
- `testOpPowRun`: fuzz run vs reference (bounded non-negative base [0..10000])
- `testOpPowEval`: 0^0=1, 0^1=0, 0^2=0, 1^0=1, 1^1=1, 1^2=1, 2^2=4, 2^3=8, 2^4=16, 4^0.5=2, (-1)^0=1
- `testOpPowNegativeBaseError`: (-1)^2 and (-1)^(-2) revert with PowNegativeBase
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A90 LibOpSqrt

**Source:** `src/lib/op/math/LibOpSqrt.sol` (lines 13-56)
- `integrity` (line 19): 1 input, 1 output
- `run` (line 28): `a.sqrt(LOG_TABLES_ADDRESS)`
- `referenceFn` (line 44): reference implementation

**Test:** `test/src/lib/op/math/LibOpSqrt.t.sol`
- `testOpSqrtIntegrity`: fuzz integrity
- `testOpSqrtRun`: fuzz run vs reference (takes abs, excludes int224.min)
- `testOpSqrtEvalExamples`: sqrt(0)=0, sqrt(1)=1, sqrt(0.5), sqrt(2), sqrt(2.5)
- `testOpSqrtEvalNegativeInput`: sqrt(-1) reverts with PowNegativeBase
- Bad inputs/outputs/operand tests present

**Gaps:** None.

---

## A91 LibOpSub

**Source:** `src/lib/op/math/LibOpSub.sol` (lines 14-101)
- `integrity` (line 21): n-ary, minimum 2 inputs, 1 output
- `run` (line 33): iterative sub with unpacked intermediates
- `referenceFn` (line 75): reference implementation

**Test:** `test/src/lib/op/math/LibOpSub.t.sol`
- `testOpSubIntegrityHappy`, `testOpSubIntegrityUnhappyZeroInputs`, `testOpSubIntegrityUnhappyOneInput`: integrity
- `testOpSubRun`: fuzz run vs reference (bounded exponents)
- `testOpSubEvalTwoInputs`: 1-0, 1-1, 2-1, 2-2, max-0, 1-2 (negative result), 1-0.1, max-1, max-max
- `testOpSubEvalThreeInputs`: 1-0-0, 1-1-0, 2-1-1, 2-2-0
- Bad inputs/outputs/operand tests present

### Finding A91-1 (LOW): No negative-value eval examples and no overflow test for sub

1. No deterministic eval examples with negative operands (e.g. `sub(-1 -2) = 1`,
   `sub(-1 2) = -3`). The fuzz covers this, but deterministic checks catch
   regressions more reliably.
2. No `checkUnhappyOverflow` test for `sub`. The `add` opcode tests overflow
   with `max-positive-value()` sums, but `sub` has no equivalent. Subtracting
   `min-negative-value()` from `max-positive-value()` should overflow, and this
   path is untested deterministically.

---

## Findings Summary

| ID | Severity | File | Description |
|----|----------|------|-------------|
| A71-1 | LOW | LibOpAvg.t.sol | No negative-value eval examples |
| A73-1 | LOW | LibOpDiv.t.sol | No negative-value eval examples |
| A88-1 | LOW | LibOpMul.t.sol | No negative-value eval examples |
| A91-1 | LOW | LibOpSub.t.sol | No negative-value eval examples; no overflow test |
