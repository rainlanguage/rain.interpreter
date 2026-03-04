# Pass 3: Math Opcodes NatSpec Audit

Audit namespace: `audit/2026-03-04-01/pass3/`

## Scope

23 math opcode libraries in `src/lib/op/math/LibOp*.sol` (agent IDs A69--A91).

Each library exposes three functions: `integrity`, `run`, `referenceFn`. All
libraries have `@title` on the library declaration. All use explicit NatSpec tags
(`@notice`, `@param`, `@return`).

---

## File-by-File Evidence

### A69 LibOpAbs (`src/lib/op/math/LibOpAbs.sol`)

- **Library** (line 11-12): `@title LibOpAbs`, `@notice` -- correct.
- **`integrity`** (line 16-17): `@notice`, 2x `@return` -- correct. Unnamed params, no `@param` needed.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A70 LibOpAdd (`src/lib/op/math/LibOpAdd.sol`)

- **Library** (line 13-14): `@title LibOpAdd`, `@notice` -- correct.
- **`integrity`** (line 18-21): `@notice`, `@param operand`, 2x `@return` -- correct.
- **`run`** (line 29-32): `@notice`, `@param operand`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 73-75): `@notice`, `@param inputs`, `@return outputs` -- correct.

No findings.

---

### A71 LibOpAvg (`src/lib/op/math/LibOpAvg.sol`)

- **Library** (line 11-12): `@title LibOpAvg`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 44-46): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A72 LibOpCeil (`src/lib/op/math/LibOpCeil.sol`)

- **Library** (line 11-12): `@title LibOpCeil`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A73 LibOpDiv (`src/lib/op/math/LibOpDiv.sol`)

- **Library** (line 12-13): `@title LibOpDiv`, `@notice` -- correct.
- **`integrity`** (line 17-20): `@notice`, `@param operand`, 2x `@return` -- correct.
- **`run`** (line 28-32): `@notice` with continuation, `@param operand`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 71-73): `@notice`, `@param inputs`, `@return outputs` -- correct.

No findings.

---

### A74 LibOpE (`src/lib/op/math/LibOpE.sol`)

- **Library** (line 11-12): `@title LibOpE`, `@notice` -- correct.
- **`integrity`** (line 14-16): `@notice`, 2x `@return` -- correct.
- **`run`** (line 21-23): `@notice`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 33-34): `@notice`, `@return` -- correct. All params unnamed.

No findings.

---

### A75 LibOpExp (`src/lib/op/math/LibOpExp.sol`)

- **Library** (line 11-12): `@title LibOpExp`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A76 LibOpExp2 (`src/lib/op/math/LibOpExp2.sol`)

- **Library** (line 11-12): `@title LibOpExp2`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 42-44): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A77 LibOpFloor (`src/lib/op/math/LibOpFloor.sol`)

- **Library** (line 11-12): `@title LibOpFloor`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A78 LibOpFrac (`src/lib/op/math/LibOpFrac.sol`)

- **Library** (line 11-12): `@title LibOpFrac`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A79 LibOpGm (`src/lib/op/math/LibOpGm.sol`)

- **Library** (line 11-14): `@title LibOpGm`, `@notice` multi-line describing signed geometric mean -- correct.
- **`integrity`** (line 18-20): `@notice`, 2x `@return` -- correct.
- **`run`** (line 26-30): `@notice` multi-line, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 52-54): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A80 LibOpHeadroom (`src/lib/op/math/LibOpHeadroom.sol`)

- **Library** (line 11-13): `@title LibOpHeadroom`, `@notice` multi-line -- correct.
- **`integrity`** (line 17-19): `@notice`, 2x `@return` -- correct.
- **`run`** (line 25-29): `@notice` multi-line describing ceil-minus-x and integer case, `@param stackTop`, `@return` -- correct and matches implementation.
- **`referenceFn`** (line 46-48): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A81 LibOpInv (`src/lib/op/math/LibOpInv.sol`)

- **Library** (line 11-12): `@title LibOpInv`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 24-27): `@notice` with continuation, `@param stackTop`, `@return` -- see finding below.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

### Finding A81-P3-1 (INFO): Terminology inconsistency in `run` NatSpec

Line 25 says "floating point inverse" while every other math opcode consistently
uses the phrase "decimal floating point". Compare:
- LibOpAbs line 25: "decimal floating point absolute value"
- LibOpCeil line 25: "decimal floating point ceiling"
- LibOpFrac line 25: "decimal floating point frac"

Missing the word "decimal" is a minor inconsistency.

---

### A82 LibOpMax (`src/lib/op/math/LibOpMax.sol`)

- **Library** (line 11-12): `@title LibOpMax`, `@notice` -- correct.
- **`integrity`** (line 16-19): `@notice`, `@param operand`, 2x `@return` -- correct.
- **`run`** (line 27-31): `@notice` with continuation, `@param operand`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 64-66): `@notice`, `@param inputs`, `@return outputs` -- correct.

No findings.

---

### A83 LibOpMaxNegativeValue (`src/lib/op/math/LibOpMaxNegativeValue.sol`)

