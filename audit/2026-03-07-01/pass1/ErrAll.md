# A11 Pass 1 Audit: Error Definition Files

**Agent:** A11
**Date:** 2026-03-07
**Scope:** `src/error/Err*.sol` (10 files)

## Files Reviewed

All 10 error definition files were read in full.

## Evidence of Thorough Reading

### `src/error/ErrBitwise.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 13 | `UnsupportedBitwiseShiftAmount` | `uint256 shiftAmount` |
| 19 | `TruncatedBitwiseEncoding` | `uint256 startBit, uint256 length` |
| 23 | `ZeroLengthBitwiseEncoding` | (none) |

- Line 6: Empty workaround contract `ErrBitwise` for Foundry issue #6572
- All 3 errors have `@notice` tags; parameterized errors also have `@param` tags

### `src/error/ErrDeploy.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 11 | `UnknownDeploymentSuite` | `bytes32 suite` |

- Line 6: Empty workaround contract `ErrDeploy`
- NatSpec complete (`@notice`, `@param`)

### `src/error/ErrEval.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 11 | `InputsLengthMismatch` | `uint256 expected, uint256 actual` |
| 15 | `ZeroFunctionPointers` | (none) |

- Line 6: Empty workaround contract `ErrEval`
- Both errors have `@notice` tags; `InputsLengthMismatch` has `@param` tags

### `src/error/ErrExtern.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 14 | `ExternOpcodeOutOfRange` | `uint256 opcode, uint256 fsCount` |
| 20 | `ExternPointersMismatch` | `uint256 opcodeCount, uint256 integrityCount` |
| 25 | `BadOutputsLength` | `uint256 expectedLength, uint256 actualLength` |
| 28 | `ExternOpcodePointersEmpty` | (none) |

- Line 5: Import of `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol` (re-export)
- Line 7-8: Empty workaround contract `ErrExtern`
- All 4 errors have `@notice` tags; parameterized errors have `@param` tags

### `src/error/ErrIntegrity.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 12 | `StackUnderflow` | `uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs` |
| 18 | `StackUnderflowHighwater` | `uint256 opIndex, uint256 stackIndex, uint256 stackHighwater` |
| 24 | `StackAllocationMismatch` | `uint256 stackMaxIndex, uint256 bytecodeAllocation` |
| 29 | `StackOutputsMismatch` | `uint256 stackIndex, uint256 bytecodeOutputs` |
| 35 | `OutOfBoundsConstantRead` | `uint256 opIndex, uint256 constantsLength, uint256 constantRead` |
| 41 | `OutOfBoundsStackRead` | `uint256 opIndex, uint256 stackTopIndex, uint256 stackRead` |
| 47 | `CallOutputsExceedSource` | `uint256 sourceOutputs, uint256 outputs` |
| 53 | `OpcodeOutOfRange` | `uint256 opIndex, uint256 opcodeIndex, uint256 fsCount` |

- Line 6: Empty workaround contract `ErrIntegrity`
- All 8 errors have `@notice` and `@param` tags -- consistent NatSpec

### `src/error/ErrOpList.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 12 | `BadDynamicLength` | `uint256 dynamicLength, uint256 standardOpsLength` |

- Line 6: Empty workaround contract `ErrOpList`
- NatSpec complete (`@notice`, `@param`)

### `src/error/ErrParse.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 10 | `UnexpectedOperand` | (none) |
| 14 | `UnexpectedOperandValue` | (none) |
| 18 | `ExpectedOperand` | (none) |
| 23 | `OperandValuesOverflow` | `uint256 offset` |
| 27 | `UnclosedOperand` | `uint256 offset` |
| 31 | `UnsupportedLiteralType` | `uint256 offset` |
| 35 | `StringTooLong` | `uint256 offset` |
| 40 | `UnclosedStringLiteral` | `uint256 offset` |
| 44 | `HexLiteralOverflow` | `uint256 offset` |
| 48 | `ZeroLengthHexLiteral` | `uint256 offset` |
| 52 | `OddLengthHexLiteral` | `uint256 offset` |
| 56 | `MalformedHexLiteral` | `uint256 offset` |
| 60 | `MissingFinalSemi` | `uint256 offset` |
| 64 | `UnexpectedLHSChar` | `uint256 offset` |
| 68 | `UnexpectedRHSChar` | `uint256 offset` |
| 73 | `ExpectedLeftParen` | `uint256 offset` |
| 77 | `UnexpectedRightParen` | `uint256 offset` |
| 81 | `UnclosedLeftParen` | `uint256 offset` |
| 85 | `UnexpectedComment` | `uint256 offset` |
| 89 | `UnclosedComment` | `uint256 offset` |
| 93 | `MalformedCommentStart` | `uint256 offset` |
| 98 | `DuplicateLHSItem` | `uint256 offset` |
| 102 | `ExcessLHSItems` | `uint256 offset` |
| 106 | `NotAcceptingInputs` | `uint256 offset` |
| 110 | `ExcessRHSItems` | `uint256 offset` |
| 114 | `WordSize` | `string word` |
| 118 | `UnknownWord` | `string word` |
| 121 | `MaxSources` | (none) |
| 124 | `DanglingSource` | (none) |
| 131 | `ParserOutOfBounds` | (none) |
| 135 | `ParseStackOverflow` | (none) |
| 138 | `ParseStackUnderflow` | (none) |
| 142 | `ParenOverflow` | (none) |
| 146 | `NoWhitespaceAfterUsingWordsFrom` | `uint256 offset` |
| 150 | `InvalidSubParser` | `uint256 offset` |
| 154 | `UnclosedSubParseableLiteral` | `uint256 offset` |
| 158 | `SubParseableMissingDispatch` | `uint256 offset` |
| 163 | `BadSubParserResult` | `bytes bytecode` |
| 167 | `OpcodeIOOverflow` | `uint256 offset` |
| 170 | `OperandOverflow` | (none) |
| 175 | `ParseMemoryOverflow` | `uint256 freeMemoryPointer` |
| 179 | `SourceItemOpsOverflow` | (none) |
| 183 | `SourceTotalOpsOverflow` | (none) |
| 187 | `ParenInputOverflow` | (none) |
| 191 | `LineRHSItemsOverflow` | (none) |
| 197 | `UppercaseHexPrefix` | `uint256 offset` |
| 203 | `LHSItemCountOverflow` | `uint256 offset` |

