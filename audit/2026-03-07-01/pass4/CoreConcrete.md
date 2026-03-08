# Pass 4 -- Core Concrete Contracts

**Agent:** A01
**Date:** 2026-03-07
**Files reviewed:**

1. `src/abstract/BaseRainterpreterExtern.sol`
2. `src/abstract/BaseRainterpreterSubParser.sol`
3. `src/concrete/Rainterpreter.sol`
4. `src/concrete/RainterpreterStore.sol`
5. `src/concrete/RainterpreterExpressionDeployer.sol`
6. `src/concrete/RainterpreterParser.sol`
7. `src/concrete/RainterpreterDISPaiRegistry.sol`
8. `src/concrete/extern/RainterpreterReferenceExtern.sol`

---

## Evidence

### 1. BaseRainterpreterExtern.sol

- **Contract:** `BaseRainterpreterExtern` (abstract, line 29)
- **Inherits:** `IInterpreterExternV4`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `ERC165`
- **Imports (lines 5-15):** `ERC165`, `OperandV2`, `IInterpreterExternV4`, `ExternDispatchV2`, `StackItem`, `IIntegrityToolingV1`, `IOpcodeToolingV1`, `ExternOpcodeOutOfRange`, `ExternPointersMismatch`, `ExternOpcodePointersEmpty` -- all used
- **Functions:**
  - `constructor()` (line 34) -- validates pointer lengths
  - `extern(...)` (line 46) -- `external view virtual override`
  - `externIntegrity(...)` (line 83) -- `external pure virtual override`
  - `supportsInterface(...)` (line 112) -- `public view virtual override`
  - `opcodeFunctionPointers()` (line 121) -- `internal view virtual`
  - `integrityFunctionPointers()` (line 128) -- `internal pure virtual`
- **File-level constants:** `OPCODE_FUNCTION_POINTERS` (line 20), `INTEGRITY_FUNCTION_POINTERS` (line 24)
- **No `src/` imports, no commented-out code, no bare `src/` paths**

### 2. BaseRainterpreterSubParser.sol

