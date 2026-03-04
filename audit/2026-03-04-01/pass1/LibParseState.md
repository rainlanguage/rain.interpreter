# A109 -- Pass 1 (Security) -- LibParseState.sol

**Agent**: A109
**File**: `src/lib/parse/LibParseState.sol`
**Commit**: `441e9b5b`

## Evidence of Thorough Reading

### Library Name
- `LibParseState` (line 194)

### Struct / Type Definitions
- `ParseState` (line 162) -- 18-field struct holding all parser state

### Constants Defined
| Constant | Line | Value |
|---|---|---|
| `EMPTY_ACTIVE_SOURCE` | 32 | `0x20` |
| `FSM_YANG_MASK` | 36 | `1` |
| `FSM_WORD_END_MASK` | 39 | `1 << 1` |
| `FSM_ACCEPTING_INPUTS_MASK` | 42 | `1 << 2` |
| `FSM_ACTIVE_SOURCE_MASK` | 46 | `1 << 3` |
| `FSM_DEFAULT` | 52 | `FSM_ACCEPTING_INPUTS_MASK` |
| `OPERAND_VALUES_LENGTH` | 63 | `4` |
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | 67 | `0x20` |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | 71 | `0x21` |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | 75 | `0x60` |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | 79 | `0xa0` |
| `MAX_STACK_RHS_OFFSET` | 85 | `0x3f` |

### Errors (imported from ErrParse.sol)
`DanglingSource`, `MaxSources`, `ParseMemoryOverflow`, `ParseStackOverflow`,
`UnclosedLeftParen`, `ExcessRHSItems`, `ExcessLHSItems`, `NotAcceptingInputs`,
`UnsupportedLiteralType`, `InvalidSubParser`, `OpcodeIOOverflow`,
`SourceItemOpsOverflow`, `SourceTotalOpsOverflow`, `ParenInputOverflow`,
`LineRHSItemsOverflow`

### Functions
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `newActiveSourcePointer` | 210 | internal | pure |
| `resetSource` | 231 | internal | pure |
| `newState` | 257 | internal | pure |
| `pushSubParser` | 318 | internal | pure |
| `exportSubParsers` | 338 | internal | pure |
| `snapshotSourceHeadToLineTracker` | 367 | internal | pure |
| `endLine` | 402 | internal | pure |
| `highwater` | 528 | internal | pure |
| `constantValueBloom` | 553 | internal | pure |
| `pushConstantValue` | 561 | internal | pure |
| `pushLiteral` | 591 | internal | view |
| `pushOpToSource` | 666 | internal | pure |
| `endSource` | 773 | internal | pure |
| `buildBytecode` | 915 | internal | pure |
| `buildConstants` | 1009 | internal | pure |
| `checkParseMemoryOverflow` | 1059 | internal | pure |

---

## Security Review

### Assembly Memory Safety

All assembly blocks are marked `memory-safe`. Verified each block:

1. **`newActiveSourcePointer`** (line 213): Aligns free pointer to 32 bytes, writes one word, bumps free pointer. Correct -- alignment ensures `and(add(mload(0x40), 0x1F), not(0x1F))` cannot wrap (bounded by `checkParseMemoryOverflow` to < 0x10000). The write to `oldActiveSourcePointer` at address 0 when called from `resetSource(0)` is documented and harmless (INFO finding from prior audit A43-2, confirmed benign).

2. **`pushSubParser`** (line 326): Allocates one word, stores tail, bumps free pointer. Correct.

3. **`exportSubParsers`** (line 342): Allocates dynamically based on linked list length. Free pointer updated to `cursor` after the loop. Correct -- each iteration writes one word and advances cursor.

4. **`snapshotSourceHeadToLineTracker`** (line 372): Reads from state fields at hardcoded offsets. Writes back to lineTracker. Overflow check on line 386 ensures offset <= 0xF0 before the value is used for `shl`. When offset > 0xF0, `shl` produces 0, so the write is a no-op, and the function reverts afterward.

5. **`endLine`** (lines 407, 478, 488, 493, 510): Multiple assembly blocks reading/writing into the active source and state. All operate on state memory at known offsets. The linked-list jump at line 487-490 (`itemSourceHead % 0x20 == 0x1c`) correctly follows the forward pointer when reaching the boundary of a 32-byte source slot.

6. **`highwater`** (line 531): Reads paren offset and conditionally increments the RHS offset counter via `mstore8`. Overflow checked afterward (>= 0x3f).

7. **`pushConstantValue`** (line 565): Allocates two words (0x40 bytes), stores tail pointer and value. Correct.

