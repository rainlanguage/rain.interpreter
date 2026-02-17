# Pass 2: Test Coverage -- LibParsePragma

## Evidence of Thorough Reading

### Source: `src/lib/parse/LibParsePragma.sol`

- **Library**: `LibParsePragma`
- **Constants**:
  - `PRAGMA_KEYWORD_BYTES` = `bytes("using-words-from")` -- line 12
  - `PRAGMA_KEYWORD_BYTES32` = `bytes32(PRAGMA_KEYWORD_BYTES)` -- line 15
  - `PRAGMA_KEYWORD_BYTES_LENGTH` = `16` -- line 16
  - `PRAGMA_KEYWORD_MASK` = `bytes32(~((1 << (32 - PRAGMA_KEYWORD_BYTES_LENGTH) * 8) - 1))` -- line 18
- **Functions**:
  - `parsePragma(ParseState memory, uint256 cursor, uint256 end) returns (uint256)` -- line 33
- **Errors used** (imported from `ErrParse.sol`):
  - `NoWhitespaceAfterUsingWordsFrom(uint256 offset)` -- lines 56, 66
- **Key code paths in `parsePragma`**:
  1. Not-a-pragma guard: keyword mask mismatch returns cursor unchanged (line 44-46)
  2. Cursor past keyword, `cursor >= end`: revert `NoWhitespaceAfterUsingWordsFrom` (line 55-57)
  3. No whitespace after keyword: revert `NoWhitespaceAfterUsingWordsFrom` (line 65-67)
  4. Whitespace found, loop parsing literal addresses via `tryParseLiteral` (line 78-86)
  5. `pushSubParser` called for each parsed literal (line 85)
  6. Loop exits when `tryParseLiteral` returns `success == false` or `cursor >= end` (line 71, 82)

### Test File: `test/src/lib/parse/LibParsePragma.keyword.t.sol`

- **Contract**: `LibParsePragmaKeywordTest`
- **Functions**:
  - `checkPragmaParsing(string, uint256, address[], string)` -- line 27 (helper)
  - `externalParsePragma(string)` -- line 61 (helper for revert tests)
  - `testPragmaKeywordNoop(ParseState, string)` -- line 72 (fuzz)
  - `testPragmaKeywordNoWhitespace(uint256, string)` -- line 88 (fuzz)
  - `testPragmaKeywordWhitespaceNoHex(uint256, string)` -- line 100 (fuzz)
  - `testPragmaKeywordParseSubParserBasic(string, address, uint256, string)` -- line 128 (fuzz)
  - `testPragmaKeywordParseSubParserCoupleOfAddresses(...)` -- line 165 (fuzz)
  - `testPragmaKeywordParseSubParserSpecificStrings()` -- line 222

### Additional Test File: `test/src/concrete/RainterpreterParser.parserPragma.t.sol`

- **Contract**: `RainterpreterParserParserPragma`
- **Functions**:
  - `checkPragma(bytes, address[])` -- line 11 (helper)
  - `testParsePragmaNoPragma()` -- line 20
  - `testParsePragmaSinglePragma()` -- line 28
  - `testParsePragmaNoWhitespaceAfterKeyword()` -- line 45
  - `testParsePragmaWithInterstitial()` -- line 51

## Findings

### A40-1: No unit test for `cursor >= end` revert path after keyword (line 55-57) in `LibParsePragma.keyword.t.sol` [LOW]

The source has a specific revert when the input ends exactly at the keyword boundary (`cursor >= end` at line 55). This path reverts with `NoWhitespaceAfterUsingWordsFrom`. The `LibParsePragma.keyword.t.sol` test file does not have a test for this specific path. However, the integration test in `RainterpreterParser.parserPragma.t.sol` at line 45-48 (`testParsePragmaNoWhitespaceAfterKeyword`) does test `"using-words-from"` (exact keyword, no trailing content), which exercises this revert path through the full parser. The direct unit-test coverage gap is therefore mitigated but not eliminated -- the unit test file itself does not cover this scenario.

### A40-2: No test for multiple pragmas in sequence [LOW]

The `parsePragma` function is designed to parse a single pragma occurrence. However, there is no test verifying how the system handles multiple `using-words-from` pragmas at different positions in a source string (e.g., `using-words-from 0x... using-words-from 0x...`). While the caller is responsible for iterating pragma parsing, the absence of such a test means there is no verification that parsing re-entrant pragma keywords works correctly at the integration level.

### A40-3: No test for pragma with comments between addresses [LOW]

The code at line 75 calls `state.parseInterstitial(cursor, end)` which handles comments. The test `testParsePragmaWithInterstitial` in `RainterpreterParser.parserPragma.t.sol` tests interstitial (comments/whitespace) **before** the pragma keyword, but does not test comments **between** addresses within the pragma (e.g., `using-words-from 0x... /* comment */ 0x...`). The `LibParsePragma.keyword.t.sol` tests only use whitespace between addresses, not comments. This leaves the interstitial parsing between addresses untested at both the unit and integration level.

### A40-4: No test for pragma at end of input with address at boundary [INFO]

There is no test for the case where the input ends exactly at the end of a hex address with no trailing bytes (i.e., `cursor == end` at the top of the while loop after successfully parsing an address). The `testPragmaKeywordParseSubParserSpecificStrings` tests addresses followed by various suffixes but the specific `testPragmaKeywordParseSubParserBasic` fuzz test always appends a `notHexData` byte and potential `suffix` after the address. The specific strings test does test `"using-words-from 0x1234567890123456789012345678901234567890"` (line 245), which ends at exactly the address boundary, so this path does get some coverage through the specific strings. This is informational only.