- **Contract:** `BaseRainterpreterSubParser` (abstract, line 78)
- **Inherits:** `ERC165`, `ISubParserV4`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`
- **Imports (lines 5-19):** `ERC165`, `LibBytes`, `Pointer`, `ISubParserV4`, `AuthoringMetaV2` (convenience re-export), `LibSubParse`, `ParseState`, `CMASK_RHS_WORD_TAIL`, `LibParse`, `OperandV2`, `LibParseMeta`, `LibParseOperand`, `IDescribedByMetaV1`, `IParserToolingV1`, `ISubParserToolingV1`, `SubParserIndexOutOfBounds` -- all used or marked as convenience exports
- **`using` declarations (lines 85-88):**
  - `using LibBytes for bytes` -- used (line 191: `state.data.dataPointer()`)
  - `using LibParse for ParseState` -- **not used as member function** (line 195 calls `LibParse.parseWord(...)` statically)
  - `using LibParseMeta for ParseState` -- **not used as member function** (line 196 calls `LibParseMeta.lookupWord(...)` statically)
  - `using LibParseOperand for ParseState` -- used (line 198: `state.handleOperand(index)`)
- **Functions:**
  - `subParserParseMeta()` (line 93) -- `internal pure virtual`
  - `subParserWordParsers()` (line 100) -- `internal pure virtual`
  - `subParserOperandHandlers()` (line 107) -- `internal pure virtual`
  - `subParserLiteralParsers()` (line 114) -- `internal pure virtual`
  - `matchSubParseLiteralDispatch(...)` (line 139) -- `internal view virtual`
  - `subParseLiteral2(...)` (line 159) -- `external view virtual`
  - `subParseWord2(...)` (line 188) -- `external pure virtual`
  - `supportsInterface(...)` (line 215) -- `public view virtual override`
- **File-level constants:** `SUB_PARSER_WORD_PARSERS` (line 26), `SUB_PARSER_PARSE_META` (line 32), `SUB_PARSER_OPERAND_HANDLERS` (line 36), `SUB_PARSER_LITERAL_PARSERS` (line 40)

### 3. Rainterpreter.sol

- **Contract:** `Rainterpreter` (line 32)
- **Inherits:** `IInterpreterV4`, `IOpcodeToolingV1`, `ERC165`
- **Imports (lines 5-27):** All used. `INTERPRETER_BYTECODE_HASH` is a convenience re-export with forge-lint disable.
- **Functions:**
  - `constructor()` (line 38) -- validates non-empty function pointers
  - `opcodeFunctionPointers()` (line 49) -- `internal view virtual`
  - `eval4(...)` (line 54) -- `external view virtual override`
  - `supportsInterface(...)` (line 77) -- `public view virtual override`
  - `buildOpcodeFunctionPointers()` (line 83) -- `public view virtual override`

### 4. RainterpreterStore.sol

- **Contract:** `RainterpreterStore` (line 25)
- **Inherits:** `IInterpreterStoreV3`, `ERC165`
- **Imports (lines 5-17):** All used. `STORE_BYTECODE_HASH` is a convenience re-export.
- **Functions:**
  - `supportsInterface(...)` (line 43) -- `public view virtual override`
  - `set(...)` (line 48) -- `external virtual`
  - `get(...)` (line 66) -- `external view virtual`

### 5. RainterpreterExpressionDeployer.sol

- **Contract:** `RainterpreterExpressionDeployer` (line 26)
- **Inherits:** `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`, `ERC165`
- **Imports (lines 5-21):** All used.
- **Functions:**
  - `supportsInterface(...)` (line 34) -- `public view virtual override`
  - `parse2(...)` (line 41) -- `external view virtual override`
  - `parsePragma1(...)` (line 66) -- `external view virtual override`
  - `buildIntegrityFunctionPointers()` (line 73) -- `external view virtual override`
  - `describedByMetaV1()` (line 78) -- `external pure virtual override`

### 6. RainterpreterParser.sol

- **Contract:** `RainterpreterParser` (line 36)
- **Inherits:** `ERC165`, `IParserToolingV1`
- **Imports (lines 5-28):** All used. `PARSER_BYTECODE_HASH` and `PARSE_META_BUILD_DEPTH` are convenience re-exports.
- **Functions:**
  - `checkParseMemoryOverflow()` modifier (line 46)
  - `unsafeParse(...)` (line 57) -- `external view virtual`
  - `supportsInterface(...)` (line 72) -- `public view virtual override`
  - `parsePragma1(...)` (line 80) -- `external view virtual`
  - `parseMeta()` (line 94) -- `internal pure virtual`
  - `operandHandlerFunctionPointers()` (line 101) -- `internal pure virtual`
  - `literalParserFunctionPointers()` (line 108) -- `internal pure virtual`
  - `buildOperandHandlerFunctionPointers()` (line 113) -- `external pure override`
  - `buildLiteralParserFunctionPointers()` (line 118) -- `external pure override`

### 7. RainterpreterDISPaiRegistry.sol

- **Contract:** `RainterpreterDISPaiRegistry` (line 15)
- **Inherits:** `IDISPaiRegistry`, `ERC165`
- **Imports (lines 5-7):** All used.
- **Functions:**
  - `supportsInterface(...)` (line 17) -- `public view virtual override`
  - `expressionDeployerAddress()` (line 22) -- `external pure virtual override`
  - `interpreterAddress()` (line 27) -- `external pure virtual override`
  - `storeAddress()` (line 32) -- `external pure virtual override`
  - `parserAddress()` (line 37) -- `external pure virtual override`

### 8. RainterpreterReferenceExtern.sol

- **Contract:** `RainterpreterReferenceExtern` (line 161)
- **Inherits:** `BaseRainterpreterSubParser`, `BaseRainterpreterExtern`
- **Library:** `LibRainterpreterReferenceExtern` (line 88)
- **Imports (lines 5-40):** All used or marked as convenience re-exports with forge-lint disable.
- **Functions:**
  - `describedByMetaV1()` (line 165) -- `external pure override`
  - `subParserParseMeta()` (line 172) -- `internal pure virtual override`
  - `subParserWordParsers()` (line 179) -- `internal pure override`
  - `subParserOperandHandlers()` (line 186) -- `internal pure override`
  - `subParserLiteralParsers()` (line 193) -- `internal pure override`
  - `opcodeFunctionPointers()` (line 200) -- `internal pure override`
  - `integrityFunctionPointers()` (line 207) -- `internal pure override`
  - `buildLiteralParserFunctionPointers()` (line 213) -- `external pure` (no `override`)
  - `matchSubParseLiteralDispatch(...)` (line 236) -- `internal pure virtual override`
  - `buildOperandHandlerFunctionPointers()` (line 282) -- `external pure override`
  - `buildSubParserWordParsers()` (line 325) -- `external pure` (no `override`)
  - `buildOpcodeFunctionPointers()` (line 367) -- `external pure` (no `override`)
  - `buildIntegrityFunctionPointers()` (line 401) -- `external pure` (no `override`)
  - `supportsInterface(...)` (line 429) -- `public view virtual override(...)`

---

## Findings

### A01-5 (LOW) -- Inconsistent `override` on interface implementations in RainterpreterReferenceExtern

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`

