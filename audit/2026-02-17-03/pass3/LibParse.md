# Pass 3: Documentation Review

Agent: A23

## Files Reviewed

- `src/lib/parse/LibParse.sol`
- `src/lib/parse/LibParseError.sol`
- `src/lib/parse/LibParseInterstitial.sol`

---

## Evidence of Thorough Reading

### `src/lib/parse/LibParse.sol`

**Library:** `LibParse` (line 67)

**Constants (file-level):**
- `NOT_LOW_16_BIT_MASK` (line 56)
- `ACTIVE_SOURCE_MASK` (line 57)
- `SUB_PARSER_BYTECODE_HEADER_SIZE` (line 58)

**Functions:**
| Function | Line |
|---|---|
| `parseWord(uint256, uint256, uint256)` | 99 |
| `parseLHS(ParseState memory, uint256, uint256)` | 135 |
| `parseRHS(ParseState memory, uint256, uint256)` | 203 |
| `parse(ParseState memory)` | 421 |

**Errors/Events/Structs defined in file:** None (all imported from `ErrParse.sol`).

**Imported errors used:** `UnexpectedRHSChar`, `UnexpectedRightParen`, `WordSize`, `DuplicateLHSItem`, `ParserOutOfBounds`, `ExpectedLeftParen`, `UnexpectedLHSChar`, `MissingFinalSemi`, `UnexpectedComment`, `ParenOverflow`.

---

### `src/lib/parse/LibParseError.sol`

**Library:** `LibParseError` (line 7)

**Functions:**
| Function | Line |
|---|---|
| `parseErrorOffset(ParseState memory, uint256)` | 13 |
| `handleErrorSelector(ParseState memory, uint256, bytes4)` | 26 |

**Errors/Events/Structs defined in file:** None.

---

### `src/lib/parse/LibParseInterstitial.sol`

**Library:** `LibParseInterstitial` (line 17)

**Functions:**
| Function | Line |
|---|---|
| `skipComment(ParseState memory, uint256, uint256)` | 28 |
| `skipWhitespace(ParseState memory, uint256, uint256)` | 96 |
| `parseInterstitial(ParseState memory, uint256, uint256)` | 111 |

**Errors/Events/Structs defined in file:** None (imported `MalformedCommentStart`, `UnclosedComment`).

---

## Findings

### A23-1 [LOW] `LibParse`: File-level constants `NOT_LOW_16_BIT_MASK`, `ACTIVE_SOURCE_MASK`, and `SUB_PARSER_BYTECODE_HEADER_SIZE` lack NatSpec

**File:** `src/lib/parse/LibParse.sol`, lines 56-58

The three file-level constants have no `///` documentation:

```solidity
uint256 constant NOT_LOW_16_BIT_MASK = ~uint256(0xFFFF);
uint256 constant ACTIVE_SOURCE_MASK = NOT_LOW_16_BIT_MASK;
uint256 constant SUB_PARSER_BYTECODE_HEADER_SIZE = 5;
```

`NOT_LOW_16_BIT_MASK` and `ACTIVE_SOURCE_MASK` are effectively the same value but have different names suggesting different purposes. There is no documentation explaining why `ACTIVE_SOURCE_MASK` equals `NOT_LOW_16_BIT_MASK`, or what the 5 bytes in `SUB_PARSER_BYTECODE_HEADER_SIZE` represent (i.e., which header fields account for those 5 bytes).

---

### A23-2 [INFO] `LibParse.parse`: Second `@return` tag missing named identifier

**File:** `src/lib/parse/LibParse.sol`, lines 419-420

```solidity
/// @return bytecode The compiled bytecode.
/// @return The constants array.
```

The first return value has a named identifier (`bytecode`) in the NatSpec but the second return value in both the NatSpec and the function signature is unnamed. While the NatSpec tag is present, the anonymous return in the function signature makes it harder to understand the API. This is stylistic and the NatSpec tag does exist, so this is informational.

---

### A23-3 [LOW] `LibParse.parseWord`: NatSpec describes `@return` as two separate values but does not name them

**File:** `src/lib/parse/LibParse.sol`, lines 97-98

```solidity
/// @return The new cursor position after the word.
/// @return The parsed word as a bytes32.
```

The function signature on line 99 is:

```solidity
function parseWord(uint256 cursor, uint256 end, uint256 mask) internal pure returns (uint256, bytes32)
```

The return values are unnamed in the function signature. The `@return` tags are present and descriptive, but they lack named identifiers. This is consistent with the rest of the codebase but worth noting for completeness. The documentation itself is accurate and thorough.

---

### A23-4 [LOW] `LibParse.parseLHS`: NatSpec does not document the yang/yin FSM transitions or the `CMASK_COMMENT_HEAD` special-case revert

**File:** `src/lib/parse/LibParse.sol`, lines 127-133

The NatSpec says:

