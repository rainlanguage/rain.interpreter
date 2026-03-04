# Pass 4 Findings: Parse & State Libraries (A102-A117)

## Files Reviewed

- A102: `src/lib/parse/LibParse.sol`
- A103: `src/lib/parse/LibParseError.sol`
- A104: `src/lib/parse/LibParseInterstitial.sol`
- A105: `src/lib/parse/LibParseOperand.sol`
- A106: `src/lib/parse/LibParsePragma.sol`
- A107: `src/lib/parse/LibParseStackName.sol`
- A108: `src/lib/parse/LibParseStackTracker.sol`
- A109: `src/lib/parse/LibParseState.sol`
- A110: `src/lib/parse/LibSubParse.sol`
- A111: `src/lib/parse/literal/LibParseLiteral.sol`
- A112: `src/lib/parse/literal/LibParseLiteralDecimal.sol`
- A113: `src/lib/parse/literal/LibParseLiteralHex.sol`
- A114: `src/lib/parse/literal/LibParseLiteralString.sol`
- A115: `src/lib/parse/literal/LibParseLiteralSubParseable.sol`
- A116: `src/lib/state/LibInterpreterState.sol`
- A117: `src/lib/state/LibInterpreterStateDataContract.sol`

## Evidence Summary

### A102: LibParse.sol
- **Library**: `LibParse`
- **Functions**: `parseWord` (line 106), `parseLHS` (line 142), `parseRHS` (line 220), `parse` (line 435)
- **Constants**: `SUB_PARSER_BYTECODE_HEADER_SIZE` (line 59), `MAX_PAREN_OFFSET` (line 66)
- **Imports**: LibPointer, LibMemCpy, 12 CMASK constants, LibParseChar, LibParseMeta, LibParseOperand, OperandV2, OPCODE_STACK, OPCODE_UNKNOWN, LibParseStackName, 10 error types, LibParseState (+ 5 constants), LibParsePragma, LibParseInterstitial, LibParseError, LibSubParse, LibBytes, LibBytes32Array
- **Using directives**: 8 (all used)

### A103: LibParseError.sol
- **Library**: `LibParseError`
- **Functions**: `parseErrorOffset` (line 13), `handleErrorSelector` (line 26)
- No `@title` NatSpec (already flagged in Pass 3 as A103-P3-1)

### A104: LibParseInterstitial.sol
- **Library**: `LibParseInterstitial`
- **Functions**: `skipComment` (line 28), `skipWhitespace` (line 96), `parseInterstitial` (line 111)
- No `@title` NatSpec (already flagged in Pass 3 as A104-P3-1)

### A105: LibParseOperand.sol
- **Library**: `LibParseOperand`
- **Functions**: `parseOperand` (line 38), `handleOperand` (line 139), `handleOperandDisallowed` (line 156), `handleOperandDisallowedAlwaysOne` (line 167), `handleOperandSingleFull` (line 180), `handleOperandSingleFullNoDefault` (line 204), `handleOperandDoublePerByteNoDefault` (line 228), `handleOperand8M1M1` (line 261), `handleOperandM1M1` (line 313)
- **Errors used**: ExpectedOperand, UnclosedOperand, OperandValuesOverflow, UnexpectedOperand, UnexpectedOperandValue, OperandOverflow

### A106: LibParsePragma.sol
- **Library**: `LibParsePragma`
- **Functions**: `parsePragma` (line 41)
- **Constants**: `PRAGMA_KEYWORD_BYTES` (line 13), `PRAGMA_KEYWORD_BYTES32` (line 17), `PRAGMA_KEYWORD_BYTES_LENGTH` (line 19), `PRAGMA_KEYWORD_MASK` (line 23)

### A107: LibParseStackName.sol
- **Library**: `LibParseStackName`
- **Functions**: `pushStackName` (line 31), `stackNameIndex` (line 62)

### A108: LibParseStackTracker.sol
- **Library**: `LibParseStackTracker`
- **Type**: `ParseStackTracker` (line 10)
- **Functions**: `pushInputs` (line 25), `push` (line 47), `pop` (line 74)
- **Errors used**: ParseStackUnderflow, ParseStackOverflow

### A109: LibParseState.sol
- **Library**: `LibParseState`
- **Struct**: `ParseState` (line 162)
- **Constants**: EMPTY_ACTIVE_SOURCE (line 32), FSM_YANG_MASK (line 36), FSM_WORD_END_MASK (line 39), FSM_ACCEPTING_INPUTS_MASK (line 42), FSM_ACTIVE_SOURCE_MASK (line 46), FSM_DEFAULT (line 52), OPERAND_VALUES_LENGTH (line 63), PARSE_STATE_TOP_LEVEL0_OFFSET (line 67), PARSE_STATE_TOP_LEVEL0_DATA_OFFSET (line 71), PARSE_STATE_PAREN_TRACKER0_OFFSET (line 75), PARSE_STATE_LINE_TRACKER_OFFSET (line 79), MAX_STACK_RHS_OFFSET (line 85)
- **Functions**: `newActiveSourcePointer` (line 210), `resetSource` (line 231), `newState` (line 257), `pushSubParser` (line 318), `exportSubParsers` (line 338), `snapshotSourceHeadToLineTracker` (line 367), `endLine` (line 402), `highwater` (line 528), `constantValueBloom` (line 553), `pushConstantValue` (line 561), `pushLiteral` (line 591), `pushOpToSource` (line 666), `endSource` (line 773), `buildBytecode` (line 915), `buildConstants` (line 1009), `checkParseMemoryOverflow` (line 1059)

