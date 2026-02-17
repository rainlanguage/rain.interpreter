# Pass 1 (Security) — LibParse.sol

Audited file: `src/lib/parse/LibParse.sol`

## Evidence of Thorough Reading

### Library Name

`LibParse` (line 59)

### Functions

| Function | Line |
|---|---|
| `parseWord(uint256 cursor, uint256 end, uint256 mask)` | 91 |
| `parseLHS(ParseState memory state, uint256 cursor, uint256 end)` | 127 |
| `parseRHS(ParseState memory state, uint256 cursor, uint256 end)` | 195 |
| `parse(ParseState memory state)` | 412 |

### Constants

| Constant | Line |
|---|---|
| `NOT_LOW_16_BIT_MASK` | 55 |
| `ACTIVE_SOURCE_MASK` | 56 |
| `SUB_PARSER_BYTECODE_HEADER_SIZE` | 57 |

### Errors Used (imported from `ErrParse.sol`)

`UnexpectedRHSChar`, `UnexpectedRightParen`, `WordSize`, `DuplicateLHSItem`, `ParserOutOfBounds`, `ExpectedLeftParen`, `UnexpectedLHSChar`, `MissingFinalSemi`, `UnexpectedComment`, `ParenOverflow` (lines 28-38)

### Structs/Events Defined

None defined in this file.

---

## Security Findings

### F-1: `parseWord` reads up to 32 bytes via `mload` which may read past `end` boundary (INFO)

**Location:** `parseWord`, lines 100-111

**Description:** The function performs `word := mload(cursor)` which loads 32 bytes from `cursor`. The guard `iEnd` limits how many bytes are inspected by the character-mask loop, but the initial `mload` at line 102 will always read 32 bytes from `cursor`, even if fewer than 32 bytes remain between `cursor` and `end`. This means the loaded `word` may contain bytes from beyond the end of the parse data.

**Analysis:** This is an `mload` (read), not an `mstore` (write), so no memory corruption occurs. The excess bytes are scrubbed at lines 108-109 (`shl`/`shr` pair zeroes out bytes past position `i`). Additionally, the loop at line 105 is bounded by `iEnd` which is `min(remaining, 0x20)`, so the loop itself only inspects valid bytes. The scrubbed word is returned. However, if the parse data happens to end right at the end of allocated memory, the `mload` would read past the free memory pointer into uninitialized (but zero) memory. In Solidity's memory model, memory past the free pointer is always zero, so this read returns zero bytes for the out-of-range portion and those bytes are then scrubbed. No exploitable issue.

**Severity:** INFO -- No security impact. This is a standard pattern for Solidity memory-based parsing.

---

### F-2: Paren depth tracking uses hardcoded struct field offsets (MEDIUM)

**Location:** `parseRHS`, lines 321-330, 338-364

**Description:** The paren tracking logic accesses `state.parenTracker0` via hardcoded offset `add(state, 0x60)`. This offset is derived from the `ParseState` struct layout in `LibParseState.sol`. If the struct layout changes (e.g., fields are added or reordered before `parenTracker0`), this hardcoded offset would silently read/write the wrong field, potentially corrupting parser state.

The same pattern appears throughout `LibParseState.sol` (e.g., `add(state, 0x20)` for `topLevel0`, `add(state, 0xa0)` for `lineTracker`).

**Analysis:** The struct layout is well-documented with a comment block at lines 119-133 of `LibParseState.sol` that explicitly marks fields referenced by hardcoded offsets in assembly. This is a known design trade-off for gas efficiency. However, there is no compile-time or test-time assertion that the offsets match the actual struct layout. A maintainer adding a field before `parenTracker0` would silently break the parser.

**Severity:** MEDIUM -- No current exploit, but a maintenance hazard with potential for silent memory corruption if struct layout is modified. The risk is mitigated by the comment block and by test coverage that would likely catch many such errors.

---

### F-3: `parseLHS` does not check that `cursor` advances on each loop iteration for anonymous stack items (INFO)

**Location:** `parseLHS`, lines 155-157

