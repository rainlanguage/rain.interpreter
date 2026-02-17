# Pass 2 (Test Coverage) -- LibAllStandardOps.sol

## Evidence of Thorough Reading

### Source file: `src/lib/op/LibAllStandardOps.sol`

**Library name:** `LibAllStandardOps`

**Constants:**
- `ALL_STANDARD_OPS_LENGTH = 72` (line 106)

**Functions (all `internal pure`):**
1. `authoringMetaV2() returns (bytes memory)` -- line 121
2. `literalParserFunctionPointers() returns (bytes memory)` -- line 330
3. `operandHandlerFunctionPointers() returns (bytes memory)` -- line 363
4. `integrityFunctionPointers() returns (bytes memory)` -- line 535
5. `opcodeFunctionPointers() returns (bytes memory)` -- line 639

**Errors used (imported):**
- `BadDynamicLength(uint256 dynamicLength, uint256 standardOpsLength)` -- defined in `src/error/ErrOpList.sol` line 12

### Test file: `test/src/lib/op/LibAllStandardOps.t.sol`

**Contract name:** `LibAllStandardOpsTest`

**Tests:**
1. `testIntegrityFunctionPointersLength()` -- line 14
2. `testOpcodeFunctionPointersLength()` -- line 20
3. `testIntegrityAndOpcodeFunctionPointersLength()` -- line 28

### Related integration tests:
- `test/src/concrete/RainterpreterParser.pointers.t.sol` -- tests `operandHandlerFunctionPointers` and `literalParserFunctionPointers` indirectly
- `test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol` -- validates integrity function pointers and decodes `authoringMetaV2()`

## Findings

### A04-1: No direct test for `literalParserFunctionPointers()` output length
**Severity:** LOW

`LibAllStandardOpsTest` tests the output length of `integrityFunctionPointers()` and `opcodeFunctionPointers()`, and cross-checks them against `authoringMetaV2()`. However, there is no corresponding direct test that calls `LibAllStandardOps.literalParserFunctionPointers()` and asserts its output length equals `LITERAL_PARSERS_LENGTH * 2`.

The function is exercised indirectly through `RainterpreterParser.pointers.t.sol`.

### A04-2: No direct test for `operandHandlerFunctionPointers()` output length
**Severity:** LOW

Similar to A04-1, the test file has no test that directly calls `LibAllStandardOps.operandHandlerFunctionPointers()` and verifies its output length equals `ALL_STANDARD_OPS_LENGTH * 2`. The `testIntegrityAndOpcodeFunctionPointersLength` test checks integrity pointers, opcode pointers, and authoring meta word count are all consistent, but `operandHandlerFunctionPointers()` is not included in this cross-check.

Indirect coverage exists via `RainterpreterParser.pointers.t.sol`.

### A04-3: `BadDynamicLength` revert path is never tested
**Severity:** INFO

The `BadDynamicLength` error is used as a sanity check in four functions. No test anywhere in the test suite triggers this error. The source comments explicitly state this "Should be an unreachable error." Testing truly unreachable defensive checks has diminishing returns.

### A04-4: No test verifying `authoringMetaV2()` content correctness
**Severity:** LOW

No test verifies the actual content of the authoring meta entries (e.g., that keywords are correct, that no duplicate words exist, that descriptions are non-empty). There is partial indirect coverage through parse meta generation tests.

### A04-5: No test verifying four-array ordering consistency
**Severity:** MEDIUM

The source file's NatSpec explicitly states that the ordering of entries MUST match across `authoringMetaV2`, `integrityFunctionPointers`, `opcodeFunctionPointers`, and `operandHandlerFunctionPointers`. This is the central invariant of the file. The existing test only verifies that the four arrays have the same *length*, not that the *ordering* is consistent.

The file is maintained by hand with 72 parallel entries across four arrays, making manual alignment error-prone. A swap between two opcodes with the same arity could pass integrity checks and only manifest at runtime with wrong results.