- Line 6-7: Empty workaround contract `ErrParse`
- 47 errors total
- All errors have `@notice` tags; parameterized errors also have `@param` tags

### `src/error/ErrRainType.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 12 | `NotAnAddress` | `uint256 value` |

- Line 6: Empty workaround contract `ErrRainType`
- NatSpec complete (`@notice`, `@param`)

### `src/error/ErrStore.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 10 | `OddSetLength` | `uint256 length` |

- Line 6: Empty workaround contract `ErrStore`
- NatSpec complete (`@notice`, `@param`)

### `src/error/ErrSubParse.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 11 | `ExternDispatchConstantsHeightOverflow` | `uint256 constantsHeight` |
| 16 | `ConstantOpcodeConstantsHeightOverflow` | `uint256 constantsHeight` |
| 21 | `ContextGridOverflow` | `uint256 column, uint256 row` |
| 27 | `SubParserIndexOutOfBounds` | `uint256 index, uint256 length` |
| 33 | `SubParseLiteralDispatchLengthOverflow` | `uint256 dispatchLength` |

- Line 6-7: Empty workaround contract `ErrSubParse`
- All 5 errors have `@notice` and `@param` tags

## Summary

**Total errors across all 10 files:** 73

**Changes since previous audit (2026-03-01):**
- `ErrParse.sol`: Added `SourceTotalOpsOverflow` (line 183), `UppercaseHexPrefix` (line 197), `LHSItemCountOverflow` (line 203)
- `ErrSubParse.sol`: Added `SubParseLiteralDispatchLengthOverflow` (line 33)
- Previous INFORMATIONAL finding (A03-01) about inconsistent `@notice` tagging has been fully resolved -- all doc blocks now consistently use explicit `@notice` tags

## Checks Performed

1. **String revert messages in error files**: None. All files define only custom error types. (Note: `revert("")` in `LibOpConditions.sol` and `require(...)` with string in `LibOpEnsure.sol` are intentional user-facing runtime error messages for the `conditions` and `ensure` opcodes, not system errors, and are outside the scope of these error definition files.)
2. **Unused error definitions**: All 73 errors are referenced in source files beyond their definitions. The 4 new errors are used in: `LibParseState.sol` (`SourceTotalOpsOverflow`), `LibParseLiteral.sol` (`UppercaseHexPrefix`), `LibParse.sol` (`LHSItemCountOverflow`), `LibSubParse.sol` (`SubParseLiteralDispatchLengthOverflow`).
3. **Missing error parameters**: All parameterized errors include contextually appropriate parameters for debugging. Parameter-less errors are used for conditions where the error name alone is sufficient (e.g., `MaxSources()`, `DanglingSource()`, `ParserOutOfBounds()`).
4. **Information leakage**: No errors expose sensitive information. All parameters are operational values (offsets, lengths, indices, opcodes) that aid debugging without revealing private state.
5. **NatSpec consistency**: All errors now have explicit `@notice` tags. All parameterized errors have `@param` tags for each parameter. No NatSpec issues remain.
6. **License and pragma**: All files use `LicenseRef-DCL-1.0` license and `pragma solidity ^0.8.25`.
7. **Workaround contracts**: All files include the empty workaround contract for Foundry issue #6572.

## Findings

No findings. All error definition files are well-structured, consistently documented, appropriately parameterized, and free of security issues. The previous audit's NatSpec inconsistency finding has been resolved.
