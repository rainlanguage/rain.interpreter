# Pass 1: Security Review -- LibParse.sol and LibParseState.sol

**Agent:** A10
**Files:**
- `src/lib/parse/LibParse.sol`
- `src/lib/parse/LibParseState.sol`
**Date:** 2026-03-07

## Evidence of Thorough Reading

### LibParse.sol

**Library:** `LibParse` (line 75)

**Constants:**
| Name | Line | Value | Description |
|---|---|---|---|
| `SUB_PARSER_BYTECODE_HEADER_SIZE` | 59 | 5 | Fixed header size for sub-parser bytecode |
| `MAX_PAREN_OFFSET` | 66 | 59 | Maximum paren offset before overflow |

**Functions:**
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `parseWord(uint256, uint256, uint256)` | 106 | internal | pure |
| `parseLHS(ParseState memory, uint256, uint256)` | 142 | internal | pure |
| `parseRHS(ParseState memory, uint256, uint256)` | 220 | internal | view |
| `parse(ParseState memory)` | 435 | internal | view |

**Imports (lines 5-54):**
- `LibPointer`, `Pointer` from rain.solmem
- `LibMemCpy` from rain.solmem
- Character mask constants from rain.string (`CMASK_COMMENT_HEAD`, `CMASK_EOS`, `CMASK_EOL`, `CMASK_LITERAL_HEAD`, `CMASK_WHITESPACE`, `CMASK_RIGHT_PAREN`, `CMASK_LEFT_PAREN`, `CMASK_RHS_WORD_TAIL`, `CMASK_RHS_WORD_HEAD`, `CMASK_LHS_RHS_DELIMITER`, `CMASK_LHS_STACK_TAIL`, `CMASK_LHS_STACK_HEAD`, `CMASK_IDENTIFIER_HEAD`)
- `LibParseChar` from rain.string
- `LibParseMeta` from rain.interpreter.interface
- `LibParseOperand`
- `OperandV2`, `OPCODE_STACK`, `OPCODE_UNKNOWN` from IInterpreterV4
- `LibParseStackName`
- Custom errors: `UnexpectedRHSChar`, `UnexpectedRightParen`, `WordSize`, `DuplicateLHSItem`, `ParserOutOfBounds`, `ExpectedLeftParen`, `UnexpectedLHSChar`, `MissingFinalSemi`, `UnexpectedComment`, `ParenOverflow`, `LHSItemCountOverflow`
- `LibParseState`, `ParseState`, FSM constants
- `LibParsePragma`, `LibParseInterstitial`, `LibParseError`, `LibSubParse`
- `LibBytes`, `LibBytes32Array` from rain.solmem

**Using directives (lines 76-87):** LibPointer, LibParseStackName, LibParseState, LibParseInterstitial, LibParseError, LibParseMeta, LibParsePragma, LibParse, LibParseOperand, LibSubParse, LibBytes, LibBytes32Array

**Errors referenced:** `UnexpectedRHSChar`, `UnexpectedRightParen`, `WordSize`, `DuplicateLHSItem`, `ParserOutOfBounds`, `ExpectedLeftParen`, `UnexpectedLHSChar`, `MissingFinalSemi`, `UnexpectedComment`, `ParenOverflow`, `LHSItemCountOverflow`

---

### LibParseState.sol

**Library:** `LibParseState` (line 194)

**Struct:** `ParseState` (line 162), 18 fields:
- `activeSourcePtr` (uint256)
- `topLevel0` (uint256)
- `topLevel1` (uint256)
- `parenTracker0` (uint256)
- `parenTracker1` (uint256)
- `lineTracker` (uint256)
- `subParsers` (bytes32)
- `sourcesBuilder` (uint256)
- `fsm` (uint256)
- `stackNames` (uint256)
- `stackNameBloom` (uint256)
- `constantsBuilder` (uint256)
- `constantsBloom` (bytes32)
- `literalParsers` (bytes)
- `operandHandlers` (bytes)
- `operandValues` (bytes32[])
- `stackTracker` (ParseStackTracker)
- `data` (bytes)
- `meta` (bytes)

