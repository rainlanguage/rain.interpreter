# Pass 3 — NatSpec Documentation Audit: Parse Libraries

Audit date: 2026-03-01
Files reviewed: 14 parse library source files

---

## File Inventory

### 1. `src/lib/parse/LibParse.sol` (449 lines)

**Library**: `LibParse` (line 68)
- Library-level: `@title` (line 61) + `@notice` (line 62) -- complete

**Constants**:
- `SUB_PARSER_BYTECODE_HEADER_SIZE` (line 59): `@dev` -- complete

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `parseWord` | 100 | Yes (83) | `cursor`, `end`, `mask` | 2 returns documented | COMPLETE |
| `parseLHS` | 136 | Yes (128) | `state`, `cursor`, `end` | 1 return documented | COMPLETE |
| `parseRHS` | 204 | Yes (195) | `state`, `cursor`, `end` | 1 return documented | COMPLETE |
| `parse` | 425 | Yes (419) | `state` | `bytecode`, unnamed constants | SEE FINDING P3-LP-01 |

---

### 2. `src/lib/parse/LibParseState.sol` (1053 lines)

**Library**: `LibParseState` (line 185)
- Library-level: NO NatSpec -- SEE FINDING P3-LPS-01

**Struct**: `ParseState` (line 155)
- Struct-level: `@notice` (line 80) + `@param` for all fields -- complete

**Constants** (all have `@dev` tags):
- `EMPTY_ACTIVE_SOURCE` (line 31): `@dev` -- complete
- `FSM_YANG_MASK` (line 35): `@dev` -- complete
- `FSM_WORD_END_MASK` (line 38): `@dev` -- complete
- `FSM_ACCEPTING_INPUTS_MASK` (line 41): `@dev` -- complete
- `FSM_ACTIVE_SOURCE_MASK` (line 45): `@dev` -- complete
- `FSM_DEFAULT` (line 51): `@dev` -- complete
- `OPERAND_VALUES_LENGTH` (line 62): `@dev` -- complete
- `PARSE_STATE_TOP_LEVEL0_OFFSET` (line 66): `@dev` -- complete
- `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` (line 70): `@dev` -- complete
- `PARSE_STATE_PAREN_TRACKER0_OFFSET` (line 74): `@dev` -- complete
- `PARSE_STATE_LINE_TRACKER_OFFSET` (line 78): `@dev` -- complete

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `newActiveSourcePointer` | 201 | Yes (192) | `oldActiveSourcePointer` | documented | COMPLETE |
| `resetSource` | 222 | Yes (218) | `state` | void | COMPLETE |
| `newState` | 248 | Yes (238) | `data`, `meta`, `operandHandlers`, `literalParsers` | documented | COMPLETE |
| `pushSubParser` | 309 | Yes (299) | `state`, `cursor`, `subParser` | void | COMPLETE |
| `exportSubParsers` | 329 | Yes (326) | `state` | documented | COMPLETE |
| `snapshotSourceHeadToLineTracker` | 358 | Yes (354) | `state` | void | COMPLETE |
| `endLine` | 393 | Yes (387) | `state`, `cursor` | void | COMPLETE |
| `highwater` | 519 | Yes (514) | `state` | void | COMPLETE |
| `constantValueBloom` | 547 | Yes (543) | `value` | `bloom` | COMPLETE |
| `pushConstantValue` | 555 | Yes (551) | `state`, `value` | void | COMPLETE |
| `pushLiteral` | 585 | Yes (578) | `state`, `cursor`, `end` | documented | COMPLETE |
| `pushOpToSource` | 660 | Yes (650) | `state`, `opcode`, `operand` | void | COMPLETE |
| `endSource` | 767 | Yes (762) | `state` | void | COMPLETE |
| `buildBytecode` | 900 | Yes (895) | `state` | `bytecode` | COMPLETE |
| `buildConstants` | 994 | Yes (988) | `state` | `constants` | COMPLETE |
| `checkParseMemoryOverflow` | 1044 | NO `@notice` tag | none (no params) | void | SEE FINDING P3-LPS-02 |

---

### 3. `src/lib/parse/LibParseError.sol` (37 lines)

**Library**: `LibParseError` (line 7)
- Library-level: NO NatSpec -- SEE FINDING P3-LPE-01

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `parseErrorOffset` | 13 | Yes (8) | `state`, `cursor` | `offset` | COMPLETE |
| `handleErrorSelector` | 26 | Yes (20) | `state`, `cursor`, `errorSelector` | void | COMPLETE |

