# Pass 1 (Security) — LibParseState.sol

**File:** `src/lib/parse/LibParseState.sol`
**Auditor:** Claude Opus 4.6
**Date:** 2026-02-17

---

## Evidence of Thorough Reading

### Contract/Library Name

`library LibParseState` (line 148)

### Struct Defined

- `ParseState` (line 118) — 17 fields: `activeSourcePtr`, `topLevel0`, `topLevel1`, `parenTracker0`, `parenTracker1`, `lineTracker`, `subParsers`, `sourcesBuilder`, `fsm`, `stackNames`, `stackNameBloom`, `constantsBuilder`, `constantsBloom`, `literalParsers`, `operandHandlers`, `operandValues`, `stackTracker`, `data`, `meta`

### Constants Defined

- `EMPTY_ACTIVE_SOURCE` (line 30) = `0x20`
- `FSM_YANG_MASK` (line 32) = `1`
- `FSM_WORD_END_MASK` (line 33) = `1 << 1`
- `FSM_ACCEPTING_INPUTS_MASK` (line 34) = `1 << 2`
- `FSM_ACTIVE_SOURCE_MASK` (line 38) = `1 << 3`
- `FSM_DEFAULT` (line 44) = `FSM_ACCEPTING_INPUTS_MASK`
- `OPERAND_VALUES_LENGTH` (line 55) = `4`

### Functions and Line Numbers

1. `newActiveSourcePointer(uint256)` — line 160
2. `resetSource(ParseState memory)` — line 181
3. `newState(bytes memory, bytes memory, bytes memory, bytes memory)` — line 207
4. `pushSubParser(ParseState memory, uint256, bytes32)` — line 265
5. `exportSubParsers(ParseState memory)` — line 285
6. `snapshotSourceHeadToLineTracker(ParseState memory)` — line 314
7. `endLine(ParseState memory, uint256)` — line 347
8. `highwater(ParseState memory)` — line 471
9. `constantValueBloom(bytes32)` — line 494
10. `pushConstantValue(ParseState memory, bytes32)` — line 502
11. `pushLiteral(ParseState memory, uint256, uint256)` — line 532
12. `pushOpToSource(ParseState memory, uint256, OperandV2)` — line 603
13. `endSource(ParseState memory)` — line 710
14. `buildBytecode(ParseState memory)` — line 841
15. `buildConstants(ParseState memory)` — line 935

### Errors Referenced (all imported from `ErrParse.sol`)

- `DanglingSource` (used at line 859)
- `MaxSources` (used at line 722)
- `ParseStackOverflow` (used at line 485)
- `UnclosedLeftParen` (used at line 355)
- `ExcessRHSItems` (used at line 409)
- `ExcessLHSItems` (used at line 411)
- `NotAcceptingInputs` (used at line 390)
- `UnsupportedLiteralType` (used at line 539)
- `InvalidSubParser` (used at line 267)
- `OpcodeIOOverflow` (used at line 451)
- `SourceItemOpsOverflow` (used at line 629)
- `ParenInputOverflow` (used at line 677)
- `LineRHSItemsOverflow` (used at line 337)

---

## Security Findings

### Finding 1 — `highwater`: Off-By-One Allows 0x3F But Stack Layout Only Supports 0x3E

**Severity:** LOW

**Location:** Lines 481–486

**Description:**

The `highwater` function increments `newStackRHSOffset` and then checks `if (newStackRHSOffset == 0x3f)`. The struct documentation says `topLevel0` has 1 counter byte + 31 data bytes, and `topLevel1` has 31 data bytes + 1 LHS counter byte, giving 62 (0x3E) usable slots total. However, the overflow check triggers at `0x3f` (63), which means a value of `0x3e` (62) is accepted — this is the 63rd slot (0-indexed 0 to 62), but only 62 bytes are available (bytes 1..31 of `topLevel0` and bytes 0..30 of `topLevel1`).