**Description:** For anonymous stack items (the `else` branch at line 155), the cursor is advanced via `LibParseChar.skipMask(cursor + 1, end, CMASK_LHS_STACK_TAIL)`. The `+1` ensures at least one byte is consumed (the head character). After this, `state.fsm |= FSM_YANG_MASK` is set at line 164, which prevents starting a new stack item without intervening whitespace. The whitespace handler at line 166 resets yang to yin. This means progress is always guaranteed: either a character is consumed, or yang prevents re-entry, or whitespace is skipped, or the delimiter is found, or an error is raised.

**Severity:** INFO -- No issue. The FSM ensures forward progress.

---

### F-4: `parseRHS` paren input counter write-back uses unvalidated byte offset for `mstore8` (HIGH)

**Location:** `parseRHS`, lines 349-365

**Description:** When a right parenthesis `)` is encountered, the code decrements the paren offset and then writes the input counter to a target byte location computed from the paren tracker. The target write address is calculated at line 360:

```solidity
add(1, shr(0xf0, mload(add(add(stateOffset, 2), parenOffset))))
```

This reads a 16-bit pointer from the paren tracker (the operand write pointer stored when the paren was opened) and uses `shr(0xf0, ...)` to extract the top 16 bits. The result plus 1 is used as the target for `mstore8`. This pointer is an absolute memory address that was stored during `pushOpToSource`.

If `pushOpToSource` wrote a corrupted or unexpected value into the paren tracker pointer slot, `mstore8` would write to an arbitrary memory location. However, the paren tracker pointer is computed from `activeSourcePointer` in `pushOpToSource` (LibParseState.sol, line 644), which is always a valid heap-allocated pointer. The `ParseMemoryOverflow` check in `RainterpreterParser.sol` ensures all pointers stay within 16-bit range.

Additionally, the input counter value written (line 363) is read from `byte(0, mload(add(add(stateOffset, 4), parenOffset)))`, which is the paren input counter for the closed group. This counter can reach at most 255 before `ParenInputOverflow` triggers in `pushOpToSource`.

**Analysis:** The `mstore8` at line 354 writes to memory address `add(1, shr(0xf0, mload(...)))`. The pointer stored in the paren tracker is the `inputsBytePointer` from `pushOpToSource` (line 644 of LibParseState.sol), which points into the active source's data region. The `shr(0xf0, ...)` extracts the pointer from the top 16 bits of the stored value. This is correct: the pointer is stored in the high 16 bits of the paren tracker entry, and `mstore8` writes a single byte (the input count) into the second byte of the 4-byte opcode slot in the active source, which is the IO byte position.

The safety relies on:
1. `pushOpToSource` storing a valid pointer
2. The pointer being within the 16-bit addressable range (enforced by `ParseMemoryOverflow`)
3. The paren offset being valid (enforced by the `parenOffset == 0` check and the `ParenOverflow` check)

**Severity:** HIGH -- If the `ParseMemoryOverflow` check were bypassed or if the parser were used outside `RainterpreterParser` (which applies the modifier), the `mstore8` could write to an arbitrary memory location. The `ParseMemoryOverflow` guard is only applied at the `RainterpreterParser` contract level, not within `LibParse` itself. Any contract that calls `LibParse.parse()` directly without the overflow check would be vulnerable to memory corruption if the free memory pointer exceeds 0x10000.

---

### F-5: `parseRHS` sub-parser bytecode memory allocation is not 32-byte aligned (INFO)

**Location:** `parseRHS`, lines 262-275

**Description:** The sub-parser bytecode allocation at line 266 uses:
```solidity
mstore(0x40, add(subParserBytecode, add(subParserBytecodeLength, 0x20)))
```

The comment at line 265 explicitly states "This is NOT an aligned allocation." The allocated `bytes` value (`subParserBytecode`) is used as a pointer stored in the operand of the `OPCODE_UNKNOWN` op (line 274: `operand := subParserBytecode`). This pointer is later used in `subParseWordSlice` to retrieve the sub-parse data.

