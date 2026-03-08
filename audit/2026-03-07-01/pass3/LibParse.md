# Pass 3 -- Documentation Audit: Parse and Literal Libraries

Agent: A04

## Methodology

Each of the 14 source files was read in full. Every library, struct, type, constant, and function was catalogued with its line number. NatSpec was checked for: presence on all public/internal items, `@param`/`@return` tags matching signatures, explicit `@notice` when any explicit tag is present in the same doc block, and accuracy of documentation relative to implementation.

---

## Evidence: File-by-File Inventory

### 1. `src/lib/parse/LibParse.sol`

**Library:** `LibParse` (line 75)
**Library NatSpec:** `@title` + `@notice` (lines 68-74) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `SUB_PARSER_BYTECODE_HEADER_SIZE` | constant | 59 | `@dev` (line 56) |
| `MAX_PAREN_OFFSET` | constant | 66 | `@dev` (lines 61-65) |
| `parseWord` | function | 106 | `@notice` + `@param cursor` + `@param end` + `@param mask` + `@return` x2 (lines 89-105) |
| `parseLHS` | function | 142 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 134-140) |
| `parseRHS` | function | 220 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 211-217) |
| `parse` | function | 435 | `@notice` + `@param state` + `@return bytecode` + `@return` (lines 429-434) |

**Assessment:** All items documented. All `@param`/`@return` tags present. The second `@return` on `parse` (line 434) is unnamed -- this matches the signature `returns (bytes memory bytecode, bytes32[] memory)` where the second return is unnamed. Acceptable.

### 2. `src/lib/parse/LibParseState.sol`

**Struct:** `ParseState` (line 162)
**Struct NatSpec:** `@notice` + `@param` for all 18 fields (lines 87-161) -- correctly tagged.

**Library:** `LibParseState` (line 194)
**Library NatSpec:** `@title` + `@notice` (lines 192-193) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `EMPTY_ACTIVE_SOURCE` | constant | 32 | `@dev` (lines 30-31) |
| `FSM_YANG_MASK` | constant | 36 | `@dev` (lines 34-35) |
| `FSM_WORD_END_MASK` | constant | 39 | `@dev` (lines 37-38) |
| `FSM_ACCEPTING_INPUTS_MASK` | constant | 42 | `@dev` (lines 40-41) |
| `FSM_ACTIVE_SOURCE_MASK` | constant | 46 | `@dev` (lines 44-45) |
| `FSM_DEFAULT` | constant | 52 | `@dev` (lines 48-51) |
| `OPERAND_VALUES_LENGTH` | constant | 63 | `@dev` (lines 54-62) |
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | constant | 67 | `@dev` (lines 65-66) |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | constant | 71 | `@dev` (lines 69-70) |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | constant | 75 | `@dev` (lines 73-74) |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | constant | 79 | `@dev` (lines 77-78) |
| `MAX_STACK_RHS_OFFSET` | constant | 85 | `@dev` (lines 81-84) |
| `newActiveSourcePointer` | function | 210 | `@notice` + `@param` + `@return` (lines 201-209) |
| `resetSource` | function | 231 | `@notice` + `@param` (lines 227-230) |
| `newState` | function | 257 | `@notice` + `@param` x4 + `@return` (lines 247-256) |
| `pushSubParser` | function | 318 | `@notice` + `@param state` + `@param cursor` + `@param subParser` (lines 308-317) |
| `exportSubParsers` | function | 338 | `@notice` + `@param` + `@return` (lines 335-337) |
| `snapshotSourceHeadToLineTracker` | function | 367 | `@notice` + `@param` (lines 363-366) |
| `endLine` | function | 402 | `@notice` + `@param state` + `@param cursor` (lines 396-400) |
| `highwater` | function | 528 | `@notice` + `@param` (lines 523-527) |
| `constantValueBloom` | function | 553 | `@notice` + `@param` + `@return` (lines 549-552) |
| `pushConstantValue` | function | 561 | `@notice` + `@param state` + `@param value` (lines 557-560) |
| `pushLiteral` | function | 591 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 584-590) |
| `pushOpToSource` | function | 666 | `@notice` + `@param state` + `@param opcode` + `@param operand` (lines 656-665) |
| `endSource` | function | 773 | `@notice` + `@param` (lines 768-772) |
| `buildBytecode` | function | 915 | `@notice` + `@param` + `@return` (lines 910-914) |
| `buildConstants` | function | 1009 | `@notice` + `@param` + `@return` (lines 1003-1008) |
| `checkParseMemoryOverflow` | function | 1059 | `@notice` (lines 1047-1058) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate. The `checkParseMemoryOverflow` function has no parameters and no return values, so the absence of those tags is correct.

