# Pass 2 (Test Coverage) -- LibParseLiteralRepeat.sol

## Evidence of Thorough Reading

**Library:** `LibParseLiteralRepeat`
**Functions:** `parseRepeat(uint256 dispatchValue, uint256 cursor, uint256 end)` at line 41
**Errors:** `RepeatLiteralTooLong(uint256 length)` (line 33), `RepeatDispatchNotDigit(uint256 dispatchValue)` (line 37)

**Direct test:** `test/src/lib/extern/reference/literal/LibParseLiteralRepeat.t.sol` (4 test functions)
**Integration test:** `test/src/concrete/RainterpreterReferenceExtern.repeat.t.sol` (4 test functions)

## Findings

### A36-1: No test for RepeatLiteralTooLong revert path
**Severity:** MEDIUM
The `RepeatLiteralTooLong` error (triggered when body length >= 78) is never tested in either the direct or integration tests.

### A36-2: No test for parseRepeat output value correctness
**Severity:** MEDIUM
The direct unit test calls `parseRepeat` for dispatch values 0-9 but never asserts the returned value — only verifies no revert. Integration test does check output values (999, 88) but direct unit tests should also verify the formula.

### A36-3: No test for zero-length literal body (cursor == end)
**Severity:** LOW
When `cursor == end`, `length = 0` and function returns 0. This edge case is not tested.

### A36-4: No test for length = 1 (single character body)
**Severity:** LOW
Boundary case where body is exactly 1 byte is not tested.

### A36-5: No test for length = 77 (maximum valid length)
**Severity:** LOW
Maximum valid length before revert is 77. Not tested at boundary.

### A36-6: Integration tests use bare vm.expectRevert() without specifying expected error
**Severity:** LOW
Three negative tests use `vm.expectRevert()` without specifying the expected error selector. Would pass even if the revert reason changed.
