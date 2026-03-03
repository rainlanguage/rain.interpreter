# Pass 3: NatSpec Documentation Review -- Error Definition Files

## Scope

All 10 error definition files in `src/error/`:

| File | Errors | Status |
|------|--------|--------|
| `ErrBitwise.sol` | 3 | 1 finding |
| `ErrDeploy.sol` | 1 | Clean |
| `ErrEval.sol` | 2 | 1 finding |
| `ErrExtern.sol` | 4 | 1 finding |
| `ErrIntegrity.sol` | 8 | Clean |
| `ErrOpList.sol` | 1 | Clean |
| `ErrParse.sol` | 36 | 1 finding (13 errors) |
| `ErrRainType.sol` | 1 | Clean |
| `ErrStore.sol` | 1 | Clean |
| `ErrSubParse.sol` | 4 | Clean |

## Evidence

### `src/error/ErrBitwise.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 13 | `UnsupportedBitwiseShiftAmount` | `uint256 shiftAmount` | Yes | Yes |
| 19 | `TruncatedBitwiseEncoding` | `uint256 startBit, uint256 length` | Yes | Yes |
| 23 | `ZeroLengthBitwiseEncoding` | (none) | **No** | N/A |

Line 21-22: Doc block uses `///` without `@notice`. Sibling errors at lines 8 and 15 use `@notice`.

### `src/error/ErrDeploy.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 11 | `UnknownDeploymentSuite` | `bytes32 suite` | Yes | Yes |

Clean.

### `src/error/ErrEval.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 11 | `InputsLengthMismatch` | `uint256 expected, uint256 actual` | Yes | Yes |
| 15 | `ZeroFunctionPointers` | (none) | **No** | N/A |

Line 13-14: Doc block uses `///` without `@notice`. Sibling error at line 8 uses `@notice`.

### `src/error/ErrExtern.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 14 | `ExternOpcodeOutOfRange` | `uint256 opcode, uint256 fsCount` | Yes | Yes |
| 20 | `ExternPointersMismatch` | `uint256 opcodeCount, uint256 integrityCount` | Yes | Yes |
| 25 | `BadOutputsLength` | `uint256 expectedLength, uint256 actualLength` | Yes | Yes |
| 28 | `ExternOpcodePointersEmpty` | (none) | **No** | N/A |

Line 27: Doc block uses `///` without `@notice`. Sibling errors at lines 10, 16, 22 use `@notice`.

### `src/error/ErrIntegrity.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 12 | `StackUnderflow` | `uint256 opIndex, uint256 stackIndex, uint256 calculatedInputs` | Yes | Yes |
| 18 | `StackUnderflowHighwater` | `uint256 opIndex, uint256 stackIndex, uint256 stackHighwater` | Yes | Yes |
| 24 | `StackAllocationMismatch` | `uint256 stackMaxIndex, uint256 bytecodeAllocation` | Yes | Yes |
| 29 | `StackOutputsMismatch` | `uint256 stackIndex, uint256 bytecodeOutputs` | Yes | Yes |
| 35 | `OutOfBoundsConstantRead` | `uint256 opIndex, uint256 constantsLength, uint256 constantRead` | Yes | Yes |
| 41 | `OutOfBoundsStackRead` | `uint256 opIndex, uint256 stackTopIndex, uint256 stackRead` | Yes | Yes |
| 47 | `CallOutputsExceedSource` | `uint256 sourceOutputs, uint256 outputs` | Yes | Yes |
| 53 | `OpcodeOutOfRange` | `uint256 opIndex, uint256 opcodeIndex, uint256 fsCount` | Yes | Yes |

Clean.

### `src/error/ErrOpList.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 12 | `BadDynamicLength` | `uint256 dynamicLength, uint256 standardOpsLength` | Yes | Yes |

Clean.

