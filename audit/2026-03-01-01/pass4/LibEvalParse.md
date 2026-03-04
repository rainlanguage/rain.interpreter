# Pass 4: Maintainability, Consistency, and Abstractions

**Scope:** LibEval.sol, LibIntegrityCheck.sol, LibInterpreterState.sol,
LibInterpreterStateDataContract.sol, LibParse.sol, LibParseState.sol,
LibParseError.sol, LibParseInterstitial.sol

**Date:** 2026-03-01

---

## Evidence of Thorough Reading

### LibEval.sol (`src/lib/eval/LibEval.sol`)

- **Library:** `LibEval`
- **Imports:** `LibInterpreterState`, `InterpreterState`, `LibMemCpy`, `LibMemoryKV`,
  `MemoryKV`, `LibBytecode`, `Pointer`, `OperandV2`, `StackItem`, `InputsLengthMismatch`
- **Functions:** `evalLoop`, `eval2`
- **Using:** `LibMemoryKV for MemoryKV`
- **Constants:** none (file-level)

### LibIntegrityCheck.sol (`src/lib/integrity/LibIntegrityCheck.sol`)

- **Library:** `LibIntegrityCheck`
- **Struct:** `IntegrityCheckState` (stackIndex, stackMaxIndex, readHighwater,
  constants, opIndex, bytecode)
- **Imports:** `Pointer`, `OpcodeOutOfRange`, `StackAllocationMismatch`,
  `StackOutputsMismatch`, `StackUnderflow`, `StackUnderflowHighwater`,
  `BadOpInputsLength`, `BadOpOutputsLength`, `LibBytecode`, `OperandV2`
- **Functions:** `newState`, `integrityCheck2`
- **Using:** `LibIntegrityCheck for IntegrityCheckState`

### LibInterpreterState.sol (`src/lib/state/LibInterpreterState.sol`)

- **Library:** `LibInterpreterState`
- **Struct:** `InterpreterState` (stackBottoms, constants, sourceIndex, stateKV,
  namespace, store, context, bytecode, fs)
- **Constant:** `STACK_TRACER`
- **Imports:** `Pointer`, `MemoryKV`, `FullyQualifiedNamespace`,
  `IInterpreterStoreV3`, `StackItem`
- **Functions:** `stackBottoms`, `stackTrace`

### LibInterpreterStateDataContract.sol (`src/lib/state/LibInterpreterStateDataContract.sol`)

- **Library:** `LibInterpreterStateDataContract`
- **Imports:** `MemoryKV`, `Pointer`, `LibMemCpy`, `LibBytes`,
  `FullyQualifiedNamespace`, `IInterpreterStoreV3`, `InterpreterState`
- **Functions:** `serializeSize`, `unsafeSerialize`, `unsafeDeserialize`
- **Using:** `LibBytes for bytes`

### LibParse.sol (`src/lib/parse/LibParse.sol`)

- **Library:** `LibParse`
- **Constant:** `SUB_PARSER_BYTECODE_HEADER_SIZE` (5)
- **Imports:** `LibPointer`, `Pointer`, `LibMemCpy`, CMASK_* (12 masks),
  `LibParseChar`, `LibParseMeta`, `LibParseOperand`, `OperandV2`, `OPCODE_STACK`,
  `OPCODE_UNKNOWN`, `LibParseStackName`, error types (8), `LibParseState`,
  `ParseState`, FSM masks (4), `PARSE_STATE_PAREN_TRACKER0_OFFSET`,
  `LibParsePragma`, `LibParseInterstitial`, `LibParseError`, `LibSubParse`,
  `LibBytes`, `LibUint256Array`, `LibBytes32Array`
- **Functions:** `parseWord`, `parseLHS`, `parseRHS`, `parse`
- **Using:** 11 `using` declarations

### LibParseState.sol (`src/lib/parse/LibParseState.sol`)

- **Library:** `LibParseState`
- **Struct:** `ParseState` (19 fields: activeSourcePtr, topLevel0, topLevel1,
  parenTracker0, parenTracker1, lineTracker, subParsers, sourcesBuilder, fsm,
  stackNames, stackNameBloom, constantsBuilder, constantsBloom, literalParsers,
  operandHandlers, operandValues, stackTracker, data, meta)
