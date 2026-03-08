# Pass 3 -- Documentation: Core Concrete Contracts (Agent A01)

## Source Files Reviewed

### 1. `src/abstract/BaseRainterpreterExtern.sol`

**Contract:** `BaseRainterpreterExtern` (abstract)

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 20 | `OPCODE_FUNCTION_POINTERS` | constant | `@dev` |
| 24 | `INTEGRITY_FUNCTION_POINTERS` | constant | `@dev` |
| 26-28 | contract docblock | contract | untagged (implicit `@notice`, no other tags) |
| 30-33 | `constructor()` | function | untagged (implicit `@notice`, no other tags) |
| 45-80 | `extern(ExternDispatchV2, StackItem[])` | function | `@inheritdoc IInterpreterExternV4` |
| 82-109 | `externIntegrity(ExternDispatchV2, uint256, uint256)` | function | `@inheritdoc IInterpreterExternV4` |
| 111-116 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |
| 118-123 | `opcodeFunctionPointers()` | function (virtual) | `@notice`, no `@return` |
| 125-130 | `integrityFunctionPointers()` | function (virtual) | untagged (implicit `@notice`, no other tags), no `@return` |

**NatSpec assessment:** `opcodeFunctionPointers` uses explicit `@notice` (line 118) while the parallel `integrityFunctionPointers` does not (line 125). Both omit `@return`. The inconsistency is a style issue; neither block contains explicit tags that would make untagged lines ambiguous for `integrityFunctionPointers`. No `@return` on either function.

---

### 2. `src/abstract/BaseRainterpreterSubParser.sol`

**Contract:** `BaseRainterpreterSubParser` (abstract)

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 21-26 | `SUB_PARSER_WORD_PARSERS` | constant | `@dev` |
| 28-32 | `SUB_PARSER_PARSE_META` | constant | `@dev` (typo: "fingeprinting") |
| 34-36 | `SUB_PARSER_OPERAND_HANDLERS` | constant | `@dev` |
| 38-40 | `SUB_PARSER_LITERAL_PARSERS` | constant | `@dev` |
| 42-77 | contract docblock | contract | untagged (implicit `@notice`) |
| 90-95 | `subParserParseMeta()` | function (virtual) | untagged, no `@return` |
| 97-102 | `subParserWordParsers()` | function (virtual) | untagged, no `@return` |
| 104-109 | `subParserOperandHandlers()` | function (virtual) | untagged, no `@return` |
| 111-116 | `subParserLiteralParsers()` | function (virtual) | untagged, no `@return` |
| 118-149 | `matchSubParseLiteralDispatch(uint256, uint256)` | function (virtual) | `@notice`, `@param` x2, `@return` x3 |
| 151-178 | `subParseLiteral2(bytes)` | function | `@notice` + `@inheritdoc` |
| 180-212 | `subParseWord2(bytes)` | function | `@notice` + `@inheritdoc` |
| 214-219 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |

**NatSpec assessment:** Typo on line 30. Internal virtual functions missing `@return`.

---

### 3. `src/concrete/Rainterpreter.sol`

**Contract:** `Rainterpreter`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 29-31 | contract docblock | contract | `@title` + `@notice` |
| 36-37 | `constructor()` | function | untagged (implicit `@notice`, no other tags) |
| 42-51 | `opcodeFunctionPointers()` | function (virtual) | `@notice` + `@return` |
| 53-74 | `eval4(EvalV4)` | function | `@inheritdoc IInterpreterV4` |
| 76-80 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |
| 82-85 | `buildOpcodeFunctionPointers()` | function | `@inheritdoc IOpcodeToolingV1` |

**NatSpec assessment:** Complete. No issues.

---

### 4. `src/concrete/RainterpreterStore.sol`

**Contract:** `RainterpreterStore`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 19-24 | contract docblock | contract | `@title` + `@notice` |
| 28-40 | `sStore` | state variable | untagged (implicit `@notice`, no other tags) |
| 42-45 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |
| 47-63 | `set(StateNamespace, bytes32[])` | function | `@inheritdoc IInterpreterStoreV3` |
| 65-68 | `get(FullyQualifiedNamespace, bytes32)` | function | `@inheritdoc IInterpreterStoreV3` |

