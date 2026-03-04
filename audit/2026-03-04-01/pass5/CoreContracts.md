# Pass 5 - Correctness/Intent Verification: Core Contracts

## Files Reviewed

| Agent ID | File |
|----------|------|
| A01 | `src/abstract/BaseRainterpreterExtern.sol` |
| A02 | `src/abstract/BaseRainterpreterSubParser.sol` |
| A03 | `src/concrete/Rainterpreter.sol` |
| A04 | `src/concrete/RainterpreterDISPaiRegistry.sol` |
| A05 | `src/concrete/RainterpreterExpressionDeployer.sol` |
| A06 | `src/concrete/RainterpreterParser.sol` |
| A07 | `src/concrete/RainterpreterStore.sol` |
| A08 | `src/concrete/extern/RainterpreterReferenceExtern.sol` |

## Evidence Inventory

### A01: BaseRainterpreterExtern

- **Contract**: `BaseRainterpreterExtern` (abstract, line 29)
- **Inherits**: `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `ERC165`
- **Constructor** (line 34): Validates opcode pointers non-empty, opcode/integrity pointer lengths match
- **`extern()`** (line 46): Dispatches extern opcode via modulo-bounded function pointer table
- **`externIntegrity()`** (line 83): Dispatches integrity check with bounds revert on out-of-range opcode
- **`supportsInterface()`** (line 112): Reports `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `IERC165`
- **`opcodeFunctionPointers()`** (line 121): Returns `OPCODE_FUNCTION_POINTERS` (empty default)
- **`integrityFunctionPointers()`** (line 128): Returns `INTEGRITY_FUNCTION_POINTERS` (empty default)
- **Constants**: `OPCODE_FUNCTION_POINTERS` (line 20), `INTEGRITY_FUNCTION_POINTERS` (line 24) -- both empty placeholders
- **Errors used**: `ExternOpcodePointersEmpty`, `ExternPointersMismatch`, `ExternOpcodeOutOfRange`

**Verification**:
- `ExternDispatchV2` extraction matches `LibExtern.encodeExternDispatch` encoding: opcode at bits [16,32), operand at bits [0,16). Verified both shift/mask operations.
- `extern()` uses modulo dispatch (documented as cheaper than bounds check, mirrors eval loop). `externIntegrity()` uses explicit bounds check with revert. Both behaviors correctly documented.
- Constructor checks match error semantics: empty pointers -> `ExternOpcodePointersEmpty`, length mismatch -> `ExternPointersMismatch`.
- Function pointer extraction via `shr(0xf0, mload(...))` correctly reads 2-byte entries from packed byte array.
- ERC165 correctly reports all four interfaces.

### A02: BaseRainterpreterSubParser

- **Contract**: `BaseRainterpreterSubParser` (abstract, line 78)
- **Inherits**: `ERC165`, `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`
- **`subParserParseMeta()`** (line 93): Returns placeholder meta
- **`subParserWordParsers()`** (line 100): Returns placeholder word parsers
- **`subParserOperandHandlers()`** (line 107): Returns placeholder operand handlers
- **`subParserLiteralParsers()`** (line 114): Returns placeholder literal parsers
- **`matchSubParseLiteralDispatch()`** (line 139): Default returns no match
- **`subParseLiteral2()`** (line 159): Dispatches literal sub-parsing
- **`subParseWord2()`** (line 188): Dispatches word sub-parsing
- **`supportsInterface()`** (line 215): Reports all five interfaces
- **Constants**: `SUB_PARSER_WORD_PARSERS`, `SUB_PARSER_PARSE_META`, `SUB_PARSER_OPERAND_HANDLERS`, `SUB_PARSER_LITERAL_PARSERS` -- all empty placeholders
- **Error used**: `SubParserIndexOutOfBounds`

**Verification**:
- Function pointer extraction via `and(mload(...), 0xFFFF)` correctly reads bottom-aligned 2-byte entries.
- Bounds check (`index >= parsersLength`) correctly triggers `SubParserIndexOutOfBounds`.
- `matchSubParseLiteralDispatch` default returns `(false, 0, 0)` -- consistent with NatSpec "won't attempt to parse any literals".
- ERC165 correctly reports all five interfaces.
- `subParseLiteral2` and `subParseWord2` correctly implement `ISubParserV4`.

### A03: Rainterpreter

