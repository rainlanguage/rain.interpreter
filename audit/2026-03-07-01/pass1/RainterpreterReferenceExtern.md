# Pass 1 (Security) -- RainterpreterReferenceExtern.sol

**Auditor:** A03
**Date:** 2026-03-07
**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`

## Evidence of Thorough Reading

### Contract/Library Names

- `library LibRainterpreterReferenceExtern` (line 88)
- `contract RainterpreterReferenceExtern is BaseRainterpreterSubParser, BaseRainterpreterExtern` (line 161)

### Constants Defined

| Constant | Line | Value / Description |
|---|---|---|
| `SUB_PARSER_WORD_PARSERS_LENGTH` | 46 | `5` |
| `SUB_PARSER_LITERAL_PARSERS_LENGTH` | 49 | `1` |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD` | 53 | `bytes("ref-extern-repeat-")` |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32` | 58 | `bytes32(SUB_PARSER_LITERAL_REPEAT_KEYWORD)` |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` | 61 | `18` |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK` | 65-67 | Bitmask zeroing bytes after the keyword |
| `SUB_PARSER_LITERAL_REPEAT_INDEX` | 71 | `0` |
| `OPCODE_FUNCTION_POINTERS_LENGTH` | 81 | `1` |

### Errors Defined

| Error | Line |
|---|---|
| `InvalidRepeatCount()` | 74 |
| `UnconsumedRepeatDispatchBytes()` | 78 |

### Functions and Line Numbers

**LibRainterpreterReferenceExtern (library):**

| Function | Line | Visibility |
|---|---|---|
| `authoringMetaV2()` | 97 | internal pure |

**RainterpreterReferenceExtern (contract):**

| Function | Line | Visibility |
|---|---|---|
| `describedByMetaV1()` | 165 | external pure override |
| `subParserParseMeta()` | 172 | internal pure virtual override |
| `subParserWordParsers()` | 179 | internal pure override |
| `subParserOperandHandlers()` | 186 | internal pure override |
| `subParserLiteralParsers()` | 193 | internal pure override |
| `opcodeFunctionPointers()` | 200 | internal pure override |
| `integrityFunctionPointers()` | 207 | internal pure override |
| `buildLiteralParserFunctionPointers()` | 213 | external pure |
| `matchSubParseLiteralDispatch(uint256,uint256)` | 236 | internal pure virtual override |
| `buildOperandHandlerFunctionPointers()` | 282 | external pure override |
| `buildSubParserWordParsers()` | 325 | external pure |
| `buildOpcodeFunctionPointers()` | 367 | external pure |
| `buildIntegrityFunctionPointers()` | 401 | external pure |
| `supportsInterface(bytes4)` | 429 | public view virtual override |

### Imports Referenced (from generated pointers file)

- `DESCRIBED_BY_META_HASH`
- `PARSE_META` (aliased `SUB_PARSER_PARSE_META`)
- `PARSE_META_BUILD_DEPTH` (aliased `EXTERN_PARSE_META_BUILD_DEPTH`)
- `SUB_PARSER_WORD_PARSERS`
- `OPERAND_HANDLER_FUNCTION_POINTERS`
- `LITERAL_PARSER_FUNCTION_POINTERS`
- `INTEGRITY_FUNCTION_POINTERS`
- `OPCODE_FUNCTION_POINTERS`

### Inherited Base Contracts Reviewed

- `BaseRainterpreterExtern` -- extern dispatch via `extern()` and `externIntegrity()`, constructor validates pointer table consistency
- `BaseRainterpreterSubParser` -- sub-parser dispatch via `subParseWord2()` and `subParseLiteral2()`, with bounds-checked function pointer lookup

### External Op Libraries Reviewed

- `LibExternOpIntInc` -- increment extern op with `run`, `integrity`, `subParser`
- `LibExternOpStackOperand` -- copies operand to constants, subParser only
- `LibExternOpContextSender` -- context reference to sender, subParser only
- `LibExternOpContextCallingContract` -- context reference to calling contract, subParser only
- `LibExternOpContextRainlen` -- context reference to rainlang byte length, subParser only
- `LibParseLiteralRepeat` -- repeat literal parser with overflow-safe bounds

---

## Security Checklist Analysis

### Memory safety

All assembly blocks are marked `memory-safe`. The fixed-to-dynamic array conversion pattern (used in `authoringMetaV2` and all five `build*` functions) allocates `LENGTH + 1` elements, with the first slot repurposed as the dynamic array length. The `build*` functions all include `BadDynamicLength` sanity checks. The `authoringMetaV2` function in the library lacks this check but only produces metadata, not dispatch tables.

The `mload(cursor)` at line 247 reads 32 bytes starting at `cursor`. The subsequent length check on line 250 ensures `length > 18` (at least 19 bytes between cursor and end). The mask on line 251 zeroes bytes beyond position 18, so only the first 18 bytes participate in comparison. Reading past `end` into other allocated memory is harmless because the extra bytes are masked off.

### Input validation

- `matchSubParseLiteralDispatch` validates the repeat count is an integer in [0,9] using float comparison (lines 265-269), then checks `cursor != end` to reject trailing bytes (line 260-261). Both `InvalidRepeatCount` and `UnconsumedRepeatDispatchBytes` are custom errors.
- `LibParseLiteralRepeat.parseRepeat` has a redundant but correct check (`dispatchValue > 9`) and validates body length against `MAX_REPEAT_LITERAL_LENGTH = 78` to prevent overflow.
- Function pointer tables in `build*` functions are sanity-checked with `BadDynamicLength`.

### Reentrancy and state consistency

No state mutations in this contract. `extern()` in `BaseRainterpreterExtern` is `view`. All sub-parser functions are `pure` or `view`. No reentrancy risk.

### Arithmetic safety

- The `unchecked` block in `matchSubParseLiteralDispatch` (line 243) computes `end - cursor`. The caller (`consumeSubParseLiteralInputData`) derives both from the same `bytes memory data` allocation, guaranteeing `end >= cursor`.
- `LibParseLiteralRepeat.parseRepeat` uses `unchecked` but bounds `length < 78` and `dispatchValue <= 9`, with inline comments proving the arithmetic stays within uint256 range.

### Error handling

All revert paths use custom errors: `BadDynamicLength`, `InvalidRepeatCount`, `UnconsumedRepeatDispatchBytes`. Inherited base contracts use `ExternOpcodeOutOfRange`, `ExternPointersMismatch`, `ExternOpcodePointersEmpty`, `SubParserIndexOutOfBounds`. No string revert messages anywhere.

### Extern dispatch encoding/decoding

The `extern()` function in `BaseRainterpreterExtern` extracts the opcode as `(dispatch >> 0x10) & uint16_max` and operand as `dispatch & uint16_max`. This matches `LibExtern.encodeExternDispatch` which places opcode at bits [16,32) and operand at bits [0,16). The `mod(opcode, fsCount)` bounds the index.

### Function pointer tables out-of-bounds

- `extern()` uses `mod(opcode, fsCount)` -- cannot go OOB.
- `externIntegrity()` uses strict bounds check with `ExternOpcodeOutOfRange` revert.
- `subParseWord2()` and `subParseLiteral2()` in `BaseRainterpreterSubParser` both check `index >= parsersLength` with `SubParserIndexOutOfBounds` revert before the assembly pointer load.
- Constructor validates `opcodeFunctionPointers().length > 0` and matches integrity table length.

---

## Findings

No findings.

The contract has been previously audited (audit 2026-02-17-03 and triage 2026-03-01-01). The two findings from that triage relevant to this file -- A49-6 (dispatch cursor not checked against end) and A49-8 (local constants lacking NatSpec) -- have been fixed/documented and are visible in the current code:
- Line 260-261: `cursor != end` check with `UnconsumedRepeatDispatchBytes` revert (A49-6 fix)
- Lines 8-18 in `LibExternOpContextRainlen.sol`: NatSpec explaining local constant definitions (A49-8 documentation)

The previous audit's findings 1-7 (LOW/INFO) remain accurately assessed. No new issues were introduced by the fixes applied since the prior audit. All assembly blocks, dispatch mechanisms, bounds checks, and error handling are sound.
