# Pass 3: Documentation — LibParseStackTracker.sol & LibParseState.sol

Agent: A25

---

## File 1: `src/lib/parse/LibParseStackTracker.sol`

### Evidence of thorough reading

**Library:** `LibParseStackTracker` (line 9)

**User-defined type:**
- `ParseStackTracker` (line 7) — `uint256`

**Functions:**
- `pushInputs(ParseStackTracker, uint256)` — line 19
- `push(ParseStackTracker, uint256)` — line 41
- `pop(ParseStackTracker, uint256)` — line 68

**Errors (imported):**
- `ParseStackUnderflow` (from `ErrParse.sol`)
- `ParseStackOverflow` (from `ErrParse.sol`)

**Structs/events:** None

### Findings

#### A25-1 [LOW] `ParseStackTracker` user-defined type has no NatSpec

**File:** `src/lib/parse/LibParseStackTracker.sol`, line 7

The user-defined value type `ParseStackTracker` is declared with no NatSpec documentation. The type packs three fields into a `uint256` (current height in bits 0-7, inputs in bits 8-15, max/highwater in bits 16+), but this layout is never documented on the type itself. Readers must infer the layout from the function implementations.

```solidity
type ParseStackTracker is uint256;
```

Should have NatSpec documenting:
- What the type represents (tracked parse stack state)
- The packed layout: bits 0-7 = current height, bits 8-15 = inputs count, bits 16+ = high watermark

---

## File 2: `src/lib/parse/LibParseState.sol`

### Evidence of thorough reading

**Struct:** `ParseState` (line 135)

**Library:** `LibParseState` (line 165)

**Constants:**
- `EMPTY_ACTIVE_SOURCE` (line 31) — `0x20`
- `FSM_YANG_MASK` (line 33) — `1`
- `FSM_WORD_END_MASK` (line 34) — `1 << 1`
- `FSM_ACCEPTING_INPUTS_MASK` (line 35) — `1 << 2`
- `FSM_ACTIVE_SOURCE_MASK` (line 39) — `1 << 3`
- `FSM_DEFAULT` (line 45) — `FSM_ACCEPTING_INPUTS_MASK`
- `OPERAND_VALUES_LENGTH` (line 56) — `4`
- `PARSE_STATE_TOP_LEVEL0_OFFSET` (line 60) — `0x20`
- `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` (line 64) — `0x21`
- `PARSE_STATE_PAREN_TRACKER0_OFFSET` (line 68) — `0x60`
- `PARSE_STATE_LINE_TRACKER_OFFSET` (line 72) — `0xa0`

**Functions:**
- `newActiveSourcePointer(uint256)` — line 181
- `resetSource(ParseState memory)` — line 202
- `newState(bytes memory, bytes memory, bytes memory, bytes memory)` — line 228
- `pushSubParser(ParseState memory, uint256, bytes32)` — line 289
- `exportSubParsers(ParseState memory)` — line 309
- `snapshotSourceHeadToLineTracker(ParseState memory)` — line 338
- `endLine(ParseState memory, uint256)` — line 373
- `highwater(ParseState memory)` — line 499
- `constantValueBloom(bytes32)` — line 524
- `pushConstantValue(ParseState memory, bytes32)` — line 532
- `pushLiteral(ParseState memory, uint256, uint256)` — line 562
- `pushOpToSource(ParseState memory, uint256, OperandV2)` — line 637
- `endSource(ParseState memory)` — line 744
- `buildBytecode(ParseState memory)` — line 877
- `buildConstants(ParseState memory)` — line 971
- `checkParseMemoryOverflow()` — line 1021

**Errors (imported):**
- `DanglingSource`
- `MaxSources`
- `ParseMemoryOverflow`
- `ParseStackOverflow`
- `UnclosedLeftParen`
- `ExcessRHSItems`
- `ExcessLHSItems`
- `NotAcceptingInputs`
- `UnsupportedLiteralType`
- `InvalidSubParser`
- `OpcodeIOOverflow`
- `SourceItemOpsOverflow`
- `ParenInputOverflow`
- `LineRHSItemsOverflow`

**Events/structs:**
- `ParseState` struct (line 135)

### Findings

#### A25-2 [MEDIUM] `ParseState` struct has stale `@param literalBloom` referencing non-existent field

**File:** `src/lib/parse/LibParseState.sol`, line 126

The struct NatSpec at line 126-127 documents `@param literalBloom` but the struct has no field named `literalBloom`. The actual bloom filter field is named `constantsBloom` (line 156). This appears to be a stale documentation reference from a past rename. It misleads readers about what the field is called and what it tracks.

```solidity
/// @param literalBloom A bloom filter of all the literals that have been
/// encountered so far. This is used to quickly dedupe literals.
```

The actual field at line 156 is `constantsBloom`, and the description ("literals") is also inaccurate since the bloom filter tracks constant values, not literals in the broader sense.

#### A25-3 [MEDIUM] `ParseState` struct missing `@param` for 8 fields

**File:** `src/lib/parse/LibParseState.sol`, lines 74-163

The following struct fields have no `@param` tag in the struct-level NatSpec:

