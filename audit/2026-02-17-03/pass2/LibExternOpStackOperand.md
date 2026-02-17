# Pass 2 (Test Coverage) -- LibExternOpStackOperand.sol

## Evidence of Thorough Reading

**Library:** `LibExternOpStackOperand`
**Functions:** `subParser(uint256 constantsHeight, uint256, OperandV2 operand)` at line 16

**Test file:** `test/src/concrete/RainterpreterReferenceExtern.stackOperand.t.sol`
**Tests:** `testRainterpreterReferenceExternStackOperandSingle(uint256 value)` at line 13

## Findings

### A11-1: No direct unit test for LibExternOpStackOperand.subParser
**Severity:** LOW
No direct test calling the library's `subParser` function. Only exercised through full parse-eval pipeline.

### A11-2: No test for subParser with constantsHeight > 0
**Severity:** LOW
No test verifying that varying `constantsHeight` values produce correct constant index encoding.

### A11-3: Operand value bounded to uint16.max in end-to-end test
**Severity:** INFO
Fuzz test bounds `value` to `type(uint16).max`. Library function never tested with operand values above 16-bit range.
