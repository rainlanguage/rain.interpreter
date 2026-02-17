# Pass 3: Documentation — LibParseLiteral group

Agent: A27

## Files Reviewed

- `src/lib/parse/literal/LibParseLiteral.sol`
- `src/lib/parse/literal/LibParseLiteralDecimal.sol`
- `src/lib/parse/literal/LibParseLiteralHex.sol`
- `src/lib/parse/literal/LibParseLiteralString.sol`
- `src/lib/parse/literal/LibParseLiteralSubParseable.sol`

---

## Evidence of Thorough Reading

### LibParseLiteral.sol

- **Library name:** `LibParseLiteral` (line 25)
- **Constants:**
  - `LITERAL_PARSERS_LENGTH` (line 18) — value 4
  - `LITERAL_PARSER_INDEX_HEX` (line 20) — value 0
  - `LITERAL_PARSER_INDEX_DECIMAL` (line 21) — value 1
  - `LITERAL_PARSER_INDEX_STRING` (line 22) — value 2
  - `LITERAL_PARSER_INDEX_SUB_PARSE` (line 23) — value 3
- **Functions:**
  - `selectLiteralParserByIndex(ParseState memory state, uint256 index)` — line 34
  - `parseLiteral(ParseState memory state, uint256 cursor, uint256 end)` — line 51
  - `tryParseLiteral(ParseState memory state, uint256 cursor, uint256 end)` — line 67
- **Errors/Events/Structs:** None defined locally (imports `UnsupportedLiteralType`)

### LibParseLiteralDecimal.sol

- **Library name:** `LibParseLiteralDecimal` (line 10)
- **Functions:**
  - `parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end)` — line 15
- **Errors/Events/Structs:** None defined locally

### LibParseLiteralHex.sol

- **Library name:** `LibParseLiteralHex` (line 20)
- **Functions:**
  - `boundHex(ParseState memory, uint256 cursor, uint256 end)` — line 26
  - `parseHex(ParseState memory state, uint256 cursor, uint256 end)` — line 53
- **Errors/Events/Structs:** None defined locally (imports `MalformedHexLiteral`, `OddLengthHexLiteral`, `ZeroLengthHexLiteral`, `HexLiteralOverflow`)

### LibParseLiteralString.sol

- **Library name:** `LibParseLiteralString` (line 13)
- **Functions:**
  - `boundString(ParseState memory state, uint256 cursor, uint256 end)` — line 20
  - `parseString(ParseState memory state, uint256 cursor, uint256 end)` — line 77
- **Errors/Events/Structs:** None defined locally (imports `UnclosedStringLiteral`, `StringTooLong`)
- **Contract-level NatSpec:** `@title LibParseLiteralString` and description at lines 11-12

### LibParseLiteralSubParseable.sol

- **Library name:** `LibParseLiteralSubParseable` (line 14)
- **Functions:**
  - `parseSubParseable(ParseState memory state, uint256 cursor, uint256 end)` — line 30
- **Errors/Events/Structs:** None defined locally (imports `UnclosedSubParseableLiteral`, `SubParseableMissingDispatch`)

---

## Findings

### A27-1 [LOW] `selectLiteralParserByIndex` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteral.sol`, line 31-33

The NatSpec for `selectLiteralParserByIndex` provides a description but has no `@param state`, `@param index`, or `@return` tags.

```solidity
/// Selects a literal parser function pointer from the state's literal
/// parsers array by index. Not bounds checked as indexes are expected to
/// be provided by the parser itself.
function selectLiteralParserByIndex(ParseState memory state, uint256 index)
```

Missing:
- `@param state` — the parse state containing the literal parsers array
- `@param index` — the index into the literal parsers array
- `@return` — the selected literal parser function pointer

### A27-2 [LOW] `parseLiteral` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteral.sol`, line 49-50

The NatSpec describes the function behavior but omits parameter and return documentation.

