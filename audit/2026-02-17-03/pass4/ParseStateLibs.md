# Pass 4: Code Quality — Parse State Libraries

Agent A23. Files reviewed:
1. `src/lib/parse/LibParseStackTracker.sol`
2. `src/lib/parse/LibParseState.sol`
3. `src/lib/parse/LibSubParse.sol`

---

## Evidence of Thorough Reading

### File 1: `src/lib/parse/LibParseStackTracker.sol`

**Library name:** `LibParseStackTracker`

**User-defined type:**
- `ParseStackTracker` (line 7) — wraps `uint256`

**Functions:**
| Function | Line |
|---|---|
| `pushInputs(ParseStackTracker, uint256)` | 19 |
| `push(ParseStackTracker, uint256)` | 41 |
| `pop(ParseStackTracker, uint256)` | 68 |

**Errors/events/structs:** None defined locally. Imports `ParseStackUnderflow` and `ParseStackOverflow` from `ErrParse.sol`.

---

### File 2: `src/lib/parse/LibParseState.sol`

**Library name:** `LibParseState`

**Struct:**
- `ParseState` (line 135) — 19 fields

**File-level constants:**
| Constant | Line | Value |
|---|---|---|
| `EMPTY_ACTIVE_SOURCE` | 31 | `0x20` |
| `FSM_YANG_MASK` | 33 | `1` |
| `FSM_WORD_END_MASK` | 34 | `1 << 1` |
| `FSM_ACCEPTING_INPUTS_MASK` | 35 | `1 << 2` |
| `FSM_ACTIVE_SOURCE_MASK` | 39 | `1 << 3` |
| `FSM_DEFAULT` | 45 | `FSM_ACCEPTING_INPUTS_MASK` |
| `OPERAND_VALUES_LENGTH` | 56 | `4` |
| `PARSE_STATE_TOP_LEVEL0_OFFSET` | 60 | `0x20` |
| `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET` | 64 | `0x21` |
| `PARSE_STATE_PAREN_TRACKER0_OFFSET` | 68 | `0x60` |
| `PARSE_STATE_LINE_TRACKER_OFFSET` | 72 | `0xa0` |

**Functions:**
| Function | Line |
|---|---|
| `newActiveSourcePointer(uint256)` | 181 |
| `resetSource(ParseState memory)` | 202 |
| `newState(bytes, bytes, bytes, bytes)` | 228 |
| `pushSubParser(ParseState memory, uint256, bytes32)` | 289 |
| `exportSubParsers(ParseState memory)` | 309 |
| `snapshotSourceHeadToLineTracker(ParseState memory)` | 338 |
| `endLine(ParseState memory, uint256)` | 373 |
| `highwater(ParseState memory)` | 499 |
| `constantValueBloom(bytes32)` | 524 |
| `pushConstantValue(ParseState memory, bytes32)` | 532 |
| `pushLiteral(ParseState memory, uint256, uint256)` | 562 |
| `pushOpToSource(ParseState memory, uint256, OperandV2)` | 637 |
| `endSource(ParseState memory)` | 744 |
| `buildBytecode(ParseState memory)` | 877 |
| `buildConstants(ParseState memory)` | 971 |
| `checkParseMemoryOverflow()` | 1021 |

**Errors/events/structs defined locally:** `ParseState` struct only. All errors imported from `ErrParse.sol`.

---

### File 3: `src/lib/parse/LibSubParse.sol`

**Library name:** `LibSubParse`

**Functions:**
| Function | Line |
|---|---|
| `subParserContext(uint256, uint256)` | 48 |
| `subParserConstant(uint256, bytes32)` | 96 |
| `subParserExtern(IInterpreterExternV4, uint256, uint256, OperandV2, uint256)` | 161 |
| `subParseWordSlice(ParseState memory, uint256, uint256)` | 215 |
| `subParseWords(ParseState memory, bytes memory)` | 323 |
| `subParseLiteral(ParseState memory, uint256, uint256, uint256, uint256)` | 349 |
| `consumeSubParseWordInputData(bytes memory, bytes memory, bytes memory)` | 407 |
| `consumeSubParseLiteralInputData(bytes memory)` | 438 |