**Constants:**
| Name | Line | Value | Description |
|---|---|---|---|
| `EMPTY_ACTIVE_SOURCE` | 32 | 0x20 | Initial active source state |
| `FSM_YANG_MASK` | 36 | 1 | Bit 0: yang/yin state |
| `FSM_WORD_END_MASK` | 39 | 1 << 1 | Bit 1: word end state |
| `FSM_ACCEPTING_INPUTS_MASK` | 42 | 1 << 2 | Bit 2: accepting inputs |
| `FSM_ACTIVE_SOURCE_MASK` | 46 | 1 << 3 | Bit 3: active source |
| `FSM_DEFAULT` | 52 | FSM_ACCEPTING_INPUTS_MASK | Default FSM state |
| `OPERAND_VALUES_LENGTH` | 63 | 4 | Fixed operand values array length |
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | 67 | 0x20 | Struct byte offset of topLevel0 |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | 71 | 0x21 | Struct byte offset of topLevel0 data region |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | 75 | 0x60 | Struct byte offset of parenTracker0 |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | 79 | 0xa0 | Struct byte offset of lineTracker |
| `MAX_STACK_RHS_OFFSET` | 85 | 0x3f | Maximum RHS offset value |

**Functions:**
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `newActiveSourcePointer(uint256)` | 210 | internal | pure |
| `resetSource(ParseState memory)` | 231 | internal | pure |
| `newState(bytes, bytes, bytes, bytes)` | 257 | internal | pure |
| `pushSubParser(ParseState memory, uint256, bytes32)` | 318 | internal | pure |
| `exportSubParsers(ParseState memory)` | 338 | internal | pure |
| `snapshotSourceHeadToLineTracker(ParseState memory)` | 367 | internal | pure |
| `endLine(ParseState memory, uint256)` | 402 | internal | pure |
| `highwater(ParseState memory)` | 528 | internal | pure |
| `constantValueBloom(bytes32)` | 553 | internal | pure |
| `pushConstantValue(ParseState memory, bytes32)` | 561 | internal | pure |
| `pushLiteral(ParseState memory, uint256, uint256)` | 591 | internal | view |
| `pushOpToSource(ParseState memory, uint256, OperandV2)` | 666 | internal | pure |
| `endSource(ParseState memory)` | 773 | internal | pure |
| `buildBytecode(ParseState memory)` | 915 | internal | pure |
| `buildConstants(ParseState memory)` | 1009 | internal | pure |
| `checkParseMemoryOverflow()` | 1059 | internal | pure |

**Imports (lines 5-28):**
- `OperandV2`, `OPCODE_CONSTANT` from IInterpreterV4
- `LibParseStackTracker`, `ParseStackTracker`
- `Pointer` from rain.solmem
- `LibMemCpy` from rain.solmem
- `LibUint256Array` from rain.solmem
- Custom errors: `DanglingSource`, `MaxSources`, `ParseMemoryOverflow`, `ParseStackOverflow`, `UnclosedLeftParen`, `ExcessRHSItems`, `ExcessLHSItems`, `NotAcceptingInputs`, `UnsupportedLiteralType`, `InvalidSubParser`, `OpcodeIOOverflow`, `SourceItemOpsOverflow`, `SourceTotalOpsOverflow`, `ParenInputOverflow`, `LineRHSItemsOverflow`
- `LibParseLiteral`
- `LibParseError`

---

## Security Checklist Review

### Memory safety
- **`parseWord` (LibParse.sol, line 117):** `mload(cursor)` reads 32 bytes which may extend past `end` of input data. This is safe because: (1) `iEnd` is capped to `remaining` so the loop only examines valid bytes, and (2) the shift-based scrub at lines 123-124 zeroes out any bytes beyond the word length. Extra bytes read from adjacent memory objects are never used.
- **`newActiveSourcePointer` (LibParseState.sol, lines 213-219):** Aligns to 32 bytes and bumps free memory pointer. NatSpec correctly notes this is safe because `checkParseMemoryOverflow` keeps allocations below 0x10000.
- **`pushOpToSource` (LibParseState.sol, lines 659-665):** NatSpec documents that opcode must fit in 8 bits and operand in 16 bits. Reviewed all callers: `lookupWord` returns an 8-bit index, operand handlers enforce `uint16` bounds via `OperandOverflow`, `OPCODE_STACK`/`OPCODE_CONSTANT`/`OPCODE_UNKNOWN` are all <= 0xFF, stack name indices are 16-bit. For `OPCODE_UNKNOWN`, the operand is a memory pointer, which `checkParseMemoryOverflow` constrains to < 0x10000 (16 bits). All callers satisfy the documented preconditions.
- **`endSource` assembly (LibParseState.sol, lines 800-893):** Uses `mstore` to copy 32 bytes at a time from source LL nodes. May write up to 28 bytes of garbage past valid data. This is safe because: (1) the `length` field correctly bounds valid data, (2) subsequent copies overwrite garbage, and (3) the free memory pointer is rounded up to 32-byte alignment.
- **16-bit pointer system:** All linked list structures (sources builder, constants builder, paren tracker, line tracker, stack names, sub parsers) pack memory pointers into 16 bits. `checkParseMemoryOverflow` (line 1059) enforces the invariant that the free memory pointer stays below 0x10000, preventing silent pointer truncation.