The check uses `==` rather than `>=`, so a single increment past the limit is caught, but the limit value itself (0x3F) may be one too high. With 62 usable byte slots (indices 0 through 61 = 0x3D), offset 0x3E would be the 63rd and already out of bounds. However, considering the offset is 1-indexed after the increment (offset 1 corresponds to the first data byte), the maximum valid offset would be 62 = 0x3E, and the revert at 0x3F is correct.

The `==` comparison rather than `>=` is still a minor fragility concern — if the function were ever called in a code path that could increment by more than 1, the check would be silently bypassed. Currently the function only increments by 1, so this is a style/robustness concern only.

**Recommendation:** Change the check to `if (newStackRHSOffset > 0x3e)` or `if (newStackRHSOffset >= 0x3f)` for defensive programming. Using `>=` instead of `==` prevents silent bypass if future changes allow larger increments.

---

### Finding 2 — `pushSubParser`: Truncation of Tail Pointer in High 16 Bits

**Severity:** MEDIUM

**Location:** Line 279

**Description:**

```solidity
state.subParsers = subParser | bytes32(tailPointer << 0xF0);
```

The `tailPointer` is a Solidity memory pointer (from `mload(0x40)`). It is shifted left by 240 bits (`0xF0`), which retains only the low 16 bits of the pointer value. If the free memory pointer ever exceeds `0xFFFF` (65535), the high bits are silently truncated.

The `ParseMemoryOverflow` guard in `RainterpreterParser.sol` checks `freeMemoryPointer >= 0x10000` **after** parsing completes, but during parsing the memory pointer can grow beyond this limit without any in-flight check. This means:

1. Memory is allocated at line 274–276 and the pointer `tailPointer` is derived from `mload(0x40)`.
2. If the free memory pointer has grown past 0xFFFF by the time `pushSubParser` is called, the pointer stored in the high bits of `subParsers` is corrupted.
3. `exportSubParsers` (line 296) retrieves the pointer via `shr(0xF0, tail)`, which would yield a truncated (wrong) address.
4. The post-hoc `_checkParseMemoryOverflow` would revert, but if any code path invokes `exportSubParsers` before that check, or if a different caller (not `RainterpreterParser`) uses these library functions, the corrupted pointer leads to reading arbitrary memory.

This pattern (16-bit pointer truncation) is systemic across the parser and is partially mitigated by the post-hoc `ParseMemoryOverflow` check, but the mitigation is external to this library.

**Recommendation:** Consider adding the 16-bit pointer safety check at the point of allocation within the library itself (e.g., in `newActiveSourcePointer` and `pushSubParser`), rather than relying solely on an external post-hoc check. This would make the library safe to use from any caller.

---

### Finding 3 — `exportSubParsers`: Unbounded Memory Write Without Pre-Allocation Size Check

**Severity:** LOW

**Location:** Lines 289–301

**Description:**

```solidity
assembly ("memory-safe") {
    subParsersUint256 := mload(0x40)
    let cursor := add(subParsersUint256, 0x20)
    let len := 0
    for {} gt(tail, 0) {} {
        mstore(cursor, and(tail, addressMask))
        cursor := add(cursor, 0x20)
        tail := mload(shr(0xF0, tail))
        len := add(len, 1)
    }
    mstore(subParsersUint256, len)
    mstore(0x40, cursor)
}
```

The function writes array elements one at a time while traversing the linked list, advancing `cursor` by 0x20 each iteration. The free memory pointer (`0x40`) is only updated after the loop completes. During the loop, subsequent writes go into unallocated memory. This is safe as long as no other allocation occurs during the loop (which is the case since this is pure assembly with no calls), but the pattern is fragile.

More importantly, if the linked list were somehow circular (due to a bug in `pushSubParser` or memory corruption from Finding 2), this loop would write indefinitely past the end of memory, potentially overwriting critical EVM data. There is no upper bound check on `len`.

**Recommendation:** Consider adding an upper bound on the loop iteration count (e.g., max 16 sub parsers, corresponding to the 16-bit pointer space) to prevent runaway writes in case of linked list corruption.

---

