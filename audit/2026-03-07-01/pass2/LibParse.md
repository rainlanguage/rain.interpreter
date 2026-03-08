# Pass 2 -- Test Coverage Audit: `src/lib/parse/`

Agent: A04

## Source Files Reviewed

### 1. `src/lib/parse/LibParse.sol`

Library: `LibParse`

| Function | Line |
|---|---|
| `parseWord` | 106 |
| `parseLHS` | 142 |
| `parseRHS` | 220 |
| `parse` | 435 |

**Test coverage:**

- `parseWord`: Directly tested in `LibParse.parseWord.t.sol` (reference implementation, examples, too-long words via `WordSize`, end boundary).
- `parseLHS`: Tested across `LibParse.unexpectedLHS.t.sol` (fuzz `UnexpectedLHSChar`), `LibParse.namedLHS.t.sol` (`DuplicateLHSItem`, cross-source names), `LibParse.lhsOverflow.t.sol` (`LHSItemCountOverflow` at 255/256), `LibParse.comments.t.sol` (`UnexpectedComment` on LHS), `LibParse.ignoredLHS.t.sol`, `LibParse.inputsOnly.t.sol`.
- `parseRHS`: Tested across `LibParse.unexpectedRHS.t.sol` (fuzz `UnexpectedRHSChar`), `LibParse.unexpectedRightParen.t.sol` (`UnexpectedRightParen`), `LibParse.unclosedLeftParen.t.sol` (`UnclosedLeftParen`), `LibParse.parenOverflow.t.sol` (`ParenOverflow`), `LibParse.comments.t.sol` (`UnexpectedComment` on RHS), `LibParse.wordsRHS.t.sol`, `LibParse.operandDisallowed.t.sol` / `operandSingleFull.t.sol` / `operandM1M1.t.sol` / `operandDoublePerByteNoDefault.t.sol` (`ExpectedLeftParen`), `LibParse.literalIntegerDecimal.t.sol`, `LibParse.literalIntegerHex.t.sol`, `LibParse.literalString.t.sol`, `LibParse.nOutput.t.sol` (`ExcessRHSItems`, `ExcessLHSItems`).
- `parse`: Integration coverage via all the above, plus `LibParse.empty.t.sol` (`MaxSources`), `LibParse.missingFinalSemi.t.sol` (`MissingFinalSemi`), `LibParse.sourceInputs.t.sol`.

### 2. `src/lib/parse/LibParseState.sol`

Library: `LibParseState`

| Function | Line |
|---|---|
| `newActiveSourcePointer` | 210 |
| `resetSource` | 231 |
| `newState` | 257 |
| `pushSubParser` | 318 |
| `exportSubParsers` | 338 |
| `snapshotSourceHeadToLineTracker` | 367 |
| `endLine` | 402 |
| `highwater` | 528 |
| `constantValueBloom` | 553 |
| `pushConstantValue` | 561 |
| `pushLiteral` | 591 |
| `pushOpToSource` | 666 |
| `endSource` | 773 |
| `buildBytecode` | 915 |
| `buildConstants` | 1009 |
| `checkParseMemoryOverflow` | 1059 |

**Test coverage:**

- `newActiveSourcePointer`: `LibParseState.newActiveSourcePointer.t.sol` (pointer alignment, linking).
- `resetSource`: Tested indirectly via `LibParseState.endSource.t.sol` (called from `endSource`).
- `newState`: Used in 47+ test files as initialization utility. Indirect coverage is thorough.
- `pushSubParser`: `LibParseState.pushSubParser.t.sol` (linked list).
- `exportSubParsers`: `LibParseState.exportSubParsers.t.sol` (round trip).
- `snapshotSourceHeadToLineTracker`: `LibParseState.overflow.t.sol` (`LineRHSItemsOverflow`).
- `endLine`: `LibParseState.endLine.t.sol` (`NotAcceptingInputs`), `LibParseState.endLine.OpcodeIOOverflow.t.sol` (IO byte overflow for inputs and outputs).
- `highwater`: `LibParseState.highwater.t.sol` (`ParseStackOverflow` at 63 items, `ExcessRHSItems`), `LibParseState.highwaterOverflow.t.sol` (direct boundary test).
- `constantValueBloom`: `LibParseState.constantValueBloom.t.sol` (single-bit property).
- `pushConstantValue`: `LibParseState.pushConstantValue.t.sol` (constants linked list).
- `pushLiteral`: `LibParseState.pushLiteral.t.sol` (literal dedup and constant opcode).
- `pushOpToSource`: `LibParseState.pushOpToSource.t.sol` (op encoding, FSM flags, slot overflow, `SourceItemOpsOverflow`), `LibParseState.parenInputOverflow.t.sol` (`ParenInputOverflow`).
- `endSource`: `LibParseState.endSource.t.sol` (source finalization, state reset, `MaxSources`), `LibParseState.endSourceTotalOpsOverflow.t.sol` (`SourceTotalOpsOverflow`).
- `buildBytecode`: `LibParseState.buildBytecode.t.sol`, `LibParseState.danglingSource.t.sol` (`DanglingSource`).
- `buildConstants`: `LibParseState.buildConstants.t.sol` (constants array from linked list).
- `checkParseMemoryOverflow`: `LibParseState.checkParseMemoryOverflow.t.sol` (memory boundary at 0x10000).

### 3. `src/lib/parse/LibParseOperand.sol`

Library: `LibParseOperand`