- **Contract**: `Rainterpreter` (line 32)
- **Inherits**: `IInterpreterV4`, `IOpcodeToolingV1`, `ERC165`
- **Constructor** (line 38): Reverts with `ZeroFunctionPointers` if opcode table is empty
- **`opcodeFunctionPointers()`** (line 49): Returns generated `OPCODE_FUNCTION_POINTERS`
- **`eval4()`** (line 54): Deserializes bytecode, applies state overlay, evaluates
- **`supportsInterface()`** (line 77): Reports `IInterpreterV4`, `IOpcodeToolingV1`, `IERC165`
- **`buildOpcodeFunctionPointers()`** (line 83): Delegates to `LibAllStandardOps`
- **Error used**: `ZeroFunctionPointers`, `OddSetLength`

**Verification**:
- Constructor guard prevents deployment with empty function pointer table, correctly preventing division-by-zero in eval loop's modulo dispatch.
- `eval4` state overlay validation (`stateOverlay.length % 2 != 0`) correctly reverts with `OddSetLength`.
- State overlay loop correctly iterates in pairs (key, value).
- ERC165 correctly reports both interfaces.

### A04: RainterpreterDISPaiRegistry

- **Contract**: `RainterpreterDISPaiRegistry` (line 15)
- **Inherits**: `IDISPaiRegistry`, `ERC165`
- **`supportsInterface()`** (line 17): Reports `IDISPaiRegistry`
- **`expressionDeployerAddress()`** (line 22): Returns `EXPRESSION_DEPLOYER_DEPLOYED_ADDRESS`
- **`interpreterAddress()`** (line 27): Returns `INTERPRETER_DEPLOYED_ADDRESS`
- **`storeAddress()`** (line 32): Returns `STORE_DEPLOYED_ADDRESS`
- **`parserAddress()`** (line 37): Returns `PARSER_DEPLOYED_ADDRESS`

**Verification**:
- All four functions correctly map to their respective `LibInterpreterDeploy` constants.
- NatSpec accurately describes the contract as exposing deterministic Zoltu deploy addresses.
- `IDISPaiRegistry` interface conformance is complete: all four functions implemented.
- ERC165 correctly reports `IDISPaiRegistry`.

### A05: RainterpreterExpressionDeployer

- **Contract**: `RainterpreterExpressionDeployer` (line 26)
- **Inherits**: `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`, `ERC165`
- **`supportsInterface()`** (line 34): Reports all four content interfaces
- **`parse2()`** (line 41): Parses via RainterpreterParser, serializes, integrity checks
- **`parsePragma1()`** (line 66): Delegates to RainterpreterParser
- **`buildIntegrityFunctionPointers()`** (line 73): Delegates to `LibAllStandardOps`
- **`describedByMetaV1()`** (line 78): Returns `DESCRIBED_BY_META_HASH`

**Verification**:
- `parse2()` correctly: (1) calls parser's `unsafeParse`, (2) serializes bytecode+constants, (3) runs integrity check. Order and logic match NatSpec "Coordinates parse, integrity check, and serialization."
- `parsePragma1()` NatSpec says "just here for convenience" and recommends calling parser directly -- implementation correctly delegates.
- ERC165 correctly reports all four interfaces plus `IERC165`.

### A06: RainterpreterParser

- **Contract**: `RainterpreterParser` (line 36)
- **Inherits**: `ERC165`, `IParserToolingV1`
- **Modifier `checkParseMemoryOverflow`** (line 46): Post-execution memory overflow check
- **`unsafeParse()`** (line 57): Parses Rainlang to bytecode+constants
- **`supportsInterface()`** (line 72): Reports `IParserToolingV1`
- **`parsePragma1()`** (line 80): Parses only pragma section
- **`parseMeta()`** (line 94): Returns generated `PARSE_META`
- **`operandHandlerFunctionPointers()`** (line 101): Returns generated pointers
- **`literalParserFunctionPointers()`** (line 108): Returns generated pointers
- **`buildOperandHandlerFunctionPointers()`** (line 113): Delegates to `LibAllStandardOps`
- **`buildLiteralParserFunctionPointers()`** (line 118): Delegates to `LibAllStandardOps`

**Verification**:
- `unsafeParse` NatSpec correctly states it "Does not perform integrity checks -- those are the deployer's responsibility."
- `checkParseMemoryOverflow` modifier correctly runs AFTER function body (uses `_; check()` pattern).
- `parsePragma1` correctly parses interstitial then pragma, returning sub-parsers array.
- ERC165 correctly reports `IParserToolingV1`.

### A07: RainterpreterStore

- **Contract**: `RainterpreterStore` (line 25)
- **Inherits**: `IInterpreterStoreV3`, `ERC165`
- **Storage**: `sStore` mapping (line 40): `FullyQualifiedNamespace => bytes32 key => bytes32 value`
- **`supportsInterface()`** (line 43): Reports `IInterpreterStoreV3`
- **`set()`** (line 48): Qualifies namespace with `msg.sender`, stores key/value pairs, emits `Set` events
- **`get()`** (line 66): Direct mapping lookup by fully qualified namespace and key
- **Error used**: `OddSetLength`