- **Constants:** `EMPTY_ACTIVE_SOURCE`, `FSM_YANG_MASK`, `FSM_WORD_END_MASK`,
  `FSM_ACCEPTING_INPUTS_MASK`, `FSM_ACTIVE_SOURCE_MASK`, `FSM_DEFAULT`,
  `OPERAND_VALUES_LENGTH`, `PARSE_STATE_TOP_LEVEL0_OFFSET`,
  `PARSE_STATE_TOP_LEVEL0_DATA_OFFSET`, `PARSE_STATE_PAREN_TRACKER0_OFFSET`,
  `PARSE_STATE_LINE_TRACKER_OFFSET`
- **Imports:** `OperandV2`, `OPCODE_CONSTANT`, `LibParseStackTracker`,
  `ParseStackTracker`, `Pointer`, `LibMemCpy`, `LibUint256Array`, error types (14),
  `LibParseLiteral`, `LibParseError`
- **Functions:** `newActiveSourcePointer`, `resetSource`, `newState`,
  `pushSubParser`, `exportSubParsers`, `snapshotSourceHeadToLineTracker`,
  `endLine`, `highwater`, `constantValueBloom`, `pushConstantValue`,
  `pushLiteral`, `pushOpToSource`, `endSource`, `buildBytecode`,
  `buildConstants`, `checkParseMemoryOverflow`
- **Using:** `LibParseState for ParseState`, `LibParseStackTracker for ParseStackTracker`,
  `LibParseError for ParseState`, `LibParseLiteral for ParseState`,
  `LibUint256Array for uint256[]`

### LibParseError.sol (`src/lib/parse/LibParseError.sol`)

- **Library:** `LibParseError`
- **Imports:** `ParseState`
- **Functions:** `parseErrorOffset`, `handleErrorSelector`

### LibParseInterstitial.sol (`src/lib/parse/LibParseInterstitial.sol`)

- **Library:** `LibParseInterstitial`
- **Imports:** `FSM_YANG_MASK`, `ParseState`, CMASK_COMMENT_HEAD,
  CMASK_WHITESPACE, COMMENT_END_SEQUENCE, COMMENT_START_SEQUENCE,
  CMASK_COMMENT_END_SEQUENCE_END, `MalformedCommentStart`, `UnclosedComment`,
  `LibParseError`, `LibParseChar`
- **Functions:** `skipComment`, `skipWhitespace`, `parseInterstitial`
- **Using:** `LibParseError for ParseState`, `LibParseInterstitial for ParseState`

---

## Findings

### P4-EVLP-1: Unused `using` declaration in LibParse.sol [LOW]

**File:** `src/lib/parse/LibParse.sol`, line 80

```solidity
using LibUint256Array for uint256[];
```

`LibParse` declares `using LibUint256Array for uint256[]` but no `uint256[]` variable
in any of its four functions (`parseWord`, `parseLHS`, `parseRHS`, `parse`) calls
any method from `LibUint256Array`. The import of `LibUint256Array` on line 53 is
correspondingly dead code. Dead `using` declarations make it harder to understand
actual data flow and dependencies.

### P4-EVLP-2: Unused return value suppressed with expression statement [LOW]

**File:** `src/lib/parse/LibParse.sol`, lines 155-156

```solidity
(bool exists, uint256 index) = state.pushStackName(word);
(index);
```

The return value `index` from `pushStackName` is captured and then immediately
discarded via the expression statement `(index);`. This pattern suppresses the
compiler warning but obscures intent. The idiomatic Solidity approach is to use
a blank in the destructuring:

```solidity
(bool exists,) = state.pushStackName(word);
```

This is a readability issue -- the `(index);` pattern looks like it might be doing
something to a reader unfamiliar with this codebase pattern.

### P4-EVLP-3: Comment typo "ying" should be "yin" [INFO]

**Files:**
- `src/lib/parse/LibParse.sol`, line 176
- `src/lib/parse/LibParseInterstitial.sol`, line 98

Two comments say "Set ying" but the FSM state terminology throughout the codebase
is "yin/yang" (e.g., `FSM_YANG_MASK` doc on line 34 of `LibParseState.sol` says
"yin state"). The misspelling "ying" appears only in these two comments. All other
references consistently use "yin".

### P4-EVLP-4: Inconsistent opcode bounds checking between eval and integrity [INFO]

**Files:**
- `src/lib/eval/LibEval.sol`, line 100 et al. (mod-based wrapping)
- `src/lib/integrity/LibIntegrityCheck.sol`, line 152 (revert-based bounds check)