| Function | Line |
|---|---|
| `parseOperand` | 38 |
| `handleOperand` | 139 |
| `handleOperandDisallowed` | 156 |
| `handleOperandDisallowedAlwaysOne` | 167 |
| `handleOperandSingleFull` | 180 |
| `handleOperandSingleFullNoDefault` | 204 |
| `handleOperandDoublePerByteNoDefault` | 228 |
| `handleOperand8M1M1` | 261 |
| `handleOperandM1M1` | 313 |

**Test coverage:**

- `parseOperand`: `LibParseOperand.parseOperand.t.sol` (1-4 values, overflow, unclosed paren).
- `handleOperand`: `LibParseOperand.handleOperand.t.sol` (dispatch to handlers).
- `handleOperandDisallowed`: `LibParseOperand.handleOperandDisallowed.t.sol`.
- `handleOperandDisallowedAlwaysOne`: `LibParseOperand.handleOperandDisallowedAlwaysOne.t.sol`.
- `handleOperandSingleFull`: `LibParseOperand.handleOperandSingleFull.t.sol`.
- `handleOperandSingleFullNoDefault`: `LibParseOperand.handleOperandSingleFullNoDefault.t.sol`.
- `handleOperandDoublePerByteNoDefault`: `LibParseOperand.handleOperandDoublePerByteNoDefault.t.sol`.
- `handleOperand8M1M1`: `LibParseOperand.handleOperand8M1M1.t.sol`.
- `handleOperandM1M1`: `LibParseOperand.handleOperandM1M1.t.sol`.

### 4. `src/lib/parse/LibParseError.sol`

Library: `LibParseError`

| Function | Line |
|---|---|
| `parseErrorOffset` | 13 |
| `handleErrorSelector` | 26 |

**Test coverage:**

- Both functions tested in `LibParseError.t.sol` (offset calculation and selector-based revert).

### 5. `src/lib/parse/LibParseInterstitial.sol`

Library: `LibParseInterstitial`

| Function | Line |
|---|---|
| `skipComment` | 28 |
| `skipWhitespace` | 96 |
| `parseInterstitial` | 111 |

**Test coverage:**

- All three functions tested in `LibParseInterstitial.t.sol` (fuzz tests for all three, `UnclosedComment`, `MalformedCommentStart`).
- Additional comment tests in `LibParse.comments.t.sol`.

### 6. `src/lib/parse/LibParsePragma.sol`

Library: `LibParsePragma`

| Function | Line |
|---|---|
| `parsePragma` | 41 |

**Test coverage:**

- `LibParsePragma.keyword.t.sol` (extensive tests including OOB fix, pragma keyword parsing).

### 7. `src/lib/parse/LibParseStackName.sol`

Library: `LibParseStackName`

| Function | Line |
|---|---|
| `pushStackName` | 31 |
| `stackNameIndex` | 62 |

**Test coverage:**

- `LibParseStackName.t.sol` (push, lookup, bloom false positive, many names).

### 8. `src/lib/parse/LibParseStackTracker.sol`

Library: `LibParseStackTracker`

| Function | Line |
|---|---|
| `pushInputs` | 25 |
| `push` | 47 |
| `pop` | 74 |

**Test coverage:**

- `LibParseStackTracker.t.sol` (push/pop/pushInputs overflow/underflow/watermark).

### 9. `src/lib/parse/LibSubParse.sol`

Library: `LibSubParse`

| Function | Line |
|---|---|
| `subParserContext` | 49 |
| `subParserConstant` | 97 |
| `subParserExtern` | 162 |
| `subParseWordSlice` | 216 |
| `subParseWords` | 324 |
| `subParseLiteral` | 350 |
| `consumeSubParseWordInputData` | 413 |
| `consumeSubParseLiteralInputData` | 444 |

**Test coverage:**

- `subParserContext`: `LibSubParse.subParserContext.t.sol` (context opcode generation, `ContextGridOverflow`).
- `subParserConstant`: `LibSubParse.subParserConstant.t.sol` (constant opcode, `ConstantOpcodeConstantsHeightOverflow`).
- `subParserExtern`: `LibSubParse.subParserExtern.t.sol` (extern opcode, `ExternDispatchConstantsHeightOverflow`).
- `subParseWordSlice`: No dedicated test file. Tested indirectly via `LibSubParse.subParseWords.t.sol` (which calls `subParseWords`, which calls `subParseWordSlice` for each source), and via `LibSubParse.unknownWord.t.sol` (`UnknownWord`), `LibSubParse.badSubParserResult.t.sol` (`BadSubParserResult`).
- `subParseWords`: `LibSubParse.subParseWords.t.sol` (multi-source resolution, no-unknown pass-through).
- `subParseLiteral`: `LibSubParse.subParseLiteral.t.sol` (single/multiple sub-parsers, accept/reject, empty body, `UnsupportedLiteralType`, `SubParseLiteralDispatchLengthOverflow`).
- `consumeSubParseWordInputData`: `LibSubParse.consumeSubParseWordInputData.t.sol` (header unpacking).
- `consumeSubParseLiteralInputData`: `LibSubParse.consumeSubParseLiteralInputData.t.sol` (literal data unpacking).

---

## Findings

No findings.

All functions across all 9 source files have direct or thorough indirect test coverage. Every error path identified in the source code has at least one dedicated test that triggers and asserts the specific error. Edge cases (overflow boundaries, underflow, bloom false positives, paren nesting limits, LHS item count limits, memory overflow) are explicitly tested with both boundary and over-boundary values.
