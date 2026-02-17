# Pass 2 — Test Coverage: LibParseState

**Source:** `src/lib/parse/LibParseState.sol`
**Tests:**
- `test/src/lib/parse/LibParseState.constantValueBloom.t.sol`
- `test/src/lib/parse/LibParseState.exportSubParsers.t.sol`
- `test/src/lib/parse/LibParseState.newActiveSourcePointer.t.sol`
- `test/src/lib/parse/LibParseState.overflow.t.sol`
- `test/src/lib/parse/LibParseState.pushConstantValue.t.sol`
- `test/src/lib/parse/LibParseState.pushSubParser.t.sol`
- `test/src/lib/parse/LibParseState.checkParseMemoryOverflow.t.sol`
- `test/src/lib/parse/LibParseState.offsets.t.sol`

## Source Inventory

### Functions

| Function | Line | Visibility |
|---|---|---|
| `newActiveSourcePointer(uint256)` | 181 | internal pure |
| `resetSource(ParseState memory)` | 202 | internal pure |
| `newState(bytes, bytes, bytes, bytes)` | 228 | internal pure |
| `pushSubParser(ParseState memory, uint256, bytes32)` | 289 | internal pure |
| `exportSubParsers(ParseState memory)` | 309 | internal pure |
| `snapshotSourceHeadToLineTracker(ParseState memory)` | 338 | internal pure |
| `endLine(ParseState memory, uint256)` | 373 | internal pure |
| `highwater(ParseState memory)` | 499 | internal pure |
| `constantValueBloom(bytes32)` | 524 | internal pure |
| `pushConstantValue(ParseState memory, bytes32)` | 532 | internal pure |
| `pushLiteral(ParseState memory, uint256, uint256)` | 562 | internal pure |
| `pushOpToSource(ParseState memory, uint256, OperandV2)` | 637 | internal pure |
| `endSource(ParseState memory)` | 744 | internal pure |
| `buildBytecode(ParseState memory)` | 877 | internal pure |
| `buildConstants(ParseState memory)` | 971 | internal pure |
| `checkParseMemoryOverflow()` | 1021 | internal pure |

### Errors Used

| Error | Used In | Line |
|---|---|---|
| `DanglingSource()` | `buildBytecode` | 895 |
| `MaxSources()` | `endSource` | 757 |
| `ParseMemoryOverflow(uint256)` | `checkParseMemoryOverflow` | 1027 |
| `ParseStackOverflow()` | `highwater` | 515 |
| `UnclosedLeftParen(uint256)` | `endLine` | 382 |
| `ExcessRHSItems(uint256)` | `endLine` | 436 |
| `ExcessLHSItems(uint256)` | `endLine` | 438 |
| `NotAcceptingInputs(uint256)` | `endLine` | 417 |
| `UnsupportedLiteralType(uint256)` | `pushLiteral` | 569 |
| `OpcodeIOOverflow(uint256)` | `endLine` | 479 |
| `InvalidSubParser(uint256)` | `pushSubParser` | 291 |
| `SourceItemOpsOverflow()` | `pushOpToSource` | 662 |
| `ParenInputOverflow()` | `pushOpToSource` | 711 |
| `LineRHSItemsOverflow()` | `snapshotSourceHeadToLineTracker` | 363 |

### Constants Defined

| Constant | Line | Value |
|---|---|---|
| `EMPTY_ACTIVE_SOURCE` | 31 | `0x20` |
| `FSM_YANG_MASK` | 33 | `1` |
| `FSM_WORD_END_MASK` | 34 | `1 << 1` |
| `FSM_ACCEPTING_INPUTS_MASK` | 35 | `1 << 2` |
| `FSM_ACTIVE_SOURCE_MASK` | 39 | `1 << 3` |
| `FSM_DEFAULT` | 45 | `FSM_ACCEPTING_INPUTS_MASK` |
| `OPERAND_VALUES_LENGTH` | 56 | `4` |
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | 60 | `0x20` |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | 64 | `0x21` |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | 68 | `0x60` |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | 72 | `0xa0` |

## Test Coverage Analysis

### Direct Tests

| Test File | Functions Covered | Error Paths Covered |
|---|---|---|
| `constantValueBloom.t.sol` | `constantValueBloom` | None |
| `exportSubParsers.t.sol` | `exportSubParsers`, `pushSubParser` | None |
| `newActiveSourcePointer.t.sol` | `newActiveSourcePointer` | None |
| `overflow.t.sol` | (integration via parse) | `SourceItemOpsOverflow`, `LineRHSItemsOverflow` |
| `pushConstantValue.t.sol` | `pushConstantValue`, `newState`, `constantValueBloom` | None |
| `pushSubParser.t.sol` | `pushSubParser` | `InvalidSubParser` |
| `checkParseMemoryOverflow.t.sol` | `checkParseMemoryOverflow` | `ParseMemoryOverflow` |
| `offsets.t.sol` | Offset constants validation | None |

### Indirect Coverage (via integration tests)

