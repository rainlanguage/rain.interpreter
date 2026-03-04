# Pass 5 -- Correctness/Intent Verification: Parse & State Libraries

Audit of files A102-A117 for correctness mismatches between NatSpec/naming intent and actual implementation behavior.

## Files Audited

- A102: `src/lib/parse/LibParse.sol`
- A103: `src/lib/parse/LibParseError.sol`
- A104: `src/lib/parse/LibParseInterstitial.sol`
- A105: `src/lib/parse/LibParseOperand.sol`
- A106: `src/lib/parse/LibParsePragma.sol`
- A107: `src/lib/parse/LibParseStackName.sol`
- A108: `src/lib/parse/LibParseStackTracker.sol`
- A109: `src/lib/parse/LibParseState.sol`
- A110: `src/lib/parse/LibSubParse.sol`
- A111: `src/lib/parse/literal/LibParseLiteral.sol`
- A112: `src/lib/parse/literal/LibParseLiteralDecimal.sol`
- A113: `src/lib/parse/literal/LibParseLiteralHex.sol`
- A114: `src/lib/parse/literal/LibParseLiteralString.sol`
- A115: `src/lib/parse/literal/LibParseLiteralSubParseable.sol`
- A116: `src/lib/state/LibInterpreterState.sol`
- A117: `src/lib/state/LibInterpreterStateDataContract.sol`

## Findings

### A108-P5-1 (LOW): ParseStackTracker type NatSpec incorrectly describes bit layout

**File:** `src/lib/parse/LibParseStackTracker.sol`, lines 7-9

**Description:** The `@dev` NatSpec for the `ParseStackTracker` type says:

> The low 128 bits hold the current stack height; the high 128 bits hold the maximum height seen so far

The actual bit layout implemented in `push`, `pop`, and `pushInputs` is:
- bits [7:0]: current stack height (8 bits)
- bits [15:8]: inputs count (8 bits)
- bits [255:16]: maximum height / high watermark (240 bits)

The NatSpec is wrong on three counts: (1) the current height is 8 bits not 128, (2) the split point is at bit 16 not bit 128, and (3) the `inputs` field occupying bits [15:8] is not mentioned at all. A reader relying on the NatSpec to write assembly against this type would produce corrupted data.

**Classification:** LOW -- NatSpec-only issue; the implementation is correct and self-consistent.

---

### A102-P5-1 (LOW): SUB_PARSER_BYTECODE_HEADER_SIZE NatSpec describes wrong header content

**File:** `src/lib/parse/LibParse.sol`, lines 56-59

**Description:** The `@dev` NatSpec for `SUB_PARSER_BYTECODE_HEADER_SIZE` says:

> Comprises the operand values tail pointer (2 bytes), the literal parsers tail pointer (2 bytes), and the word length (1 byte).

The actual 5-byte header content, as written by `parseRHS` (word length at offset 3-4) and populated by `subParseWordSlice` (bytes 0-2), is:
- bytes 0-1: constants builder height (2 bytes) -- written in `subParseWordSlice` line 254
- byte 2: IO byte (1 byte) -- written in `subParseWordSlice` line 252
- bytes 3-4: word string length (2 bytes) -- written in `parseRHS` line 295

The NatSpec references "operand values tail pointer" and "literal parsers tail pointer" which do not appear in the header at all, and describes the word length as 1 byte when it is actually 2 bytes. The `consumeSubParseWordInputData` function reads the header correctly per the actual layout, so this is a documentation-only issue.

**Classification:** LOW -- NatSpec-only issue; the code is self-consistent across writer and reader.