- **Library** (line 11-12): `@title LibOpMaxNegativeValue`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 23-25): `@notice`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 35-36): `@notice`, `@return` -- correct. All params unnamed.

No findings.

---

### A84 LibOpMaxPositiveValue (`src/lib/op/math/LibOpMaxPositiveValue.sol`)

- **Library** (line 11-12): `@title LibOpMaxPositiveValue`, `@notice` -- see finding below.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 23-25): `@notice` correctly says "maximum representable positive float", `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 35-36): `@notice`, `@return` -- correct.

### Finding A84-P3-1 (INFO): Imprecise library `@notice`

Line 12: `@notice Exposes the maximum representable float value as a Rainlang opcode.`

Missing "positive" qualifier. The `run` function NatSpec (line 23) correctly says
"maximum representable positive float". Compare with `LibOpMaxNegativeValue`
(line 12) which correctly includes "maximum negative". Should read:
"Exposes the maximum positive representable float value as a Rainlang opcode."

---

### A85 LibOpMin (`src/lib/op/math/LibOpMin.sol`)

- **Library** (line 11-12): `@title LibOpMin`, `@notice` -- correct.
- **`integrity`** (line 16-19): `@notice`, `@param operand`, 2x `@return` -- correct.
- **`run`** (line 27-31): `@notice` with continuation, `@param operand`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 65-66): `@notice`, `@param inputs`, `@return outputs` -- correct.

No findings.

---

### A86 LibOpMinNegativeValue (`src/lib/op/math/LibOpMinNegativeValue.sol`)

- **Library** (line 11-12): `@title LibOpMinNegativeValue`, `@notice` -- see finding below.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 23-25): `@notice` correctly says "minimum representable negative float", `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 35-36): `@notice`, `@return` -- correct.

### Finding A86-P3-1 (INFO): Imprecise library `@notice`

Line 12: `@notice Exposes the minimum representable float value as a Rainlang opcode.`

Missing "negative" qualifier. "Minimum representable float value" is ambiguous --
it could mean the smallest magnitude or the most negative. The `run` function
NatSpec (line 23) correctly says "minimum representable negative float". Compare
with `LibOpMinPositiveValue` (line 12) which correctly includes "minimum positive".
Should read: "Exposes the minimum negative representable float value as a Rainlang opcode."

---

### A87 LibOpMinPositiveValue (`src/lib/op/math/LibOpMinPositiveValue.sol`)

- **Library** (line 11-12): `@title LibOpMinPositiveValue`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, 2x `@return` -- correct.
- **`run`** (line 23-25): `@notice`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 35-36): `@notice`, `@return` -- correct.

No findings.

---

### A88 LibOpMul (`src/lib/op/math/LibOpMul.sol`)

- **Library** (line 12-13): `@title LibOpMul`, `@notice` -- correct.
- **`integrity`** (line 17-20): `@notice`, `@param operand`, `@return inputs`, `@return outputs` -- correct.
- **`run`** (line 28-31): `@notice`, `@param operand`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 71-73): `@notice`, `@param inputs`, `@return outputs` -- correct.

No findings.

---

### A89 LibOpPower (`src/lib/op/math/LibOpPower.sol`)

- **Library** (line 11-12): `@title LibOpPower`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, `@return inputs`, `@return outputs` -- correct.
- **`run`** (line 24-27): `@notice` multi-line, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 44-46): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A90 LibOpSqrt (`src/lib/op/math/LibOpSqrt.sol`)

- **Library** (line 11-12): `@title LibOpSqrt`, `@notice` -- correct.
- **`integrity`** (line 16-18): `@notice`, `@return inputs`, `@return outputs` -- correct.
- **`run`** (line 24-27): `@notice` multi-line, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 41-43): `@notice`, `@param inputs`, `@return` -- correct.

No findings.

---

### A91 LibOpSub (`src/lib/op/math/LibOpSub.sol`)

- **Library** (line 12-13): `@title LibOpSub`, `@notice` -- correct.
- **`integrity`** (line 17-20): `@notice`, `@param operand`, `@return inputs`, `@return outputs` -- correct.
- **`run`** (line 28-32): `@notice` multi-line, `@param operand`, `@param stackTop`, `@return` -- correct.
- **`referenceFn`** (line 72-74): `@notice`, `@param inputs`, `@return outputs` -- correct.

No findings.

---

## Findings Summary

| ID | Severity | File | Description |
|----|----------|------|-------------|
| A81-P3-1 | INFO | LibOpInv.sol | `run` NatSpec says "floating point" instead of "decimal floating point" |
| A84-P3-1 | INFO | LibOpMaxPositiveValue.sol | Library `@notice` missing "positive" qualifier |
| A86-P3-1 | INFO | LibOpMinNegativeValue.sol | Library `@notice` missing "negative" qualifier |

No LOW or higher findings. All 23 libraries have:
- `@title` on library declaration
- `@notice` on all three functions
- `@param` for every named parameter
- `@return` for all return values
- No NatSpec tag rule violations (all blocks with explicit tags are fully tagged)
- NatSpec accurately describes implementation behavior