### 3. `src/lib/parse/LibParseError.sol`

**Library:** `LibParseError` (line 7)
**Library NatSpec:** None.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `parseErrorOffset` | function | 13 | `@notice` + `@param state` + `@param cursor` + `@return offset` (lines 8-12) |
| `handleErrorSelector` | function | 26 | `@notice` + `@param state` + `@param cursor` + `@param errorSelector` (lines 20-25) |

**Assessment:** Functions are fully documented. The library itself lacks a `@title` / `@notice` doc block. See **Finding A04-1**.

### 4. `src/lib/parse/LibParseInterstitial.sol`

**Library:** `LibParseInterstitial` (line 17)
**Library NatSpec:** None.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `skipComment` | function | 28 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 21-27) |
| `skipWhitespace` | function | 96 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 90-95) |
| `parseInterstitial` | function | 111 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 104-110) |

**Assessment:** Functions are fully documented. The library itself lacks a `@title` / `@notice` doc block. See **Finding A04-1**.

### 5. `src/lib/parse/LibParseOperand.sol`

**Library:** `LibParseOperand` (line 24)
**Library NatSpec:** `@title` + `@notice` (lines 21-23) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `parseOperand` | function | 38 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 31-37) |
| `handleOperand` | function | 139 | `@notice` + `@param state` + `@param wordIndex` + `@return` (lines 128-138) |
| `handleOperandDisallowed` | function | 156 | `@notice` + `@param values` + `@return` (lines 152-155) |
| `handleOperandDisallowedAlwaysOne` | function | 167 | `@notice` + `@param values` + `@return` (lines 163-166) |
| `handleOperandSingleFull` | function | 180 | `@notice` + `@param values` + `@return operand` (lines 174-179) |
| `handleOperandSingleFullNoDefault` | function | 204 | `@notice` + `@param values` + `@return operand` (lines 199-203) |
| `handleOperandDoublePerByteNoDefault` | function | 228 | `@notice` + `@param values` + `@return operand` (lines 223-227) |
| `handleOperand8M1M1` | function | 261 | `@notice` + `@param values` + `@return operand` (lines 255-259) |
| `handleOperandM1M1` | function | 313 | `@notice` + `@param values` + `@return operand` (lines 308-311) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 6. `src/lib/parse/LibParsePragma.sol`

