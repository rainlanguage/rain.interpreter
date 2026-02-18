# Error Files — Pass 3 (Documentation)

Agent: A07

## Files Reviewed
- `src/error/ErrBitwise.sol` — 3 errors, all fully documented
- `src/error/ErrDeploy.sol` — 1 error, fully documented
- `src/error/ErrEval.sol` — 2 errors, fully documented
- `src/error/ErrExtern.sol` — 4 errors
- `src/error/ErrIntegrity.sol` — 8 errors, all fully documented
- `src/error/ErrOpList.sol` — 1 error, fully documented
- `src/error/ErrParse.sol` — 40+ errors
- `src/error/ErrStore.sol` — 1 error, fully documented

## Findings

### A07-1: `BadOutputsLength` in ErrExtern.sol missing `@param` tags
**Severity:** LOW

Missing `@param expectedLength` and `@param actualLength` (line 22-23).

### A07-2 through A07-30: ErrParse.sol errors missing `@param` tags
**Severity:** LOW (each)

29 errors in ErrParse.sol have descriptions but are missing `@param` tags for their parameters. Most have an `offset` parameter without `@param offset`. The affected errors are:

- A07-2: `UnsupportedLiteralType` (30)
- A07-3: `StringTooLong` (33)
- A07-4: `UnclosedStringLiteral` (37)
- A07-5: `HexLiteralOverflow` (40)
- A07-6: `ZeroLengthHexLiteral` (43)
- A07-7: `OddLengthHexLiteral` (46)
- A07-8: `MalformedHexLiteral` (49)
- A07-9: `MalformedExponentDigits` (53)
- A07-10: `MalformedDecimalPoint` (56)
- A07-11: `MissingFinalSemi` (59)
- A07-12: `UnexpectedLHSChar` (62)
- A07-13: `UnexpectedRHSChar` (65)
- A07-14: `ExpectedLeftParen` (69)
- A07-15: `UnexpectedRightParen` (72)
- A07-16: `UnclosedLeftParen` (75)
- A07-17: `UnexpectedComment` (78)
- A07-18: `UnclosedComment` (81)
- A07-19: `MalformedCommentStart` (84)
- A07-20: `ExcessLHSItems` (92)
- A07-21: `NotAcceptingInputs` (95)
- A07-22: `ExcessRHSItems` (98)
- A07-23: `WordSize` (101) — missing `@param word`
- A07-24: `UnknownWord` (104) — missing `@param word`
- A07-25: `NoWhitespaceAfterUsingWordsFrom` (127)
- A07-26: `InvalidSubParser` (130)
- A07-27: `UnclosedSubParseableLiteral` (133)
- A07-28: `SubParseableMissingDispatch` (136)
- A07-29: `BadSubParserResult` (140) — missing `@param bytecode`
- A07-30: `OpcodeIOOverflow` (143)

### A07-31: `DuplicateLHSItem` uses `@dev` tag inconsistently
**Severity:** INFO

Line 86-89: Uses `@dev` for description while all other errors in the file use plain `///`. Note: this is the only error in ErrParse.sol that correctly has a `@param` tag.

### A07-32: `NoWhitespaceAfterUsingWordsFrom` NatSpec says "pragma keyword"
**Severity:** INFO

Line 126: Description says "after the pragma keyword" but the error is specifically about the "using words from" construct. Could be more precise.