**Errors/events/structs:** None defined locally. Imports from `ErrParse.sol` and `ErrSubParse.sol`.

---

## Findings

### A23-1: Incorrect inline comments in `newState` constructor (LOW)

**File:** `src/lib/parse/LibParseState.sol`, lines 258-261

The inline comments in the `ParseState` constructor literal are misaligned with the struct field order. The struct field order after `stackNameBloom` is: `constantsBuilder`, `constantsBloom`, `literalParsers`, ...

But the comments read:
```solidity
// stackNameBloom
0,
// literalBloom       <-- should be "constantsBuilder"
0,
// constantsBuilder   <-- should be "constantsBloom"
0,
// literalParsers
literalParsers,
```

Two issues:
1. The comment `// literalBloom` (line 258) refers to a field that does not exist in the `ParseState` struct. The actual field is `constantsBloom`.
2. The comment `// constantsBuilder` (line 260) is one position too late; the actual `constantsBuilder` field is at the position labeled `// literalBloom`.

---

### A23-2: Stale function name in comment (LOW)

**File:** `src/lib/parse/LibParseState.sol`, line 235

The comment `// (will be built in `newActiveSource`)` references a function that does not exist. The actual function is `newActiveSourcePointer` (line 181). The comment should read `newActiveSourcePointer` or, more precisely, it is built via `resetSource` which calls `newActiveSourcePointer`.

---

### A23-3: FSM NatSpec does not match defined constants (MEDIUM)

**File:** `src/lib/parse/LibParseState.sol`, lines 88-93

The NatSpec for the `fsm` field in the `ParseState` struct documents five bits:
```
- bit 0: LHS/RHS => 0 = LHS, 1 = RHS
- bit 1: yang/yin => 0 = yin, 1 = yang
- bit 2: word end => 0 = not end, 1 = end
- bit 3: accepting inputs => 0 = not accepting, 1 = accepting
- bit 4: interstitial => 0 = not interstitial, 1 = interstitial
```

The actual defined constants are:
```
bit 0: FSM_YANG_MASK = 1           (yang/yin)
bit 1: FSM_WORD_END_MASK = 1 << 1  (word end)
bit 2: FSM_ACCEPTING_INPUTS_MASK = 1 << 2  (accepting inputs)
bit 3: FSM_ACTIVE_SOURCE_MASK = 1 << 3     (active source)
```

Discrepancies:
1. The NatSpec lists "LHS/RHS" at bit 0 and "interstitial" at bit 4, but no corresponding `FSM_LHS_RHS_MASK` or `FSM_INTERSTITIAL_MASK` constants exist anywhere in the codebase.
2. The NatSpec omits `FSM_ACTIVE_SOURCE_MASK` (bit 3), which is used extensively.
3. All bit positions are shifted by one compared to reality (yang is documented at bit 1 but is actually bit 0, etc.).

This is rated MEDIUM rather than LOW because incorrect documentation of bit-packed state flags can lead developers to introduce bugs when modifying the FSM logic.

---

### A23-4: Magic number `0x3f` in `highwater` (LOW)

**File:** `src/lib/parse/LibParseState.sol`, line 514

```solidity
if (newStackRHSOffset >= 0x3f) {
    revert ParseStackOverflow();
}
```

The value `0x3f` (63) represents the maximum number of top-level stack items that can be tracked across `topLevel0` (31 data bytes) plus `topLevel1` (31 data bytes) = 62 data bytes. The limit of 63 (not 62) accounts for the counter byte consuming one byte of `topLevel0`. This relationship is non-obvious and would benefit from a named constant with a comment explaining the derivation.

---

### A23-5: Magic number `0x10` for IO byte in sub-parser helpers (INFO)

**File:** `src/lib/parse/LibSubParse.sol`, lines 71, 124

```solidity
// 0 inputs 1 output.
mstore8(add(bytecode, 0x21), 0x10)
```

The value `0x10` encodes "0 inputs, 1 output" as a packed nibble pair (high nibble = outputs, low nibble = inputs). While the inline comment explains the meaning, a named constant would be more self-documenting and consistent with how other magic values in the parse system are handled (e.g., `OPCODE_CONSTANT`, `OPCODE_CONTEXT`).

