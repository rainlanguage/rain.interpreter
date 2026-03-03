# Audit Pass 1 -- LibParse.sol

**Agent:** A30
**File:** `src/lib/parse/LibParse.sol` (449 lines)
**Date:** 2026-03-01

## Evidence of Thorough Reading

### Library Name
`LibParse` (line 68)

### Constants
| Name | Value | Line |
|------|-------|------|
| `SUB_PARSER_BYTECODE_HEADER_SIZE` | `5` | 59 |

### Functions
| Name | Line | Visibility |
|------|------|------------|
| `parseWord` | 100 | `internal pure` |
| `parseLHS` | 136 | `internal pure` |
| `parseRHS` | 204 | `internal view` |
| `parse` | 425 | `internal view` |

### Imported Types/Errors/Constants
**Types:** `Pointer`, `ParseState`, `OperandV2`

**Errors (from ErrParse.sol):**
`UnexpectedRHSChar`, `UnexpectedRightParen`, `WordSize`, `DuplicateLHSItem`, `ParserOutOfBounds`, `ExpectedLeftParen`, `UnexpectedLHSChar`, `MissingFinalSemi`, `UnexpectedComment`, `ParenOverflow`

**Constants (from LibParseState.sol):**
`FSM_YANG_MASK`, `FSM_DEFAULT`, `FSM_ACTIVE_SOURCE_MASK`, `FSM_WORD_END_MASK`, `PARSE_STATE_PAREN_TRACKER0_OFFSET`

**Libraries used via `using...for`:**
`LibPointer`, `LibParseStackName`, `LibParseState`, `LibParseInterstitial`, `LibParseError`, `LibParseMeta`, `LibParsePragma`, `LibParse`, `LibParseOperand`, `LibSubParse`, `LibBytes`, `LibUint256Array`, `LibBytes32Array`

---

## Findings

### A30-1: parseOperand reads memory at cursor without bounds check when cursor == end [INFO]

**Location:** Called from `parseRHS` lines 228, 261 -> `LibParseOperand.parseOperand` line 37-39

**Description:**
After `parseWord` returns in `parseRHS`, the cursor may equal `end` (e.g., when the last character of the input is the last character of a word). `parseOperand` is then called with `cursor == end`. At line 37-39 of `LibParseOperand.sol`, `mload(cursor)` reads 32 bytes starting at `end`, which is past the data boundary.

Since this is a memory read (not calldata), it reads whatever happens to be at that memory address rather than reverting. In the common case the garbage byte does not match `CMASK_OPERAND_START` and the function returns cursor unchanged. In the unlikely case the garbage byte does match, the `while (cursor < end)` loop at line 63 exits immediately, `success` remains false, and the function reverts with `UnclosedOperand`.

**Impact:** The behavior is correct in all cases (either no-op or clean revert). The read is from Solidity-managed memory so no out-of-bounds revert occurs. The only theoretical concern is a misleading error message (`UnclosedOperand` instead of a more descriptive error) in the edge case where post-data garbage matches `<`.

**Severity:** INFO

**Recommendation:** No code change required. The current behavior is safe. If clarity is desired, a `cursor >= end` guard before the `mload` in `parseOperand` would make the intent explicit.

---

### A30-2: Sub-parser bytecode construction uses unaligned memory allocation [INFO]

**Location:** `parseRHS` lines 271-284

**Description:**
The sub-parser bytecode allocation at line 275:
```solidity
mstore(0x40, add(subParserBytecode, add(subParserBytecodeLength, 0x20)))
```
is explicitly documented as "NOT an aligned allocation." This is intentional -- the sub-parser bytecode is treated as raw bytes passed to external sub-parser contracts, not as a Solidity `bytes` variable that would need 32-byte alignment for ABI encoding.

Later code in `pushOpToSource` stores a pointer to this bytecode as the operand of `OPCODE_UNKNOWN`. When `subParseWordSlice` dereferences it, the pointer is used to build the `data` variable passed to `subParser.subParseWord2(data)`, which ABI-encodes it for the external call.

**Impact:** The unaligned allocation does not cause issues because the bytecode is consumed through explicit pointer manipulation, not through Solidity's ABI decoder on the allocating side. The external call ABI-encodes the data regardless of alignment.

**Severity:** INFO

**Recommendation:** No change needed. The existing comment at line 274 documents the intentional non-alignment.

---

### A30-3: parseWord mload reads up to 31 bytes past data end [INFO]

**Location:** `parseWord` line 111

**Description:**
`word := mload(cursor)` always reads 32 bytes from the cursor position, even when less than 32 bytes remain between cursor and end. The `iEnd` variable correctly limits the loop to only check bytes within bounds (`iEnd = min(remaining, 0x20)`), and the scrub operation zeros out bytes beyond the word length. The extra bytes read are from Solidity-managed memory.

**Impact:** None. The over-read is from heap memory, not calldata or storage. The scrubbed bytes are discarded. This is a standard pattern in Solidity assembly for processing packed data.

**Severity:** INFO

---

### A30-4: checkParseMemoryOverflow is post-hoc, not preventive [INFO]

**Location:** `LibParseState.checkParseMemoryOverflow` (line 1044 of LibParseState.sol), called as modifier in `RainterpreterParser.sol`

**Description:**
The 16-bit pointer system used throughout the parser (active source slots, paren tracker, sources builder, constants builder, stack names) requires all memory pointers to fit in 16 bits (< 0x10000). `checkParseMemoryOverflow` validates this constraint after the entire parse operation completes. If memory crosses the 0x10000 boundary during parsing, linked list pointers are silently truncated before the check runs.

The NatSpec in `pushSubParser` (line 303-305 of LibParseState.sol) explicitly documents this dependency: "this function relies on `checkParseMemoryOverflow` keeping the free memory pointer below `0x10000`. If that invariant is violated, the tail pointer will be silently truncated and the linked list corrupted."

**Impact:** If memory overflows during parsing, the resulting bytecode is corrupted. However, the post-hoc check will revert the transaction, so corrupted bytecode never escapes the parser. The risk is zero for external callers since the modifier ensures the revert. An internal library caller that skips the check could produce corrupted output, but all entry points in `RainterpreterParser.sol` use the modifier.

**Severity:** INFO

**Recommendation:** No change needed. The design is sound -- the post-hoc check catches any overflow and reverts the entire transaction, preventing corrupted output from being returned. The NatSpec correctly documents the invariant dependency.

---

## Summary

No LOW or higher findings were identified in `LibParse.sol`. The code demonstrates careful attention to:

1. **Paren tracking bounds:** The `ParenOverflow` check at line 341 correctly prevents the phantom write in `pushOpToSource` from corrupting `lineTracker`. The boundary of 59 (rejecting 60+) accounts for the +4 phantom write offset.

2. **Cursor advancement:** All cursor advances are bounded by `end`. The `while (cursor < end)` loops in `parseLHS`, `parseRHS`, and `parse` prevent processing past the data boundary. The `parseWord` function correctly limits iteration via `iEnd = min(remaining, 0x20)`.

3. **Memory safety:** Assembly blocks are correctly marked `memory-safe`. The `mload` operations that read past data boundaries are from Solidity heap memory and produce either correct no-ops or clean reverts.

4. **Sub-parser bytecode construction:** The allocation, header population, word copy, and operand values copy are correctly sequenced with non-overlapping memory regions.

5. **Right paren handling:** The paren offset decrement, input counter write-back, and pointer dereference are all correct for the valid range of paren offsets (0 to 57 in multiples of 3).