---

### 4. `src/lib/parse/LibParseInterstitial.sol` (128 lines)

**Library**: `LibParseInterstitial` (line 17)
- Library-level: NO NatSpec -- SEE FINDING P3-LPI-01

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `skipComment` | 28 | Yes (21) | `state`, `cursor`, `end` | documented | COMPLETE |
| `skipWhitespace` | 96 | Yes (90) | `state`, `cursor`, `end` | documented | COMPLETE |
| `parseInterstitial` | 111 | Yes (104) | `state`, `cursor`, `end` | documented | COMPLETE |

---

### 5. `src/lib/parse/LibParseOperand.sol` (348 lines)

**Library**: `LibParseOperand` (line 21)
- Library-level: NO NatSpec -- SEE FINDING P3-LPO-01

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `parseOperand` | 35 | Yes (28) | `state`, `cursor`, `end` | documented | COMPLETE |
| `handleOperand` | 136 | Yes (125) | `state`, `wordIndex` | documented | COMPLETE |
| `handleOperandDisallowed` | 153 | Yes (149) | `values` | documented | COMPLETE |
| `handleOperandDisallowedAlwaysOne` | 164 | Yes (160) | `values` | documented | COMPLETE |
| `handleOperandSingleFull` | 177 | Yes (171) | `values` | `operand` | COMPLETE |
| `handleOperandSingleFullNoDefault` | 201 | Yes (196) | `values` | `operand` | COMPLETE |
| `handleOperandDoublePerByteNoDefault` | 225 | Yes (220) | `values` | `operand` | COMPLETE |
| `handleOperand8M1M1` | 258 | Yes (252) | `values` | `operand` | COMPLETE |
| `handleOperandM1M1` | 310 | Yes (305) | `values` | `operand` | COMPLETE |

---

### 6. `src/lib/parse/LibParsePragma.sol` (92 lines)

**Library**: `LibParsePragma` (line 20)
- Library-level: NO NatSpec -- SEE FINDING P3-LPP-01

**Constants**:
- `PRAGMA_KEYWORD_BYTES` (line 12): No NatSpec -- SEE FINDING P3-LPP-02
- `PRAGMA_KEYWORD_BYTES32` (line 15): No NatSpec -- SEE FINDING P3-LPP-02
- `PRAGMA_KEYWORD_BYTES_LENGTH` (line 16): No NatSpec -- SEE FINDING P3-LPP-02
- `PRAGMA_KEYWORD_MASK` (line 18): No NatSpec -- SEE FINDING P3-LPP-02

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `parsePragma` | 33 | Yes (26) | `state`, `cursor`, `end` | documented | COMPLETE |

---

### 7. `src/lib/parse/LibParseStackName.sol` (89 lines)

**Library**: `LibParseStackName` (line 21)
- Library-level: `@title` (line 7) + `@notice` (line 8) -- complete

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `pushStackName` | 31 | Yes (22) | `state`, `word` | `exists`, `index` | COMPLETE |
| `stackNameIndex` | 62 | Yes (54) | `state`, `word` | `exists`, `index` | COMPLETE |

---

### 8. `src/lib/parse/LibParseStackTracker.sol` (77 lines)

**Library**: `LibParseStackTracker` (line 9)
- Library-level: NO NatSpec -- SEE FINDING P3-LPST-01

**Type**: `ParseStackTracker` (line 7): No NatSpec -- SEE FINDING P3-LPST-02

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `pushInputs` | 19 | Yes (12) | `tracker`, `n` | documented | COMPLETE |
| `push` | 41 | Yes (31) | `tracker`, `n` | documented | COMPLETE |
| `pop` | 68 | Yes (57) | `tracker`, `n` | documented | COMPLETE |

---

### 9. `src/lib/parse/LibSubParse.sol` (450 lines)

