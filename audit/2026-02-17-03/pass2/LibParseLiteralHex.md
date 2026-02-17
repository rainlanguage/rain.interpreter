# Pass 2: Test Coverage -- LibParseLiteralHex

## Source File
`src/lib/parse/literal/LibParseLiteralHex.sol`

## Evidence of Thorough Reading

**Library:** `LibParseLiteralHex`

**Functions:**
- `boundHex(ParseState memory, uint256 cursor, uint256 end) -> (uint256, uint256, uint256)` (line 26)
- `parseHex(ParseState memory state, uint256 cursor, uint256 end) -> (uint256, bytes32)` (line 53)

**Errors used:**
- `HexLiteralOverflow` (line 62) -- hex literal > 64 hex chars (32 bytes)
- `ZeroLengthHexLiteral` (line 64) -- `0x` with no digits
- `OddLengthHexLiteral` (line 66) -- odd number of hex digits
- `MalformedHexLiteral` (line 100) -- non-hex character encountered (defensive; should not be reachable due to `boundHex`)

**Assembly blocks:**
- Lines 35-40: `boundHex` loop -- scans forward while chars match `CMASK_HEX`
- Lines 74-75: `parseHex` reads byte at cursor
- Line 79: bit shift for hex character classification

**Key behaviors:**
- `boundHex` starts at `cursor + 2` (skipping `0x`), scans for hex chars
- `parseHex` processes hex digits right-to-left (LSB first), shifting nybbles into position
- Handles 0-9, a-f, A-F character ranges separately
- Returns `hexEnd` as the new cursor, not the loop cursor (which walked backwards)

## Test Coverage Analysis

**Direct test files:**
1. `test/src/lib/parse/literal/LibParseLiteralHex.boundHex.t.sol`
2. `test/src/lib/parse/literal/LibParseLiteralHex.parseHex.t.sol`

### boundHex tests (`LibParseLiteralBoundLiteralHexTest`):
- `testParseLiteralBoundLiteralHexBounds` (line 25) -- tests `"0x"`, `"0x00"`, `"0x0000"` bounds
- `testParseLiteralBoundLiteralHexFuzz` (line 32) -- fuzz test with random hex strings + delimiter

### parseHex tests (`LibParseLiteralHexBoundHexTest` -- note: contract name is misleading):
- `testParseLiteralHexRoundTrip` (line 18) -- fuzz round-trip: random bytes32 -> hex string -> parse -> compare

### Integration tests (`LibParse.literalIntegerHex.t.sol`):
- `testParseIntegerLiteralHex00` -- single hex literal `0xa2`
- `testParseIntegerLiteralHex01` -- two hex literals
- `testParseIntegerLiteralHex02` -- deduplication of hex literals
- `testParseIntegerLiteralHexUint256Max` -- max uint256 in hex

## Findings

### A35-1 No test for `HexLiteralOverflow` error
**Severity:** MEDIUM

The `HexLiteralOverflow` error (line 62) fires when the hex literal has more than 64 hex characters (>32 bytes). Grep for `HexLiteralOverflow` across `test/` returns zero matches. No test provides a hex literal longer than 64 characters to verify this revert path.

### A35-2 No test for `ZeroLengthHexLiteral` error
**Severity:** MEDIUM

The `ZeroLengthHexLiteral` error (line 64) fires when the input is `0x` with no hex digits following. Grep for `ZeroLengthHexLiteral` across `test/` returns zero matches. The `boundHex` test does test `"0x"` bounds (innerStart=2, innerEnd=2), which confirms the bounds are correct, but no test actually calls `parseHex` with `"0x"` to verify the revert.

### A35-3 No test for `OddLengthHexLiteral` error
**Severity:** MEDIUM

The `OddLengthHexLiteral` error (line 66) fires for hex literals with an odd number of digits (e.g., `0xabc`). Grep for `OddLengthHexLiteral` across `test/` returns zero matches. No test verifies this revert path.

### A35-4 No test for `MalformedHexLiteral` error
**Severity:** LOW

The `MalformedHexLiteral` error (line 100) is a defensive check inside the parse loop for non-hex characters. This path should be unreachable in normal operation because `boundHex` already limits the scan to hex characters. However, if `parseHex` were called without going through `boundHex`, or if `boundHex` had a bug, this error would fire. No test verifies it. The severity is LOW because it is a defense-in-depth check for an unreachable path.

### A35-5 No test for mixed-case hex parsing
**Severity:** LOW

The `parseHex` function handles three character ranges separately: `0-9`, `a-f`, `A-F`. The fuzz round-trip test (`testParseLiteralHexRoundTrip`) uses `Strings.toHexString` which produces lowercase hex only. There is no test with uppercase hex characters (e.g., `0xABCDEF`) or mixed case (e.g., `0xAbCd`). The integration test `0xa2` uses lowercase only. While the code handles all cases, the uppercase and mixed-case paths are untested.

### A35-6 Misleading test contract name
**Severity:** INFO

The contract in `LibParseLiteralHex.parseHex.t.sol` is named `LibParseLiteralHexBoundHexTest` (line 13) but it tests `parseHex`, not `boundHex`. The file name is correct but the contract name is copy-pasted from the boundHex test file. This is a documentation/naming issue, not a coverage issue.

### A35-7 No test for small hex values
**Severity:** INFO

The fuzz test generates random `bytes32` values, which are overwhelmingly 64-character hex strings. There is no explicit test for small hex values like `0x00`, `0x01`, `0xff`, `0x0001` that would exercise the value-building loop with few iterations. The integration test covers `0xa2` and `0x03` which are small values but only go through the full parser pipeline.
