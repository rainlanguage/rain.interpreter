# Pass 2 (Test Coverage) -- BaseRainterpreterSubParser.sol

## Evidence of Thorough Reading

### Source File: `src/abstract/BaseRainterpreterSubParser.sol`

**Contract name:** `BaseRainterpreterSubParser` (abstract, lines 83-225)

**Constants (file-level):**
- `SUB_PARSER_WORD_PARSERS` (line 25)
- `SUB_PARSER_PARSE_META` (line 31)
- `SUB_PARSER_OPERAND_HANDLERS` (line 35)
- `SUB_PARSER_LITERAL_PARSERS` (line 39)

**Errors (file-level):**
- `SubParserIndexOutOfBounds(uint256 index, uint256 length)` (line 45)

**Functions:**
- `subParserParseMeta()` -- internal pure virtual, line 98
- `subParserWordParsers()` -- internal pure virtual, line 105
- `subParserOperandHandlers()` -- internal pure virtual, line 112
- `subParserLiteralParsers()` -- internal pure virtual, line 119
- `matchSubParseLiteralDispatch(uint256 cursor, uint256 end)` -- internal view virtual, line 144
- `subParseLiteral2(bytes memory data)` -- external view virtual, line 164
- `subParseWord2(bytes memory data)` -- external pure virtual, line 193
- `supportsInterface(bytes4 interfaceId)` -- public view virtual override, line 220

### Test File: `test/src/abstract/BaseRainterpreterSubParser.ierc165.t.sol`

**Test functions:**
- `testRainterpreterSubParserIERC165(uint32 badInterfaceIdUint)` (line 38)

### Indirect Coverage via `RainterpreterReferenceExtern` Tests

- `RainterpreterReferenceExtern.intInc.t.sol` -- exercises `subParseWord2` happy path and `exists == false` return
- `RainterpreterReferenceExtern.repeat.t.sol` -- exercises `subParseLiteral2` and `matchSubParseLiteralDispatch`
- `RainterpreterReferenceExtern.ierc165.t.sol` -- exercises `supportsInterface`

## Findings

### A02-1: No test for `SubParserIndexOutOfBounds` revert in `subParseWord2`

**Severity:** MEDIUM

The `subParseWord2` function (line 207-208) reverts with `SubParserIndexOutOfBounds` when the looked-up word index exceeds the number of available word parser function pointers. No test anywhere in the test suite triggers this revert path. A grep for `SubParserIndexOutOfBounds` across all `*.t.sol` files returns zero results.

### A02-2: No test for `SubParserIndexOutOfBounds` revert in `subParseLiteral2`

**Severity:** MEDIUM

The `subParseLiteral2` function (line 173-174) contains the same `SubParserIndexOutOfBounds` guard for the literal parser function pointer table. This revert path is also never triggered by any test.

### A02-3: No direct unit tests for `subParseLiteral2` on `BaseRainterpreterSubParser`

**Severity:** LOW

The `subParseLiteral2` function is only exercised indirectly through the `RainterpreterReferenceExtern` end-to-end tests. There are no tests that directly call `subParseLiteral2` on a `BaseRainterpreterSubParser` instance to verify its dispatch logic in isolation.

### A02-4: No test for `subParseWord2` with empty/zero-length word parsers table

**Severity:** LOW

The base contract's default `subParserWordParsers()` returns empty bytes. If `subParseWord2` is called on a contract that does not override `subParserWordParsers()` but does have parse meta that matches a word, `parsersLength` would be 0 and any index would trigger `SubParserIndexOutOfBounds`. This edge case is never tested.

### A02-5: No direct test for the four virtual getter functions

**Severity:** INFO

The four virtual getter functions (`subParserParseMeta`, `subParserWordParsers`, `subParserOperandHandlers`, `subParserLiteralParsers`) are `internal` and return placeholder empty bytes by default. No test verifies that the default implementations return the expected placeholder values.
