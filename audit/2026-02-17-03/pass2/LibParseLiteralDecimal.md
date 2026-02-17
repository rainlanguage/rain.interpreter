# Pass 2: Test Coverage -- LibParseLiteralDecimal

## Source File
`src/lib/parse/literal/LibParseLiteralDecimal.sol`

## Evidence of Thorough Reading

**Library:** `LibParseLiteralDecimal`

**Functions:**
- `parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end) -> (uint256, bytes32)` (line 15)

**Dependencies:**
- `LibParseDecimalFloat.parseDecimalFloatInline` (from `rain.math.float`) -- does the actual decimal parsing
- `LibParseError.handleErrorSelector` -- converts error selector to revert
- `LibDecimalFloat.packLossless` -- packs coefficient + exponent into a Float

**Key behavior:**
- Delegates all parsing to external library `parseDecimalFloatInline`
- Uses `handleErrorSelector` to propagate any error from the external parser
- Packs result via `packLossless` which can also revert on precision loss

## Test Coverage Analysis

**Direct test file:** `test/src/lib/parse/literal/LibParseLiteralDecimal.parseDecimalFloat.t.sol`

**Test contract:** `LibParseLiteralDecimalParseDecimalFloatTest`

**Tests found:**
- `testParseLiteralDecimalFloatEmpty` (line 41) -- empty string reverts with `ParseEmptyDecimalString`
- `testParseLiteralDecimalFloatNonDecimal` (line 46) -- non-decimal string reverts
- `testParseLiteralDecimalFloatExponentRevert` (line 51) -- lone `e` reverts
- `testParseLiteralDecimalFloatExponentRevert2` (line 56) -- `1e` reverts with `MalformedExponentDigits`
- `testParseLiteralDecimalFloatExponentRevert3` (line 60) -- `1e-` reverts
- `testParseLiteralDecimalFloatExponentRevert4` (line 65) -- `e1` reverts
- `testParseLiteralDecimalFloatExponentRevert5` (line 72) -- `e10` reverts
- `testParseLiteralDecimalFloatExponentRevert6` (line 78) -- `e-10` reverts
- `testParseLiteralDecimalFloatDotRevert` (line 83) -- `.` reverts
- `testParseLiteralDecimalFloatDotRevert2` (line 88) -- `.1` reverts
- `testParseLiteralDecimalFloatDotRevert3` (line 93) -- `1.` reverts with `MalformedDecimalPoint`
- `testParseLiteralDecimalFloatDotE` (line 98) -- `.e` reverts
- `testParseLiteralDecimalFloatDotE0` (line 103) -- `.e0` reverts
- `testParseLiteralDecimalFloatEDot` (line 108) -- `e.` reverts
- `testParseLiteralDecimalFloatNegativeE` (line 113) -- `0.0e-` reverts
- `testParseLiteralDecimalFloatNegativeFrac` (line 118) -- `0.-1` reverts
- `testParseLiteralDecimalFloatPrecisionRevert0` (line 123) -- max int with decimal reverts
- `testParseLiteralDecimalFloatPrecisionRevert1` (line 132) -- max decimal precision reverts

**Integration tests in `LibParse.literalIntegerDecimal.t.sol`:**
- Tests parsing `1`, `10`, `25`, `11`, `233` through full parser
- Tests max int128 value
- Tests leading zeros
- Tests uint256 overflow cases
- Tests e-notation (1e2, 10e2, 1e30, 1e18, 1001e15)
- Tests yang enforcement, paren rejection

## Findings

### A34-1 No happy-path unit test for `parseDecimalFloatPacked`
**Severity:** MEDIUM

The direct test file `LibParseLiteralDecimal.parseDecimalFloat.t.sol` contains 18 test functions, but **all of them test error/revert paths**. There is no single test in this file that verifies a successful parse returning the correct `(cursor, value)` pair. Happy-path behavior is only tested indirectly through `LibParse.literalIntegerDecimal.t.sol`, which goes through the full parser pipeline and checks bytecode output rather than directly asserting the return values of `parseDecimalFloatPacked`.

A direct unit test should verify that e.g., `parseDecimalFloatPacked` on `"123"` returns the correct cursor position and the expected packed float value.

### A34-2 No fuzz test for decimal parsing round-trip
**Severity:** LOW

Unlike `LibParseLiteralHex.parseHex.t.sol` which has a fuzz round-trip test (`testParseLiteralHexRoundTrip`), the decimal parser has no fuzz test that generates random valid decimal strings and verifies they parse to the correct value. This is partially mitigated by the fact that the core parsing logic is in the external `rain.math.float` library which presumably has its own tests.

### A34-3 No test for cursor position after successful parse
**Severity:** LOW

None of the tests verify the cursor position returned by `parseDecimalFloatPacked` after a successful parse. The cursor position determines where parsing continues; an off-by-one error here would cause the parser to skip or re-read a character. The integration tests implicitly validate this (parsing would fail if the cursor was wrong), but there is no explicit assertion.

### A34-4 No test for decimal values with fractional parts
**Severity:** LOW

The direct unit test file has no happy-path tests at all (see A34-1), but notably the integration tests also do not exercise fractional decimal values (e.g., `1.5`, `3.14`, `0.001`) through the full parser. The e-notation tests use integer coefficients with positive exponents. The error tests cover malformed decimals (e.g., `1.`, `.1`) but not valid fractional values.
