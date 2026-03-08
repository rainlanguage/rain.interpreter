# Pass 5 -- Intent vs Behavior: Core Concrete Contracts

**Agent:** A01
**Date:** 2026-03-08
**Scope:** `BaseRainterpreterExtern`, `BaseRainterpreterSubParser`, `Rainterpreter`, `RainterpreterStore`, `RainterpreterExpressionDeployer`, `RainterpreterParser`, `RainterpreterDISPaiRegistry`, `RainterpreterReferenceExtern`

---

## 1. BaseRainterpreterExtern (`src/abstract/BaseRainterpreterExtern.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 34 | `constructor()` | Yes |
| 46 | `extern(ExternDispatchV2, StackItem[])` | Yes |
| 83 | `externIntegrity(ExternDispatchV2, uint256, uint256)` | Yes |
| 112 | `supportsInterface(bytes4)` | Yes |
| 121 | `opcodeFunctionPointers()` | Yes |
| 128 | `integrityFunctionPointers()` | Yes |

### Evidence

- **constructor (L34-43):** NatSpec says "Validates that opcode function pointers are non-empty and that opcode and integrity function pointer tables have the same length." Implementation checks `opcodeFunctionPointersLength == 0` (reverts `ExternOpcodePointersEmpty`) and `opcodeFunctionPointersLength != integrityFunctionPointersLength` (reverts `ExternPointersMismatch`). Matches.
- **extern (L46-80):** Uses modulo dispatch (`mod(opcode, fsCount)`) to ensure in-bounds access. NatSpec comment explains this is cheaper than bounds checking and prevents arbitrary memory reads. `externIntegrity` separately reverts on out-of-range opcodes at parse time. Matches.
- **externIntegrity (L83-109):** Reverts with `ExternOpcodeOutOfRange` if `opcode >= fsCount`. NatSpec is `@inheritdoc`. Matches.
- **supportsInterface (L112-116):** Reports `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, and delegates to `super` (`ERC165`). All four interfaces are in the contract's inheritance. Matches.
- **opcodeFunctionPointers (L121-123):** Returns the default empty constant. NatSpec says "Overrideable function to provide the list of function pointers for opcode dispatches." Matches.
- **integrityFunctionPointers (L128-130):** Returns the default empty constant. Matches.

### Dispatch Encoding Verification

`extern` decodes `ExternDispatchV2` as:
- `opcode = (dispatch >> 0x10) & 0xFFFF` (bits 16-31)
- `operand = dispatch & 0xFFFF` (bits 0-15)

This matches `LibExtern.encodeExternDispatch`: `bytes32(opcode) << 0x10 | operand` and `LibExtern.decodeExternDispatch`. Consistent.

### Finding: None

---

## 2. BaseRainterpreterSubParser (`src/abstract/BaseRainterpreterSubParser.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 93 | `subParserParseMeta()` | Yes |
| 100 | `subParserWordParsers()` | Yes |
| 107 | `subParserOperandHandlers()` | Yes |
| 114 | `subParserLiteralParsers()` | Yes |
| 139 | `matchSubParseLiteralDispatch(uint256, uint256)` | Yes |
| 159 | `subParseLiteral2(bytes)` | Yes |
| 188 | `subParseWord2(bytes)` | Yes |
| 215 | `supportsInterface(bytes4)` | Yes |

### Evidence

- **subParseLiteral2 (L159-178):** NatSpec says "A basic implementation of sub parsing literals that uses encoded function pointers to dispatch everything necessary in O(1)." Implementation calls `matchSubParseLiteralDispatch` to check if the dispatch is recognized, then loads the function pointer at `index` from `subParserLiteralParsers()`, with bounds check (`SubParserIndexOutOfBounds`). Returns `(true, result)` on success, `(false, 0)` on failure. Matches.
- **subParseWord2 (L188-212):** NatSpec says "A basic implementation of sub parsing words that uses encoded function pointers to dispatch everything necessary in O(1)." Implementation parses input data, looks up the word in the meta, handles operands, then dispatches to the sub parser function at the matching index. Bounds check present. Returns `(false, "", [])` if word not found. Matches.
- **supportsInterface (L215-219):** Reports `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`, and `ERC165`. All are in the inheritance chain. Matches.
- **matchSubParseLiteralDispatch (L139-149):** Default implementation returns `(false, 0, 0)`. NatSpec says "if not overridden simply won't attempt to parse any literals." Matches.
- **Function pointer extraction (L171-173):** Uses `and(mload(add(ptr, (index+1)*2)), 0xFFFF)` pattern. For `index=0`, this loads 32 bytes from `ptr+2`, and `and(..., 0xFFFF)` extracts the lowest 16 bits, which correspond to bytes at `ptr+32` and `ptr+33` -- the first 2-byte function pointer in the data (after the 32-byte length prefix). Correct.

