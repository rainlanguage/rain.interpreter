# Pass 3 — NatSpec Documentation Audit: Extern & Abstract Contracts

Auditor: Claude Opus 4.6
Date: 2026-03-01
Scope: 10 files covering extern abstract bases, reference extern, LibExtern, and reference op/literal libraries.

---

## File Inventory and Evidence of Thorough Reading

### 1. `src/abstract/BaseRainterpreterExtern.sol` (131 lines)

**Contract:** `BaseRainterpreterExtern` (abstract)
**Constants (file-level):**
- `OPCODE_FUNCTION_POINTERS` (line 20) — `@dev` documented
- `INTEGRITY_FUNCTION_POINTERS` (line 24) — `@dev` documented

**Functions:**
- `constructor()` (line 34) — NatSpec present (untagged, defaults to `@notice`)
- `extern(ExternDispatchV2, StackItem[])` (line 46) — `@inheritdoc IInterpreterExternV4`
- `externIntegrity(ExternDispatchV2, uint256, uint256)` (line 83) — `@inheritdoc IInterpreterExternV4`
- `supportsInterface(bytes4)` (line 112) — `@inheritdoc ERC165`
- `opcodeFunctionPointers()` (line 121) — NatSpec present (untagged)
- `integrityFunctionPointers()` (line 128) — NatSpec present (untagged)

### 2. `src/abstract/BaseRainterpreterSubParser.sol` (220 lines)

**Contract:** `BaseRainterpreterSubParser` (abstract)
**Constants (file-level):**
- `SUB_PARSER_WORD_PARSERS` (line 26) — `@dev` documented
- `SUB_PARSER_PARSE_META` (line 32) — `@dev` documented
- `SUB_PARSER_OPERAND_HANDLERS` (line 36) — `@dev` documented
- `SUB_PARSER_LITERAL_PARSERS` (line 40) — `@dev` documented

**Functions:**
- `subParserParseMeta()` (line 93) — NatSpec present (untagged)
- `subParserWordParsers()` (line 100) — NatSpec present (untagged)
- `subParserOperandHandlers()` (line 107) — NatSpec present (untagged)
- `subParserLiteralParsers()` (line 114) — NatSpec present (untagged)
- `matchSubParseLiteralDispatch(uint256, uint256)` (line 139) — `@notice`, `@param cursor`, `@param end`, `@return success`, `@return index`, `@return value` all present
- `subParseLiteral2(bytes)` (line 159) — `@notice` + `@inheritdoc ISubParserV4`
- `subParseWord2(bytes)` (line 188) — `@notice` + `@inheritdoc ISubParserV4`
- `supportsInterface(bytes4)` (line 215) — `@inheritdoc ERC165`

### 3. `src/concrete/extern/RainterpreterReferenceExtern.sol` (427 lines)

**Library:** `LibRainterpreterReferenceExtern`
**Contract:** `RainterpreterReferenceExtern`
**Constants (file-level):**
- `SUB_PARSER_WORD_PARSERS_LENGTH` (line 46) — `@dev` documented
- `SUB_PARSER_LITERAL_PARSERS_LENGTH` (line 49) — `@dev` documented
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD` (line 53) — `@dev` documented
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32` (line 58) — `@dev` documented
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` (line 61) — `@dev` documented
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK` (line 65) — `@dev` documented
- `SUB_PARSER_LITERAL_REPEAT_INDEX` (line 71) — `@dev` documented
- `OPCODE_FUNCTION_POINTERS_LENGTH` (line 77) — `@dev` documented

**Errors:**
- `InvalidRepeatCount` (line 74) — `@dev` documented

**Library functions:**
- `LibRainterpreterReferenceExtern.authoringMetaV2()` (line 93) — NatSpec present (untagged)

**Contract functions:**
- `describedByMetaV1()` (line 161) — `@inheritdoc IDescribedByMetaV1`
- `subParserParseMeta()` (line 168) — NatSpec present (untagged)
- `subParserWordParsers()` (line 175) — NatSpec present (untagged)
- `subParserOperandHandlers()` (line 182) — NatSpec present (untagged)
- `subParserLiteralParsers()` (line 189) — NatSpec present (untagged)
- `opcodeFunctionPointers()` (line 196) — NatSpec present (untagged)
- `integrityFunctionPointers()` (line 203) — NatSpec present (untagged)
- `buildLiteralParserFunctionPointers()` (line 209) — `@notice` + `@inheritdoc IParserToolingV1`
- `matchSubParseLiteralDispatch(uint256, uint256)` (line 232) — `@inheritdoc BaseRainterpreterSubParser`
- `buildOperandHandlerFunctionPointers()` (line 275) — `@notice` + `@inheritdoc IParserToolingV1`
- `buildSubParserWordParsers()` (line 318) — `@notice` + `@inheritdoc ISubParserToolingV1`
- `buildOpcodeFunctionPointers()` (line 358) — NatSpec present (untagged, no `@return`)
- `buildIntegrityFunctionPointers()` (line 390) — NatSpec present (untagged, no `@return`)
- `supportsInterface(bytes4)` (line 418) — `@notice` + `@inheritdoc BaseRainterpreterSubParser`