```solidity
/// Parses the left-hand side (LHS) of a source line. Handles named and
/// anonymous stack items, whitespace, and the LHS/RHS delimiter. Reverts
/// on unexpected characters, comments, or duplicate named stack items.
```

This is a reasonable summary. However, the function makes critical FSM state transitions (setting yang/yin, setting `FSM_ACTIVE_SOURCE_MASK`) that affect subsequent parsing. The NatSpec mentions "unexpected characters, comments, or duplicate named stack items" which does cover the revert conditions. The yang/yin FSM behavior is internal detail that may not need explicit NatSpec. Informational-level -- the existing documentation is adequate but could be more precise about how FSM state is modified.

---

### A23-5 [LOW] `LibParse.parseRHS`: NatSpec does not describe FSM state transitions or the paren-tracking mechanism

**File:** `src/lib/parse/LibParse.sol`, lines 194-200

The NatSpec says:

```solidity
/// Parses the right-hand side (RHS) of a source line. Resolves words
/// against known opcodes, LHS stack names, and sub parsers. Handles
/// parenthesised operand groups, literals, and line/source terminators.
```

The function is 210 lines long and handles: word lookup with three fallback levels (meta, LHS stack names, sub-parsers), paren depth tracking with a 3-byte-per-level scheme, highwater tracking, FSM transitions, literal pushing, and line/source endings. The NatSpec provides a high-level summary but does not describe:
- The three-tier word resolution (meta -> stack name -> sub-parser)
- That paren depth is tracked in a byte-offset scheme with 3 bytes per level
- That `FSM_WORD_END_MASK` enforces mandatory left-paren after known/unknown words

Given the complexity of this function, the documentation is adequate at the summary level but leaves significant implementation detail undocumented.

---

### A23-6 [INFO] `LibParseError`: Library itself has no library-level NatSpec

**File:** `src/lib/parse/LibParseError.sol`, line 7

```solidity
library LibParseError {
```

There is no `/// @title` or other library-level NatSpec above the `library` declaration. Both functions within the library are well-documented with `@param` and `@return` tags. Only the library-level documentation is missing.

---

### A23-7 [INFO] `LibParseInterstitial`: Library itself has no library-level NatSpec

**File:** `src/lib/parse/LibParseInterstitial.sol`, line 17

```solidity
library LibParseInterstitial {
```

There is no `/// @title` or other library-level NatSpec above the `library` declaration. All three functions within the library are well-documented with `@param` and `@return` tags. Only the library-level documentation is missing.

---

### A23-8 [INFO] `LibParseInterstitial.skipComment`: NatSpec uses "MAY REVERT" phrasing but does not list the specific errors

**File:** `src/lib/parse/LibParseInterstitial.sol`, lines 21-27

```solidity
/// The cursor currently points at the head of a comment. We need to skip
/// over all data until we find the end of the comment. This MAY REVERT if
/// the comment is malformed, e.g. if the comment doesn't start with `/*`.
```

The function can revert with `UnclosedComment` (line 40, line 83) or `MalformedCommentStart` (line 49). The NatSpec only mentions malformed start as an example but does not mention the `UnclosedComment` case at all. The `@param` and `@return` tags are complete and accurate.

---

### A23-9 [INFO] `LibParseInterstitial.skipWhitespace`: NatSpec mentions "yin state" -- term is not defined

**File:** `src/lib/parse/LibParseInterstitial.sol`, lines 90-95

```solidity
/// Advances the cursor past any contiguous whitespace characters and
/// resets the FSM to yin state.
```

The term "yin state" (clearing `FSM_YANG_MASK`) is used here and "yang state" is used elsewhere. These terms are internal conventions for the FSM but are never formally defined in NatSpec anywhere in these files. A reader unfamiliar with the codebase would not know what yin/yang means in this context. The `@param` and `@return` tags are complete and accurate.

---

## Summary

| ID | Severity | File | Description |
|---|---|---|---|
| A23-1 | LOW | LibParse.sol | File-level constants lack NatSpec |
| A23-2 | INFO | LibParse.sol | `parse` second `@return` unnamed |
| A23-3 | LOW | LibParse.sol | `parseWord` return values unnamed |
| A23-4 | LOW | LibParse.sol | `parseLHS` NatSpec omits FSM transition details |
| A23-5 | LOW | LibParse.sol | `parseRHS` NatSpec omits significant implementation details |
| A23-6 | INFO | LibParseError.sol | Library missing top-level NatSpec |
| A23-7 | INFO | LibParseInterstitial.sol | Library missing top-level NatSpec |
| A23-8 | INFO | LibParseInterstitial.sol | `skipComment` NatSpec omits `UnclosedComment` error |
| A23-9 | INFO | LibParseInterstitial.sol | `skipWhitespace` NatSpec uses undefined "yin" term |

All functions across all three files have NatSpec documentation with `@param` and `@return` tags. No function is completely undocumented. The findings are primarily about the depth and precision of existing documentation rather than missing documentation.