**Library**: `LibSubParse` (line 36)
- Library-level: `@title` (line 25) + `@notice` (line 26) -- complete

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `subParserContext` | 48 | Yes (40) | `column`, `row` | 3 returns documented | COMPLETE |
| `subParserConstant` | 96 | Yes (89) | `constantsHeight`, `value` | 3 returns documented | COMPLETE |
| `subParserExtern` | 161 | Yes (144) | `extern`, `constantsHeight`, `ioByte`, `operand`, `opcodeIndex` | 3 returns documented | COMPLETE |
| `subParseWordSlice` | 215 | Yes (210) | `state`, `cursor`, `end` | void | COMPLETE |
| `subParseWords` | 323 | Yes (316) | `state`, `bytecode` | 2 returns documented | COMPLETE |
| `subParseLiteral` | 349 | Yes (340) | `state`, `dispatchStart`, `dispatchEnd`, `bodyStart`, `bodyEnd` | documented | COMPLETE |
| `consumeSubParseWordInputData` | 407 | Yes (396) | `data`, `meta`, `operandHandlers` | `constantsHeight`, `ioByte`, `state` | COMPLETE |
| `consumeSubParseLiteralInputData` | 438 | Yes (431) | `data` | `dispatchStart`, `bodyStart`, `bodyEnd` | COMPLETE |

---

### 10. `src/lib/parse/literal/LibParseLiteral.sol` (125 lines)

**Library**: `LibParseLiteral` (line 23)
- Library-level: NO NatSpec -- SEE FINDING P3-LPL-01

**Constants**:
- `LITERAL_PARSERS_LENGTH` (line 16): No NatSpec -- SEE FINDING P3-LPL-02
- `LITERAL_PARSER_INDEX_HEX` (line 18): No NatSpec -- SEE FINDING P3-LPL-02
- `LITERAL_PARSER_INDEX_DECIMAL` (line 19): No NatSpec -- SEE FINDING P3-LPL-02
- `LITERAL_PARSER_INDEX_STRING` (line 20): No NatSpec -- SEE FINDING P3-LPL-02
- `LITERAL_PARSER_INDEX_SUB_PARSE` (line 21): No NatSpec -- SEE FINDING P3-LPL-02

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `selectLiteralParserByIndex` | 33 | Yes (27) | `state`, `index` | documented | COMPLETE |
| `parseLiteral` | 55 | Yes (48) | `state`, `cursor`, `end` | 2 returns documented | COMPLETE |
| `tryParseLiteral` | 77 | Yes (68) | `state`, `cursor`, `end` | 3 returns documented | COMPLETE |

---

### 11. `src/lib/parse/literal/LibParseLiteralDecimal.sol` (30 lines)

**Library**: `LibParseLiteralDecimal` (line 10)
- Library-level: NO NatSpec -- SEE FINDING P3-LPLD-01

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `parseDecimalFloatPacked` | 20 | Yes (13) | `state`, `start`, `end` | 2 returns documented | COMPLETE |

---

### 12. `src/lib/parse/literal/LibParseLiteralHex.sol` (122 lines)

**Library**: `LibParseLiteralHex` (line 20)
- Library-level: NO NatSpec -- SEE FINDING P3-LPLH-01

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `boundHex` | 31 | Yes (24) | `cursor`, `end` (note: `state` unused) | 3 returns documented | COMPLETE |
| `parseHex` | 63 | Yes (51) | `state`, `cursor`, `end` | 2 returns documented | COMPLETE |

---

### 13. `src/lib/parse/literal/LibParseLiteralString.sol` (112 lines)

**Library**: `LibParseLiteralString` (line 13)
- Library-level: `@title` (line 11) + `@notice` (line 12) -- complete

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `boundString` | 26 | Yes (17) | `state`, `cursor`, `end` | 3 returns documented | COMPLETE |
| `parseString` | 88 | Yes (77) | `state`, `cursor`, `end` | 2 returns documented | COMPLETE |

---

### 14. `src/lib/parse/literal/LibParseLiteralSubParseable.sol` (88 lines)

**Library**: `LibParseLiteralSubParseable` (line 14)
- Library-level: NO NatSpec -- SEE FINDING P3-LPLSP-01

**Functions**:
| Function | Line | `@notice` | `@param` | `@return` | Status |
|---|---|---|---|---|---|
| `parseSubParseable` | 35 | Yes (20) | `state`, `cursor`, `end` | 2 returns documented | COMPLETE |

---

## Error NatSpec Audit (ErrParse.sol)