### Finding 4 — `endLine`: Unchecked Arithmetic on `totalRHSTopLevel - lineRHSSnapshot`

**Severity:** LOW

**Location:** Line 378

**Description:**

```solidity
uint256 lineRHSTopLevel = totalRHSTopLevel - ((state.lineTracker >> 8) & 0xFF);
```

This subtraction is inside an `unchecked` block (line 348). If the snapshot value `(state.lineTracker >> 8) & 0xFF` is greater than `totalRHSTopLevel` (which is `state.topLevel0 >> 0xf8`), the subtraction wraps to a very large number. This would cause the subsequent loop at line 418 (`for (uint256 offset = 0x20; offset < end; offset += 0x10)`) to iterate an enormous number of times, likely running out of gas.

In practice, the snapshot is taken from `totalRHSTopLevel` at the start of the line (line 462: `state.lineTracker = totalRHSTopLevel << 8`), so the invariant `totalRHSTopLevel >= snapshot` should always hold. However, the lack of an explicit check means any bug that corrupts `lineTracker` or `topLevel0` between lines could cause silent wraparound.

**Recommendation:** Add a safety check that `totalRHSTopLevel >= (state.lineTracker >> 8) & 0xFF` or move this arithmetic outside the `unchecked` block.

---

### Finding 5 — `pushOpToSource`: Operand and Opcode Can Overflow Into Adjacent Bit Fields

**Severity:** LOW

**Location:** Lines 682–692

**Description:**

```solidity
activeSource =
    bytes32(uint256(activeSource) + 0x20)
    | OperandV2.unwrap(operand) << offset
    | bytes32(opcode << (offset + 0x18));
```

`OperandV2` is `bytes32` (32 bytes). The code shifts it left by `offset` (which ranges from 0x20 to 0xE0 in steps of 0x20). Since `OperandV2.unwrap(operand)` is a full `bytes32`, only the low 16 bits are expected to contain meaningful data (as per the comment "The operand is assumed to be 16 bits"). If the operand contains data in higher bits, it would OR into adjacent fields or even into the offset/pointer bits of `activeSource`.

Similarly, `opcode` is a `uint256` and "assumed to be 8 bits." If it exceeds 8 bits, it would overflow into adjacent opcode/operand slots.

The callers are responsible for ensuring operands and opcodes are within range. This is a trust boundary issue — the library assumes correct inputs without validation.

**Recommendation:** Mask the operand to 16 bits and the opcode to 8 bits before shifting:
```solidity
| (OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF))) << offset
| bytes32((opcode & 0xFF) << (offset + 0x18));
```

---

### Finding 6 — `snapshotSourceHeadToLineTracker`: Source Head Pointer Stored in 16 Bits

**Severity:** INFO

**Location:** Lines 322–332

**Description:**

```solidity
let sourceHead := add(activeSourcePtr, sub(0x20, byteOffset))
...
lineTracker := or(lineTracker, shl(offset, sourceHead))
```

`sourceHead` is a full memory pointer, but it is stored in a 16-bit slot within `lineTracker`. This relies on the parser's memory never exceeding 0xFFFF, which is enforced by the external `ParseMemoryOverflow` check. This is consistent with Finding 2 — the 16-bit pointer assumption is systemic and the mitigation is external.

---

### Finding 7 — `endSource`: Linked List Traversal Trusts 16-Bit Pointer Integrity

**Severity:** INFO

**Location:** Lines 734–746

**Description:**

In `endSource`, the assembly block follows linked list pointers by extracting 16-bit values:

```solidity
let tailPointer := and(shr(0x10, mload(cursor)), 0xFFFF)
```

If any of these 16-bit pointers were corrupted (e.g., due to memory exceeding 0xFFFF during allocation), the traversal would read from arbitrary memory locations, potentially producing garbage source bytecode. The post-hoc `ParseMemoryOverflow` check is the sole mitigation.

---

### Finding 8 — `endLine`: Pointer Arithmetic in `itemSourceHead` Loop Assumes 32-Byte Alignment

**Severity:** INFO

