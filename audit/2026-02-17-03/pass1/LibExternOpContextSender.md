# Pass 1 (Security) — LibExternOpContextSender.sol

**File:** `src/lib/extern/reference/op/LibExternOpContextSender.sol`
**Audit date:** 2026-02-17
**Auditor:** Claude Opus 4.6

## Evidence of Thorough Reading

### Contract/Library Name
- `LibExternOpContextSender` (library, line 13)

### Functions
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `subParser(uint256, uint256, OperandV2)` | 17 | `internal` | `pure` |

### Errors/Events/Structs Defined
None defined in this file.

### Imports
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 5)
- `LibSubParse` from `../../../parse/LibSubParse.sol` (line 6)
- `CONTEXT_BASE_COLUMN` (value: `0`) from `rain.interpreter.interface/lib/caller/LibContext.sol` (line 7)
- `CONTEXT_BASE_ROW_SENDER` (value: `0`) from `rain.interpreter.interface/lib/caller/LibContext.sol` (line 7)

## Analysis

### Overview

This is a minimal library containing a single function, `subParser`, which delegates entirely to `LibSubParse.subParserContext(CONTEXT_BASE_COLUMN, CONTEXT_BASE_ROW_SENDER)`. It provides a sub-parser word that resolves to a context grid reference for the transaction sender at position `(column=0, row=0)`.

The function signature accepts three parameters (`uint256`, `uint256`, `OperandV2`), none of which are named or used in the function body. These are required by the sub-parser function pointer signature convention used by `RainterpreterReferenceExtern` but are intentionally ignored since this opcode has no operand-dependent behavior.

### Security Checklist

1. **Assembly memory safety:** No assembly in this file. The delegated `LibSubParse.subParserContext` uses `assembly ("memory-safe")` blocks, which were reviewed separately.

2. **Unchecked arithmetic:** No arithmetic in this file.

3. **Custom errors only:** No reverts in this file. The delegated function `subParserContext` reverts with `ContextGridOverflow(column, row)` if either value exceeds `uint8`, but the constants `CONTEXT_BASE_COLUMN = 0` and `CONTEXT_BASE_ROW_SENDER = 0` can never trigger this.

4. **Operand validation:** The `OperandV2` parameter is ignored. This is consistent with the operand handler registered in `RainterpreterReferenceExtern.sol` (line 289), which uses `handleOperandDisallowed`, meaning any attempt to provide operands to this word during parsing will be rejected. The unused parameter is safe here.

5. **Stack underflow/overflow:** This opcode produces a context read (0 inputs, 1 output as encoded by `subParserContext`), which is correct for reading a single context value.

6. **Context bounds checking:** The context indices `(0, 0)` refer to `msg.sender` in the base context, which is always populated by `LibContext.base()` (confirmed at `LibContext.sol` line 63-71, which always creates a 2-element array). Context bounds checking at eval time is handled by the interpreter's context access opcode, not by this sub-parser.

7. **Reentrancy:** Not applicable. This is a pure function with no external calls.

8. **Extern dispatch:** This opcode does NOT generate an extern dispatch. It resolves to `OPCODE_CONTEXT` (a native interpreter opcode), not `OPCODE_EXTERN`. No extern call occurs at runtime for this word.

## Findings

### INFO-1: Unnamed function parameters

**Severity:** INFO

**Description:** The `subParser` function at line 17 has three parameters, none of which are named. While the function signature is dictated by the sub-parser pointer convention and none of these parameters are used, naming them (even if unused) would improve readability for auditors and maintainers trying to understand what data is available.

```solidity
function subParser(uint256, uint256, OperandV2) internal pure returns (bool, bytes memory, bytes32[] memory) {
```

**Recommendation:** Consider naming the parameters for documentation purposes (e.g., `uint256 constantsHeight`, `uint256 ioByte`, `OperandV2 operand`), even if they remain unused. Alternatively, this is fine as-is since the pattern is consistent with other similar sub-parsers in the codebase that also ignore their parameters.

---

**Summary:** No security issues found. This is a trivially simple delegation function that passes hardcoded constant values to a well-validated library function. The attack surface is effectively zero.
