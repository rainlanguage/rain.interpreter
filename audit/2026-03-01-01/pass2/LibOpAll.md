# Pass 2: Test Coverage — Opcode Libraries

**Audit:** 2026-03-01-01
**Agent IDs:** A07-A29 (all opcode source files)

## Findings

### P2-01 (LOW) Missing operand-disallowed tests for 10 logic opcodes

**Files affected:**
- `test/src/lib/op/logic/LibOpGreaterThan.t.sol`
- `test/src/lib/op/logic/LibOpLessThan.t.sol`
- `test/src/lib/op/logic/LibOpGreaterThanOrEqualTo.t.sol`
- `test/src/lib/op/logic/LibOpLessThanOrEqualTo.t.sol`
- `test/src/lib/op/logic/LibOpEqualTo.t.sol`
- `test/src/lib/op/logic/LibOpBinaryEqualTo.t.sol`
- `test/src/lib/op/logic/LibOpIsZero.t.sol`
- `test/src/lib/op/logic/LibOpIf.t.sol`
- `test/src/lib/op/logic/LibOpAny.t.sol`
- `test/src/lib/op/logic/LibOpEvery.t.sol`

These 10 logic opcodes do not have a test verifying that the parser rejects an unexpected operand (e.g., `greater-than<0>(1 2)`). Most other opcodes include a `testOp*EvalOperandDisallowed` or `testOp*EvalBadOperand` test. Within the logic category itself, `LibOpConditions` and `LibOpEnsure` DO have this test.

### P2-02 (LOW) Missing operand-disallowed tests for 5 math opcodes

**Files affected:**
- `test/src/lib/op/math/LibOpSub.t.sol`
- `test/src/lib/op/math/LibOpMaxPositiveValue.t.sol`
- `test/src/lib/op/math/LibOpMaxNegativeValue.t.sol`
- `test/src/lib/op/math/LibOpMinPositiveValue.t.sol`
- `test/src/lib/op/math/LibOpMinNegativeValue.t.sol`

These 5 math opcodes do not test that the parser rejects unexpected operands. All other math opcodes DO have this test. `LibOpSub` is an N-ary opcode that should reject operands like `sub<0>(1 2)`. The four value opcodes are 0-input opcodes that should reject operands like `max-positive-value<0>()`.

### P2-03 (LOW) Missing operand-disallowed test for `LibOpHash`

**File:** `test/src/lib/op/crypto/LibOpHash.t.sol`

`LibOpHash` does not test that the parser rejects an unexpected operand (e.g., `hash<0>(0x00)`). The `hash` opcode's input count is driven by the number of parenthesized arguments, not by an explicit operand, so an explicit operand should be rejected.

## Overall Assessment

The opcode test suite is comprehensive. Virtually every opcode follows a thorough pattern: fuzz-tested `integrity`, fuzz-tested `run` via `opReferenceCheck`, end-to-end eval tests via parsed Rainlang, `checkBadInputs`/`checkBadOutputs` for incorrect I/O counts, and `checkUnhappyParse`/`checkDisallowedOperand` for operand rejection. The only systematic gap is the missing operand-disallowed tests for the subset identified above.
