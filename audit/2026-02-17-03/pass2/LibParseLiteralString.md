# Pass 2 (Test Coverage) -- LibParseLiteralString.sol

## Evidence of Thorough Reading

### Source File: `src/lib/parse/literal/LibParseLiteralString.sol`

**Library name:** `LibParseLiteralString`

**Functions:**

| Function | Line |
|---|---|
| `boundString(ParseState memory state, uint256 cursor, uint256 end) -> (uint256, uint256, uint256)` | 20 |
| `parseString(ParseState memory state, uint256 cursor, uint256 end) -> (uint256, bytes32)` | 77 |

**Errors used (imported from `src/error/ErrParse.sol`):**

| Error | Source Line | Usage Line |
|---|---|---|
| `StringTooLong(uint256 offset)` | ErrParse.sol:33 | 48 |
| `UnclosedStringLiteral(uint256 offset)` | ErrParse.sol:37 | 61 |

**Other imports used:**
- `CMASK_STRING_LITERAL_END` -- used at line 60 to check closing `"` character
- `CMASK_STRING_LITERAL_TAIL` -- used at line 30 as the valid-character mask in the scan loop
- `LibIntOrAString.fromStringV3` -- used at line 95 to convert the parsed string to an `IntOrAString`

### Test File 1: `test/src/lib/parse/literal/LibParseLiteralString.boundString.t.sol`

**Contract name:** `LibParseLiteralStringBoundTest`

**Functions:**

| Function | Line |
|---|---|
| `externalBoundString(bytes memory data) -> (uint256, uint256, uint256, uint256)` | 19 |
| `externalBoundLiteralForceLength(bytes memory data, uint256 length) -> (uint256, uint256, uint256, uint256)` | 29 |
| `checkStringBounds(string memory str, uint256, uint256, uint256)` | 46 |
| `testParseStringLiteralBounds(string memory str)` | 61 |
| `testParseStringLiteralBoundsTooLong(string memory str)` | 69 |
| `testParseStringLiteralBoundsInvalidCharBefore(string memory str, uint256 badIndex)` | 78 |
| `testParseStringLiteralBoundsParserOutOfBounds(string memory str, uint256 length)` | 90 |

### Test File 2: `test/src/lib/parse/literal/LibParseLiteralString.parseString.t.sol`

**Contract name:** `LibParseLiteralStringTest`

**Functions:**

| Function | Line |
|---|---|
| `parseStringExternal(ParseState memory state) -> (uint256, bytes32)` | 20 |
| `testParseStringLiteralEmpty()` | 25 |
| `testParseStringLiteralAny(bytes memory data)` | 36 |
| `testParseStringLiteralCorrupt(bytes memory data, uint256 corruptIndex)` | 50 |

### Integration Test File: `test/src/lib/parse/LibParse.literalString.t.sol`

**Contract name:** `LibParseLiteralStringTest`

**Functions:**

| Function | Line |
|---|---|
| `externalParse(string memory str) -> (bytes memory, bytes32[] memory)` | 19 |
| `testParseStringLiteralEmpty()` | 25 |
| `testParseStringLiteralSimple()` | 42 |
| `testParseStringLiteralShortASCII(string memory str)` | 60 |
| `testParseStringLiteralTwo(string memory strA, string memory strB)` | 81 |
| `testParseStringLiteralLongASCII(string memory str)` | 106 |
| `testParseStringLiteralInvalidCharAfter(string memory strA, string memory strB)` | 118 |
| `testParseStringLiteralInvalidCharWithin(string memory str, uint256 badIndex)` | 135 |

## Coverage Analysis

### `boundString` coverage

| Condition / Path | Covered? | Test(s) |
|---|---|---|
| Happy path: valid string < 32 bytes | Yes | `testParseStringLiteralBounds` (fuzz) |
| Revert `StringTooLong`: string >= 32 bytes | Yes | `testParseStringLiteralBoundsTooLong` (fuzz) |
| Revert `UnclosedStringLiteral`: invalid char in string body | Yes | `testParseStringLiteralBoundsInvalidCharBefore` (fuzz) |
| Revert `UnclosedStringLiteral`: closing `"` beyond `end` | Yes | `testParseStringLiteralBoundsParserOutOfBounds` (fuzz) |
| Empty string `""` | Yes | `testParseStringLiteralEmpty` (in parseString tests) |

### `parseString` coverage

| Condition / Path | Covered? | Test(s) |
|---|---|---|
| Happy path: empty string | Yes | `testParseStringLiteralEmpty` |
| Happy path: fuzz valid strings | Yes | `testParseStringLiteralAny` (fuzz) |
| Revert on corrupt char | Yes | `testParseStringLiteralCorrupt` (fuzz) |
| Memory snapshot/restore correctness | Partial | Only tested via returned value; no explicit assertion that memory before `str` is restored |
| Integration through full `parse()` pipeline | Yes | `LibParse.literalString.t.sol` tests |

## Findings

### A37-1: No explicit test for `parseString` memory snapshot restoration

**Severity:** LOW

**Description:** `parseString` (lines 87-98) temporarily overwrites memory at `sub(stringStart, 0x20)` with the string length, calls `LibIntOrAString.fromStringV3`, and then restores the original memory content from `memSnapshot`. No test explicitly verifies that the memory word before the string data is correctly restored after `parseString` returns. The existing tests only assert on the return value (`IntOrAString`) and the cursor position, but never inspect the surrounding memory. If the restore were omitted or buggy, subsequent parsing could silently corrupt state. A test that reads the memory word before the string data before and after calling `parseString` and asserts equality would close this gap.

### A37-2: No test for exactly 31-byte string (boundary value)

**Severity:** INFO

**Description:** The `boundString` function allows strings up to 31 bytes (i.e., `i < 0x20` passes for `i` up to 31, and reverts at `i == 0x20`). The fuzz tests in `testParseStringLiteralBounds` constrain input to `length < 0x20` (i.e., < 32), so a 31-byte string is technically in the fuzz space but is not guaranteed to be tested. The `testParseStringLiteralBoundsTooLong` test constrains `length >= 0x20` (i.e., >= 32). There is no explicit concrete test for the boundary case of exactly 31 bytes, which is the maximum valid string length. Fuzz testing may cover this, but a dedicated concrete test would provide deterministic regression coverage for this critical boundary.

### A37-3: No test for `UnclosedStringLiteral` when `end == innerEnd`

**Severity:** LOW

**Description:** At line 60, the condition `end == innerEnd` is checked as a separate reason to revert with `UnclosedStringLiteral`. This handles the case where the character at `innerEnd` passes the `CMASK_STRING_LITERAL_END` check but `innerEnd` equals `end`, meaning there is no room for the closing quote. The `testParseStringLiteralBoundsParserOutOfBounds` test truncates the length to cut off the closing `"`, but it does so for various lengths; it does not specifically target the case where `end` falls exactly at `innerEnd` (i.e., `end` points to the `"` itself, meaning the closing quote is at the boundary). While fuzz testing may occasionally hit this, there is no dedicated test for this specific branch of the disjunction at line 60.
