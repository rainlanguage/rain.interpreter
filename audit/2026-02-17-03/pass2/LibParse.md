# Pass 2 (Test Coverage) -- LibParse.sol

## Evidence of Thorough Reading

### Source File: `src/lib/parse/LibParse.sol`

**Library name:** `LibParse`

**Constants:**
- `NOT_LOW_16_BIT_MASK` (line 56)
- `ACTIVE_SOURCE_MASK` (line 57)
- `SUB_PARSER_BYTECODE_HEADER_SIZE` (line 58)

**Functions:**
- `parseWord(uint256 cursor, uint256 end, uint256 mask)` -- line 99
- `parseLHS(ParseState memory state, uint256 cursor, uint256 end)` -- line 135
- `parseRHS(ParseState memory state, uint256 cursor, uint256 end)` -- line 203
- `parse(ParseState memory state)` -- line 421

**Errors used (imported from ErrParse.sol):**
- `UnexpectedRHSChar` (line 28)
- `UnexpectedRightParen` (line 29)
- `WordSize` (line 30)
- `DuplicateLHSItem` (line 31)
- `ParserOutOfBounds` (line 32)
- `ExpectedLeftParen` (line 33)
- `UnexpectedLHSChar` (line 34)
- `MissingFinalSemi` (line 35)
- `UnexpectedComment` (line 36)
- `ParenOverflow` (line 37)

### Test Files Read (27 LibParse.*.t.sol files):

- `LibParse.parseWord.t.sol` -- tests `parseWord` with reference impl, examples, too-long words, end boundary
- `LibParse.comments.t.sol` -- tests comment handling in interstitial, LHS, RHS positions; unclosed comments
- `LibParse.empty.t.sol` -- tests empty expressions from 0 to 16 sources (MaxSources error)
- `LibParse.empty.gas.t.sol` -- gas benchmarks for empty expressions
- `LibParse.missingFinalSemi.t.sol` -- tests `MissingFinalSemi` error for various incomplete inputs
- `LibParse.unexpectedLHS.t.sol` -- tests `UnexpectedLHSChar` for EOL, EOF, underscore tail, single char, named tail
- `LibParse.unexpectedRHS.t.sol` -- tests `UnexpectedRHSChar` for unexpected first char on RHS, left paren on RHS
- `LibParse.unexpectedRightParen.t.sol` -- tests `UnexpectedRightParen` at depth 0 and nested
- `LibParse.unclosedLeftParen.t.sol` -- tests `UnclosedLeftParen` single and nested
- `LibParse.ignoredLHS.t.sol` -- tests anonymous LHS items (underscores)
- `LibParse.namedLHS.t.sol` -- tests named LHS items, duplicate names, word size limits, stack indexing
- `LibParse.wordsRHS.t.sol` -- tests RHS word parsing: single, sequential, nested, multi-line, multi-source
- `LibParse.inputsOnly.t.sol` -- tests inputs-only expressions
- `LibParse.sourceInputs.t.sol` -- tests source input handling across lines
- `LibParse.nOutput.t.sol` -- tests multi-output and zero-output RHS items
- `LibParse.literalIntegerDecimal.t.sol` -- tests decimal literal parsing, e-notation, overflow, yang
- `LibParse.literalIntegerHex.t.sol` -- tests hex literal parsing, uint256 max, deduplication
- `LibParse.literalString.t.sol` -- tests string literal parsing, too-long, invalid chars
- `LibParse.operandDisallowed.t.sol` -- tests disallowed operands
- `LibParse.operandSingleFull.t.sol` -- tests single full operand parsing
- `LibParse.operandM1M1.t.sol` -- tests M1M1 operand parsing
- `LibParse.operand8M1M1.t.sol` -- tests 8M1M1 operand parsing
- `LibParse.operandDoublePerByteNoDefault.t.sol` -- tests double-per-byte-no-default operand parsing
- `LibParse.singleIgnored.gas.t.sol` -- gas benchmark
- `LibParse.singleLHSNamed.gas.t.sol` -- gas benchmark
- `LibParse.singleRHSNamed.gas.t.sol` -- gas benchmark
- `LibParse.inputsOnly.gas.t.sol` -- gas benchmark

## Findings

### A30-1: No test triggers `ParenOverflow` error

**Severity:** MEDIUM

The `ParenOverflow` error (line 338 in `LibParse.sol`) is thrown when parenthesis nesting exceeds the 20-group limit (`newParenOffset > 59`). No test in the entire `test/` directory triggers this error. A grep for `ParenOverflow.selector` across all test files returns zero matches. This means the boundary condition for maximum paren nesting depth is completely untested.

The code path at line 337-339:
```solidity
if (newParenOffset > 59) {
    revert ParenOverflow();
}
```

