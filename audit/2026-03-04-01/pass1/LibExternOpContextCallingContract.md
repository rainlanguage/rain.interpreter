# Pass 1 (Security) -- LibExternOpContextCallingContract.sol (A24)

**File:** `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol`

## Evidence

### Library
- `LibExternOpContextCallingContract` (line 15)

### Imports
- `CONTEXT_BASE_COLUMN` (= 0) from `LibContext.sol`
- `CONTEXT_BASE_ROW_CALLING_CONTRACT` (= 1) from `LibContext.sol`

### Functions
- `subParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand) returns (bool, bytes memory, bytes32[] memory)` -- line 25, `internal pure`

## Security Review

### Delegation to LibSubParse.subParserContext
The function delegates entirely to `LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_CALLING_CONTRACT)`, passing constant values 0 and 1. The `subParserContext` function validates that both column and row fit in `uint8` (line 54 of `LibSubParse.sol`), which these constants trivially satisfy.

### Unused parameters
`constantsHeight`, `ioByte`, and `operand` are explicitly consumed via the tuple expression `(constantsHeight, ioByte, operand)` on line 30 to suppress compiler warnings. This is correct -- context ops do not use these parameters.

### No assembly
No assembly blocks in this library. Memory safety concerns are in `LibSubParse.subParserContext` (audited separately).

## Findings

No security findings.