### `src/error/ErrParse.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 10 | `UnexpectedOperand` | (none) | **No** | N/A |
| 14 | `UnexpectedOperandValue` | (none) | **No** | N/A |
| 18 | `ExpectedOperand` | (none) | **No** | N/A |
| 23 | `OperandValuesOverflow` | `uint256 offset` | Yes | Yes |
| 27 | `UnclosedOperand` | `uint256 offset` | Yes | Yes |
| 31 | `UnsupportedLiteralType` | `uint256 offset` | Yes | Yes |
| 35 | `StringTooLong` | `uint256 offset` | Yes | Yes |
| 40 | `UnclosedStringLiteral` | `uint256 offset` | Yes | Yes |
| 44 | `HexLiteralOverflow` | `uint256 offset` | Yes | Yes |
| 48 | `ZeroLengthHexLiteral` | `uint256 offset` | Yes | Yes |
| 52 | `OddLengthHexLiteral` | `uint256 offset` | Yes | Yes |
| 56 | `MalformedHexLiteral` | `uint256 offset` | Yes | Yes |
| 60 | `MissingFinalSemi` | `uint256 offset` | Yes | Yes |
| 64 | `UnexpectedLHSChar` | `uint256 offset` | Yes | Yes |
| 68 | `UnexpectedRHSChar` | `uint256 offset` | Yes | Yes |
| 73 | `ExpectedLeftParen` | `uint256 offset` | Yes | Yes |
| 77 | `UnexpectedRightParen` | `uint256 offset` | Yes | Yes |
| 81 | `UnclosedLeftParen` | `uint256 offset` | Yes | Yes |
| 85 | `UnexpectedComment` | `uint256 offset` | Yes | Yes |
| 89 | `UnclosedComment` | `uint256 offset` | Yes | Yes |
| 93 | `MalformedCommentStart` | `uint256 offset` | Yes | Yes |
| 98 | `DuplicateLHSItem` | `uint256 offset` | Yes | Yes |
| 102 | `ExcessLHSItems` | `uint256 offset` | Yes | Yes |
| 106 | `NotAcceptingInputs` | `uint256 offset` | Yes | Yes |
| 110 | `ExcessRHSItems` | `uint256 offset` | Yes | Yes |
| 114 | `WordSize` | `string word` | Yes | Yes |
| 118 | `UnknownWord` | `string word` | Yes | Yes |
| 121 | `MaxSources` | (none) | **No** | N/A |
| 124 | `DanglingSource` | (none) | **No** | N/A |
| 127 | `ParserOutOfBounds` | (none) | **No** | N/A |
| 131 | `ParseStackOverflow` | (none) | **No** | N/A |
| 134 | `ParseStackUnderflow` | (none) | **No** | N/A |
| 138 | `ParenOverflow` | (none) | **No** | N/A |
| 163 | `OpcodeIOOverflow` | `uint256 offset` | Yes | Yes |
| 166 | `OperandOverflow` | (none) | **No** | N/A |
| 171 | `ParseMemoryOverflow` | `uint256 freeMemoryPointer` | Yes | Yes |
| 175 | `SourceItemOpsOverflow` | (none) | **No** | N/A |
| 179 | `ParenInputOverflow` | (none) | **No** | N/A |
| 183 | `LineRHSItemsOverflow` | (none) | **No** | N/A |

13 errors use `///` without `@notice` while 23 sibling errors in the same file use `@notice`.

### `src/error/ErrRainType.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 12 | `NotAnAddress` | `uint256 value` | Yes | Yes |

Clean.

### `src/error/ErrStore.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 10 | `OddSetLength` | `uint256 length` | Yes | Yes |

Clean.

### `src/error/ErrSubParse.sol`

| Line | Error | Params | `@notice` | `@param` |
|------|-------|--------|-----------|----------|
| 11 | `ExternDispatchConstantsHeightOverflow` | `uint256 constantsHeight` | Yes | Yes |
| 16 | `ConstantOpcodeConstantsHeightOverflow` | `uint256 constantsHeight` | Yes | Yes |
| 21 | `ContextGridOverflow` | `uint256 column, uint256 row` | Yes | Yes |
| 27 | `SubParserIndexOutOfBounds` | `uint256 index, uint256 length` | Yes | Yes |

Clean.

## Findings

### P3-ERR-1 (LOW): Missing `@notice` tags on 16 errors across 4 files

**Files and lines:**

- `src/error/ErrBitwise.sol` line 21: `ZeroLengthBitwiseEncoding`
- `src/error/ErrEval.sol` line 13: `ZeroFunctionPointers`
- `src/error/ErrExtern.sol` line 27: `ExternOpcodePointersEmpty`
- `src/error/ErrParse.sol` lines 8, 12, 16, 120, 123, 126, 129, 133, 136, 165, 173, 177, 181: `UnexpectedOperand`, `UnexpectedOperandValue`, `ExpectedOperand`, `MaxSources`, `DanglingSource`, `ParserOutOfBounds`, `ParseStackOverflow`, `ParseStackUnderflow`, `ParenOverflow`, `OperandOverflow`, `SourceItemOpsOverflow`, `ParenInputOverflow`, `LineRHSItemsOverflow`

**Convention violated:** Per CLAUDE.md: "when a doc block contains any explicit tag (e.g. `@title`), all entries must be explicitly tagged -- untagged lines continue the previous tag, not implicit `@notice`." While these errors use plain `///` (no tags at all), sibling errors in each of these four files use `@notice`. The mix of tagged and untagged doc styles within a single file is inconsistent and could cause tooling to render the documentation differently depending on which NatSpec interpretation is used.

**Fix:** Add `@notice` to all 16 doc blocks. See `.fixes/P3-ERR-1.md`.
