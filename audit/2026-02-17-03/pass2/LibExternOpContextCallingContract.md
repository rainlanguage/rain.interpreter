# Pass 2 (Test Coverage) -- LibExternOpContextCallingContract.sol

## Evidence of Thorough Reading

**Library:** `LibExternOpContextCallingContract`
**Functions:** `subParser(uint256, uint256, OperandV2)` at line 19

**Test file:** `test/src/concrete/RainterpreterReferenceExtern.contextCallingContract.t.sol`
**Tests:** `testRainterpreterReferenceExternContextContractHappy()` at line 12

## Findings

### A07-1: No direct unit test for LibExternOpContextCallingContract.subParser
**Severity:** LOW
Only tested indirectly via end-to-end `checkHappy` test.

### A07-2: No test for subParser with varying constantsHeight or ioByte inputs
**Severity:** LOW
The function accepts three parameters that are ignored. No fuzz test confirming stability regardless of input values.

### A07-3: Test contract name mismatch
**Severity:** INFO
Test contract is named `RainterpreterReferenceExternContextSenderTest` instead of `...ContextCallingContractTest`. Copy-paste issue.