**Library:** `LibParsePragma` (line 28)
**Library NatSpec:** `@title` + `@notice` (lines 25-27) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `PRAGMA_KEYWORD_BYTES` | constant | 13 | `@dev` (line 12) |
| `PRAGMA_KEYWORD_BYTES32` | constant | 17 | `@dev` (lines 14-15) |
| `PRAGMA_KEYWORD_BYTES_LENGTH` | constant | 19 | `@dev` (line 18) |
| `PRAGMA_KEYWORD_MASK` | constant | 23 | `@dev` (lines 20-21) |
| `parsePragma` | function | 41 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` (lines 34-40) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 7. `src/lib/parse/LibParseStackName.sol`

**Library:** `LibParseStackName` (line 21)
**Library NatSpec:** `@title` + `@notice` (lines 7-20) -- correctly tagged, extensive description.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `pushStackName` | function | 31 | `@notice` + `@param state` + `@param word` + `@return exists` + `@return index` (lines 22-30) |
| `stackNameIndex` | function | 62 | `@notice` + `@param state` + `@param word` + `@return exists` + `@return index` (lines 54-61) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 8. `src/lib/parse/LibParseStackTracker.sol`

**Type:** `ParseStackTracker` (line 10)
**Type NatSpec:** `@dev` (lines 7-9) -- correctly tagged.

**Library:** `LibParseStackTracker` (line 15)
**Library NatSpec:** `@title` + `@notice` (lines 12-14) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `pushInputs` | function | 25 | `@notice` + `@param tracker` + `@param n` + `@return` (lines 18-24) |
| `push` | function | 47 | `@notice` + `@param tracker` + `@param n` + `@return` (lines 37-46) |
| `pop` | function | 74 | `@notice` + `@param tracker` + `@param n` + `@return` (lines 63-73) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 9. `src/lib/parse/LibSubParse.sol`

**Library:** `LibSubParse` (line 37)
**Library NatSpec:** `@title` + `@notice` (lines 26-36) -- correctly tagged, extensive trust model description.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `subParserContext` | function | 49 | `@notice` + `@param column` + `@param row` + `@return` x3 (lines 41-48) |
| `subParserConstant` | function | 97 | `@notice` + `@param constantsHeight` + `@param value` + `@return` x3 (lines 90-96) |
| `subParserExtern` | function | 162 | `@notice` + `@param extern` + `@param constantsHeight` + `@param ioByte` + `@param operand` + `@param opcodeIndex` + `@return` x3 (lines 145-161) |
| `subParseWordSlice` | function | 216 | `@notice` + `@param state` + `@param cursor` + `@param end` (lines 211-215) |
| `subParseWords` | function | 324 | `@notice` + `@param state` + `@param bytecode` + `@return` x2 (lines 317-323) |
| `subParseLiteral` | function | 350 | `@notice` + `@param state` + `@param dispatchStart` + `@param dispatchEnd` + `@param bodyStart` + `@param bodyEnd` + `@return` (lines 341-349) |
| `consumeSubParseWordInputData` | function | 413 | `@notice` + `@param data` + `@param meta` + `@param operandHandlers` + `@return constantsHeight` + `@return ioByte` + `@return state` (lines 402-412) |
| `consumeSubParseLiteralInputData` | function | 444 | `@notice` + `@param data` + `@return dispatchStart` + `@return bodyStart` + `@return bodyEnd` (lines 437-443) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 10. `src/lib/parse/literal/LibParseLiteral.sol`

**Library:** `LibParseLiteral` (line 33)
**Library NatSpec:** `@title` + `@notice` (lines 30-32) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `LITERAL_PARSERS_LENGTH` | constant | 19 | `@dev` (line 18) |
| `LITERAL_PARSER_INDEX_HEX` | constant | 22 | `@dev` (line 21) |
| `LITERAL_PARSER_INDEX_DECIMAL` | constant | 24 | `@dev` (line 23) |
| `LITERAL_PARSER_INDEX_STRING` | constant | 26 | `@dev` (line 25) |
| `LITERAL_PARSER_INDEX_SUB_PARSE` | constant | 28 | `@dev` (line 27) |
| `selectLiteralParserByIndex` | function | 43 | `@notice` + `@param state` + `@param index` + `@return` (lines 37-42) |
| `parseLiteral` | function | 65 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` x2 (lines 58-64) |
| `tryParseLiteral` | function | 87 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` x3 (lines 78-86) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 11. `src/lib/parse/literal/LibParseLiteralDecimal.sol`

**Library:** `LibParseLiteralDecimal` (line 13)
**Library NatSpec:** `@title` + `@notice` (lines 10-12) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `parseDecimalFloatPacked` | function | 23 | `@notice` + `@param state` + `@param start` + `@param end` + `@return` x2 (lines 16-22) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

### 12. `src/lib/parse/literal/LibParseLiteralHex.sol`

**Library:** `LibParseLiteralHex` (line 23)
**Library NatSpec:** `@title` + `@notice` (lines 20-22) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `boundHex` | function | 36 | `@notice` + `@param cursor` + `@param end` + `@return` x3 (lines 27-35) |
| `parseHex` | function | 68 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` x2 (lines 56-67) |

