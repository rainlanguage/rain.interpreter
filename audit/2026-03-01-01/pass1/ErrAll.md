# A03 Pass 1 Audit: Error Definition Files

**Agent:** A03
**Date:** 2026-03-01
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

- Line 6: Empty workaround contract `ErrBitwise`
- Line 5: Import: none beyond the Foundry workaround
- Lines 22-23: `ZeroLengthBitwiseEncoding` doc block lacks `@notice` tag (other errors in file use it)

### `src/error/ErrDeploy.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 11 | `UnknownDeploymentSuite` | `bytes32 suite` |

- Line 6: Empty workaround contract `ErrDeploy`

### `src/error/ErrEval.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 11 | `InputsLengthMismatch` | `uint256 expected, uint256 actual` |
| 15 | `ZeroFunctionPointers` | (none) |

- Line 6: Empty workaround contract `ErrEval`
- Lines 13-15: `ZeroFunctionPointers` doc block lacks `@notice` tag (`InputsLengthMismatch` uses it)

### `src/error/ErrExtern.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 14 | `ExternOpcodeOutOfRange` | `uint256 opcode, uint256 fsCount` |
| 20 | `ExternPointersMismatch` | `uint256 opcodeCount, uint256 integrityCount` |
| 25 | `BadOutputsLength` | `uint256 expectedLength, uint256 actualLength` |
| 28 | `ExternOpcodePointersEmpty` | (none) |

- Line 5: Import of `NotAnExternContract` from `rain.interpreter.interface/error/ErrExtern.sol` (re-export)
- Line 7: Empty workaround contract `ErrExtern`
- Lines 27-28: `ExternOpcodePointersEmpty` doc block lacks `@notice` tag (other errors in file use it)

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
- All errors have `@notice` and `@param` tags -- consistent NatSpec

### `src/error/ErrOpList.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 12 | `BadDynamicLength` | `uint256 dynamicLength, uint256 standardOpsLength` |

- Line 6: Empty workaround contract `ErrOpList`
- NatSpec complete

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
| 127 | `ParserOutOfBounds` | (none) |
| 131 | `ParseStackOverflow` | (none) |
| 134 | `ParseStackUnderflow` | (none) |
| 138 | `ParenOverflow` | (none) |
| 142 | `NoWhitespaceAfterUsingWordsFrom` | `uint256 offset` |
| 146 | `InvalidSubParser` | `uint256 offset` |
| 150 | `UnclosedSubParseableLiteral` | `uint256 offset` |
| 154 | `SubParseableMissingDispatch` | `uint256 offset` |
| 159 | `BadSubParserResult` | `bytes bytecode` |
| 163 | `OpcodeIOOverflow` | `uint256 offset` |
| 166 | `OperandOverflow` | (none) |
| 171 | `ParseMemoryOverflow` | `uint256 freeMemoryPointer` |
| 175 | `SourceItemOpsOverflow` | (none) |
| 179 | `ParenInputOverflow` | (none) |
| 183 | `LineRHSItemsOverflow` | (none) |

- Line 7: Empty workaround contract `ErrParse`
- Mixed NatSpec: some errors have `@notice`/`@param`, others have untagged `///` only

### `src/error/ErrRainType.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 12 | `NotAnAddress` | `uint256 value` |

- Line 6: Empty workaround contract `ErrRainType`
- NatSpec complete

### `src/error/ErrStore.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 10 | `OddSetLength` | `uint256 length` |

- Line 6: Empty workaround contract `ErrStore`
- NatSpec complete

### `src/error/ErrSubParse.sol`

| Line | Error | Parameters |
|------|-------|------------|
| 11 | `ExternDispatchConstantsHeightOverflow` | `uint256 constantsHeight` |
| 16 | `ConstantOpcodeConstantsHeightOverflow` | `uint256 constantsHeight` |
| 21 | `ContextGridOverflow` | `uint256 column, uint256 row` |
| 27 | `SubParserIndexOutOfBounds` | `uint256 index, uint256 length` |

