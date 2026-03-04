# A06 — Pass 1 (Security) — RainterpreterParser.sol

## Evidence of Thorough Reading

**Contract name:** `RainterpreterParser` (inherits `ERC165`, `IParserToolingV1`)

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 46 | `checkParseMemoryOverflow` | modifier | — | — |
| 57 | `unsafeParse(bytes memory data)` | function | external | view virtual |
| 72 | `supportsInterface(bytes4 interfaceId)` | function | public | view virtual override |
| 80 | `parsePragma1(bytes memory data)` | function | external | view virtual |
| 94 | `parseMeta()` | function | internal | pure virtual |
| 101 | `operandHandlerFunctionPointers()` | function | internal | pure virtual |
| 108 | `literalParserFunctionPointers()` | function | internal | pure virtual |
| 113 | `buildOperandHandlerFunctionPointers()` | function | external | pure override |
| 118 | `buildLiteralParserFunctionPointers()` | function | external | pure override |

**Errors defined in this file:** None. Uses `ParseMemoryOverflow` from `../error/ErrParse.sol` (via `LibParseState.checkParseMemoryOverflow`).

**Events defined:** None.

**Structs/types defined:** None.

**Constants imported from generated pointers file (`RainterpreterParser.pointers.sol`):**
- `LITERAL_PARSER_FUNCTION_POINTERS`
- `BYTECODE_HASH` (re-exported as `PARSER_BYTECODE_HASH`)
- `OPERAND_HANDLER_FUNCTION_POINTERS`
- `PARSE_META`
- `PARSE_META_BUILD_DEPTH` (re-exported)

**Using-for declarations (lines 37-41):**
- `LibParse for ParseState`
- `LibParseState for ParseState`
- `LibParsePragma for ParseState`
- `LibParseInterstitial for ParseState`
- `LibBytes for bytes`

---

## Security Review

### Assembly memory safety

No assembly blocks in this file. The `checkParseMemoryOverflow` modifier delegates to `LibParseState.checkParseMemoryOverflow()` which contains a single `mload(0x40)` read correctly tagged `memory-safe`. No writes.

### Bounds checks and function pointer tables

The three `internal pure virtual` functions (`parseMeta`, `operandHandlerFunctionPointers`, `literalParserFunctionPointers`) return compile-time constants from the generated pointers file. These are consumed by `LibParseState.newState` and stored into the `ParseState` struct. The operand handler table is indexed by opcode index from the bloom-filter word lookup; the literal parser table is indexed by literal dispatch. Bounds checking for these indexes happens inside `LibParseOperand` and `LibParseLiteral` respectively, not in this file. No OOB risk originates here.

### Operand parsing

Delegated entirely to `LibParse.parse()` and its sub-libraries. No operand logic in this file.

### Custom errors

No string reverts anywhere in the file. The only revert path is `ParseMemoryOverflow(uint256)` via the modifier, which is a properly defined custom error.

### Access control

`unsafeParse` and `parsePragma1` are `external view` with no access control. This is by design and documented in the NatSpec (lines 32-34): the parser is a pure transformation, not intended to be called directly. The expression deployer is the intended caller and adds integrity checks.

### Modifier ordering

The `checkParseMemoryOverflow` modifier places `_;` before the check (line 47-48), so the overflow check runs after parsing completes. This is correct — the check needs the final free memory pointer value. Both external parsing entry points (`unsafeParse`, `parsePragma1`) apply this modifier.

### Virtual override surface

`parseMeta()`, `operandHandlerFunctionPointers()`, `literalParserFunctionPointers()`, `parsePragma1()`, `unsafeParse()`, and `supportsInterface()` are all `virtual`. A subclass could override any of these. This is safe because the canonical expression deployer calls a hardcoded address produced by the Zoltu deterministic deployer; a subclassed parser would require a different deployer. The `build*` functions are NOT virtual, preserving the canonical ground-truth pointers.

### `parsePragma1` cursor discard

Line 88 discards the cursor after pragma parsing with `(cursor);`. This is intentional — `parsePragma1` extracts only the pragma section; the remaining input is expected to contain valid Rainlang for later parsing by `unsafeParse`. No validation of remaining content is needed here.

---

## Findings

No LOW+ findings.

This contract is a thin entry point that delegates all parsing logic to `LibParse*` libraries. Its attack surface is minimal: two `view` entry points, no state mutation, no assembly, no external calls beyond library delegatecalls, and a memory overflow guard on both paths. The security-critical parsing logic resides in the library layer (`LibParse`, `LibParseState`, `LibParseOperand`, `LibParseLiteral`, `LibSubParse`) and should be assessed there.