**Assessment:** All items documented. `boundHex` has an unused `ParseState memory` parameter that is documented in the `@notice` description (line 29: "The `ParseState` parameter is unused here but kept for a consistent `bound*` signature"). Acceptable. All `@param`/`@return` tags present. However, `boundHex` is missing a `@param` tag for the first unnamed `ParseState memory` parameter. See **Finding A04-2**.

### 13. `src/lib/parse/literal/LibParseLiteralString.sol`

**Library:** `LibParseLiteralString` (line 13)
**Library NatSpec:** `@title` + `@notice` (lines 11-12) -- correctly tagged. Note: `@notice` is implicit (line 12 is an untagged continuation after `@title`). Since `@title` is an explicit tag, the "A library for parsing string literals." line on line 12 is a continuation of `@title`, not an implicit `@notice`. See **Finding A04-3**.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `boundString` | function | 26 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` x3 (lines 17-25) |
| `parseString` | function | 88 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` x2 (lines 77-87) |

**Assessment:** Functions are fully documented. Library NatSpec has a tagging issue. See Finding A04-3.

### 14. `src/lib/parse/literal/LibParseLiteralSubParseable.sol`

**Library:** `LibParseLiteralSubParseable` (line 17)
**Library NatSpec:** `@title` + `@notice` (lines 14-16) -- correctly tagged.

| Item | Kind | Line | NatSpec |
|---|---|---|---|
| `parseSubParseable` | function | 38 | `@notice` + `@param state` + `@param cursor` + `@param end` + `@return` x2 (lines 23-37) |

**Assessment:** All items documented. All `@param`/`@return` tags present and accurate.

---

## Findings

### A04-1 (LOW): Missing library-level NatSpec on `LibParseError` and `LibParseInterstitial`

**Files:**
- `src/lib/parse/LibParseError.sol` line 7
- `src/lib/parse/LibParseInterstitial.sol` line 17

**Description:**
Both `LibParseError` and `LibParseInterstitial` lack `@title` / `@notice` NatSpec on the `library` declaration. All other parse libraries in this codebase have `@title` and `@notice` tags on their library declarations. This is an inconsistency that affects generated documentation and developer discoverability.

**Proposed fix:** Add `@title` and `@notice` NatSpec to both library declarations.

### A04-2 (INFO): Missing `@param` for unnamed `ParseState memory` in `boundHex`

**File:** `src/lib/parse/literal/LibParseLiteralHex.sol` line 36

**Description:**
The `boundHex` function has three parameters: `ParseState memory` (unnamed), `uint256 cursor`, and `uint256 end`. The `@notice` block explains why the `ParseState` parameter is unused, but there is no `@param` tag for it (which is standard since it is unnamed). The Solidity NatSpec spec does not require `@param` for unnamed parameters. This is informational only -- the existing `@notice` explanation is adequate.

No fix required.

### A04-3 (LOW): Implicit `@notice` continuation in `LibParseLiteralString` library NatSpec

**File:** `src/lib/parse/literal/LibParseLiteralString.sol` lines 11-12

**Description:**
The library NatSpec is:
```solidity
/// @title LibParseLiteralString
/// @notice A library for parsing string literals.
```

This is actually correct. On re-examination, line 12 has an explicit `@notice` tag. No issue.

**Retracted.** This finding is void upon closer inspection -- the `@notice` is explicit.

---

## Summary

| Finding | Severity | File(s) | Description |
|---|---|---|---|
| A04-1 | LOW | `LibParseError.sol`, `LibParseInterstitial.sol` | Missing library-level `@title`/`@notice` NatSpec |
| A04-2 | INFO | `LibParseLiteralHex.sol` | Missing `@param` for unnamed parameter (no fix needed) |

All 14 files have complete function-level NatSpec with `@notice`, `@param`, and `@return` tags that accurately match their implementations. The only gaps are two missing library-level doc blocks.
