# Pass 3 - Documentation Audit: Eval, Integrity, Extern Libraries (A21-A29)

## Files Audited

| Agent ID | File |
|----------|------|
| A21 | `src/lib/eval/LibEval.sol` |
| A22 | `src/lib/extern/LibExtern.sol` |
| A23 | `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol` |
| A24 | `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol` |
| A25 | `src/lib/extern/reference/op/LibExternOpContextRainlen.sol` |
| A26 | `src/lib/extern/reference/op/LibExternOpContextSender.sol` |
| A27 | `src/lib/extern/reference/op/LibExternOpIntInc.sol` |
| A28 | `src/lib/extern/reference/op/LibExternOpStackOperand.sol` |
| A29 | `src/lib/integrity/LibIntegrityCheck.sol` |

## Evidence

### A21: LibEval.sol

**Library**: `LibEval` (line 15) -- no `@title` or library-level NatSpec.

| Function | Line | Visibility | NatSpec |
|----------|------|------------|---------|
| `evalLoop` | 41 | internal view | `@notice`, `@param state`, `@param parentSourceIndex`, `@param stackTop`, `@param stackBottom`, `@return` |
| `eval4` | 191 | internal view | `@notice`, `@param state`, `@param inputs`, `@param maxOutputs`, 2x `@return` |

**Errors/Types**: None defined in this file (`InputsLengthMismatch` imported from `ErrEval.sol`).

**NatSpec accuracy**: All descriptions verified against implementation. `evalLoop` correctly describes 32-byte word reading, 8-opcode packing, modulo-bounded dispatch, remainder loop, and stack trace emission. `eval4` correctly describes input validation, stack copy, evalLoop delegation, and output construction. Both functions' params and returns match signatures.

### A22: LibExtern.sol

**Library**: `LibExtern` (line 17) -- `@title` (line 14), `@notice` (lines 15-16). All tagged.

| Function | Line | Visibility | NatSpec |
|----------|------|------------|---------|
| `encodeExternDispatch` | 27 | internal pure | `@notice`, `@param opcode`, `@param operand`, `@return` |
| `decodeExternDispatch` | 35 | internal pure | `@notice`, `@param dispatch`, 2x `@return` |
| `encodeExternCall` | 56 | internal pure | `@notice`, `@param extern`, `@param dispatch`, `@return` |
| `decodeExternCall` | 70 | internal pure | `@notice`, `@param dispatch`, 2x `@return` |

**NatSpec accuracy**: Bit layout descriptions verified against implementation for all four functions. Encoding/decoding operations match documented bit ranges.

### A23: LibParseLiteralRepeat.sol

**Library**: `LibParseLiteralRepeat` (line 45) -- `@title` (line 5), `@notice` (lines 6-28). All tagged.

| Item | Line | NatSpec |
|------|------|---------|
| `MAX_REPEAT_LITERAL_LENGTH` constant | 34 | `@dev` with overflow explanation |
| `RepeatLiteralTooLong` error | 39 | `@dev`, `@param length` |
| `RepeatDispatchNotDigit` error | 43 | `@dev`, `@param dispatchValue` |
| `parseRepeat` function | 53 | `@notice`, `@param dispatchValue`, `@param cursor`, `@param end`, `@return` |

**NatSpec accuracy**: All descriptions match implementation. Overflow bounds in `@dev` comments are mathematically correct.

### A24: LibExternOpContextCallingContract.sol

**Library**: `LibExternOpContextCallingContract` (line 15) -- `@title` (line 12), `@notice` (lines 13-14). All tagged.

| Function | Line | NatSpec |
|----------|------|---------|
| `subParser` | 25 | `@notice`, `@param constantsHeight`, `@param ioByte`, `@param operand`, 3x `@return` |

**NatSpec accuracy**: Correct. Delegates to `LibSubParse.subParserContext`. Params marked "(unused)" are indeed silenced via tuple discard.

### A25: LibExternOpContextRainlen.sol

**Library**: `LibExternOpContextRainlen` (line 23) -- `@title` (line 20), `@notice` (lines 21-22). All tagged.

