# Pass 1: Security Audit - LibExternOpContextCallingContract.sol

**File:** `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol`

## Evidence of Thorough Reading

### Contract/Library Name
- `LibExternOpContextCallingContract` (library, line 15)

### Functions
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `subParser(uint256, uint256, OperandV2)` | 19 | internal | pure |

### Errors / Events / Structs
- None defined in this file.

### Imports
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 5)
- `LibSubParse` from `../../../parse/LibSubParse.sol` (line 6)
- `CONTEXT_BASE_COLUMN` from `rain.interpreter.interface/lib/caller/LibContext.sol` (line 8)
- `CONTEXT_BASE_ROW_CALLING_CONTRACT` from `rain.interpreter.interface/lib/caller/LibContext.sol` (line 9)

### Constants Referenced (defined externally)
- `CONTEXT_BASE_COLUMN = 0` (LibContext.sol, line 25)
- `CONTEXT_BASE_ROW_CALLING_CONTRACT = 1` (LibContext.sol, line 34)

## Analysis

This is a minimal library (23 lines total) with a single function `subParser` at line 19. The function:

1. Accepts three parameters (`uint256`, `uint256`, `OperandV2`) but ignores all of them (unnamed parameters).
2. Delegates entirely to `LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_CALLING_CONTRACT)`, which encodes a context opcode referencing column 0, row 1.
3. The constants `CONTEXT_BASE_COLUMN = 0` and `CONTEXT_BASE_ROW_CALLING_CONTRACT = 1` both fit in uint8, so the `ContextGridOverflow` check in `subParserContext` will never trigger.
4. `subParserContext` handles all the bytecode construction and bounds checking internally, which was verified by reading `LibSubParse.sol`.

### Security Checklist

- **Assembly memory safety:** No assembly in this file. The delegated call to `LibSubParse.subParserContext` uses assembly marked `memory-safe` and was reviewed separately.
- **Unchecked arithmetic:** No arithmetic in this file.
- **Custom errors only:** No reverts in this file. Potential reverts are in `LibSubParse.subParserContext` which uses custom error `ContextGridOverflow`.
- **Unused parameters:** All three parameters are intentionally unused. The function signature must match the function pointer type expected by `RainterpreterReferenceExtern.buildSubParserWordParsers()` (line 325-327 of `RainterpreterReferenceExtern.sol`), which requires `function(uint256, uint256, OperandV2) internal view returns (bool, bytes memory, bytes32[] memory)`. The function is `pure` but is stored in a `view` function pointer, which is safe (pure is a subset of view).
- **Context bounds:** The hardcoded column=0, row=1 values correspond to the calling contract address, which is always present in the base context (set by `LibContext.base()`). There is no risk of out-of-bounds context access at eval time as long as the calling contract provides the base context, which is the documented convention.

## Findings

No security findings. This library is a trivial wrapper that passes two hardcoded constants to `LibSubParse.subParserContext`. The constants are within valid bounds, there is no arithmetic, no assembly, no external calls, and no state access. The security surface area is effectively zero -- all meaningful logic and validation resides in `LibSubParse.subParserContext`.