### 4. `src/lib/extern/LibExtern.sol` (80 lines)

**Library:** `LibExtern`
- `@title` and `@notice` present on library

**Functions:**
- `encodeExternDispatch(uint256, OperandV2)` (line 27) — `@notice`, `@param opcode`, `@param operand`, `@return` all present
- `decodeExternDispatch(ExternDispatchV2)` (line 35) — `@notice`, `@param dispatch`, `@return` x2 present
- `encodeExternCall(IInterpreterExternV4, ExternDispatchV2)` (line 56) — `@notice`, `@param extern`, `@param dispatch`, `@return` all present
- `decodeExternCall(EncodedExternDispatchV2)` (line 70) — `@notice`, `@param dispatch`, `@return` x2 present

### 5. `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol` (73 lines)

**Library:** `LibParseLiteralRepeat`
- `@title` and `@notice` present on library

**Constants:**
- `MAX_REPEAT_LITERAL_LENGTH` (line 34) — `@dev` documented

**Errors:**
- `RepeatLiteralTooLong(uint256)` (line 39) — `@dev` + `@param` documented
- `RepeatDispatchNotDigit(uint256)` (line 43) — `@dev` + `@param` documented

**Functions:**
- `parseRepeat(uint256, uint256, uint256)` (line 53) — `@notice`, `@param dispatchValue`, `@param cursor`, `@param end`, `@return` all present

### 6. `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol` (23 lines)

**Library:** `LibExternOpContextCallingContract`
- `@title` and `@notice` present

**Functions:**
- `subParser(uint256, uint256, OperandV2)` (line 19) — NatSpec present (untagged), no `@param` or `@return`

### 7. `src/lib/extern/reference/op/LibExternOpContextRainlen.sol` (22 lines)

**Library:** `LibExternOpContextRainlen`
- `@title` and `@notice` present

**Constants:**
- `CONTEXT_CALLER_CONTEXT_COLUMN` (line 8) — no NatSpec
- `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` (line 9) — no NatSpec

**Functions:**
- `subParser(uint256, uint256, OperandV2)` (line 18) — NatSpec present (untagged), no `@param` or `@return`

### 8. `src/lib/extern/reference/op/LibExternOpContextSender.sol` (21 lines)

**Library:** `LibExternOpContextSender`
- `@title` and `@notice` present

**Functions:**
- `subParser(uint256, uint256, OperandV2)` (line 17) — NatSpec present (untagged), no `@param` or `@return`

### 9. `src/lib/extern/reference/op/LibExternOpIntInc.sol` (67 lines)

**Library:** `LibExternOpIntInc`
- `@title` and `@notice` present

**Constants:**
- `OP_INDEX_INCREMENT` (line 13) — `@dev` documented

**Functions:**
- `run(OperandV2, StackItem[])` (line 27) — `@notice`, `@param inputs`, `@return` present
- `integrity(OperandV2, uint256, uint256)` (line 44) — `@notice`, `@param inputs`, `@return` x2 present
- `subParser(uint256, uint256, OperandV2)` (line 57) — `@notice`, `@param constantsHeight`, `@param ioByte`, `@param operand`, `@return` x3 present

### 10. `src/lib/extern/reference/op/LibExternOpStackOperand.sol` (31 lines)

**Library:** `LibExternOpStackOperand`
- `@title` and `@notice` present

**Functions:**
- `subParser(uint256, uint256, OperandV2)` (line 23) — `@notice`, `@param constantsHeight`, `@param operand`, `@return` x3 present

---

## Findings

### P3-EA-01 [LOW] — `opcodeFunctionPointers` NatSpec says "word dispatches" instead of "opcode dispatches"

**File:** `src/abstract/BaseRainterpreterExtern.sol`, line 118-119
**Description:** The NatSpec for `opcodeFunctionPointers()` reads "Overrideable function to provide the list of function pointers for word dispatches." The term "word dispatches" is the parser-side terminology. This function provides pointers for **opcode** dispatches at eval time (used in `extern()`). The sister function `integrityFunctionPointers` correctly says "integrity checks." Using "word dispatches" here is misleading and could confuse readers about the function's purpose.
**Fix:** Change "word dispatches" to "opcode dispatches" or "extern opcode dispatches."

