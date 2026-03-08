# Pass 2: Test Coverage Audit -- DeployerParserRegistry

Agent: A02
Date: 2026-03-07
Source files:
- `/Users/thedavidmeister/Code/rain.interpreter/src/concrete/RainterpreterExpressionDeployer.sol`
- `/Users/thedavidmeister/Code/rain.interpreter/src/concrete/RainterpreterParser.sol`
- `/Users/thedavidmeister/Code/rain.interpreter/src/concrete/RainterpreterDISPaiRegistry.sol`
- `/Users/thedavidmeister/Code/rain.interpreter/src/concrete/extern/RainterpreterReferenceExtern.sol`

---

## 1. RainterpreterExpressionDeployer

| Function | Line | Test File(s) | Covered |
|---|---|---|---|
| `supportsInterface` | 34 | `ierc165.t.sol` | Yes (fuzz + all 5 interface IDs) |
| `parse2` | 41 | `parse2.t.sol` | Yes (empty, parse error, integrity failure) |
| `parsePragma1` | 66 | `parsePragma1.t.sol` | Yes (no pragma, single, two, error propagation) |
| `buildIntegrityFunctionPointers` | 73 | `pointers.t.sol` | Yes (dynamic vs constant comparison) |
| `describedByMetaV1` | 78 | `describedByMetaV1.t.sol`, `meta.t.sol` | Yes |

Coverage assessment: All functions and error paths are tested.

---

## 2. RainterpreterParser

| Function | Line | Test File(s) | Covered |
|---|---|---|---|
| `checkParseMemoryOverflow` (modifier) | 46 | `parseMemoryOverflow.t.sol` | Yes (revert + pass) |
| `unsafeParse` | 57 | `unsafeParse.t.sol` | Yes (happy path, empty) |
| `supportsInterface` | 72 | `ierc165.t.sol` | Yes (fuzz + IParserToolingV1 + IERC165) |
| `parsePragma1` | 80 | `parserPragma.t.sol`, `parsePragmaEmpty.t.sol` | Yes |
| `parseMeta` (internal) | 94 | `pointers.t.sol` | Yes (constant verified) |
| `operandHandlerFunctionPointers` (internal) | 101 | `pointers.t.sol` | Yes |
| `literalParserFunctionPointers` (internal) | 108 | `pointers.t.sol` | Yes |
| `buildOperandHandlerFunctionPointers` | 113 | `pointers.t.sol` | Yes |
| `buildLiteralParserFunctionPointers` | 118 | `pointers.t.sol` | Yes |

Coverage assessment: All functions and error paths are tested.

---

## 3. RainterpreterDISPaiRegistry

| Function | Line | Test File(s) | Covered |
|---|---|---|---|
| `supportsInterface` | 17 | `ierc165.t.sol` | Yes (fuzz + IDISPaiRegistry + IERC165) |
| `expressionDeployerAddress` | 22 | `t.sol` | Yes (value + non-zero check) |
| `interpreterAddress` | 27 | `t.sol` | Yes |
| `storeAddress` | 31 | `t.sol` | Yes |
| `parserAddress` | 36 | `t.sol` | Yes |

Coverage assessment: All functions tested. These are trivial getters returning constants; the existing tests verify both correctness and non-zero values.

---

## 4. RainterpreterReferenceExtern

| Function | Line | Test File(s) | Covered |
|---|---|---|---|
| `describedByMetaV1` | 165 | `describedByMetaV1.t.sol` | Yes |
| `subParserParseMeta` (internal) | 172 | `pointers.t.sol` | Yes |
| `subParserWordParsers` (internal) | 179 | `pointers.t.sol` | Yes |
| `subParserOperandHandlers` (internal) | 186 | `pointers.t.sol` | Yes |
| `subParserLiteralParsers` (internal) | 193 | `pointers.t.sol` | Yes |
| `opcodeFunctionPointers` (internal) | 200 | `pointers.t.sol` | Yes |
| `integrityFunctionPointers` (internal) | 207 | `pointers.t.sol` | Yes |
| `buildLiteralParserFunctionPointers` | 213 | `pointers.t.sol` | Yes |
| `matchSubParseLiteralDispatch` | 236 | `repeat.t.sol` | Yes (happy, negative, fractional, >9, trailing) |
| `buildOperandHandlerFunctionPointers` | 282 | `pointers.t.sol` | Yes |
| `buildSubParserWordParsers` | 325 | `pointers.t.sol` | Yes |
| `buildOpcodeFunctionPointers` | 367 | `pointers.t.sol` | Yes |
| `buildIntegrityFunctionPointers` | 401 | `pointers.t.sol` | Yes |
| `supportsInterface` | 429 | `ierc165.t.sol` | Yes (8 interface IDs + fuzz) |
| Inherited `extern` | base | `intInc.t.sol` | Yes (direct call, sugared, unsugared, mod wrap) |
| Inherited `externIntegrity` | base | `intInc.t.sol` | Yes (direct call, fuzz) |
| Inherited `subParseWord2` | base | `intInc.t.sol` | Yes (known word, unknown word) |
| Inherited `subParseLiteral2` | base | `subParserIndexOutOfBounds.t.sol` | Yes |

### Error paths in `matchSubParseLiteralDispatch` (line 236):

| Error | Tested |
|---|---|
| `UnconsumedRepeatDispatchBytes` (line 261) | Yes (`repeat.t.sol` -- trailing bytes) |
| `InvalidRepeatCount` negative (line 269) | Yes (`repeat.t.sol` -- negative) |
| `InvalidRepeatCount` fractional (line 269) | Yes (`repeat.t.sol` -- non-integer) |
| `InvalidRepeatCount` > 9 (line 269) | Yes (`repeat.t.sol` -- too large) |
| Non-matching keyword returns `(false, 0, 0)` (line 274) | Yes (tested via `unknownWord.t.sol` integration path) |

### `BadDynamicLength` revert in `buildLiteralParserFunctionPointers` / `buildOperandHandlerFunctionPointers` / `buildSubParserWordParsers` / `buildOpcodeFunctionPointers` / `buildIntegrityFunctionPointers`:

These are defensive checks against compile-time constant mismatches (i.e., the length placeholder vs array literal). The pointer tests verify these functions succeed without reverting, which implicitly confirms the length check passes. Since these guards protect against a developer accidentally editing the array without updating the length constant -- and cannot be triggered by runtime inputs -- the lack of a dedicated revert test is acceptable.

---

## Findings

### A02-2: Missing boundary tests for repeat literal count 0 and 9

**Severity:** LOW

**Title:** `matchSubParseLiteralDispatch` missing boundary tests for valid repeat counts 0 and 9

**Description:** The `matchSubParseLiteralDispatch` function in `RainterpreterReferenceExtern.sol` (line 265-268) validates that `repeatCount` is in range [0, 9] and is an integer. The `repeat.t.sol` test file covers the happy path with digit 9 and digit 8, and covers the error cases (negative, fractional, > 9). However, the boundary value 0 is not tested. While digit 9 is tested (so the upper boundary is partially covered), there is no explicit test that `ref-extern-repeat-0` produces the expected output value of 0 regardless of body length. The value 0 is notable because it produces 0 for any body length (unlike digits 1-9), which is a distinct behavioral edge case worth exercising.

Additionally, `repeat.t.sol` tests the happy path with hardcoded values only (no fuzz testing across all valid digits 0-9). A fuzz test bounded to [0, 9] would provide better coverage of the valid range.
