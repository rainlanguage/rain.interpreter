# Pass 2: Test Coverage -- BaseRainterpreterSubParser

**Audit:** 2026-03-04-01
**Source:** `src/abstract/BaseRainterpreterSubParser.sol`
**Agent ID:** A02

## Evidence

### Functions and line numbers

| Function | Line | Tested |
|---|---|---|
| `subParserParseMeta()` | 93 | Virtual, indirectly via ReferenceExtern |
| `subParserWordParsers()` | 100 | Virtual, indirectly via ReferenceExtern |
| `subParserOperandHandlers()` | 107 | Virtual, indirectly via ReferenceExtern |
| `subParserLiteralParsers()` | 114 | Virtual, indirectly via ReferenceExtern |
| `matchSubParseLiteralDispatch()` | 139 | Default returns false; tested in subParseLiteral2 no-match test |
| `subParseLiteral2()` | 159 | Happy, no-match, index-out-of-bounds |
| `subParseWord2()` | 188 | Index-out-of-bounds (2 variants) only |
| `supportsInterface()` | 215 | Fuzz tested |

### Test files

- `test/src/abstract/BaseRainterpreterSubParser.ierc165.t.sol`
- `test/src/abstract/BaseRainterpreterSubParser.subParseLiteral2.t.sol`
- `test/src/abstract/BaseRainterpreterSubParser.subParseWord2.t.sol`

### Errors

| Error | Tested |
|---|---|
| `SubParserIndexOutOfBounds` (literal) | Yes (subParseLiteral2 index-out-of-bounds test) |
| `SubParserIndexOutOfBounds` (word) | Yes (subParseWord2, 2 variants) |

## Findings

### P2-A02-01 (LOW) `subParseWord2` missing happy-path and no-match base-level tests

The `subParseWord2` function has two code paths that are not tested at the base abstract level:

1. **Happy path** (line 197-208): A word is found in the parse meta, the word parser function pointer is called, and a valid `(true, bytecode, constants)` tuple is returned. This is only tested indirectly through `RainterpreterReferenceExtern.intInc.t.sol`.

2. **No-match path** (line 209-211): A word is NOT found in the parse meta, and the function returns `(false, "", new bytes32[](0))`. This is only tested indirectly through `RainterpreterReferenceExtern.intInc.t.sol:testRainterpreterReferenceExternIntIncSubParseUnknownWord`.

The `subParseLiteral2` function has both of these paths directly tested at the base level. `subParseWord2` should too.

Carryover from audit `2026-03-01-01` finding `P2-EAD-01`.