| Item | Line | NatSpec |
|------|------|---------|
| `CONTEXT_CALLER_CONTEXT_COLUMN` constant | 13 | `@dev` |
| `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` constant | 18 | `@dev` |
| `subParser` function | 33 | `@notice`, `@param constantsHeight`, `@param ioByte`, `@param operand`, 3x `@return` |

**NatSpec accuracy**: Correct.

### A26: LibExternOpContextSender.sol

**Library**: `LibExternOpContextSender` (line 13) -- `@title` (line 9), `@notice` (lines 10-12). All tagged.

| Function | Line | NatSpec |
|----------|------|---------|
| `subParser` | 23 | `@notice`, `@param constantsHeight`, `@param ioByte`, `@param operand`, 3x `@return` |

**NatSpec accuracy**: Correct.

### A27: LibExternOpIntInc.sol

**Library**: `LibExternOpIntInc` (line 18) -- `@title` (line 15), `@notice` (lines 16-17). All tagged.

| Item | Line | NatSpec |
|------|------|---------|
| `OP_INDEX_INCREMENT` constant | 13 | `@dev` |
| `run` function | 27 | `@notice`, `@param inputs`, `@return` |
| `integrity` function | 44 | `@notice`, `@param inputs`, 2x `@return` |
| `subParser` function | 57 | `@notice`, `@param constantsHeight`, `@param ioByte`, `@param operand`, 3x `@return` |

**NatSpec accuracy**: Correct. Unnamed parameters in `run` and `integrity` are intentionally unnamed and unused.

### A28: LibExternOpStackOperand.sol

**Library**: `LibExternOpStackOperand` (line 14) -- `@title` (line 8), `@notice` (lines 9-13). All tagged.

| Function | Line | NatSpec |
|----------|------|---------|
| `subParser` | 23 | `@notice`, `@param constantsHeight`, `@param operand`, 3x `@return` |

**NatSpec accuracy**: Correct. Unnamed `uint256` (ioByte) parameter intentionally unnamed and unused.

### A29: LibIntegrityCheck.sol

**Library**: `LibIntegrityCheck` (line 44) -- no `@title` or library-level NatSpec.

| Item | Line | NatSpec |
|------|------|---------|
| `IntegrityCheckState` struct | 35 | Untagged first line, then `@param` for all 6 fields |
| `newState` function | 56 | `@notice`, `@param bytecode`, `@param stackIndex`, `@param constants`, `@return` |
| `integrityCheck2` function | 91 | `@notice`, `@param fPointers`, `@param bytecode`, `@param constants`, `@return io` |

**Errors**: All imported (`OpcodeOutOfRange`, `StackAllocationMismatch`, `StackOutputsMismatch`, `StackUnderflow`, `StackUnderflowHighwater` from `ErrIntegrity.sol`; `BadOpInputsLength`, `BadOpOutputsLength` from interface).

**NatSpec accuracy**: All descriptions verified against implementation. `integrityCheck2` correctly describes the walk-over-all-sources behavior, IO validation, highwater enforcement, and packed IO output. `newState` accurately describes the initial state construction.

## Findings

### A21-P3-1: Missing `@title` on `LibEval` library

**Severity**: LOW
**File**: `src/lib/eval/LibEval.sol`, line 15
**Description**: The `LibEval` library declaration has no preceding NatSpec doc block. All other libraries in this audit batch (A22-A28) have `@title` and `@notice` tags on their library declarations. `LibEval` is a core component (the evaluation engine) and should have library-level documentation.

### A29-P3-1: Untagged line in `IntegrityCheckState` struct doc block

**Severity**: LOW
**File**: `src/lib/integrity/LibIntegrityCheck.sol`, line 18
**Description**: The `IntegrityCheckState` struct doc block begins with an untagged line `/// Tracks the state of the integrity check walk over a single source.` followed by explicitly tagged `@param` lines. Per the project NatSpec convention, when explicit tags are present in a doc block, all entries must be explicitly tagged. The first line should be `/// @notice Tracks the state...`.

### A29-P3-2: Missing `@title` on `LibIntegrityCheck` library

**Severity**: LOW
**File**: `src/lib/integrity/LibIntegrityCheck.sol`, line 44
**Description**: The `LibIntegrityCheck` library declaration has no preceding NatSpec doc block. It should have `@title` and `@notice` tags consistent with the other libraries in the codebase.
