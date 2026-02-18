# Pass 1 (Security) — LibExternOpContextRainlen.sol

## Evidence of Thorough Reading

**File**: `src/lib/extern/reference/op/LibExternOpContextRainlen.sol` (22 lines)

**Library name**: `LibExternOpContextRainlen`

**Functions**:
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `subParser(uint256, uint256, OperandV2)` | 18 | `internal` | `pure` |

**Errors/Events/Structs defined**: None

**File-level constants**:
| Constant | Line | Value |
|----------|------|-------|
| `CONTEXT_CALLER_CONTEXT_COLUMN` | 8 | `1` |
| `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` | 9 | `0` |

**Imports**:
- `OperandV2` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 5)
- `LibSubParse` from `../../../parse/LibSubParse.sol` (line 6)

## Analysis

This library is minimal: a single `subParser` function that delegates entirely to `LibSubParse.subParserContext(1, 0)`. The function ignores all three of its parameters (constants height, IO byte, and operand) and always returns a context opcode referencing column 1, row 0.

### Delegation target review

`LibSubParse.subParserContext` (line 37 of `LibSubParse.sol`) validates that both `column` and `row` fit in `uint8`, reverting with `ContextGridOverflow` otherwise. Since the constants passed here are `1` and `0`, this check always passes. The assembly in `subParserContext` is marked `memory-safe` and correctly allocates bytecode and an empty constants array via the free memory pointer.

### Security checklist

- **Assembly memory safety**: No assembly in this file. The delegated `subParserContext` assembly is reviewed separately.
- **Unchecked arithmetic**: No arithmetic in this file.
- **Custom errors only**: No reverts in this file. The delegated function uses `ContextGridOverflow` (a custom error), which is correct.
- **Stack underflow/overflow**: Not applicable — this is a parse-time function, not a runtime opcode.
- **Operand validation**: The operand parameter is intentionally ignored, consistent with the other context reference ops (`LibExternOpContextSender`, `LibExternOpContextCallingContract`). This is correct because context lookups have fixed column/row and no operand configuration.

## Findings

### INFO-1: File-local constants instead of shared interface constants

**Severity**: INFO

**Description**: `CONTEXT_CALLER_CONTEXT_COLUMN` (= 1) and `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` (= 0) are defined as file-level constants in this file (lines 8-9). The sibling libraries `LibExternOpContextSender` and `LibExternOpContextCallingContract` import their equivalent constants (`CONTEXT_BASE_COLUMN`, `CONTEXT_BASE_ROW_SENDER`, `CONTEXT_BASE_ROW_CALLING_CONTRACT`) from `rain.interpreter.interface/lib/caller/LibContext.sol`.

This library defines its own constants because column 1 (caller context) is a different context column from column 0 (base context), so the base context constants from `LibContext.sol` are not directly applicable. However, the constants are not exported to or defined in any shared location, meaning any other code that needs to reference the caller-context column or the rainlen row must duplicate these magic numbers. If the context layout ever changes, this file would need to be updated independently.

This is informational because the values are correct for the current context layout and the library is a reference implementation.

### INFO-2: Unused function parameters

**Severity**: INFO

**Description**: The `subParser` function at line 18 accepts three parameters (`uint256, uint256, OperandV2`) but uses none of them. The parameters are unnamed, indicating this is intentional — the function signature must match the function pointer type used in `RainterpreterReferenceExtern`'s sub-parser word pointer array.

This is consistent with the pattern used by `LibExternOpContextSender` and `LibExternOpContextCallingContract`. No security concern; this is purely informational.

---

**No CRITICAL, HIGH, MEDIUM, or LOW findings.** This file is a trivial delegation wrapper with hardcoded safe constants and no logic of its own.
