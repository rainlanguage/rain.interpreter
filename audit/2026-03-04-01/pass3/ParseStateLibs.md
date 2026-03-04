# Pass 3 (NatSpec) -- Parse, State, and Literal Libraries

## Files Audited

| Agent ID | File |
|----------|------|
| A103 | `src/lib/parse/LibParseError.sol` |
| A104 | `src/lib/parse/LibParseInterstitial.sol` |
| A116 | `src/lib/state/LibInterpreterState.sol` |
| A117 | `src/lib/state/LibInterpreterStateDataContract.sol` |
| A102 | `src/lib/parse/LibParse.sol` |
| A105 | `src/lib/parse/LibParseOperand.sol` |
| A106 | `src/lib/parse/LibParsePragma.sol` |
| A107 | `src/lib/parse/LibParseStackName.sol` |
| A108 | `src/lib/parse/LibParseStackTracker.sol` |
| A109 | `src/lib/parse/LibParseState.sol` |
| A110 | `src/lib/parse/LibSubParse.sol` |
| A111 | `src/lib/parse/literal/LibParseLiteral.sol` |
| A112 | `src/lib/parse/literal/LibParseLiteralDecimal.sol` |
| A113 | `src/lib/parse/literal/LibParseLiteralHex.sol` |
| A114 | `src/lib/parse/literal/LibParseLiteralString.sol` |
| A115 | `src/lib/parse/literal/LibParseLiteralSubParseable.sol` |

## Evidence

### A102: LibParse.sol
- Library `LibParse` at line 75; `@title` at line 68.
- Constants: `SUB_PARSER_BYTECODE_HEADER_SIZE` (59), `MAX_PAREN_OFFSET` (66) -- both `@dev` documented.
- Functions: `parseWord` (106), `parseLHS` (142), `parseRHS` (220), `parse` (435).
- All functions have `@notice`, all `@param` tags, and `@return` tags. No findings.

### A103: LibParseError.sol
- Library `LibParseError` at line 7. **No `@title` tag.**
- Functions: `parseErrorOffset` (13), `handleErrorSelector` (26).
- All functions have `@notice`, all `@param` tags. `parseErrorOffset` has `@return offset`. `handleErrorSelector` returns void. Complete.

### A104: LibParseInterstitial.sol
- Library `LibParseInterstitial` at line 17. **No `@title` tag.**
- Functions: `skipComment` (28), `skipWhitespace` (96), `parseInterstitial` (111).
- All functions have `@notice`, all `@param` tags, and `@return` tags. Complete except for missing `@title`.

### A105: LibParseOperand.sol
- Library `LibParseOperand` at line 24; `@title` at line 21.
- Functions: `parseOperand` (38), `handleOperand` (139), `handleOperandDisallowed` (156), `handleOperandDisallowedAlwaysOne` (167), `handleOperandSingleFull` (180), `handleOperandSingleFullNoDefault` (204), `handleOperandDoublePerByteNoDefault` (228), `handleOperand8M1M1` (261), `handleOperandM1M1` (313).
- All functions fully documented. No findings.

### A106: LibParsePragma.sol
- Library `LibParsePragma` at line 28; `@title` at line 25.
- Constants: `PRAGMA_KEYWORD_BYTES` (13), `PRAGMA_KEYWORD_BYTES32` (17), `PRAGMA_KEYWORD_BYTES_LENGTH` (19), `PRAGMA_KEYWORD_MASK` (23) -- all `@dev` documented.
- Functions: `parsePragma` (41). Fully documented. No findings.

### A107: LibParseStackName.sol
- Library `LibParseStackName` at line 21; `@title` at line 7.
- Functions: `pushStackName` (31), `stackNameIndex` (62).
- All functions fully documented. No findings.

### A108: LibParseStackTracker.sol
- Library `LibParseStackTracker` at line 15; `@title` at line 12.
- Type: `ParseStackTracker` (10) with `@dev`.
- Functions: `pushInputs` (25), `push` (47), `pop` (74).
- All functions fully documented. No findings.

### A109: LibParseState.sol
- Library `LibParseState` at line 194; `@title` at line 192.
- Struct `ParseState` at line 162 with `@notice` and all `@param` fields documented.
- Constants: `EMPTY_ACTIVE_SOURCE` (32), `FSM_YANG_MASK` (36), `FSM_WORD_END_MASK` (39), `FSM_ACCEPTING_INPUTS_MASK` (42), `FSM_ACTIVE_SOURCE_MASK` (46), `FSM_DEFAULT` (52), `OPERAND_VALUES_LENGTH` (63), `PARSE_STATE_TOP_LEVEL0_OFFSET` (67), `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` (71), `PARSE_STATE_PAREN_TRACKER0_OFFSET` (75), `PARSE_STATE_LINE_TRACKER_OFFSET` (79), `MAX_STACK_RHS_OFFSET` (85) -- all `@dev` documented.
- Functions: `newActiveSourcePointer` (210), `resetSource` (231), `newState` (257), `pushSubParser` (318), `exportSubParsers` (338), `snapshotSourceHeadToLineTracker` (367), `endLine` (402), `highwater` (528), `constantValueBloom` (553), `pushConstantValue` (561), `pushLiteral` (591), `pushOpToSource` (666), `endSource` (773), `buildBytecode` (915), `buildConstants` (1009), `checkParseMemoryOverflow` (1059).
- All functions fully documented. No findings.