**Analysis:** The unaligned allocation is intentional and documented. The `bytes` value is a pointer to a valid memory region with a correct length prefix. Since this is only used as a pointer (not as a Solidity `bytes` passed to external code that expects alignment), the lack of alignment is not a security issue. The `ParseMemoryOverflow` check ensures the pointer fits in 16 bits.

**Severity:** INFO -- Intentional design choice, documented in code.

---

### F-6: `ACTIVE_SOURCE_MASK` constant is defined but never used in this file (INFO)

**Location:** Line 56

**Description:** The constant `ACTIVE_SOURCE_MASK` is defined as `NOT_LOW_16_BIT_MASK` at line 56 but is not referenced anywhere in `LibParse.sol`. A grep of the codebase would be needed to confirm whether it is used elsewhere or is dead code.

**Severity:** INFO -- Code quality observation, no security impact.

---

### F-7: Operand is not truncated when written to source in `pushOpToSource` (MEDIUM)

**Location:** `LibParseState.sol`, `pushOpToSource`, lines 682-692

**Description:** In `pushOpToSource`, the operand is written into the active source at lines 688-692:

```solidity
| OperandV2.unwrap(operand) << offset
```

`OperandV2` is a `bytes32` type. If the operand value is larger than 16 bits, the excess bits will be shifted into higher positions of the active source word, potentially overwriting other opcode/operand data. For known opcodes, operand handlers (`handleOperandSingleFull`, etc.) validate that values fit within 16 bits and revert on overflow via `OperandOverflow`. For `OPCODE_STACK`, the operand is a stack name index which is bounded by `ParseStackOverflow` (max 62 items, so max index ~62, well within 16 bits).

For `OPCODE_UNKNOWN`, the operand is set to the pointer to the sub-parser bytecode (line 274 of LibParse.sol). This pointer is a memory address, and the `ParseMemoryOverflow` guard ensures it stays below 0x10000 (16 bits). Without the guard, this pointer could exceed 16 bits and corrupt adjacent opcode data in the source.

**Analysis:** The operand is effectively assumed to be 16 bits throughout the system. For all current code paths, this invariant is maintained by:
- Operand handlers that validate and truncate values
- Stack indices bounded by `ParseStackOverflow`
- Memory pointers bounded by `ParseMemoryOverflow`

However, `pushOpToSource` itself does not enforce the 16-bit constraint. It relies on callers to ensure the operand fits.

**Severity:** MEDIUM -- The invariant is maintained by all current callers, but `pushOpToSource` is `internal` and could be called with an oversized operand by future code added to the library, silently corrupting the source bytecode. A defense-in-depth mask would be prudent.

---

### F-8: `parseWord` allows exactly 31-byte words, reverts only at 32 bytes (INFO)

**Location:** `parseWord`, lines 112-114

**Description:** The `WordSize` revert triggers only when `i == 0x20` (32 bytes). Words of length 1-31 bytes are accepted. The word is stored as a `bytes32` with the right side zero-padded. This is consistent with the system's design where words are `bytes32` values used as lookup keys.

**Severity:** INFO -- Behaves as designed. The 32-byte limit exists because `bytes32` cannot represent a longer value, and a 32-byte word would leave no room for the zero-padding that distinguishes shorter words.

---

### F-9: No bounds check on `subParserBytecodeLength` calculation (LOW)

**Location:** `parseRHS`, lines 245-255

**Description:** The `subParserBytecodeLength` is computed as:
```solidity
uint256 subParserBytecodeLength = SUB_PARSER_BYTECODE_HEADER_SIZE + wordLength;
// ...
subParserBytecodeLength += state.operandValues.length * 0x20 + 0x20;
```