The eval loop uses `mod(opcodeIndex, fsCount)` to silently wrap out-of-range opcodes
into the valid range, while the integrity check uses an explicit bounds check with
`revert OpcodeOutOfRange(...)`. This is intentional -- the eval loop NatSpec explains
the design -- but the two modules use fundamentally different strategies for the same
concern. The integrity check is the authoritative validation point, and the eval loop
deliberately avoids a branch for gas efficiency. This is documented and correct
behaviour.

This finding is informational only. No change needed -- the design choice is
deliberate and documented.

### P4-EVLP-5: Magic number 59 for paren depth limit [LOW]

**File:** `src/lib/parse/LibParse.sol`, line 341

```solidity
if (newParenOffset > 59) {
    revert ParenOverflow();
}
```

The threshold `59` is derived from the paren tracker layout (62 bytes / 3 bytes per
group = 20 groups, minus 1 for the phantom counter write at `parenOffset + 4`,
giving a max offset of 57, but the check rejects at 60 since `newParenOffset` is
already incremented by 3). The inline comment (lines 335-340) explains the
derivation. A named constant would make this more maintainable and grep-friendly,
e.g.:

```solidity
uint256 constant MAX_PAREN_OFFSET = 59;
```

### P4-EVLP-6: Magic number 0x3f for stack RHS overflow [LOW]

**File:** `src/lib/parse/LibParseState.sol`, line 537

```solidity
if (newStackRHSOffset >= 0x3f) {
    revert ParseStackOverflow();
}
```

The inline comment (lines 534-536) explains why `0x3f` (63) is the limit, but this
magic number appears only once and could be a named constant for clarity. The
comment is already adequate, so this is low severity.

### P4-EVLP-7: `LibParseState.sol` is 1053 lines with 16 functions [INFO]

**File:** `src/lib/parse/LibParseState.sol`

This file is the largest in the reviewed set at over 1000 lines. It contains 16
functions that handle very different concerns: source allocation
(`newActiveSourcePointer`), FSM state management (`resetSource`, `highwater`),
constants management (`pushConstantValue`, `constantValueBloom`, `buildConstants`),
literal handling (`pushLiteral`), opcode emission (`pushOpToSource`), source
finalisation (`endSource`, `buildBytecode`), line tracking (`endLine`,
`snapshotSourceHeadToLineTracker`), sub parser management (`pushSubParser`,
`exportSubParsers`), and memory safety (`checkParseMemoryOverflow`).

This is an observation, not a defect. The functions are cohesive around the
`ParseState` struct and its lifecycle. Splitting would fragment the struct's
invariant management. However, future contributors should be aware that this file
requires understanding the full `ParseState` memory layout to modify safely.

### P4-EVLP-8: `ParseState` struct field ordering relies on assembly offset coupling [INFO]

**File:** `src/lib/parse/LibParseState.sol`, lines 155-183

The `ParseState` struct has a comment block at lines 156-170 marking fields that
are "referenced directly in assembly by hardcoded offsets". The named constants
(`PARSE_STATE_TOP_LEVEL0_OFFSET`, `PARSE_STATE_PAREN_TRACKER0_OFFSET`,
`PARSE_STATE_LINE_TRACKER_OFFSET`) encode byte offsets into the struct's memory
layout. Reordering struct fields without updating these constants would silently
corrupt the parser.

This coupling is necessary for the assembly-heavy implementation but makes the
code fragile to refactoring. The comment block acknowledging this is good practice.
No change needed -- flagging for awareness.

---

## Cross-file Consistency Notes

1. **Assembly `memory-safe` annotations:** All assembly blocks across all eight files
   consistently use `assembly ("memory-safe")`. No missing annotations found.

2. **Error handling:** All files use custom error types, no string reverts. Error
   patterns are consistent: parse errors include byte offsets, integrity errors
   include opcode indices, eval errors include expected vs actual values.

3. **NatSpec coverage:** All public/internal functions have `@notice` and `@param`
   tags. NatSpec is thorough and consistent across all eight files.

4. **No commented-out code:** No commented-out code blocks found in any of the
   reviewed files.

5. **No dead code:** All functions are reachable. `handleErrorSelector` in
   `LibParseError` is called from `LibParseLiteralDecimal`.

6. **`unchecked` blocks:** Used consistently in arithmetic-heavy functions.
   Functions that don't do arithmetic (e.g., `parseInterstitial`) correctly omit
   `unchecked`. Minor inconsistency: `skipWhitespace` wraps a trivial
   `state.fsm &= ~FSM_YANG_MASK` in `unchecked` but this has no practical impact
   since that operation cannot overflow.