### A110: LibSubParse.sol
- Library `LibSubParse` at line 37; `@title` at line 26.
- Functions: `subParserContext` (49), `subParserConstant` (97), `subParserExtern` (162), `subParseWordSlice` (216), `subParseWords` (324), `subParseLiteral` (350), `consumeSubParseWordInputData` (413), `consumeSubParseLiteralInputData` (444).
- All functions fully documented. No findings.

### A111: LibParseLiteral.sol
- Library `LibParseLiteral` at line 33; `@title` at line 30.
- Constants: `LITERAL_PARSERS_LENGTH` (19), `LITERAL_PARSER_INDEX_HEX` (21), `LITERAL_PARSER_INDEX_DECIMAL` (23), `LITERAL_PARSER_INDEX_STRING` (25), `LITERAL_PARSER_INDEX_SUB_PARSE` (27) -- all `@dev` documented.
- Functions: `selectLiteralParserByIndex` (43), `parseLiteral` (65), `tryParseLiteral` (87).
- All functions fully documented. No findings.

### A112: LibParseLiteralDecimal.sol
- Library `LibParseLiteralDecimal` at line 13; `@title` at line 10.
- Functions: `parseDecimalFloatPacked` (23).
- Fully documented. No findings.

### A113: LibParseLiteralHex.sol
- Library `LibParseLiteralHex` at line 23; `@title` at line 20.
- Functions: `boundHex` (36), `parseHex` (68).
- `boundHex` has an unnamed `ParseState memory` parameter with no `@param` tag. The NatSpec `@notice` explains that the parameter is unused but retained for a consistent signature. See INFO finding.
- `parseHex` fully documented.

### A114: LibParseLiteralString.sol
- Library `LibParseLiteralString` at line 13; `@title` at line 11.
- Functions: `boundString` (26), `parseString` (88).
- All functions fully documented. No findings.

### A115: LibParseLiteralSubParseable.sol
- Library `LibParseLiteralSubParseable` at line 17; `@title` at line 14.
- Functions: `parseSubParseable` (38).
- Fully documented. No findings.

### A116: LibInterpreterState.sol
- Library `LibInterpreterState` at line 55. **No `@title` tag.**
- Struct `InterpreterState` at line 42 with `@notice` and all `@param` fields documented.
- Constant: `STACK_TRACER` (17) with `@dev`.
- Functions: `stackBottoms` (62), `stackTrace` (126).
- All functions fully documented. Finding only for missing `@title`.

### A117: LibInterpreterStateDataContract.sol
- Library `LibInterpreterStateDataContract` at line 14. **No `@title` tag.**
- Functions: `serializeSize` (26), `unsafeSerialize` (39), `unsafeDeserialize` (69).
- All functions fully documented. Finding only for missing `@title`.

## Findings

### A103-P3-1 [LOW] LibParseError missing `@title`

**File:** `src/lib/parse/LibParseError.sol`
**Line:** 7

`LibParseError` has no `@title` tag. All other parse libraries in this directory have `@title` tags on the library declaration.

**Recommendation:** Add `@title LibParseError` and a `@notice` describing its purpose above the library declaration.

### A104-P3-1 [LOW] LibParseInterstitial missing `@title`

**File:** `src/lib/parse/LibParseInterstitial.sol`
**Line:** 17

`LibParseInterstitial` has no `@title` tag. All other parse libraries have `@title` tags.

**Recommendation:** Add `@title LibParseInterstitial` and a `@notice` describing its purpose above the library declaration.

### A116-P3-1 [LOW] LibInterpreterState missing `@title`

**File:** `src/lib/state/LibInterpreterState.sol`
**Line:** 55

`LibInterpreterState` has no `@title` tag.

**Recommendation:** Add `@title LibInterpreterState` and a `@notice` describing its purpose above the library declaration.

### A117-P3-1 [LOW] LibInterpreterStateDataContract missing `@title`

**File:** `src/lib/state/LibInterpreterStateDataContract.sol`
**Line:** 14

`LibInterpreterStateDataContract` has no `@title` tag.

**Recommendation:** Add `@title LibInterpreterStateDataContract` and a `@notice` describing its purpose above the library declaration.

### A113-P3-1 [INFO] boundHex unnamed parameter has no `@param` tag

**File:** `src/lib/parse/literal/LibParseLiteralHex.sol`
**Line:** 36

`boundHex` accepts an unnamed `ParseState memory` first parameter (no variable name in the signature) and has no corresponding `@param` tag. The `@notice` text does explain that the parameter is unused but retained for a consistent `bound*` signature. Since the parameter is unnamed in the Solidity function signature, the compiler does not require a `@param` tag, and adding one is not straightforward (there is no name to reference). Current documentation is adequate.
