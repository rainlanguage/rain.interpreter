# Pass 2 — Test Coverage: LibSubParse

**Source:** `src/lib/parse/LibSubParse.sol`
**Tests:**
- `test/src/lib/parse/LibSubParse.subParserConstant.t.sol`
- `test/src/lib/parse/LibSubParse.subParserExtern.t.sol`
- `test/src/lib/parse/LibSubParse.subParserContext.t.sol`
- `test/src/lib/parse/LibSubParse.badSubParserResult.t.sol`

## Source Inventory

### Functions

| Function | Line | Visibility |
|---|---|---|
| `subParserContext(uint256, uint256)` | 48 | internal pure |
| `subParserConstant(uint256, bytes32)` | 96 | internal pure |
| `subParserExtern(IInterpreterExternV4, uint256, uint256, OperandV2, uint256)` | 161 | internal pure |
| `subParseWordSlice(ParseState memory, uint256, uint256)` | 215 | internal view |
| `subParseWords(ParseState memory, bytes memory)` | 323 | internal view |
| `subParseLiteral(ParseState memory, uint256, uint256, uint256, uint256)` | 349 | internal view |
| `consumeSubParseWordInputData(bytes memory, bytes memory, bytes memory)` | 407 | internal pure |
| `consumeSubParseLiteralInputData(bytes memory)` | 438 | internal pure |

### Errors Used

| Error | Used In | Line |
|---|---|---|
| `ContextGridOverflow(uint256, uint256)` | `subParserContext` | 54 |
| `ConstantOpcodeConstantsHeightOverflow(uint256)` | `subParserConstant` | 102 |
| `ExternDispatchConstantsHeightOverflow(uint256)` | `subParserExtern` | 172 |
| `BadSubParserResult(bytes)` | `subParseWordSlice` | 268 |
| `UnknownWord(string)` | `subParseWordSlice` | 310 |
| `UnsupportedLiteralType(uint256)` | `subParseLiteral` | 392 |

## Test Coverage Analysis

### Direct Tests

| Test File | Functions Covered | Error Paths Covered |
|---|---|---|
| `subParserContext.t.sol` | `subParserContext` | `ContextGridOverflow` (column overflow, row overflow) |
| `subParserConstant.t.sol` | `subParserConstant` | `ConstantOpcodeConstantsHeightOverflow` |
| `subParserExtern.t.sol` | `subParserExtern` | `ExternDispatchConstantsHeightOverflow` |
| `badSubParserResult.t.sol` | `subParseWordSlice` (indirectly via full parse) | `BadSubParserResult` (0, 3, 5, 8 bytes) |

### Indirect Coverage

| Function | Indirect Test Coverage |
|---|---|
| `subParseWords` | Called from `LibParse.parse()`, exercised by all parser integration tests that use sub parsers |
| `subParseWordSlice` | Called from `subParseWords`, exercised by `badSubParserResult.t.sol` and extern integration tests |
| `subParseLiteral` | Called from `LibParseLiteralSubParseable.sol`, exercised by `LibParseLiteralSubParseable.parseSubParseable.t.sol` |
| `consumeSubParseWordInputData` | Called from `BaseRainterpreterSubParser.sol`, exercised by extern integration tests |
| `consumeSubParseLiteralInputData` | Called from `BaseRainterpreterSubParser.sol`, exercised by literal sub-parse integration tests |

## Findings

### A44-1: No direct unit test for subParseWordSlice() (HIGH)

`subParseWordSlice` (lines 215-313) is a critical function that iterates over bytecode ops, detects unknown opcodes, delegates to sub parsers, copies results back into the bytecode, and appends sub-parser constants. The only direct test (`badSubParserResult.t.sol`) tests one error path via full parser integration. The normal success path (sub parser resolves an unknown word) and the `UnknownWord` revert path are not tested in isolation.

**Evidence:** No test file named `LibSubParse.subParseWordSlice.t.sol` exists. The `BadSubParserResult` test goes through the full parser rather than calling `subParseWordSlice` directly.

### A44-2: UnknownWord error path tested only via integration (MEDIUM)

The `UnknownWord` revert in `subParseWordSlice` (line 310) fires when no sub parser can resolve an unknown opcode. This is tested indirectly in `RainterpreterReferenceExtern.unknownWord.t.sol` but not through any direct LibSubParse test.

**Evidence:** Grep for `UnknownWord` across `test/` finds only `test/src/concrete/RainterpreterReferenceExtern.unknownWord.t.sol`.

### A44-3: UnsupportedLiteralType error path in subParseLiteral() not directly tested (MEDIUM)

`subParseLiteral` reverts with `UnsupportedLiteralType` when no sub parser can handle the literal (line 392). This error path is only tested via the abstract `ParseLiteralTest.sol` helper.

**Evidence:** Grep for `UnsupportedLiteralType` in test files shows only `test/abstract/ParseLiteralTest.sol`.

### A44-4: No direct unit test for subParseWords() (LOW)

`subParseWords` (lines 323-338) iterates over all sources in the bytecode and delegates to `subParseWordSlice`. It is a thin wrapper but its source-iteration logic (computing cursor and end from `LibBytecode`) is only exercised through full parser integration.

**Evidence:** No test file named `LibSubParse.subParseWords.t.sol` exists.

### A44-5: No direct unit test for subParseLiteral() (LOW)

`subParseLiteral` (lines 349-394) builds the sub-parse payload from dispatch and body regions, iterates sub parsers, and returns the parsed value. It is exercised indirectly through `LibParseLiteralSubParseable.parseSubParseable.t.sol` but has no isolated unit test.

**Evidence:** No test file named `LibSubParse.subParseLiteral.t.sol` exists.

### A44-6: No direct unit test for consumeSubParseWordInputData() (LOW)

`consumeSubParseWordInputData` (lines 407-429) unpacks the sub-parse header and constructs a new `ParseState`. It is exercised indirectly through `BaseRainterpreterSubParser` but has no isolated unit test verifying correct header extraction.

**Evidence:** No test file named `LibSubParse.consumeSubParseWordInputData.t.sol` exists. The function is only referenced in `src/abstract/BaseRainterpreterSubParser.sol`.

### A44-7: No direct unit test for consumeSubParseLiteralInputData() (LOW)

`consumeSubParseLiteralInputData` (lines 438-449) unpacks dispatch and body region pointers from encoded bytes. It is exercised indirectly through `BaseRainterpreterSubParser` but has no isolated unit test.

**Evidence:** No test file named `LibSubParse.consumeSubParseLiteralInputData.t.sol` exists. The function is only referenced in `src/abstract/BaseRainterpreterSubParser.sol`.

### A44-8: Sub parser constant accumulation not tested (LOW)

When `subParseWordSlice` resolves an unknown word, it appends the sub parser's constants via `state.pushConstantValue` (line 283). No test verifies that constants from sub parsers are correctly accumulated and appear at the right indices in the final constants array.

**Evidence:** The `badSubParserResult.t.sol` test returns empty constants arrays. No test returns non-empty constants from a sub parser and verifies them.

### A44-9: Multiple sub parser iteration not tested in subParseLiteral() (INFO)

`subParseLiteral` iterates over all registered sub parsers (lines 380-390), stopping at the first success. No test registers multiple sub parsers where the first fails and a later one succeeds for a literal. The word-level equivalent has indirect coverage via extern tests but the literal path does not.

**Evidence:** `LibParseLiteralSubParseable.parseSubParseable.t.sol` only uses a single sub parser.
