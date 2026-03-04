# Pass 2: Test Coverage -- RainterpreterReferenceExtern

**Audit:** 2026-03-04-01
**Source:** `src/concrete/extern/RainterpreterReferenceExtern.sol`
**Agent ID:** A08

## Evidence

### Functions and line numbers

| Function | Line | Tested |
|---|---|---|
| `describedByMetaV1()` | 165 | Tested |
| `subParserParseMeta()` | 172 | Indirect via pointer tests |
| `subParserWordParsers()` | 179 | Indirect via pointer tests |
| `subParserOperandHandlers()` | 186 | Indirect via pointer tests |
| `subParserLiteralParsers()` | 193 | Indirect via pointer tests |
| `opcodeFunctionPointers()` | 200 | Indirect via pointer tests |
| `integrityFunctionPointers()` | 207 | Indirect via pointer tests |
| `buildLiteralParserFunctionPointers()` | 213 | Tested |
| `matchSubParseLiteralDispatch()` | 236 | Tested: happy 8/9, negative, non-integer, >9, trailing bytes |
| `buildOperandHandlerFunctionPointers()` | 282 | Tested |
| `buildSubParserWordParsers()` | 325 | Tested |
| `buildOpcodeFunctionPointers()` | 367 | Tested |
| `buildIntegrityFunctionPointers()` | 401 | Tested |
| `supportsInterface()` | 429 | Fuzz tested |

### Test files

- `test/src/concrete/RainterpreterReferenceExtern.repeat.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.subParserIndexOutOfBounds.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.intInc.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.pointers.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.stackOperand.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.unknownWord.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.contextCallingContract.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.contextRainlen.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.contextSender.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.describedByMetaV1.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.ierc165.t.sol`

### Errors

| Error | Tested |
|---|---|
| `InvalidRepeatCount` | Yes (negative, non-integer, >9) |
| `UnconsumedRepeatDispatchBytes` | Yes (trailing bytes) |
| `SubParserIndexOutOfBounds` (literal) | Yes (mock with out-of-bounds index) |

## Findings

### P2-A08-01 (LOW) `matchSubParseLiteralDispatch` boundary digit 0 not tested through full stack

The repeat literal tests exercise digits 8 and 9 through the full parse-and-eval stack (`testRainterpreterReferenceExternRepeatHappy`). Digit 0 (the lower boundary of the valid range 0-9) is not tested through the full stack. The `matchSubParseLiteralDispatch` function at line 266 checks `repeatCount.lt(LibDecimalFloat.packLossless(0, 0))`, making 0 a boundary value that should be explicitly tested.

Digit 0 is covered by `LibParseLiteralRepeat.t.sol` fuzz tests at the library level, but not through the full `RainterpreterReferenceExtern` parse + eval integration path.

Carryover from audit `2026-03-01-01` finding `P2-EAD-04`.

### P2-A08-02 (INFO) `matchSubParseLiteralDispatch` dispatch exactly at keyword length not tested

At line 250, the condition `length > SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` requires the dispatch to be strictly longer than the 18-byte keyword. If a dispatch body is exactly 18 bytes matching the keyword with no trailing digit, it should correctly fail to match. There is no test for this boundary -- all tests either have a valid digit after the keyword or test an entirely different keyword.
