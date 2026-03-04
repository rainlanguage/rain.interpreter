# Pass 1 (Security) -- LibExternOpContextSender.sol (A26)

**File:** `src/lib/extern/reference/op/LibExternOpContextSender.sol`

## Evidence

### Library
- `LibExternOpContextSender` (line 13)

### Imports
- `CONTEXT_BASE_COLUMN` (= 0) from `LibContext.sol`
- `CONTEXT_BASE_ROW_SENDER` (= 0) from `LibContext.sol`

### Functions
- `subParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand) returns (bool, bytes memory, bytes32[] memory)` -- line 23, `internal pure`

## Security Review

### Delegation to LibSubParse.subParserContext
The function delegates entirely to `LibSubParse.subParserContext(0, 0)`. Both values trivially fit in `uint8`. Column 0 is the base context (always present), row 0 is the sender (always present). No out-of-bounds risk at eval time.

### Unused parameters
Same pattern as A24/A25. `constantsHeight`, `ioByte`, and `operand` are consumed in a tuple expression.

### No assembly
No assembly blocks in this library.

## Findings

No security findings.