In the `unchecked` block, if `wordLength` or `operandValues.length` were extremely large, this could overflow. However:
- `wordLength` is at most 31 (bounded by `parseWord`'s `WordSize` check)
- `operandValues.length` is at most `OPERAND_VALUES_LENGTH` (4), bounded by `OperandValuesOverflow` in `parseOperand`

So the maximum value is `5 + 31 + 4*32 + 32 = 196`, which cannot overflow.

**Severity:** LOW -- Theoretically the arithmetic is unchecked, but practically bounded by upstream invariants.

---

### F-10: All reverts use custom errors (INFO)

**Location:** Throughout the file.

**Description:** Every revert path in `LibParse.sol` uses a custom error:
- `WordSize` (line 113)
- `UnexpectedLHSChar` (lines 140, 178)
- `DuplicateLHSItem` (line 151)
- `UnexpectedComment` (lines 176, 397)
- `UnexpectedRHSChar` (lines 208, 399)
- `ExpectedLeftParen` (line 310)
- `ParenOverflow` (line 329)
- `UnexpectedRightParen` (line 342)
- `ParserOutOfBounds` (line 425)
- `MissingFinalSemi` (line 428)

No string-based reverts (`revert("...")`) are used.

**Severity:** INFO -- Compliant with project conventions.

---

### F-11: `parseLHS` increments `topLevel1` without overflow check (LOW)

**Location:** `parseLHS`, line 160

**Description:** `state.topLevel1++` is inside an `unchecked` block. The `topLevel1` field is a `uint256`, and the low byte is used as the LHS stack count for the current source. The `pushStackName` function at LibParseStackName.sol line 47 reads `state.topLevel1 & 0xFF` to determine the stack index. If `topLevel1` were incremented past 255, the low byte would wrap to 0, causing incorrect stack indices.

However, the `highwater` function in `LibParseState.sol` (line 484) checks `newStackRHSOffset == 0x3f` and reverts with `ParseStackOverflow`. The total number of stack items per source is capped at 62, so `topLevel1` can reach at most ~62 before other overflow guards trigger. The byte cannot wrap to 0.

**Severity:** LOW -- The overflow is prevented by upstream bounds (62 max stack items), but the protection is indirect. A dedicated check on `topLevel1` would be more explicit.

---

### F-12: `parseLHS` `lineTracker++` without overflow check (LOW)

**Location:** `parseLHS`, line 161

**Description:** `state.lineTracker++` is inside an `unchecked` block. The low byte of `lineTracker` counts LHS items for the current line. If more than 255 LHS items appeared on a single line, the counter would wrap. However, the `ParseStackOverflow` guard limits total stack items per source to 62, and `ExcessLHSItems` in `endLine` validates LHS/RHS counts match. This makes 255+ LHS items on a single line impossible in practice.

**Severity:** LOW -- Protected indirectly by other guards.

---

### F-13: `parse` function checks `cursor != end` after the while loop but cursor could exceed end (LOW)

**Location:** `parse`, lines 419-426

**Description:** The main parse loop at line 419 is `while (cursor < end)`. After the loop, line 424 checks `if (cursor != end)` and reverts with `ParserOutOfBounds`. This means if cursor somehow exceeded `end` (e.g., cursor jumped past end due to a bug in `parseLHS` or `parseRHS`), the `cursor != end` check would catch it. This is correct defensive programming.

However, within the `unchecked` block, if any of the inner parsing functions returned a cursor value greater than `end`, the `while (cursor < end)` loop would terminate, and the `cursor != end` check would revert. This is the intended behavior.

**Severity:** LOW -- The check is correct and provides a safety net. The concern is theoretical: if an inner function had a bug causing cursor to skip past `end` by exactly the right amount, the `while` loop would exit normally but the `cursor != end` would catch it. Good defense-in-depth.

---

## Summary

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 4 |
| INFO | 6 |

The most significant finding is **F-4** (HIGH): the `mstore8` write-back of paren input counters relies on pointers being within 16-bit range, which is only enforced at the `RainterpreterParser` contract level via `checkParseMemoryOverflow`, not within `LibParse` itself. Any direct user of `LibParse.parse()` that does not apply this check could be vulnerable to memory corruption if the free memory pointer exceeds 0x10000. **F-7** (MEDIUM) highlights the related concern that `pushOpToSource` does not mask the operand to 16 bits, relying entirely on callers for correctness. **F-2** (MEDIUM) flags the maintenance risk of hardcoded struct offsets in assembly.
