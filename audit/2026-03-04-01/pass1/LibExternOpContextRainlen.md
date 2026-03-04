# Pass 1 (Security) -- LibExternOpContextRainlen.sol (A25)

**File:** `src/lib/extern/reference/op/LibExternOpContextRainlen.sol`

## Evidence

### Library
- `LibExternOpContextRainlen` (line 23)

### Constants (file-level)
- `CONTEXT_CALLER_CONTEXT_COLUMN = 1` (line 13) -- caller context column index
- `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN = 0` (line 18) -- rainlang length row index

### Functions
- `subParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand) returns (bool, bytes memory, bytes32[] memory)` -- line 33, `internal pure`

## Security Review

### Delegation to LibSubParse.subParserContext
The function delegates entirely to `LibSubParse.subParserContext(1, 0)`. Both values trivially fit in `uint8`.

### Context column 1 availability
Column 1 is caller-provided context. If the caller does not provide context column 1, or provides it with fewer rows than expected, the `OPCODE_CONTEXT` handler in the interpreter will access an out-of-bounds row. However, context bounds checking is the responsibility of the interpreter's `LibOpContext` at eval time, not this sub-parser library. This is by design.

### Unused parameters
Same pattern as A24. `constantsHeight`, `ioByte`, and `operand` are consumed in a tuple expression.

### No assembly
No assembly blocks in this library.

## Findings

No security findings.