```solidity
/// Parses a literal value at the cursor position. Reverts with
/// `UnsupportedLiteralType` if the literal type cannot be determined.
function parseLiteral(ParseState memory state, uint256 cursor, uint256 end)
```

Missing:
- `@param state` — the current parse state
- `@param cursor` — the current cursor position in the source
- `@param end` — the end boundary of the source
- `@return` — the new cursor position and the parsed literal value

### A27-3 [LOW] `tryParseLiteral` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteral.sol`, line 64-66

The NatSpec describes dispatch behavior but omits parameter and return documentation.

```solidity
/// Attempts to parse a literal value at the cursor position. Dispatches
/// to hex, decimal, string, or sub-parseable parsers based on the head
/// character. Returns false if the literal type is not recognized.
function tryParseLiteral(ParseState memory state, uint256 cursor, uint256 end)
```

Missing:
- `@param state` — the current parse state
- `@param cursor` — the current cursor position in the source
- `@param end` — the end boundary of the source
- `@return` (first) — true if a literal was successfully parsed, false otherwise
- `@return` (second) — the new cursor position (unchanged if unsuccessful)
- `@return` (third) — the parsed literal value (zero if unsuccessful)

### A27-4 [LOW] `parseDecimalFloatPacked` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteralDecimal.sol`, line 13-14

The NatSpec provides a description but no parameter or return documentation.

```solidity
/// Parses a decimal float literal from the source and returns it as a
/// losslessly packed float in bytes32 form.
function parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end)
```

Missing:
- `@param state` — the current parse state
- `@param start` — the start position of the decimal literal in the source
- `@param end` — the end boundary of the source
- `@return` (first) — the new cursor position after the parsed literal
- `@return` (second) — the losslessly packed float value as bytes32

### A27-5 [LOW] `boundHex` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteralHex.sol`, line 24-25

The NatSpec describes the scan behavior but omits parameter and return documentation.

```solidity
/// Finds the bounds of a hex literal by scanning forward from past the
/// "0x" prefix until a non-hex character is encountered.
function boundHex(ParseState memory, uint256 cursor, uint256 end)
```

Missing:
- `@param` (first) — the parse state (unnamed in signature)
- `@param cursor` — the current cursor position (at the start of the hex literal including `0x`)
- `@param end` — the end boundary of the source
- `@return` (first) — the inner start position (past the `0x` prefix)
- `@return` (second) — the inner end position (first non-hex character)
- `@return` (third) — the outer end / new cursor position

### A27-6 [LOW] `parseHex` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteralHex.sol`, line 46-52

The NatSpec describes the algorithm but omits parameter and return documentation.

```solidity
/// Algorithm for parsing hexadecimal literals:
/// - start at the end of the literal
/// - for each character:
///   - convert the character to a nybble
///   - shift the nybble into the total at the correct position
///     (4 bits per nybble)
/// - return the total
function parseHex(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256, bytes32) {
```

Missing:
- `@param state` — the current parse state
- `@param cursor` — the current cursor position in the source (at the `0` of `0x`)
- `@param end` — the end boundary of the source
- `@return` (first) — the new cursor position after the parsed hex literal
- `@return` (second) — the parsed hex value as bytes32

### A27-7 [LOW] `boundString` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteralString.sol`, line 17-19

The NatSpec describes the purpose but omits parameter and return documentation.

```solidity
/// Find the bounds for some string literal at the cursor. The caller is
/// responsible for checking that the cursor is at the start of a string
/// literal. Bounds are as per `boundLiteral`.
function boundString(ParseState memory state, uint256 cursor, uint256 end)
```

Missing:
- `@param state` — the current parse state
- `@param cursor` — the current cursor position (at the opening `"`)
- `@param end` — the end boundary of the source
- `@return` (first) — inner start position (past the opening `"`)
- `@return` (second) — inner end position (at the closing `"`)
- `@return` (third) — outer end position (past the closing `"`)

### A27-8 [INFO] `boundString` references nonexistent `boundLiteral`