1. **`subParsers`** (line 148) — No `@param`. Only has an inline `@dev` comment about assembly offsets.
2. **`stackNameBloom`** (line 154) — No `@param`. Undocumented.
3. **`constantsBloom`** (line 156) — No `@param` matching this field name (the stale `@param literalBloom` at line 126 does not match).
4. **`operandHandlers`** (line 158) — No `@param`. Undocumented.
5. **`operandValues`** (line 159) — No `@param`. Undocumented.
6. **`stackTracker`** (line 160) — No `@param`. Undocumented.
7. **`data`** (line 161) — No `@param`. Undocumented.
8. **`meta`** (line 162) — No `@param`. Undocumented.

Each field should have a `@param` tag describing its purpose and encoding.

#### A25-4 [LOW] Constants `FSM_YANG_MASK` and `FSM_WORD_END_MASK` have no NatSpec

**File:** `src/lib/parse/LibParseState.sol`, lines 33-34

These two FSM mask constants have no `@dev` or `///` documentation, while the other FSM constants (`FSM_ACCEPTING_INPUTS_MASK`, `FSM_ACTIVE_SOURCE_MASK`, `FSM_DEFAULT`) do have comments.

```solidity
uint256 constant FSM_YANG_MASK = 1;
uint256 constant FSM_WORD_END_MASK = 1 << 1;
```

#### A25-5 [LOW] `ParseState.fsm` NatSpec describes bit 1 as "yang/yin" and bit 0 as "LHS/RHS" but code uses bit 0 as `FSM_YANG_MASK`

**File:** `src/lib/parse/LibParseState.sol`, lines 88-93

The struct NatSpec for `fsm` documents:
- bit 0: LHS/RHS
- bit 1: yang/yin
- bit 2: word end
- bit 3: accepting inputs
- bit 4: interstitial

But the constants define:
- `FSM_YANG_MASK = 1` (bit 0)
- `FSM_WORD_END_MASK = 1 << 1` (bit 1)
- `FSM_ACCEPTING_INPUTS_MASK = 1 << 2` (bit 2)
- `FSM_ACTIVE_SOURCE_MASK = 1 << 3` (bit 3)

The documentation says bit 0 is LHS/RHS and bit 1 is yang/yin, but `FSM_YANG_MASK = 1` means yang is bit 0 and `FSM_WORD_END_MASK = 1 << 1` means word end is bit 1. The documented layout does not match the implemented constants. Additionally, the documentation lists "interstitial" at bit 4 but there is no `FSM_INTERSTITIAL_MASK` constant in this file, and `FSM_ACTIVE_SOURCE_MASK` occupies bit 3 which the documentation claims is "accepting inputs" (actually bit 2 per `FSM_ACCEPTING_INPUTS_MASK = 1 << 2`).

This is a documentation accuracy issue -- the bit assignments in NatSpec are out of sync with the actual constant values.

#### A25-6 [LOW] `endLine` function NatSpec is minimal -- missing `@param cursor` description

**File:** `src/lib/parse/LibParseState.sol`, line 371

The `endLine` function NatSpec says `@param cursor The current cursor position for error reporting.` This is adequate but sparse for a function of this complexity (120 lines, multiple error paths). The `@param state` tag says only "The parse state to finalise the current line for" which is accurate but does not hint at the many fields mutated (fsm, lineTracker, topLevel0, stackTracker).

No `@return` tag needed (void function) -- this is fine.

#### A25-7 [INFO] `checkParseMemoryOverflow` function has no `@param` or `@return` tags but needs none

**File:** `src/lib/parse/LibParseState.sol`, line 1021

This function takes no parameters and returns nothing, so the absence of `@param`/`@return` is correct. The NatSpec description is thorough and accurate. No action needed -- included for completeness of the enumeration.

#### A25-8 [LOW] `PARSE_STATE_TOP_LEVEL0_OFFSET` and sibling constants document offsets but not how they were derived

**File:** `src/lib/parse/LibParseState.sol`, lines 58-72

The constants `PARSE_STATE_TOP_LEVEL0_OFFSET` (0x20), `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` (0x21), `PARSE_STATE_PAREN_TRACKER0_OFFSET` (0x60), and `PARSE_STATE_LINE_TRACKER_OFFSET` (0xa0) have NatSpec explaining what they are byte offsets of, but not how those values are derived from the struct layout. Since these offsets are hardcoded and depend on the memory layout of `ParseState`, if the struct field order changes, these constants silently become wrong. A brief NatSpec note explaining the derivation (e.g., "activeSourcePtr is at offset 0x00, topLevel0 is the second field at 0x20") would help maintainers verify correctness.

#### A25-9 [INFO] `newState` function NatSpec accurately describes all parameters and return

**File:** `src/lib/parse/LibParseState.sol`, lines 218-227

The `newState` function has complete NatSpec with `@param` for all four parameters (`data`, `meta`, `operandHandlers`, `literalParsers`) and `@return`. Documentation is accurate. No issues.

#### A25-10 [INFO] All 15 library functions in `LibParseState` have NatSpec

All functions enumerated in the evidence section have `///` NatSpec comments above them with descriptions, `@param` tags for all parameters, and `@return` tags where applicable. The documentation quality varies (some are more detailed than others) but all functions are documented.