### Finding: None

---

## 3. Rainterpreter (`src/concrete/Rainterpreter.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 38 | `constructor()` | Yes |
| 49 | `opcodeFunctionPointers()` | Yes |
| 54 | `eval4(EvalV4)` | Yes |
| 77 | `supportsInterface(bytes4)` | Yes |
| 83 | `buildOpcodeFunctionPointers()` | Yes |

### Evidence

- **constructor (L38-40):** NatSpec says "Guards against deployment with an empty opcode function pointer table." Checks `opcodeFunctionPointers().length == 0` and reverts `ZeroFunctionPointers`. Matches.
- **opcodeFunctionPointers (L49-51):** NatSpec explains the table is used by eval loop, warns about empty bytes causing division-by-zero. Returns `OPCODE_FUNCTION_POINTERS` constant. Matches.
- **eval4 (L54-74):** Deserializes bytecode, validates state overlay has even length (reverts `OddSetLength`), applies overlay as key-value pairs to `stateKV`, then calls `state.eval4()`. NatSpec is `@inheritdoc IInterpreterV4`. The function is `view` -- state writes are returned, not persisted. Matches the interface documentation.
- **supportsInterface (L77-79):** Reports `IInterpreterV4` and `IOpcodeToolingV1`. Both are in the inheritance chain. Matches.
- **buildOpcodeFunctionPointers (L83-85):** Delegates to `LibAllStandardOps.opcodeFunctionPointers()`. NatSpec is `@inheritdoc IOpcodeToolingV1`. Matches.

### Finding: None

---

## 4. RainterpreterStore (`src/concrete/RainterpreterStore.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 43 | `supportsInterface(bytes4)` | Yes |
| 48 | `set(StateNamespace, bytes32[])` | Yes |
| 66 | `get(FullyQualifiedNamespace, bytes32)` | Yes |

### Evidence

- **set (L48-63):** NatSpec is `@inheritdoc IInterpreterStoreV3`. Validates even length (`OddSetLength`), qualifies namespace with `msg.sender`, iterates pairwise setting `sStore[fqns][key] = value` and emitting `Set`. Matches the interface documentation that says "MUST NOT be possible for a caller to modify the state changes associated with some other caller." Namespace qualification by `msg.sender` enforces this.
- **get (L66-68):** Returns `sStore[namespace][key]`. Takes `FullyQualifiedNamespace` (already qualified). Matches interface: "any UNSET VALUES SILENTLY FALLBACK TO `0`" (Solidity default for mappings).
- **supportsInterface (L43-45):** Reports `IInterpreterStoreV3`. Matches.
- **sStore mapping (L40):** NatSpec describes 4-tier sandbox (msg.sender, namespace, key, value). The mapping `FullyQualifiedNamespace => (bytes32 => bytes32)` encodes tiers 0+1 in the namespace, tier 2 as key, tier 3 as value. Matches.

### Finding: None

---

## 5. RainterpreterExpressionDeployer (`src/concrete/RainterpreterExpressionDeployer.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 34 | `supportsInterface(bytes4)` | Yes |
| 41 | `parse2(bytes)` | Yes |
| 66 | `parsePragma1(bytes)` | Yes |
| 73 | `buildIntegrityFunctionPointers()` | Yes |
| 78 | `describedByMetaV1()` | Yes |

### Evidence