**Location:** Lines 424–458

**Description:**

The inner loop in `endLine` iterates through opcodes in the source:

```solidity
if (itemSourceHead % 0x20 == 0x1c) {
    assembly ("memory-safe") {
        itemSourceHead := shr(0xf0, mload(itemSourceHead))
    }
}
```

The check `itemSourceHead % 0x20 == 0x1c` detects when the cursor has reached the end of a 32-byte linked list slot (offset 0x1c = 28, which is 4 bytes from the end, matching the 4-byte reserved pointer/offset area). This correctly follows the linked list forward pointer. However, this depends on `newActiveSourcePointer` always producing 32-byte-aligned allocations. The alignment is enforced at line 167 (`and(add(mload(0x40), 0x1F), not(0x1F))`), so this is sound.

No action needed — this is an observation confirming correctness.

---

### Finding 9 — All Reverts Use Custom Errors

**Severity:** INFO (Positive)

**Description:**

All revert paths in `LibParseState.sol` use custom error types from `ErrParse.sol`. No `revert("string")` or `require(condition, "string")` patterns are present. The following custom errors are used:

- `InvalidSubParser` (line 267)
- `LineRHSItemsOverflow` (line 337)
- `UnclosedLeftParen` (line 355)
- `NotAcceptingInputs` (line 390)
- `ExcessRHSItems` (line 409)
- `ExcessLHSItems` (line 411)
- `OpcodeIOOverflow` (line 451)
- `ParseStackOverflow` (line 485)
- `UnsupportedLiteralType` (line 539)
- `SourceItemOpsOverflow` (line 629)
- `ParenInputOverflow` (line 677)
- `MaxSources` (line 722)
- `DanglingSource` (line 859)

---

### Finding 10 — Assembly Blocks Consistently Marked `memory-safe`

**Severity:** INFO (Positive)

**Description:**

All 18 `assembly` blocks in the file use the `"memory-safe"` annotation. Manual review confirms that each block either:
- Reads/writes only to memory it has allocated via the free memory pointer, or
- Writes only to memory owned by the `ParseState` struct (which is allocated by the caller).

The `memory-safe` annotations appear correct.

---

### Finding 11 — `buildConstants`: Loop Termination Relies on Consistent `constantsHeight` and Linked List Length

**Severity:** LOW

**Location:** Lines 939–970

**Description:**

```solidity
cursor := add(cursor, mul(constantsHeight, 0x20))
mstore(0x40, add(cursor, 0x20))
for {} gt(cursor, end) {
    cursor := sub(cursor, 0x20)
    tailPtr := and(mload(tailPtr), 0xFFFF)
} {
    mstore(cursor, mload(add(tailPtr, 0x20)))
}
```

The loop writes `constantsHeight` values by decrementing `cursor` from the end of the allocated array back to the start. It simultaneously traverses the linked list via `tailPtr`. If the linked list is shorter than `constantsHeight` (due to a bug in `pushConstantValue`), `tailPtr` will reach 0 and subsequent `mload(add(0, 0x20))` will read from memory address 0x20, which is the Solidity scratch space. This would silently produce incorrect constant values rather than reverting.

Conversely, if the linked list is longer than `constantsHeight`, the extra entries are silently ignored.

In practice, `constantsHeight` is incremented exactly once per `pushConstantValue` call (line 518), so the invariant should hold. This is a robustness observation.

**Recommendation:** No immediate action needed, but a debug assertion that `tailPtr == 0` after the loop completes would catch any future inconsistency.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH     | 0 |
| MEDIUM   | 1 |
| LOW      | 4 |
| INFO     | 6 |

The primary security concern is the systemic reliance on 16-bit memory pointers throughout the parser (Finding 2), which is mitigated by an external post-hoc check in `RainterpreterParser.sol` but not within this library itself. If this library were used by any caller that does not apply the `checkParseMemoryOverflow` modifier, 16-bit pointer truncation could corrupt the parser's linked list structures, leading to incorrect bytecode generation or reads from arbitrary memory.
