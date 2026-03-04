# A08 — Pass 1 (Security) — RainterpreterReferenceExtern.sol

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`
**Agent:** A08
**Date:** 2026-03-04

## Evidence

### Contract

`RainterpreterReferenceExtern` (line 161) — inherits `BaseRainterpreterSubParser`, `BaseRainterpreterExtern`.

### Library

`LibRainterpreterReferenceExtern` (line 88) — `authoringMetaV2()` (line 97).

### Functions (contract)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `describedByMetaV1()` | 165 | external | pure |
| `subParserParseMeta()` | 172 | internal | pure |
| `subParserWordParsers()` | 179 | internal | pure |
| `subParserOperandHandlers()` | 186 | internal | pure |
| `subParserLiteralParsers()` | 193 | internal | pure |
| `opcodeFunctionPointers()` | 200 | internal | pure |
| `integrityFunctionPointers()` | 207 | internal | pure |
| `buildLiteralParserFunctionPointers()` | 213 | external | pure |
| `matchSubParseLiteralDispatch()` | 236 | internal | pure |
| `buildOperandHandlerFunctionPointers()` | 282 | external | pure |
| `buildSubParserWordParsers()` | 325 | external | pure |
| `buildOpcodeFunctionPointers()` | 367 | external | pure |
| `buildIntegrityFunctionPointers()` | 401 | external | pure |
| `supportsInterface()` | 429 | public | view |

### Constants

| Name | Line | Value |
|---|---|---|
| `SUB_PARSER_WORD_PARSERS_LENGTH` | 46 | 5 |
| `SUB_PARSER_LITERAL_PARSERS_LENGTH` | 49 | 1 |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD` | 53 | `bytes("ref-extern-repeat-")` |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32` | 58 | `bytes32(SUB_PARSER_LITERAL_REPEAT_KEYWORD)` |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` | 61 | 18 |
| `SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK` | 65-67 | Masks top 18 bytes |
| `SUB_PARSER_LITERAL_REPEAT_INDEX` | 71 | 0 |
| `OPCODE_FUNCTION_POINTERS_LENGTH` | 81 | 1 |

### Custom Errors

| Error | Line |
|---|---|
| `InvalidRepeatCount()` | 74 |
| `UnconsumedRepeatDispatchBytes()` | 78 |

### Imported Errors Used

- `BadDynamicLength` (from `ErrOpList.sol`) — used in all `build*` functions

## Security Review

### 1. Extern dispatch and function pointer tables

The contract overrides `opcodeFunctionPointers()` and `integrityFunctionPointers()` from `BaseRainterpreterExtern` at lines 200 and 207, returning pre-compiled constants from the generated pointers file. The base constructor validates these are non-empty and equal-length (both 2 bytes = 1 pointer each, matching `OPCODE_FUNCTION_POINTERS_LENGTH = 1`). The base `extern()` function applies `mod` to bound the opcode index, preventing OOB. **No issue.**

### 2. Assembly memory safety

All assembly blocks in this file use the `"memory-safe"` annotation. Each follows the same pattern: reinterpreting a fixed-size array as a dynamic array by overwriting the length slot. This is a standard pattern used throughout the codebase and does not write to arbitrary memory. Specifically:

- Lines 124-127 (`authoringMetaV2`): Converts fixed `AuthoringMetaV2[6]` to dynamic `AuthoringMetaV2[]`.
- Lines 217-219 (`buildLiteralParserFunctionPointers`): Converts fixed function pointer array to `uint256[]`.
- Lines 223-225: Same block, second conversion.
- Lines 246-248 (`matchSubParseLiteralDispatch`): Reads 32 bytes from cursor — cursor is a memory pointer within `data` provided by `consumeSubParseLiteralInputData`, which computes it from ABI-decoded input. Reads at the cursor position are safe as they are within the bounds of the input data allocated by the caller.
- Lines 286-288, 304-306 (`buildOperandHandlerFunctionPointers`): Same fixed-to-dynamic pattern.
- Lines 330-332, 345-347 (`buildSubParserWordParsers`): Same pattern.
- Lines 371-373, 379-381 (`buildOpcodeFunctionPointers`): Same pattern.
- Lines 405-407, 413-415 (`buildIntegrityFunctionPointers`): Same pattern.

**No issue.**

### 3. Reentrancy

No state modifications anywhere in this contract. All functions are `pure` or `view`. The inherited `extern()` is `view`. The inherited `subParseWord2()` is `pure` and `subParseLiteral2()` is `view`. **No issue.**

### 4. `matchSubParseLiteralDispatch` — repeat literal validation

Lines 236-277. The function:
1. Reads 32 bytes from `cursor` (line 247) and masks to compare against the keyword.
2. Requires `length > SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH` (line 250), ensuring there is at least one byte after the keyword to parse as a decimal.
3. Parses the remaining bytes as a decimal float via `parseDecimalFloatPacked` (line 257).
4. Checks `cursor != end` (line 260) to ensure no trailing bytes.
5. Validates the repeat count is an integer in [0, 9] (lines 265-268).

The `unchecked` block at line 243 wraps `end - cursor` (line 244). This is safe because `cursor` and `end` are derived from `consumeSubParseLiteralInputData`, which computes `bodyStart = dispatchStart + dispatchLength` and `bodyEnd = data + 0x20 + mload(data)`. The `cursor` here is `dispatchStart` and `end` is `bodyStart` (the dispatch region boundaries), so `end >= cursor` is guaranteed by construction. **No issue.**

### 5. `buildOpcodeFunctionPointers` / `buildIntegrityFunctionPointers` length constants

`buildIntegrityFunctionPointers` (line 401) uses `OPCODE_FUNCTION_POINTERS_LENGTH` for both the array size and the expected length. This is correct because the base constructor enforces that opcode and integrity pointer tables must have the same length. **No issue.**

### 6. `supportsInterface` diamond resolution

Line 429-437. The `supportsInterface` override resolves the diamond between `BaseRainterpreterSubParser` and `BaseRainterpreterExtern`, both of which inherit from `ERC165`. The `super.supportsInterface(interfaceId)` call uses C3 linearization, which will call `BaseRainterpreterSubParser.supportsInterface` first (rightmost parent in Solidity's C3 is called last in the chain, but `super` follows the linearization). Both base implementations check their respective interface IDs and delegate to `ERC165.supportsInterface`. **No issue.**

### 7. Build functions are tooling-only

All `build*` functions are `external pure` and are intended for offline tooling comparison against the compiled constants. They are not called at runtime. The `BadDynamicLength` revert in each is a sanity check that should be unreachable. **No issue.**

## Findings

No LOW+ findings.

## INFO

- A08-INFO-01: The `buildSubParserWordParsers` function (line 325) has `view` mutability on its inner function type (line 327: `internal view returns (...)`) even though the function itself is declared `external pure`. This compiles because the function pointers are never actually called — they are only used to extract their numeric pointer values. The mismatch is harmless but could be confusing to reviewers.

- A08-INFO-02: `matchSubParseLiteralDispatch` creates a throwaway `ParseState` via `LibParseState.newState("", "", "", "")` at line 253 solely to call `parseDecimalFloatPacked`. The parse state is not used for error reporting context and is immediately discarded. This is a minor gas/readability concern, not a security issue.