- **parse2 (L41-61):** NatSpec is `@inheritdoc IParserV2`. Implementation: (1) calls `RainterpreterParser.unsafeParse(data)` to get bytecode + constants, (2) computes serialized size and serializes, (3) runs integrity check via `LibIntegrityCheck.integrityCheck2`. Returns serialized bytecode. NatSpec matches: "Parses Rainlang source data into bytecode."
- **parsePragma1 (L66-70):** NatSpec says "This is just here for convenience for `IParserV2` consumers, it would be more gas efficient to call the parser directly." Delegates to `RainterpreterParser.parsePragma1(data)`. Matches: it is a convenience wrapper.
- **supportsInterface (L34-38):** Reports `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`. All are in the inheritance chain. Matches.
- **buildIntegrityFunctionPointers (L73-75):** Delegates to `LibAllStandardOps.integrityFunctionPointers()`. NatSpec is `@inheritdoc IIntegrityToolingV1`. Matches.
- **describedByMetaV1 (L78-80):** Returns `DESCRIBED_BY_META_HASH`. NatSpec is `@inheritdoc IDescribedByMetaV1`. Matches.

### Finding: None

---

## 6. RainterpreterParser (`src/concrete/RainterpreterParser.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 46 | `checkParseMemoryOverflow()` (modifier) | Yes |
| 57 | `unsafeParse(bytes)` | Yes |
| 72 | `supportsInterface(bytes4)` | Yes |
| 80 | `parsePragma1(bytes)` | Yes |
| 94 | `parseMeta()` | Yes |
| 101 | `operandHandlerFunctionPointers()` | Yes |
| 108 | `literalParserFunctionPointers()` | Yes |
| 113 | `buildOperandHandlerFunctionPointers()` | Yes |
| 118 | `buildLiteralParserFunctionPointers()` | Yes |

### Evidence

- **unsafeParse (L57-69):** NatSpec says "Parses Rainlang source `data` into bytecode and constants. Called by the expression deployer. Does not perform integrity checks -- those are the deployer's responsibility." Implementation creates parse state and calls `parse()`. No integrity check. Matches.
- **parsePragma1 (L80-90):** NatSpec says "Parses only the pragma section of Rainlang source `data`." Implementation creates state, parses interstitial, parses pragma, and returns `PragmaV1` with sub-parsers. Matches.
- **supportsInterface (L72-74):** Reports `IParserToolingV1` only. The contract intentionally does NOT report `IParserV2` or `IParserPragmaV1` because it is "NOT intended to be called directly" (per @dev in the contract NatSpec). Consistent with documented intent.
- **checkParseMemoryOverflow (L46-49):** NatSpec says "reverting if the free memory pointer reached or exceeded 0x10000 during parsing." Runs after the function body (`_; checkParseMemoryOverflow()`). Matches.
- **parseMeta, operandHandlerFunctionPointers, literalParserFunctionPointers (L94-110):** Each returns its respective generated constant. NatSpec accurately describes each as a virtual function returning the relevant data. Matches.

### Finding: None

---

## 7. RainterpreterDISPaiRegistry (`src/concrete/RainterpreterDISPaiRegistry.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 17 | `supportsInterface(bytes4)` | Yes |
| 22 | `expressionDeployerAddress()` | Yes |
| 27 | `interpreterAddress()` | Yes |
| 32 | `storeAddress()` | Yes |
| 37 | `parserAddress()` | Yes |

### Evidence

- **All four getters (L22-39):** Each returns the corresponding `LibInterpreterDeploy.*_DEPLOYED_ADDRESS` constant. NatSpec is `@inheritdoc IDISPaiRegistry` for all. The `IDISPaiRegistry` interface documents each as "Returns the deterministic deploy address of the [component]." Matches.
- **supportsInterface (L17-19):** Reports `IDISPaiRegistry`. Matches.
- **Contract NatSpec (L9-14):** Says "DISPaiR registry contract that exposes the deterministic Zoltu deploy addresses of the four core interpreter components: Deployer, Interpreter, Store, and Parser." Four functions, four components. Matches.

### Finding: None

---

## 8. RainterpreterReferenceExtern (`src/concrete/extern/RainterpreterReferenceExtern.sol`)

### Functions