### Input validation
- **Rainlang text:** All character processing uses 128-bit bitmask checks. Bytes above 0x7F (non-ASCII) never match any mask and are rejected via `UnexpectedLHSChar` or `UnexpectedRHSChar`. The library header documents this (lines 71-74).
- **Sub parser addresses:** `pushSubParser` (line 319) validates that the address fits in 160 bits.
- **LHS item count:** Overflow check at LibParse.sol line 182 prevents the byte counters in `topLevel1` and `lineTracker` from silently wrapping.
- **Paren depth:** `MAX_PAREN_OFFSET` check at LibParse.sol line 351 prevents paren tracker overflow.
- **Line RHS items:** `snapshotSourceHeadToLineTracker` (line 386) checks for overflow beyond 14 line-level top-level items.

### Arithmetic safety
- All arithmetic in `unchecked` blocks is bounded by structural limits (memory < 0x10000, byte-sized counters with explicit overflow checks, limited paren depth).
- `constantsBuilder` height (16-bit) cannot overflow because each constant costs 0x40 bytes of memory, limiting total constants to ~1024 before `checkParseMemoryOverflow` triggers.

### Error handling
- All reverts use custom errors (no string messages). Verified: `UnexpectedRHSChar`, `UnexpectedRightParen`, `WordSize`, `DuplicateLHSItem`, `ParserOutOfBounds`, `ExpectedLeftParen`, `UnexpectedLHSChar`, `MissingFinalSemi`, `UnexpectedComment`, `ParenOverflow`, `LHSItemCountOverflow`, `DanglingSource`, `MaxSources`, `ParseMemoryOverflow`, `ParseStackOverflow`, `UnclosedLeftParen`, `ExcessRHSItems`, `ExcessLHSItems`, `NotAcceptingInputs`, `UnsupportedLiteralType`, `InvalidSubParser`, `OpcodeIOOverflow`, `SourceItemOpsOverflow`, `SourceTotalOpsOverflow`, `ParenInputOverflow`, `LineRHSItemsOverflow`.

### Assembly blocks
- All assembly blocks are marked `"memory-safe"`.
- Pointer arithmetic is correct for the big-endian memory layout used by Solidity.
- The `pushOpToSource` paren tracker assembly (lines 700-737) correctly increments the parent group counter, zeros the child counter, and stores the operand byte pointer.
- The right-paren handling in `parseRHS` (LibParse.sol lines 373-388) correctly reads the input counter from the closed group and writes it to the IO byte of the opcode that opened the group.

---

## Findings

### A10-1 (INFO): Off-by-one in MAX_STACK_RHS_OFFSET allows word counter to overlap LHS byte

**Severity:** INFO

**Affected lines:** LibParseState.sol line 85 (`MAX_STACK_RHS_OFFSET = 0x3f`) and line 543 (`>= MAX_STACK_RHS_OFFSET`).

**Description:**

The `topLevel0` field (32 bytes at struct offset 0x20) stores the RHS offset counter in its high byte and per-word ops counters in bytes 1-31 (offsets 0-30). The `topLevel1` field (32 bytes at struct offset 0x40) stores per-word ops counters in bytes 0-30 (offsets 31-61) and the per-source LHS item count in byte 31 (the low byte, accessed via `state.topLevel1 & 0xFF`).

The word counter for RHS offset N is located at memory address `state + 0x20 + N + 1`. For offset 62 (N=62), this is `state + 0x5f`, which is exactly the LHS item count byte in `topLevel1`.

`MAX_STACK_RHS_OFFSET` is `0x3f` (63). The check at line 543 is `newStackRHSOffset >= 0x3f`, which allows offset 62 (since 62 < 63). If offset 62 is reached, `pushOpToSource` writes a word counter at the LHS byte location, corrupting it.

In practice, this is unexploitable because `highwater` (called immediately after `pushOpToSource` for stack references and literals, or when the paren closes for word opcodes) will increment the offset to 63 and revert via `ParseStackOverflow`, undoing the corruption. The corrupted LHS byte is never read between the write and the revert because:
1. LHS parsing for the current line is complete before RHS parsing starts.
2. New lines cannot begin inside paren groups.
3. `pushOpToSource` itself does not read `topLevel1 & 0xFF`.

Despite being practically unexploitable, the off-by-one is a latent defect: `MAX_STACK_RHS_OFFSET` should be `0x3e` (62) to cleanly prevent the overlap rather than relying on the subsequent revert.