**NatSpec assessment:** Complete. No issues.

---

### 5. `src/concrete/RainterpreterExpressionDeployer.sol`

**Contract:** `RainterpreterExpressionDeployer`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 23-25 | contract docblock | contract | `@title` + `@notice` |
| 33-38 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |
| 40-61 | `parse2(bytes)` | function | `@inheritdoc IParserV2` |
| 63-70 | `parsePragma1(bytes)` | function | `@notice` + `@inheritdoc IParserPragmaV1` |
| 72-75 | `buildIntegrityFunctionPointers()` | function | `@inheritdoc IIntegrityToolingV1` |
| 77-80 | `describedByMetaV1()` | function | `@inheritdoc IDescribedByMetaV1` |

**NatSpec assessment:** Complete. No issues.

---

### 6. `src/concrete/RainterpreterParser.sol`

**Contract:** `RainterpreterParser`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 30-35 | contract docblock | contract | `@title` + `@notice` + `@dev` |
| 43-49 | `checkParseMemoryOverflow` | modifier | untagged (implicit `@notice`, no other tags) |
| 51-69 | `unsafeParse(bytes)` | function | `@notice` + `@param` + `@return` x2 |
| 71-74 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |
| 76-90 | `parsePragma1(bytes)` | function | `@notice` + `@param` + `@return` |
| 92-96 | `parseMeta()` | function | `@notice` + `@return` |
| 98-103 | `operandHandlerFunctionPointers()` | function | `@notice` + `@return` |
| 105-110 | `literalParserFunctionPointers()` | function | `@notice` + `@return` |
| 112-115 | `buildOperandHandlerFunctionPointers()` | function | `@inheritdoc IParserToolingV1` |
| 117-120 | `buildLiteralParserFunctionPointers()` | function | `@inheritdoc IParserToolingV1` |

**NatSpec assessment:** Complete. No issues.

---

### 7. `src/concrete/RainterpreterDISPaiRegistry.sol`

**Contract:** `RainterpreterDISPaiRegistry`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 9-14 | contract docblock | contract | `@title` + `@notice` |
| 16-19 | `supportsInterface(bytes4)` | function | `@inheritdoc ERC165` |
| 21-24 | `expressionDeployerAddress()` | function | `@inheritdoc IDISPaiRegistry` |
| 26-29 | `interpreterAddress()` | function | `@inheritdoc IDISPaiRegistry` |
| 31-34 | `storeAddress()` | function | `@inheritdoc IDISPaiRegistry` |
| 36-39 | `parserAddress()` | function | `@inheritdoc IDISPaiRegistry` |

**NatSpec assessment:** Complete. No issues.

---

### 8. `src/concrete/extern/RainterpreterReferenceExtern.sol`

**Constants and errors:**

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 42-46 | `SUB_PARSER_WORD_PARSERS_LENGTH` | constant | `@dev` |
| 48-49 | `SUB_PARSER_LITERAL_PARSERS_LENGTH` | constant | `@dev` |
| 51-53 | `SUB_PARSER_LITERAL_REPEAT_KEYWORD` | constant | `@dev` |
| 55-58 | `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32` | constant | `@dev` |
| 60-61 | `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` | constant | `@dev` |
| 63-67 | `SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK` | constant | `@dev` |
| 69-71 | `SUB_PARSER_LITERAL_REPEAT_INDEX` | constant | `@dev` |
| 73-74 | `InvalidRepeatCount` | error | `@dev` |
| 76-78 | `UnconsumedRepeatDispatchBytes` | error | `@dev` |
| 80-81 | `OPCODE_FUNCTION_POINTERS_LENGTH` | constant | `@dev` |

**Library:** `LibRainterpreterReferenceExtern`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 83-87 | library docblock | library | `@title` + `@notice` |
| 89-129 | `authoringMetaV2()` | function | untagged (implicit `@notice`, no other tags), no `@return` |