`RainterpreterReferenceExtern` inherits `BaseRainterpreterSubParser` (which inherits `IParserToolingV1` and `ISubParserToolingV1`) and `BaseRainterpreterExtern` (which inherits `IOpcodeToolingV1` and `IIntegrityToolingV1`). Five `build*` functions implement interface methods, but only one uses `override`:

| Function | Line | Has `override`? | Interface |
|---|---|---|---|
| `buildOperandHandlerFunctionPointers()` | 282 | Yes | `IParserToolingV1` |
| `buildLiteralParserFunctionPointers()` | 213 | **No** | `IParserToolingV1` |
| `buildSubParserWordParsers()` | 325 | **No** | `ISubParserToolingV1` |
| `buildOpcodeFunctionPointers()` | 367 | **No** | `IOpcodeToolingV1` |
| `buildIntegrityFunctionPointers()` | 401 | **No** | `IIntegrityToolingV1` |

The four functions without `override` are inconsistent with `buildOperandHandlerFunctionPointers` and with how the same interfaces are implemented in `Rainterpreter.sol` (line 83, has `override`), `RainterpreterExpressionDeployer.sol` (line 73, has `override`), and `RainterpreterParser.sol` (lines 113/118, both have `override`).

### A01-6 (LOW) -- Inconsistent `virtual` on override functions in RainterpreterReferenceExtern

**File:** `src/concrete/extern/RainterpreterReferenceExtern.sol`

Among the internal override functions that return constant pointer tables, `subParserParseMeta()` (line 172) uses `virtual override`, while the structurally identical sibling functions use only `override`:

- `subParserParseMeta()` (line 172): `internal pure virtual override`
- `subParserWordParsers()` (line 179): `internal pure override`
- `subParserOperandHandlers()` (line 186): `internal pure override`
- `subParserLiteralParsers()` (line 193): `internal pure override`
- `opcodeFunctionPointers()` (line 200): `internal pure override`
- `integrityFunctionPointers()` (line 207): `internal pure override`

Either all should be `virtual override` (allowing further subclassing) or none should. The current state is inconsistent.

### A01-7 (LOW) -- Inconsistent NatSpec tagging between sibling functions in BaseRainterpreterExtern

**File:** `src/abstract/BaseRainterpreterExtern.sol`

The `opcodeFunctionPointers()` function (line 118) uses explicit `@notice`, while the adjacent and structurally identical `integrityFunctionPointers()` function (line 125) uses an untagged doc block (implicit `@notice`). Both doc blocks are single-tag blocks so implicit `@notice` is technically valid, but the inconsistency between two adjacent sibling functions is a style issue.

```
/// @notice Overrideable function to provide the list of function pointers   <-- line 118
/// for opcode dispatches.

/// Overrideable function to provide the list of function pointers for       <-- line 125
/// integrity checks.
```

### A01-8 (INFO) -- Unused `using` declarations in BaseRainterpreterSubParser

**File:** `src/abstract/BaseRainterpreterSubParser.sol`

Two `using` declarations are never invoked as member functions:

- Line 86: `using LibParse for ParseState` -- `LibParse.parseWord(...)` is called statically on line 195, not as `state.parseWord(...)`.
- Line 87: `using LibParseMeta for ParseState` -- `LibParseMeta.lookupWord(...)` is called statically on line 196, not as `state.lookupWord(...)`.

These declarations have no effect but add visual noise. They could be removed, and the direct `import {LibParse, ...}` / `import {LibParseMeta}` would still provide the needed static function access.

### A01-9 (INFO) -- Typo in NatSpec comment in BaseRainterpreterSubParser (duplicate of A01-4)

**File:** `src/abstract/BaseRainterpreterSubParser.sol`, line 30

The word "fingeprinting" should be "fingerprinting":

```
/// bytes. The exact same process of hashing, blooming, fingeprinting and index
```