---

### A23-6: Repeated bytecode allocation pattern across three functions (INFO)

**File:** `src/lib/parse/LibSubParse.sol`, lines 58-76, 107-131, 178-193

The functions `subParserContext`, `subParserConstant`, and `subParserExtern` each contain nearly identical inline assembly for allocating a 4-byte unaligned bytecode buffer. The pattern is:
```yul
bytecode := mload(0x40)
mstore(0x40, add(bytecode, 0x24))
// ... write 4 bytes ...
mstore(bytecode, 4)
```

Each has the same "UNALIGNED allocation" comment block. While the slight differences in what gets written into the 4 bytes makes a shared helper non-trivial, the repetition increases maintenance burden. If the allocation convention changes, three sites must be updated.

---

### A23-7: `subParseWordSlice` writes to the source header before checking sub-parser success (INFO)

**File:** `src/lib/parse/LibSubParse.sol`, lines 243-259

In the `subParseWordSlice` function, the header of the sub-parse data is mutated in-place (writing `constantsHeight` and `ioByte` into the data buffer) before calling `subParser.subParseWord2(data)`. If the sub-parser call fails (returns `success = false`) and the loop continues to the next sub-parser, the same `data` pointer is reused but the header has already been written. This is correct because the header is overwritten each iteration regardless, but the code structure could be clearer about this -- the header write is inside the `while (deref != 0)` loop, which is the correct placement. No bug, just an observation about readability.

---

### A23-8: Inconsistent `@dev` tag usage in NatSpec across assigned files (INFO)

**File:** `src/lib/parse/LibParseState.sol` (lines 29-72) vs `src/lib/parse/LibSubParse.sol` (lines 25-35) vs `src/lib/parse/LibParseStackTracker.sol`

File-level constants in `LibParseState.sol` use `/// @dev` for some NatSpec blocks (lines 29, 37, 41, 47, 58-72) but the library-level and function-level NatSpec in the same file and in `LibSubParse.sol` use plain `///` without `@dev`. The `LibSubParse` library has a `@title` tag (line 25) while `LibParseState` and `LibParseStackTracker` do not. This is a minor style inconsistency.

Per user preferences, `@notice` is not used, so plain `///` is the preferred form. The `@dev` usage on constants is acceptable but creates a visual inconsistency with the function-level NatSpec in the same file.

---

### A23-9: `endLine` cyclomatic complexity suppression (INFO)

**File:** `src/lib/parse/LibParseState.sol`, line 372

```solidity
//slither-disable-next-line cyclomatic-complexity
function endLine(ParseState memory state, uint256 cursor) internal pure {
```

The `endLine` function is the most complex function in these three files, with nested loops, multiple conditional branches, and mixed Solidity/assembly. The slither suppression acknowledges this. While this is not a defect per se, the function combines at least three distinct responsibilities: paren balance validation, LHS/RHS item reconciliation, and opcode IO computation with stack tracking. Splitting these into sub-functions would improve readability and testability, though the gas cost of additional function calls in a parse-time-only context is a valid counterargument.

---

## Summary

| ID | Severity | File | Description |
|---|---|---|---|
| A23-1 | LOW | LibParseState.sol | Incorrect inline comments in `newState` constructor |
| A23-2 | LOW | LibParseState.sol | Stale function name `newActiveSource` in comment |
| A23-3 | MEDIUM | LibParseState.sol | FSM NatSpec does not match defined constants |
| A23-4 | LOW | LibParseState.sol | Magic number `0x3f` should be a named constant |
| A23-5 | INFO | LibSubParse.sol | Magic number `0x10` for IO byte |
| A23-6 | INFO | LibSubParse.sol | Repeated bytecode allocation pattern |
| A23-7 | INFO | LibSubParse.sol | Header mutation before sub-parser success check |
| A23-8 | INFO | All three files | Inconsistent `@dev` tag and `@title` usage |
| A23-9 | INFO | LibParseState.sol | `endLine` high cyclomatic complexity |
