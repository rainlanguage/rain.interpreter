# Pass 2: Test Coverage -- LibParseError

## Source File
`src/lib/parse/LibParseError.sol`

## Evidence of Thorough Reading

**Library:** `LibParseError`

**Functions:**
- `parseErrorOffset(ParseState memory state, uint256 cursor) -> uint256 offset` (line 13)
- `handleErrorSelector(ParseState memory state, uint256 cursor, bytes4 errorSelector)` (line 26)

**Errors/Events/Structs:** None defined directly (uses errors from callers).

**Assembly blocks:**
- Line 15-17: `parseErrorOffset` -- computes `cursor - (data + 0x20)`
- Line 29-33: `handleErrorSelector` -- stores selector + offset and reverts

## Test Coverage Analysis

**Direct test files:** None. No `test/src/lib/parse/LibParseError*.t.sol` files exist.

**Indirect coverage search:**
- Grep for `parseErrorOffset` across `test/` -- no results.
- Grep for `handleErrorSelector` across `test/` -- no results.
- Grep for `LibParseError` across `test/` -- no results.

**Callers in source:**
- `LibParseInterstitial.sol` uses `parseErrorOffset` in `skipComment`
- `LibParseLiteral.sol` uses `parseErrorOffset` in `parseLiteral`
- `LibParseLiteralDecimal.sol` uses `handleErrorSelector` in `parseDecimalFloatPacked`
- `LibParseLiteralHex.sol` uses `parseErrorOffset` in `parseHex`
- `LibParseLiteralString.sol`, `LibSubParse.sol`, `LibParsePragma.sol`, `LibParseOperand.sol`, `LibParseState.sol` also use it

The functions are exercised transitively whenever any parser error path triggers, which does happen in the comment tests and some literal tests. However, there is no unit-level test isolating these functions.

## Findings

### A31-1 No direct unit tests for `parseErrorOffset`
**Severity:** LOW

`parseErrorOffset` contains assembly arithmetic (`sub(cursor, add(data, 0x20))`) that computes a byte offset from the start of parse data. There are no unit tests verifying this calculation in isolation. While it is exercised indirectly by parser integration tests that check error offsets (e.g., `LibParse.comments.t.sol` checks `UnclosedComment` offset values), a dedicated test would verify correctness for edge cases such as:
- `cursor` pointing to the first byte of data (offset = 0)
- `cursor` pointing to the last byte of data
- Very large data buffers

### A31-2 No direct unit tests for `handleErrorSelector`
**Severity:** LOW

`handleErrorSelector` is an assembly-heavy function that performs manual ABI encoding of an error selector + uint256 offset, then reverts. There are no tests verifying:
- That a non-zero selector correctly reverts with the expected encoded data
- That a zero selector (no error) does not revert
- That the revert data has the correct ABI encoding format (selector at offset 0, uint256 at offset 4, total length 0x24)

The zero-selector path (no-op) is exercised transitively whenever `parseDecimalFloatPacked` succeeds, but there is no isolated test confirming this behavior.

### A31-3 No test for `handleErrorSelector` with zero selector
**Severity:** INFO

The `handleErrorSelector` function has a branch where `errorSelector == 0` causes no revert (silent return). This path is exercised indirectly by successful decimal parsing, but is not tested in isolation to confirm the function is truly a no-op for zero selectors.
