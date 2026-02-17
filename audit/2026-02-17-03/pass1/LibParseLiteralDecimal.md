# Pass 1 (Security) - LibParseLiteralDecimal.sol

## File

`src/lib/parse/literal/LibParseLiteralDecimal.sol`

## Evidence of Thorough Reading

### Library Name

`LibParseLiteralDecimal`

### Functions

| Function | Line | Visibility |
|----------|------|------------|
| `parseDecimalFloatPacked(ParseState memory, uint256, uint256)` | 15 | internal pure |

### Errors/Events/Structs Defined

None defined directly in this file. The library relies on:
- Errors from `rain.math.float` via `LibParseDecimalFloat.parseDecimalFloatInline()` (returns error selectors as `bytes4` rather than reverting directly)
- Errors from `LibDecimalFloat.packLossless()` which reverts with `CoefficientOverflow(int256, int256)` if the parsed value cannot be losslessly packed into a `Float`

### Imports

- `ParseState` from `../LibParseState.sol`
- `LibParseError` from `../LibParseError.sol`
- `LibParseDecimalFloat`, `Float` from `rain.math.float/lib/parse/LibParseDecimalFloat.sol`
- `LibDecimalFloat` from `rain.math.float/lib/LibDecimalFloat.sol`

### Using Directives

- `using LibParseError for ParseState`

## Analysis

This is a very small library (25 lines total, single function) that acts as a thin wrapper. The function:

1. Calls `LibParseDecimalFloat.parseDecimalFloatInline(start, end)` which returns an error selector, a cursor, a signed coefficient, and an exponent.
2. Calls `state.handleErrorSelector(cursor, errorSelector)` to revert if the parsing produced an error. The `handleErrorSelector` function in `LibParseError` uses inline assembly to revert with the error selector and a byte offset if the selector is non-zero.
3. Calls `LibDecimalFloat.packLossless(signedCoefficient, exponent)` to pack the parsed values into a `Float`, which internally calls `packLossy` and reverts with `CoefficientOverflow` if the conversion is lossy.
4. Returns the cursor and the unwrapped `Float` as `bytes32`.

## Findings

### 1. INFO - No Assembly Blocks

This file contains no assembly blocks. All assembly is in the called libraries (`LibParseError.handleErrorSelector` and `LibDecimalFloat.packLossless`). Those blocks are out of scope for this file-level review but were examined to understand the error flow. The assembly in `handleErrorSelector` writes to scratch space (offsets 0 and 4, within the 0x00-0x3f range) and is tagged `memory-safe`. The assembly in `packLossy` is also tagged `memory-safe`.

### 2. INFO - No Unchecked Arithmetic

This file has no `unchecked` blocks. All arithmetic is in the external library calls which handle their own overflow checking. `parseDecimalFloatInline` does use `unchecked` internally but returns error selectors rather than reverting, and those errors are properly handled by `handleErrorSelector` on line 22.

### 3. INFO - No String Revert Messages

All error paths in this file and its immediate call chain use custom errors:
- `handleErrorSelector` reverts with the 4-byte error selector from the parser (e.g., `ParseEmptyDecimalString`, `MalformedDecimalPoint`, `MalformedExponentDigits`, `ParseDecimalPrecisionLoss`, `ParseDecimalFloatExcessCharacters`)
- `packLossless` reverts with `CoefficientOverflow`

No `revert("...")` string messages are used.

### 4. INFO - Delegation to External Library

The security of this function depends entirely on the correctness of `rain.math.float` (`LibParseDecimalFloat` and `LibDecimalFloat`). This library is imported as a git submodule. Any vulnerabilities in the parsing or packing logic would flow through this wrapper. The wrapper itself correctly propagates all error conditions and does not suppress or ignore any return values.

## Summary

No security issues found in this file. The library is a minimal 8-line wrapper function that correctly delegates to `rain.math.float` for parsing and packing, and properly handles all error propagation via `handleErrorSelector`. The file has no assembly, no unchecked arithmetic, and no string-based reverts.