Errors with `@notice` + `@param` tags (complete): `OperandValuesOverflow`, `UnclosedOperand`, `UnsupportedLiteralType`, `StringTooLong`, `UnclosedStringLiteral`, `HexLiteralOverflow`, `ZeroLengthHexLiteral`, `OddLengthHexLiteral`, `MalformedHexLiteral`, `MissingFinalSemi`, `UnexpectedLHSChar`, `UnexpectedRHSChar`, `ExpectedLeftParen`, `UnexpectedRightParen`, `UnclosedLeftParen`, `UnexpectedComment`, `UnclosedComment`, `MalformedCommentStart`, `DuplicateLHSItem`, `ExcessLHSItems`, `NotAcceptingInputs`, `ExcessRHSItems`, `WordSize`, `UnknownWord`, `NoWhitespaceAfterUsingWordsFrom`, `InvalidSubParser`, `UnclosedSubParseableLiteral`, `SubParseableMissingDispatch`, `BadSubParserResult`, `OpcodeIOOverflow`, `ParseMemoryOverflow`.

Errors missing `@notice`/`@dev` tag (doc comments exist but no explicit tag): SEE FINDING P3-ERR-01
- `UnexpectedOperand` (line 8-10)
- `UnexpectedOperandValue` (line 12-14)
- `ExpectedOperand` (line 16-18)
- `MaxSources` (line 120-121)
- `DanglingSource` (line 123-124)
- `ParserOutOfBounds` (line 126-127)
- `ParseStackOverflow` (line 129-131)
- `ParseStackUnderflow` (line 133-134)
- `ParenOverflow` (line 136-138)
- `OperandOverflow` (line 165-166)
- `SourceItemOpsOverflow` (line 173-175)
- `ParenInputOverflow` (line 177-179)
- `LineRHSItemsOverflow` (line 181-183)

---

## Findings

### P3-LP-01: `parse()` second `@return` tag missing name [INFO]

**File**: `src/lib/parse/LibParse.sol`, line 424
**Description**: The `parse` function returns two values: `bytes memory bytecode` (named) and `bytes32[] memory` (unnamed). The NatSpec has `@return bytecode` and `@return The constants array.` but the second return value has no name in the function signature, so `@return` cannot bind to a name. The documentation content is present but the return variable itself is unnamed in the signature.

This is cosmetic but inconsistent with the first return which is named.

---

### P3-LPS-01: `LibParseState` library missing library-level NatSpec [LOW]

**File**: `src/lib/parse/LibParseState.sol`, line 185
**Description**: The `LibParseState` library has no `@title` or `@notice` tag. The `ParseState` struct is well documented, but the library itself (which contains 16 functions) has no introductory documentation.

---

### P3-LPS-02: `checkParseMemoryOverflow` missing `@notice` tag [LOW]

**File**: `src/lib/parse/LibParseState.sol`, lines 1032-1044
**Description**: The `checkParseMemoryOverflow` function has a detailed NatSpec comment block (lines 1032-1043) but uses no explicit tag. Since `LibParseState` is a library and other functions in the same library use `@notice`, consistency requires this function to also use `@notice`. The untagged lines default to `@notice` only when no tags are present in the doc block, but as a standalone doc block with no tags, it technically defaults correctly. However, for consistency with all other functions in the file which explicitly use `@notice`, an explicit tag should be added.

---

### P3-LPE-01: `LibParseError` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/LibParseError.sol`, line 7
**Description**: The `LibParseError` library has no `@title` or `@notice` tag. Both functions within it are fully documented.

---

### P3-LPI-01: `LibParseInterstitial` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/LibParseInterstitial.sol`, line 17
**Description**: The `LibParseInterstitial` library has no `@title` or `@notice` tag. All functions within it are fully documented.

---

### P3-LPO-01: `LibParseOperand` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/LibParseOperand.sol`, line 21
**Description**: The `LibParseOperand` library has no `@title` or `@notice` tag. All functions within it are fully documented.

---

### P3-LPP-01: `LibParsePragma` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/LibParsePragma.sol`, line 20
**Description**: The `LibParsePragma` library has no `@title` or `@notice` tag. The single function within it is fully documented.

---

### P3-LPP-02: Pragma constants missing NatSpec [LOW]

**File**: `src/lib/parse/LibParsePragma.sol`, lines 12-18
**Description**: Four file-level constants have no NatSpec documentation:
- `PRAGMA_KEYWORD_BYTES` (line 12)
- `PRAGMA_KEYWORD_BYTES32` (line 15)
- `PRAGMA_KEYWORD_BYTES_LENGTH` (line 16)
- `PRAGMA_KEYWORD_MASK` (line 18)