- Line 7: Empty workaround contract `ErrSubParse`
- NatSpec complete

## Usage Verification

All errors were searched for references in `src/` (excluding their definition files). Results:

| Error | Used In |
|-------|---------|
| `UnsupportedBitwiseShiftAmount` | `LibOpShiftBitsLeft.sol`, `LibOpShiftBitsRight.sol` |
| `TruncatedBitwiseEncoding` | `LibOpEncodeBits.sol` |
| `ZeroLengthBitwiseEncoding` | `LibOpEncodeBits.sol` |
| `UnknownDeploymentSuite` | `script/Deploy.sol` only (not in `src/`) |
| `InputsLengthMismatch` | `LibEval.sol` |
| `ZeroFunctionPointers` | `Rainterpreter.sol` |
| `ExternOpcodeOutOfRange` | `BaseRainterpreterExtern.sol` |
| `ExternPointersMismatch` | `BaseRainterpreterExtern.sol` |
| `BadOutputsLength` | `LibOpExtern.sol` |
| `ExternOpcodePointersEmpty` | `BaseRainterpreterExtern.sol` |
| `StackUnderflow` | `LibIntegrityCheck.sol` |
| `StackUnderflowHighwater` | `LibIntegrityCheck.sol` |
| `StackAllocationMismatch` | `LibIntegrityCheck.sol` |
| `StackOutputsMismatch` | `LibIntegrityCheck.sol` |
| `OutOfBoundsConstantRead` | `LibOpConstant.sol` |
| `OutOfBoundsStackRead` | `LibOpStack.sol` |
| `CallOutputsExceedSource` | `LibOpCall.sol` |
| `OpcodeOutOfRange` | `LibIntegrityCheck.sol` |
| `BadDynamicLength` | `LibAllStandardOps.sol`, `RainterpreterReferenceExtern.sol` |
| `NotAnAddress` | 10 ERC op libraries |
| `OddSetLength` | `RainterpreterStore.sol`, `Rainterpreter.sol` |
| `ExternDispatchConstantsHeightOverflow` | `LibSubParse.sol` |
| `ConstantOpcodeConstantsHeightOverflow` | `LibSubParse.sol` |
| `ContextGridOverflow` | `LibSubParse.sol` |
| `SubParserIndexOutOfBounds` | `BaseRainterpreterSubParser.sol` |
| All 38 ErrParse errors | Various parse libraries (verified individually) |

All error selectors were computed and confirmed unique -- no 4-byte selector collisions.

## Checks Performed

1. **Unused error definitions**: No errors are defined without any reference in the codebase.
2. **String message reverts**: None found. All files use custom error types exclusively.
3. **Parameter type issues**: No ABI encoding problems identified. All parameter types are appropriate for their purpose.

## Findings

### A03-01 (INFORMATIONAL): Inconsistent NatSpec tagging across error files

**Files:**
- `src/error/ErrBitwise.sol` line 22 (`ZeroLengthBitwiseEncoding`)
- `src/error/ErrEval.sol` line 13 (`ZeroFunctionPointers`)
- `src/error/ErrExtern.sol` line 27 (`ExternOpcodePointersEmpty`)
- `src/error/ErrParse.sol` lines 8, 12, 16, 120, 123, 126, 129, 133, 136, 165, 173, 177, 181 (13 errors total)

**Description:** Some errors use `@notice` and `@param` NatSpec tags while other errors in the same file use plain untagged `///` comments. Per Solidity NatSpec rules, untagged `///` lines are implicitly `@notice` when no tags are present in the block, so this is not a correctness issue. However, the inconsistency within files reduces readability and could lead to mistakes if a tagged line (e.g. `@param`) is later added to an untagged block without also adding `@notice`.

**Severity:** INFORMATIONAL -- no functional impact, purely documentation consistency.

---

No LOW or higher severity findings were identified in the error definition files. These files define only custom error types with no logic, no storage, no external calls, and no access control. The security surface is minimal. All errors are used in the codebase, all use custom error types (no string reverts), and all parameter types are appropriate.