A test should construct an expression with 21 levels of nested parentheses (e.g., `_:a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a()))))))))))))))))))));`) and verify it reverts with `ParenOverflow()`.

### A30-2: No test triggers `ParserOutOfBounds` error from `parse()`

**Severity:** LOW

The `ParserOutOfBounds` error (line 434 in `LibParse.sol`) is thrown when `cursor != end` after the main parse loop completes. No test triggers this specific revert. The test `testParseStringLiteralBoundsParserOutOfBounds` in `LibParseLiteralString.boundString.t.sol` has a misleading name -- it actually tests for `UnclosedStringLiteral`, not `ParserOutOfBounds`.

The `ParserOutOfBounds` check at line 433-435:
```solidity
if (cursor != end) {
    revert ParserOutOfBounds();
}
```

This is a defensive check that should be difficult to trigger under normal conditions (the parser loop runs `while (cursor < end)` and each iteration advances `cursor`). However, it is possible this could be triggered if a sub-function returns a cursor past `end`. The lack of a test means this invariant is not verified.

### A30-3: No test for yang-state `UnexpectedRHSChar` in `parseRHS` (consecutive words without whitespace)

**Severity:** LOW

Line 215-217 in `parseRHS`:
```solidity
if (state.fsm & FSM_YANG_MASK > 0) {
    revert UnexpectedRHSChar(state.parseErrorOffset(cursor));
}
```

This path fires when the parser is in yang state (just finished processing something) and encounters another RHS word head without intervening whitespace. While `testParseIntegerLiteralDecimalYang` tests this for the literal-then-word case (`1e0e`), no test exercises the direct word-word path (e.g., two consecutive words without whitespace like `_:a()b();`). The existing tests only cover the first-character-on-RHS case via `testParseUnexpectedRHS`.

### A30-4: No test for stack name fallback path in `parseRHS` via `stackNameIndex`

**Severity:** LOW

Lines 236-242 in `parseRHS`:
```solidity
(exists, opcodeIndex) = state.stackNameIndex(word);
if (exists) {
    state.pushOpToSource(OPCODE_STACK, OperandV2.wrap(bytes32(opcodeIndex)));
    state.highwater();
}
```

While `testParseNamedLHSStackIndex` in `LibParse.namedLHS.t.sol` exercises this path (e.g., `a _:1 2,b:a,...`), the test uses a custom meta fixture with a `stack` opcode. The stack-name-as-RHS-value path is tested, but only with very specific patterns. There are no fuzz tests exploring boundary conditions such as:
- Stack name at the very first/last position on the RHS
- Stack name as the only item on a line with no other context
- Stack name with index at the maximum representable value

### A30-5: No test for `OPCODE_UNKNOWN` sub-parser bytecode construction boundary conditions

**Severity:** LOW

Lines 244-310 in `parseRHS` handle the fallback to sub-parsing for unknown words. While there are sub-parser tests in `test/src/lib/parse/LibSubParse.*.t.sol` that exercise the end-to-end sub-parsing flow, the specific bytecode construction logic in `parseRHS` (lines 248-304) -- including the `SUB_PARSER_BYTECODE_HEADER_SIZE` calculation, memory allocation, and `unsafeCopyBytesTo` -- is only tested indirectly. There are no tests that specifically validate:
- The sub-parser bytecode layout when the unknown word is at maximum length (31 bytes)
- The sub-parser bytecode layout when there are many operand values
- The memory allocation alignment given the comment "This is NOT an aligned allocation"

### A30-6: `parseLHS` yang path tested but only for specific cases

**Severity:** INFO

The yang path in `parseLHS` (line 147-149) that reverts with `UnexpectedLHSChar` when encountering a stack head while already in yang state is tested by `testParseUnexpectedLHSUnderscoreTail` (e.g., `a_:;`, `_a_:;`). The test coverage for this specific path is adequate for the named identifier case but the anonymous identifier case of two underscores without whitespace is not explicitly tested (though it would follow the same yang logic). However, since the fuzz test `testParseUnexpectedLHSSingleChar` covers many character combinations and the yang logic is simple, this is informational only.

### A30-7: `parseLHS` comment head path tested but not for all positions

**Severity:** INFO

The comment detection in `parseLHS` (line 183-184) that reverts with `UnexpectedComment` is tested in `LibParse.comments.t.sol` for several positions: after ignored LHS item, after named LHS item, in LHS whitespace. The coverage for this specific branch is adequate.

### A30-8: No boundary test for `parseWord` with exactly 31-character words hitting `end`

**Severity:** INFO

The `parseWord` function (line 99) has a boundary at exactly 31 characters (the maximum valid word length). `testLibParseParseWordEnd` tests lengths 1 to 31 and `testLibParseParseWordExamples` tests a 31-character word explicitly. The boundary between 31 (valid) and 32 (invalid, triggers `WordSize`) is tested. Coverage is adequate.
