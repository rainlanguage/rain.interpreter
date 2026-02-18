# Pass 2: Test Coverage -- LibParseLiteral

## Source File
`src/lib/parse/literal/LibParseLiteral.sol`

## Evidence of Thorough Reading

**Library:** `LibParseLiteral`

**Constants:**
- `LITERAL_PARSERS_LENGTH = 4` (line 18)
- `LITERAL_PARSER_INDEX_HEX = 0` (line 20)
- `LITERAL_PARSER_INDEX_DECIMAL = 1` (line 21)
- `LITERAL_PARSER_INDEX_STRING = 2` (line 22)
- `LITERAL_PARSER_INDEX_SUB_PARSE = 3` (line 23)

**Functions:**
- `selectLiteralParserByIndex(ParseState memory state, uint256 index) -> function pointer` (line 34)
- `parseLiteral(ParseState memory state, uint256 cursor, uint256 end) -> (uint256, bytes32)` (line 51)
- `tryParseLiteral(ParseState memory state, uint256 cursor, uint256 end) -> (bool, uint256, bytes32)` (line 67)

**Assembly blocks:**
- Line 43-45: `selectLiteralParserByIndex` -- reads 2-byte function pointer from `literalParsers` array by index. Not bounds checked (comment at lines 41-42).

**Key behaviors:**
- `parseLiteral` wraps `tryParseLiteral`, reverting with `UnsupportedLiteralType` on failure
- `tryParseLiteral` reads head byte, dispatches:
  - Numeric head (`0-9`) -> check second byte for `0x` hex dispatch vs decimal
  - String head (`"`) -> string parser
  - Sub-parseable head (`[`) -> sub-parse parser
  - Otherwise -> returns `(false, cursor, 0)`
- Hex disambiguation at line 92: `(head | disambiguate) == CMASK_LITERAL_HEX_DISPATCH`

## Test Coverage Analysis

**Direct test files:** None named `LibParseLiteral.*.t.sol`. The abstract `ParseLiteralTest.sol` provides shared helpers.

**Indirect coverage:**
- `test/abstract/ParseLiteralTest.sol` -- defines `checkUnsupportedLiteralType` and `checkLiteralBounds` helpers
- `test/src/lib/parse/LibParse.literalIntegerHex.t.sol` -- tests hex literal parsing through full parser
- `test/src/lib/parse/LibParse.literalIntegerDecimal.t.sol` -- tests decimal literal parsing through full parser
- `test/src/lib/parse/LibParse.operandDisallowed.t.sol` -- triggers `UnsupportedLiteralType` at line 16

**Coverage of `UnsupportedLiteralType`:**
- `LibParse.operandDisallowed.t.sol` triggers it with `"_:a<;"` (the `<` char is not a recognized literal head)
- `ParseLiteralTest.sol` defines a helper for it but grep shows it is not called from any concrete test file beyond the abstract definition itself

## Findings

### A33-1 No direct unit test for `selectLiteralParserByIndex`
**Severity:** MEDIUM

`selectLiteralParserByIndex` performs unchecked array indexing with assembly. The comment states indexes are "provided by the parser itself and not user input," but the function is `internal` and could be called with any index. There is no test verifying:
- That valid indexes (0-3) return the correct function pointer
- That the 2-byte masking (`0xFFFF`) at line 44 correctly extracts the pointer
- Behavior with out-of-bounds indexes (reading garbage memory)

The lack of bounds checking is a design decision documented in comments, but the absence of tests verifying even the happy path is a gap.

### A33-2 No direct unit test for `tryParseLiteral` dispatch logic
**Severity:** LOW

The dispatch logic in `tryParseLiteral` (lines 72-113) determines which literal parser to invoke based on the head character. This is only tested indirectly through integration tests. There is no unit test verifying:
- All four dispatch paths (hex, decimal, string, sub-parseable) with minimal input
- The hex disambiguation logic at line 92 (`(head | disambiguate) == CMASK_LITERAL_HEX_DISPATCH`)
- The false return path (line 108) for unrecognized literal types
- Edge case: `0` followed by a non-`x` character routes to decimal, not hex

### A33-3 No test for `parseLiteral` revert path
**Severity:** LOW

`parseLiteral` (line 51) wraps `tryParseLiteral` and reverts with `UnsupportedLiteralType` when `tryParseLiteral` returns false. The `UnsupportedLiteralType` error is triggered in `LibParse.operandDisallowed.t.sol` but through the full parser pipeline, not through a direct call to `parseLiteral`. There is no test that directly calls `parseLiteral` with an unrecognized head character and checks the revert.

### A33-4 `checkUnsupportedLiteralType` helper defined but not called in concrete tests
**Severity:** INFO

The `ParseLiteralTest.sol` abstract contract defines `checkUnsupportedLiteralType` (line 15) which would directly test `parseLiteral`'s revert behavior, but grep shows this helper is only defined in the abstract -- it is never called from any concrete test contract. This suggests test coverage was planned but not implemented.