| Error/Function | Indirect Test Files |
|---|---|
| `MaxSources()` | `LibParse.empty.t.sol` (line 507) |
| `ExcessRHSItems(uint256)` | `LibParse.nOutput.t.sol`, `LibOpEnsure.t.sol` |
| `ExcessLHSItems(uint256)` | `LibParse.nOutput.t.sol` |
| `UnclosedLeftParen(uint256)` | `LibParse.unclosedLeftParen.t.sol` |
| `NotAcceptingInputs(uint256)` | Not found in any test |
| `UnsupportedLiteralType(uint256)` | `ParseLiteralTest.sol` (abstract helper) |

## Findings

### A43-1: No direct unit test for endLine() (HIGH)

`endLine` is the most complex function in the library (lines 373-492, ~120 lines). It handles paren validation, LHS/RHS reconciliation, opcode I/O merging, and stack tracker updates. It is only tested indirectly through full parser integration tests. No unit test isolates its behavior with controlled state inputs.

**Evidence:** No test file named `LibParseState.endLine.t.sol` exists. The function is called through `LibParse.parse()` in integration tests.

### A43-2: NotAcceptingInputs error path never tested (MEDIUM)

`endLine` reverts with `NotAcceptingInputs` when `lineRHSTopLevel == 0` and the FSM is not accepting inputs (line 416-417). No test -- direct or indirect -- triggers this revert.

**Evidence:** Grep for `NotAcceptingInputs` across `test/` returns zero results.

### A43-3: OpcodeIOOverflow error path never tested (MEDIUM)

`endLine` reverts with `OpcodeIOOverflow` when `opOutputs > 0x0F || opInputs > 0x0F` (lines 478-480). No test triggers this revert.

**Evidence:** Grep for `OpcodeIOOverflow` across `test/` returns zero results.

### A43-4: DanglingSource error path never tested (MEDIUM)

`buildBytecode` reverts with `DanglingSource` when `activeSource != EMPTY_ACTIVE_SOURCE` (line 894-896). No test constructs a state with a non-empty active source and calls `buildBytecode`.

**Evidence:** Grep for `DanglingSource` across `test/` returns zero results.

### A43-5: ParenInputOverflow error path never tested (MEDIUM)

`pushOpToSource` reverts with `ParenInputOverflow` when the paren input counter reaches 0xFF (line 699-711). No test triggers this revert.

**Evidence:** Grep for `ParenInputOverflow` across `test/` returns zero results.

### A43-6: ParseStackOverflow in highwater() never tested (MEDIUM)

`highwater` reverts with `ParseStackOverflow` when `newStackRHSOffset >= 0x3f` (line 514-516). No test triggers this revert path. The `ParseStackOverflow` error is shared with `LibParseStackTracker`, and no test for either location exists.

**Evidence:** Grep for `ParseStackOverflow` across `test/` returns zero results.

### A43-7: No direct unit tests for pushOpToSource() (MEDIUM)

`pushOpToSource` (lines 637-737) handles opcode writing, paren tracking, top-level counter increment, FSM updates, and linked-list allocation. It is only exercised through the full parser. A bug in its assembly (e.g., the `mstore8` counter increment at line 659, or the paren tracker pointer arithmetic at lines 686-708) would be hard to isolate via integration tests alone.

**Evidence:** No test file named `LibParseState.pushOpToSource.t.sol` exists.

### A43-8: No direct unit tests for endSource() (MEDIUM)

`endSource` (lines 744-870) performs the complex RTL-to-LTR reordering of opcodes, source prefix writing, and linked-list traversal. It is only exercised through full parser integration tests.

**Evidence:** No test file named `LibParseState.endSource.t.sol` exists.

### A43-9: No direct unit tests for buildBytecode() (MEDIUM)

`buildBytecode` (lines 877-963) assembles all sources into a single contiguous byte array. Only exercised through full parser integration tests. Its relative pointer computation and memory copy logic is untested in isolation.

**Evidence:** No test file named `LibParseState.buildBytecode.t.sol` exists.

### A43-10: No direct unit tests for buildConstants() (LOW)

`buildConstants` (lines 971-1007) traverses the constants linked list and writes values in reverse order. While `pushConstantValue` has direct tests, the final array construction is only tested through integration.

**Evidence:** No test file named `LibParseState.buildConstants.t.sol` exists. The `pushConstantValue` test verifies linked-list structure but does not call `buildConstants`.

### A43-11: No direct unit tests for pushLiteral() (LOW)

`pushLiteral` (lines 562-625) handles literal deduplication via bloom filter and linked-list traversal, then pushes a constant opcode. It is only exercised through parser integration tests.

**Evidence:** No test file named `LibParseState.pushLiteral.t.sol` exists.

### A43-12: No direct unit test for resetSource() (INFO)

`resetSource` (lines 202-216) zeroes out per-source fields and allocates a new active source pointer. It is called by `newState` and `endSource`. While `newState` is tested indirectly through `pushConstantValue.t.sol`, no test verifies that all fields are correctly zeroed.

**Evidence:** No test file named `LibParseState.resetSource.t.sol` exists.

### A43-13: No direct unit test for snapshotSourceHeadToLineTracker() (INFO)

`snapshotSourceHeadToLineTracker` is called by `pushOpToSource` and `endLine`. Its LineRHSItemsOverflow revert is tested in `overflow.t.sol`. However, the normal path (writing a pointer into the line tracker) is only verified transitively through parser output correctness.

**Evidence:** Only the overflow test exists; no test verifies the snapshot pointer value itself.