| Line | Function | Verified |
|------|----------|----------|
| 165 | `describedByMetaV1()` | Yes |
| 172 | `subParserParseMeta()` | Yes |
| 179 | `subParserWordParsers()` | Yes |
| 186 | `subParserOperandHandlers()` | Yes |
| 193 | `subParserLiteralParsers()` | Yes |
| 200 | `opcodeFunctionPointers()` | Yes |
| 207 | `integrityFunctionPointers()` | Yes |
| 213 | `buildLiteralParserFunctionPointers()` | Yes |
| 236 | `matchSubParseLiteralDispatch(uint256, uint256)` | Yes |
| 282 | `buildOperandHandlerFunctionPointers()` | Yes |
| 325 | `buildSubParserWordParsers()` | Yes |
| 367 | `buildOpcodeFunctionPointers()` | Yes |
| 401 | `buildIntegrityFunctionPointers()` | Yes |
| 429 | `supportsInterface(bytes4)` | Yes |

### Evidence

- **supportsInterface (L429-437):** Resolves diamond inheritance between `BaseRainterpreterSubParser` and `BaseRainterpreterExtern` via `super.supportsInterface`. C3 linearization: `RainterpreterReferenceExtern -> BaseRainterpreterExtern -> BaseRainterpreterSubParser -> ERC165`. The combined set correctly includes: `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`, `IERC165`. All interfaces from both base contracts are reported. Matches.
- **matchSubParseLiteralDispatch (L236-277):** Implements keyword matching for `"ref-extern-repeat-"`. Validates that the next characters are a decimal float, checks it is an integer 0-9 via `lt`, `gt`, and `frac().isZero()` checks. Reverts `InvalidRepeatCount` for out-of-range or non-integer values, `UnconsumedRepeatDispatchBytes` for trailing bytes. NatSpec inherits from base. Matches.
- **All override functions (L172-209):** Each returns the corresponding generated constant from `RainterpreterReferenceExtern.pointers.sol`. NatSpec for each says it "Simply returns the known constant value." Matches.
- **All build* functions (L213-422):** Each constructs a function pointer array from individual library functions, validates length with `BadDynamicLength`, and converts to 16-bit bytes. Used for tooling verification against compiled constants. NatSpec describes this purpose. Matches.
- **describedByMetaV1 (L165-167):** Returns `DESCRIBED_BY_META_HASH`. NatSpec is `@inheritdoc IDescribedByMetaV1`. Matches.

### Constants Verification

- `SUB_PARSER_WORD_PARSERS_LENGTH = 5` -- matches the 5 entries in `authoringMetaV2()` and the 5 entries in `buildSubParserWordParsers()` and `buildOperandHandlerFunctionPointers()`. Consistent.
- `SUB_PARSER_LITERAL_PARSERS_LENGTH = 1` -- matches the 1 entry in `buildLiteralParserFunctionPointers()`. Consistent.
- `OPCODE_FUNCTION_POINTERS_LENGTH = 1` -- matches the 1 entry in `buildOpcodeFunctionPointers()` and `buildIntegrityFunctionPointers()`. Consistent.
- `SUB_PARSER_LITERAL_REPEAT_KEYWORD = "ref-extern-repeat-"` (18 bytes) matches `SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH = 18`. Consistent.

### Finding: None

---

## Summary

All 8 contracts verified. Every function's behavior matches its name, NatSpec, and documented intent. ERC165 `supportsInterface` implementations correctly report all declared interfaces. Error conditions match their triggers. Constants match their documented meanings. Dispatch encoding/decoding is consistent between `BaseRainterpreterExtern` and `LibExtern`.

**Findings: None (all PASS)**

### Informational Notes (no action required)

1. **`OddSetLength` error reuse:** The error is defined in `ErrStore.sol` with NatSpec "Thrown when a `set` call is made with an odd number of arguments." It is also used in `Rainterpreter.eval4` for state overlay validation, which is not a `set` call. The error semantics (odd length in a key-value pair array) are the same, so the reuse is reasonable. The NatSpec in the error definition file could be broadened but this is purely cosmetic.

2. **`RainterpreterParser` interface omissions:** The parser intentionally omits `IParserV2` and `IParserPragmaV1` from its inheritance and `supportsInterface`, despite exposing `unsafeParse` and `parsePragma1` as external functions. This is explicitly documented in the contract NatSpec ("NOT intended to be called directly so intentionally does NOT implement various interfaces") and is by design.