### P3-EA-02 [LOW] — `buildOpcodeFunctionPointers` and `buildIntegrityFunctionPointers` missing `@return` tags

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`, lines 350-358 and 382-390
**Description:** Both `buildOpcodeFunctionPointers()` and `buildIntegrityFunctionPointers()` are external functions returning `bytes memory`. Their NatSpec comments describe their purpose but lack `@return` tags documenting the return value. Per conventions, all public/external functions need `@return` tags. Other build functions on the same contract (`buildLiteralParserFunctionPointers`, `buildOperandHandlerFunctionPointers`, `buildSubParserWordParsers`) use `@inheritdoc` to pull interface documentation which includes return semantics.
**Fix:** Add `@return` tags, or add `@inheritdoc IOpcodeToolingV1` / `@inheritdoc IIntegrityToolingV1` directives.

### P3-EA-03 [LOW] — `subParser` functions on context op libraries missing `@param` and `@return` tags

**Files:**
- `src/lib/extern/reference/op/LibExternOpContextCallingContract.sol`, line 19
- `src/lib/extern/reference/op/LibExternOpContextRainlen.sol`, line 18
- `src/lib/extern/reference/op/LibExternOpContextSender.sol`, line 17

**Description:** The `subParser(uint256, uint256, OperandV2)` function in each of these three libraries has a plain `///` comment but no `@param` or `@return` NatSpec tags. The sibling implementations in `LibExternOpIntInc.subParser` and `LibExternOpStackOperand.subParser` fully document all parameters and return values. These three functions have unnamed parameters which makes `@param` tags impossible without first naming them, but the `@return` tags and parameter naming are both needed for documentation completeness.
**Fix:** Name the parameters (e.g. `constantsHeight`, `ioByte`, `operand` to match the pattern in `LibExternOpIntInc`) and add `@param` and `@return` tags.

### P3-EA-04 [LOW] — Undocumented constants in `LibExternOpContextRainlen.sol`

**File:** `src/lib/extern/reference/op/LibExternOpContextRainlen.sol`, lines 8-9
**Description:** The file-level constants `CONTEXT_CALLER_CONTEXT_COLUMN` and `CONTEXT_CALLER_CONTEXT_ROW_RAINLEN` have no NatSpec documentation. By contrast, the equivalent constants in `LibExternOpContextCallingContract.sol` and `LibExternOpContextSender.sol` are imported from the interface library (`LibContext.sol`) where they are presumably documented. These locally-defined constants should have `@dev` documentation explaining what context grid position they reference.
**Fix:** Add `@dev` NatSpec to both constants.

### P3-EA-05 [LOW] — Typo in `SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK` NatSpec

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`, line 63
**Description:** The NatSpec reads "The mask to apply to the dispatch bytes when parsing to **determin** whether the dispatch is for the repeat literal parser." The word "determin" should be "determine."
**Fix:** Correct the typo.

### P3-EA-06 [INFO] — `LibRainterpreterReferenceExtern.authoringMetaV2` missing `@return` tag

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`, line 93
**Description:** The `authoringMetaV2()` function has a descriptive untagged NatSpec comment but no `@return` tag for its `bytes memory` return value. This is an internal function so the convention requirement for `@param`/`@return` applies less strictly, but adding a `@return` tag would improve clarity.

### P3-EA-07 [INFO] — `ExternOpcodePointersEmpty` error NatSpec lacks `@notice` tag

**File:** `src/error/ErrExtern.sol`, line 27-28
**Description:** The `ExternOpcodePointersEmpty` error uses an untagged `///` comment while the other errors in the same file (`ExternOpcodeOutOfRange`, `ExternPointersMismatch`, `BadOutputsLength`) all use explicit `@notice` tags. Since no explicit tags are present in this block, it defaults to `@notice` and is technically correct. However it is inconsistent with the rest of the file.

### P3-EA-08 [INFO] — `LibParseLiteralRepeat.parseRepeat` `@param dispatchValue` may be misleading

**File:** `src/lib/extern/reference/literal/LibParseLiteralRepeat.sol`, line 48
**Description:** The NatSpec says `@param dispatchValue The single decimal digit to repeat (0-9)`. However, the actual value passed to this function through the function pointer dispatch in `BaseRainterpreterSubParser.subParseLiteral2` is a packed decimal float `bytes32` reinterpreted as `uint256` (via assembly function pointer casting). The function's guard `if (dispatchValue > 9)` checks this raw value against 9, which may not produce correct results for packed float representations of digits 0-9. The documentation describes the *intended* semantic (a digit 0-9) but not the actual representation of the value. This is at the boundary of a documentation finding and a correctness finding; flagging here for documentation purposes.

### P3-EA-09 [INFO] — Internal override functions in `RainterpreterReferenceExtern` lack `@return` tags

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`, lines 168, 175, 182, 189, 196, 203
**Description:** The six internal override functions (`subParserParseMeta`, `subParserWordParsers`, `subParserOperandHandlers`, `subParserLiteralParsers`, `opcodeFunctionPointers`, `integrityFunctionPointers`) each have untagged NatSpec but no `@return` tags. As internal functions, this is lower priority, but they mirror the pattern of their base class counterparts which also lack `@return` tags.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0     |
| HIGH     | 0     |
| MEDIUM   | 0     |
| LOW      | 5     |
| INFO     | 4     |

The extern system documentation is generally well-maintained. `LibExtern.sol` is exemplary with complete `@notice`, `@param`, and `@return` tags on all functions. `LibExternOpIntInc` and `LibExternOpStackOperand` also demonstrate good documentation practice. The main gaps are: (1) a misleading "word dispatches" description in the base extern contract, (2) missing `@return` tags on two external build functions, (3) three context op libraries with undocumented `subParser` functions, (4) undocumented local constants, and (5) a typo.