8. **`pushOpToSource`** (lines 682, 701, 756): Complex block that increments per-item ops counter, updates paren tracker, and writes opcode+operand into source. Each counter has an overflow guard (`SourceItemOpsOverflow`, `ParenInputOverflow`).

9. **`endSource`** (line 800): Large block that traverses the linked list of source slots, reorders opcodes LTR, writes source prefix. `totalOpsOverflow` checked after the assembly block. Free pointer properly rounded up to 32-byte alignment.

10. **`buildBytecode`** (lines 939, 991): Allocates output buffer, writes source count, relative pointers, and copies source data. Free pointer properly allocated and aligned.

11. **`buildConstants`** (line 1013): Allocates output array, fills in reverse order from linked list. Loop termination correct: writes exactly `constantsHeight` items. Free pointer set to `cursor + 0x20` which is one word past the last element (correct).

12. **`checkParseMemoryOverflow`** (line 1061): Simple read of free pointer. Correct.

### Bounds Checks

- **Per-item ops**: Bounded to 255 by `SourceItemOpsOverflow` check in `pushOpToSource` (line 686-691).
- **Total ops per source**: Bounded to 255 by `SourceTotalOpsOverflow` check in `endSource` (line 877/895-896).
- **Stack RHS offset**: Bounded to 62 by `ParseStackOverflow` check in `highwater` (line 543-544).
- **Line RHS items**: Bounded to 14 by `LineRHSItemsOverflow` check in `snapshotSourceHeadToLineTracker` (line 386/391-392).
- **Paren input counter**: Bounded to 255 by `ParenInputOverflow` check in `pushOpToSource` (line 728/739-740).
- **Source count**: Bounded to 15 by `MaxSources` check in `endSource` (line 785-786).
- **Memory overflow**: Bounded to < 0x10000 by `checkParseMemoryOverflow` post-condition in `RainterpreterParser`.
- **Opcode IO**: Bounded to 15 inputs / 15 outputs by `OpcodeIOOverflow` check in `endLine` (line 507-508).

### Operand / Opcode Width

`pushOpToSource` documents that opcode must fit in 8 bits and operand in 16 bits. Callers verified:
- `LibParse` calls with `opcodeIndex` (from word lookup, bounded by meta table size).
- `OPCODE_CONSTANT`, `OPCODE_STACK`, `OPCODE_UNKNOWN` are all small constants.
- Operand handlers (`handleOperandSingleFull`, etc.) check `operandUint > type(uint16).max` and revert with `OperandOverflow`.

### State Initialization

`newState` zeroes all fields and delegates to `resetSource` for per-source fields. `resetSource` zeroes `topLevel0`, `topLevel1`, `parenTracker0`, `parenTracker1`, `lineTracker`, `stackNames`, `stackNameBloom`, `stackTracker`, and allocates a fresh active source. Correct.

### Linked List Integrity

The 16-bit pointer constraint is enforced by `checkParseMemoryOverflow` as a post-condition. As noted in prior audit A43-4, if memory exceeds 0x10000 during parsing, pointer truncation may cause incorrect behavior *within* the parse call, but the entire transaction reverts, so no corrupted state persists. This is the documented and accepted design.

---

## Findings

### A109-1 (INFO): `buildConstants` comment references nonexistent "fingerprint"

**Location**: `buildConstants()`, lines 1035-1038

**Description**: The loop post-condition comment reads:

```solidity
// tail pointer in tail keys is the low 16 bits under the
// fingerprint, which is different from the tail pointer in
// the constants builder, where it sits above the constants
// height.
```

The word "fingerprint" is misleading. In `pushConstantValue`, each linked list node stores a raw tail pointer (first word) and a constant value (second word). There is no fingerprint stored in the nodes. This was previously flagged as A43-3 in the prior audit.

**Impact**: None -- code is correct. The comment may confuse future auditors.

**Severity**: INFO

### A109-2 (INFO): `newActiveSourcePointer(0)` writes to scratch space

**Location**: `newActiveSourcePointer()`, line 222; called from `resetSource()` at line 232

**Description**: When `resetSource` calls `newActiveSourcePointer(0)`, line 222 writes to memory address 0 (Solidity scratch space). This was previously flagged as A43-2. The write is benign because the node at address 0 is never traversed -- the linked list traversal in `endSource` terminates when the tail pointer is 0.

**Severity**: INFO

---

No new LOW+ findings. All prior findings from the A43 audit (SourceTotalOpsOverflow, scratch space write, fingerprint comment, post-condition check pattern) have been either fixed or confirmed as INFO-level. The overflow guards, bounds checks, memory management, and linked list operations are all correct.