**File:** `src/lib/parse/literal/LibParseLiteralString.sol`, line 19

The NatSpec says "Bounds are as per `boundLiteral`" but no function named `boundLiteral` exists in this library or in the codebase (based on the pattern of the other bound functions like `boundHex`). This reference is misleading.

### A27-9 [LOW] `parseString` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteralString.sol`, line 71-76

The NatSpec describes the algorithm but omits parameter and return documentation.

```solidity
/// Algorithm for parsing string literals:
/// - Get the inner length of the string
/// - Mutate memory in place to add a length prefix, record the original data
/// - Use this solidity string to build an `IntOrAString`
/// - Restore the original data that the length prefix overwrote
/// - Return the `IntOrAString`
function parseString(ParseState memory state, uint256 cursor, uint256 end)
```

Missing:
- `@param state` — the current parse state
- `@param cursor` — the current cursor position (at the opening `"`)
- `@param end` — the end boundary of the source
- `@return` (first) — the new cursor position after the string literal
- `@return` (second) — the string encoded as an `IntOrAString` in bytes32 form

### A27-10 [LOW] `parseSubParseable` missing `@param` and `@return` tags

**File:** `src/lib/parse/literal/LibParseLiteralSubParseable.sol`, line 20-29

The NatSpec has a thorough description of the sub-parseable literal format but omits parameter and return documentation.

```solidity
/// Parse a sub parseable literal. All sub parseable literals are bounded by
/// square brackets, and contain a dispatch and a body. ...
function parseSubParseable(ParseState memory state, uint256 cursor, uint256 end)
```

Missing:
- `@param state` — the current parse state
- `@param cursor` — the current cursor position (at the opening `[`)
- `@param end` — the end boundary of the source
- `@return` (first) — the new cursor position after the closing `]`
- `@return` (second) — the sub-parsed value as bytes32

### A27-11 [INFO] Constants in `LibParseLiteral.sol` have no NatSpec

**File:** `src/lib/parse/literal/LibParseLiteral.sol`, lines 18-23

The five constants (`LITERAL_PARSERS_LENGTH`, `LITERAL_PARSER_INDEX_HEX`, `LITERAL_PARSER_INDEX_DECIMAL`, `LITERAL_PARSER_INDEX_STRING`, `LITERAL_PARSER_INDEX_SUB_PARSE`) have no documentation. Their names are self-descriptive, but NatSpec would clarify the relationship to the parallel arrays in `LibAllStandardOps`.

### A27-12 [INFO] `LibParseLiteral`, `LibParseLiteralDecimal`, `LibParseLiteralHex`, `LibParseLiteralSubParseable` missing library-level NatSpec

**Files:**
- `src/lib/parse/literal/LibParseLiteral.sol`, line 25
- `src/lib/parse/literal/LibParseLiteralDecimal.sol`, line 10
- `src/lib/parse/literal/LibParseLiteralHex.sol`, line 20
- `src/lib/parse/literal/LibParseLiteralSubParseable.sol`, line 14

Only `LibParseLiteralString` (line 11-12) has a `@title` and description at the library level. The other four libraries have no library-level NatSpec documentation.

### A27-13 [INFO] `boundHex` first parameter is unnamed

**File:** `src/lib/parse/literal/LibParseLiteralHex.sol`, line 26

The first parameter `ParseState memory` has no name, which is unusual. While Solidity allows unnamed parameters, it makes documentation impossible for this parameter. Other bound/parse functions in the group name their `ParseState` parameter `state`.

```solidity
function boundHex(ParseState memory, uint256 cursor, uint256 end)
```

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH     | 0 |
| MEDIUM   | 0 |
| LOW      | 10 |
| INFO     | 3 |

All 10 LOW findings follow the same pattern: functions have descriptive NatSpec text but are missing `@param` and `@return` tags. This is a systematic gap across all five files. Every function in all five libraries is affected. The three INFO findings cover missing library-level NatSpec, a stale cross-reference to a nonexistent function, and an unnamed parameter.