**Verification**:
- `set()` correctly qualifies `StateNamespace` with `msg.sender` via `namespace.qualifyNamespace(msg.sender)`, ensuring caller isolation as required by `IInterpreterStoreV3`.
- `set()` correctly emits `Set` event per key/value pair, matching the interface event signature.
- `set()` odd-length check correctly reverts with `OddSetLength`.
- `get()` correctly takes a `FullyQualifiedNamespace` (pre-qualified by caller) and returns the stored value.
- NatSpec sandbox tier documentation (lines 29-37) accurately describes the isolation model.
- ERC165 correctly reports `IInterpreterStoreV3`.

### A08: RainterpreterReferenceExtern

- **Contract**: `RainterpreterReferenceExtern` (line 161)
- **Inherits**: `BaseRainterpreterSubParser`, `BaseRainterpreterExtern`
- **Library**: `LibRainterpreterReferenceExtern` (line 88)
- **`describedByMetaV1()`** (line 165): Returns `DESCRIBED_BY_META_HASH`
- **Override functions** (lines 172-208): All return generated constants
- **`buildLiteralParserFunctionPointers()`** (line 213): Builds literal parser pointers
- **`matchSubParseLiteralDispatch()`** (line 236): Matches "ref-extern-repeat-" prefix
- **`buildOperandHandlerFunctionPointers()`** (line 282): Builds operand handler pointers
- **`buildSubParserWordParsers()`** (line 325): Builds sub-parser word pointers
- **`buildOpcodeFunctionPointers()`** (line 367): Builds opcode function pointers
- **`buildIntegrityFunctionPointers()`** (line 401): Builds integrity function pointers
- **`supportsInterface()`** (line 429): Resolves diamond inheritance
- **Constants**: `SUB_PARSER_WORD_PARSERS_LENGTH = 5`, `SUB_PARSER_LITERAL_PARSERS_LENGTH = 1`, `OPCODE_FUNCTION_POINTERS_LENGTH = 1`, keyword constants for repeat literal
- **Errors**: `InvalidRepeatCount`, `UnconsumedRepeatDispatchBytes`

**Verification**:
- Keyword mask computation: `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH = 18` correctly produces a mask that preserves the first 18 bytes of a bytes32 word.
- Repeat count validation (lines 265-268): correctly limits to integers 0-9 by checking < 0, > 9, and fractional part.
- `matchSubParseLiteralDispatch` correctly reverts with `UnconsumedRepeatDispatchBytes` when trailing bytes exist after the decimal.
- `authoringMetaV2()` array has exactly `SUB_PARSER_WORD_PARSERS_LENGTH` (5) entries matching the 5 sub-parser functions.
- `supportsInterface` C3 linearization: `RainterpreterReferenceExtern` -> `BaseRainterpreterExtern` -> `BaseRainterpreterSubParser` -> `ERC165`. The `super` call chains through all parent `supportsInterface` implementations, correctly accumulating all interface IDs from both parents.
- All `build*` functions correctly use length-encoded fixed-size array trick with `BadDynamicLength` sanity check.

## Findings

### A01-P5-1: NatSpec on `opcodeFunctionPointers` says `view` is required but default implementation is pure-equivalent [INFO]

**File**: `src/abstract/BaseRainterpreterExtern.sol`, line 121

**Description**: The `opcodeFunctionPointers()` function is declared `internal view virtual` in `BaseRainterpreterExtern`. The default implementation simply returns a constant (`OPCODE_FUNCTION_POINTERS`), which requires no state access. The NatSpec on `Rainterpreter.opcodeFunctionPointers()` (A03, line 43-48) documents the `view` visibility as necessary for subclass flexibility, but the base extern's version has no such documentation explaining why `view` is needed over `pure`.

Meanwhile, the sibling `integrityFunctionPointers()` at line 128 is declared `pure`, creating an asymmetry within the same contract where both functions serve structurally identical roles (returning a constant byte array).

This is not a bug -- `view` allows overrides that read storage, and `RainterpreterReferenceExtern` overrides to `pure` which is valid. However, the asymmetry between `opcodeFunctionPointers` (`view`) and `integrityFunctionPointers` (`pure`) is undocumented and could confuse future implementers about which visibility to use when overriding.

**Severity**: INFO

**Recommendation**: Add a brief NatSpec comment to `opcodeFunctionPointers()` in `BaseRainterpreterExtern` explaining that `view` is intentional to permit overrides that read state (matching the pattern documented on `Rainterpreter.opcodeFunctionPointers()`).