These define the `using-words-from` pragma keyword matching parameters and should have `@dev` documentation explaining their purpose.

---

### P3-LPST-01: `LibParseStackTracker` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/LibParseStackTracker.sol`, line 9
**Description**: The `LibParseStackTracker` library has no `@title` or `@notice` tag. All functions within it are fully documented.

---

### P3-LPST-02: `ParseStackTracker` type missing NatSpec [LOW]

**File**: `src/lib/parse/LibParseStackTracker.sol`, line 7
**Description**: The `ParseStackTracker` user-defined value type (`type ParseStackTracker is uint256`) has no NatSpec. This type encodes three packed fields (current height in bits 0-7, inputs in bits 8-15, max/highwater in bits 16+) that are documented implicitly across the `push`, `pop`, and `pushInputs` functions but never explained as a whole. A `@dev` comment on the type declaration would help readers understand the encoding.

---

### P3-LPL-01: `LibParseLiteral` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/literal/LibParseLiteral.sol`, line 23
**Description**: The `LibParseLiteral` library has no `@title` or `@notice` tag. All functions within it are fully documented.

---

### P3-LPL-02: Literal parser index constants missing NatSpec [LOW]

**File**: `src/lib/parse/literal/LibParseLiteral.sol`, lines 16-21
**Description**: Five file-level constants have no NatSpec documentation:
- `LITERAL_PARSERS_LENGTH` (line 16)
- `LITERAL_PARSER_INDEX_HEX` (line 18)
- `LITERAL_PARSER_INDEX_DECIMAL` (line 19)
- `LITERAL_PARSER_INDEX_STRING` (line 20)
- `LITERAL_PARSER_INDEX_SUB_PARSE` (line 21)

These define the dispatch indices for literal type resolution and should have `@dev` documentation.

---

### P3-LPLD-01: `LibParseLiteralDecimal` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/literal/LibParseLiteralDecimal.sol`, line 10
**Description**: The `LibParseLiteralDecimal` library has no `@title` or `@notice` tag. The single function within it is fully documented.

---

### P3-LPLH-01: `LibParseLiteralHex` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/literal/LibParseLiteralHex.sol`, line 20
**Description**: The `LibParseLiteralHex` library has no `@title` or `@notice` tag. All functions within it are fully documented.

---

### P3-LPLSP-01: `LibParseLiteralSubParseable` library missing library-level NatSpec [INFO]

**File**: `src/lib/parse/literal/LibParseLiteralSubParseable.sol`, line 14
**Description**: The `LibParseLiteralSubParseable` library has no `@title` or `@notice` tag. The single function within it is fully documented.

---

### P3-ERR-01: 13 errors in ErrParse.sol missing explicit NatSpec tags [LOW]

**File**: `src/error/ErrParse.sol`
**Description**: 13 custom errors have NatSpec doc comments but lack explicit tags (`@notice`/`@dev`). While untagged doc comments default to `@notice` when no other tags are present in the block, many peer errors in the same file DO use explicit `@notice`. This inconsistency should be resolved. The affected errors are:

- `UnexpectedOperand` (line 8-10)
- `UnexpectedOperandValue` (line 12-14)
- `ExpectedOperand` (line 16-18)
- `MaxSources` (line 120-121)
- `DanglingSource` (line 123-124)
- `ParserOutOfBounds` (line 126-127)
- `ParseStackOverflow` (line 129-131)
- `ParseStackUnderflow` (line 133-134)
- `ParenOverflow` (line 136-138)
- `OperandOverflow` (line 165-166)
- `SourceItemOpsOverflow` (line 173-175)
- `ParenInputOverflow` (line 177-179)
- `LineRHSItemsOverflow` (line 181-183)

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 5 (P3-LPS-01, P3-LPS-02, P3-LPP-02, P3-LPST-02, P3-LPL-02, P3-ERR-01) |
| INFO | 9 (P3-LP-01, P3-LPE-01, P3-LPI-01, P3-LPO-01, P3-LPP-01, P3-LPST-01, P3-LPL-01, P3-LPLD-01, P3-LPLH-01, P3-LPLSP-01) |

All 45 internal functions across the 14 files have `@notice`, `@param`, and `@return` NatSpec tags present and accurate. The findings are limited to missing library-level documentation, missing constant documentation, inconsistent tag usage on errors, and one type definition without NatSpec.