**Contract:** `RainterpreterReferenceExtern`

| Line | Item | Type | NatSpec |
|------|------|------|--------|
| 132-160 | contract docblock | contract | `@title` + `@notice` (multi-section) |
| 164-167 | `describedByMetaV1()` | function | `@inheritdoc IDescribedByMetaV1` |
| 169-174 | `subParserParseMeta()` | function override | untagged, no `@return` |
| 176-181 | `subParserWordParsers()` | function override | untagged, no `@return` |
| 183-188 | `subParserOperandHandlers()` | function override | untagged, no `@return` |
| 190-195 | `subParserLiteralParsers()` | function override | untagged, no `@return` |
| 197-202 | `opcodeFunctionPointers()` | function override | untagged, no `@return` |
| 204-209 | `integrityFunctionPointers()` | function override | untagged, no `@return` |
| 211-233 | `buildLiteralParserFunctionPointers()` | function | `@notice` + `@inheritdoc IParserToolingV1` |
| 235-277 | `matchSubParseLiteralDispatch(...)` | function override | `@inheritdoc BaseRainterpreterSubParser` |
| 279-314 | `buildOperandHandlerFunctionPointers()` | function | `@notice` + `@inheritdoc IParserToolingV1` |
| 316-355 | `buildSubParserWordParsers()` | function | `@notice` + `@inheritdoc ISubParserToolingV1` |
| 357-389 | `buildOpcodeFunctionPointers()` | function | `@notice` + `@return` |
| 391-423 | `buildIntegrityFunctionPointers()` | function | `@notice` + `@return` |
| 425-437 | `supportsInterface(bytes4)` | function override | `@notice` + `@inheritdoc BaseRainterpreterSubParser` |

**NatSpec assessment:** Stale/incorrect `@notice` on `buildLiteralParserFunctionPointers` (line 211). Typo in `BaseRainterpreterSubParser.sol`.

---

## Findings

### A01-1

- **Severity:** LOW
- **Title:** Incorrect NatSpec on `buildLiteralParserFunctionPointers` in `RainterpreterReferenceExtern`
- **Affected file:** `src/concrete/extern/RainterpreterReferenceExtern.sol`
- **Affected lines:** 211
- **Description:** Line 211 states `@notice The literal parsers are the same as the main parser.` This is incorrect. The reference extern builds its own literal parser table containing `LibParseLiteralRepeat.parseRepeat` (a single-entry table for the "repeat" literal), while the main parser (`RainterpreterParser`) uses `LibAllStandardOps.literalParserFunctionPointers()` which includes decimal, hex, string, and sub-parsed literal parsers -- a completely different set. The NatSpec misleads readers about what this function returns. Should describe the actual content: the extern's own literal parsers for sub-parsing.

### A01-2

- **Severity:** LOW
- **Title:** Typo in NatSpec for `SUB_PARSER_PARSE_META` constant
- **Affected file:** `src/abstract/BaseRainterpreterSubParser.sol`
- **Affected lines:** 30
- **Description:** The `@dev` comment on line 30 reads "fingeprinting" -- missing the letter 'r'. Should be "fingerprinting". The full line is: `/// bytes. The exact same process of hashing, blooming, fingeprinting and index`. This appears in developer-facing documentation for a core abstract contract.

### A01-3

- **Severity:** INFO
- **Title:** Inconsistent `@notice` tagging between `opcodeFunctionPointers` and `integrityFunctionPointers` in `BaseRainterpreterExtern`
- **Affected file:** `src/abstract/BaseRainterpreterExtern.sol`
- **Affected lines:** 118, 125
- **Description:** `opcodeFunctionPointers()` (line 118) uses explicit `@notice`, while the parallel `integrityFunctionPointers()` (line 125) omits it. Both are internal virtual functions with identical documentation patterns. Since neither doc block contains other explicit tags, the omission is technically valid (untagged lines are implicit `@notice`), but the inconsistency between two adjacent parallel functions reduces documentation quality.