### A110: LibSubParse.sol
- **Library**: `LibSubParse`
- **Functions**: `subParserContext` (line 49), `subParserConstant` (line 97), `subParserExtern` (line 162), `subParseWordSlice` (line 216), `subParseWords` (line 324), `subParseLiteral` (line 350), `consumeSubParseWordInputData` (line 413), `consumeSubParseLiteralInputData` (line 444)

### A111: LibParseLiteral.sol
- **Library**: `LibParseLiteral`
- **Constants**: LITERAL_PARSERS_LENGTH (line 19), LITERAL_PARSER_INDEX_HEX (line 22), LITERAL_PARSER_INDEX_DECIMAL (line 24), LITERAL_PARSER_INDEX_STRING (line 26), LITERAL_PARSER_INDEX_SUB_PARSE (line 28)
- **Functions**: `selectLiteralParserByIndex` (line 43), `parseLiteral` (line 65), `tryParseLiteral` (line 87)

### A112: LibParseLiteralDecimal.sol
- **Library**: `LibParseLiteralDecimal`
- **Functions**: `parseDecimalFloatPacked` (line 23)

### A113: LibParseLiteralHex.sol
- **Library**: `LibParseLiteralHex`
- **Functions**: `boundHex` (line 36), `parseHex` (line 68)
- **Errors used**: MalformedHexLiteral, OddLengthHexLiteral, ZeroLengthHexLiteral, HexLiteralOverflow

### A114: LibParseLiteralString.sol
- **Library**: `LibParseLiteralString`
- **Functions**: `boundString` (line 26), `parseString` (line 88)
- **Errors used**: UnclosedStringLiteral, StringTooLong

### A115: LibParseLiteralSubParseable.sol
- **Library**: `LibParseLiteralSubParseable`
- **Functions**: `parseSubParseable` (line 38)
- **Errors used**: UnclosedSubParseableLiteral, SubParseableMissingDispatch

### A116: LibInterpreterState.sol
- **Library**: `LibInterpreterState`
- **Struct**: `InterpreterState` (line 42)
- **Constants**: STACK_TRACER (line 17)
- **Functions**: `stackBottoms` (line 62), `stackTrace` (line 126)
- No `@title` NatSpec (already flagged in Pass 3 as A116-P3-1)

### A117: LibInterpreterStateDataContract.sol
- **Library**: `LibInterpreterStateDataContract`
- **Functions**: `serializeSize` (line 26), `unsafeSerialize` (line 39), `unsafeDeserialize` (line 69)
- No `@title` NatSpec (already flagged in Pass 3 as A117-P3-1)

---

## Findings

### A115-P4-1 [LOW] Unused import and `using` directive for `LibParse` in `LibParseLiteralSubParseable`

**File**: `src/lib/parse/literal/LibParseLiteralSubParseable.sol`, lines 6 and 18

**Description**: `LibParseLiteralSubParseable` imports `LibParse` (line 6) and declares `using LibParse for ParseState` (line 18), but no function from `LibParse` is ever called within the library. The `parseSubParseable` function only calls:
- `state.parseErrorOffset()` -- from `LibParseError`
- `state.skipWhitespace()` -- from `LibParseInterstitial`
- `state.subParseLiteral()` -- from `LibSubParse`

The unused import and `using` directive are dead code that adds unnecessary compilation overhead and makes the dependency graph misleading.

### A102-P4-1 [INFO] Inconsistent "ying" vs "yin" in comments

**Files**:
- `src/lib/parse/LibParse.sol`, line 192: `// Set ying as we now open to possibilities.`
- `src/lib/parse/LibParseInterstitial.sol`, line 98: `// Set ying as we now open to possibilities.`

**Description**: The codebase uses "yin/yang" terminology for the FSM state (bit 0). The constant documentation in `LibParseState.sol` line 35 and 12 other comment sites consistently use "yin", but two comments use the misspelling "ying". This is a minor comment inconsistency; the correct romanization is "yin" (as used elsewhere).

### A105-P4-1 [INFO] Duplicated Float-to-uint conversion logic across operand handlers

**File**: `src/lib/parse/LibParseOperand.sol`

**Description**: The following code block appears identically in `handleOperandSingleFull` (lines 182-191) and `handleOperandSingleFullNoDefault` (lines 206-215):

```solidity
assembly ("memory-safe") {
    operand := mload(add(values, 0x20))
}
(int256 signedCoefficient, int256 exponent) = Float.wrap(OperandV2.unwrap(operand)).unpack();
uint256 operandUint = LibDecimalFloat.toFixedDecimalLossless(signedCoefficient, exponent, 0);
if (operandUint > type(uint16).max) {
    revert OperandOverflow();
}
operand = OperandV2.wrap(bytes32(operandUint));
```

More broadly, the `unpack` + `toFixedDecimalLossless` + overflow check pattern is repeated 9 times across 5 operand handler functions, differing only in the overflow bound (`type(uint16).max`, `type(uint8).max`, or `1`). An internal helper function like `floatToUintBounded(Float value, uint256 max)` would reduce duplication and make the overflow bound explicit at each call site.
