# Pass 3: Documentation — Core Concrete Contracts

**Audit:** 2026-03-01-01

## Scope

| File | Lines |
|---|---|
| `src/concrete/Rainterpreter.sol` | 81 |
| `src/concrete/RainterpreterStore.sol` | 69 |
| `src/concrete/RainterpreterParser.sol` | 115 |
| `src/concrete/RainterpreterExpressionDeployer.sol` | 81 |
| `src/concrete/RainterpreterDISPaiRegistry.sol` | 40 |
| `src/interface/IDISPaiRegistry.sol` | 25 |

## Evidence of Review

### Rainterpreter.sol

- **Contract:** `Rainterpreter` (line 32), inherits `IInterpreterV4`, `IOpcodeToolingV1`, `ERC165`
- **Contract-level NatSpec:** `@title` (line 29), `@notice` (line 30-31). Correct.
- **Constructor:** line 38-40. Doc at line 36-37, untagged `///` only, no explicit tags -- valid (implicit `@notice`).
- **`opcodeFunctionPointers()`** internal view virtual (line 45). Doc at lines 42-44: untagged description (42-43) + `@return` (44).
- **`eval4(EvalV4)`** external view virtual override (line 50). `@inheritdoc IInterpreterV4` (line 49). Correct.
- **`supportsInterface(bytes4)`** public view virtual override (line 73). `@inheritdoc ERC165` (line 72). Correct.
- **`buildOpcodeFunctionPointers()`** public view virtual override (line 78). `@inheritdoc IOpcodeToolingV1` (line 77). Correct.

### RainterpreterStore.sol

- **Contract:** `RainterpreterStore` (line 25), inherits `IInterpreterStoreV3`, `ERC165`
- **Contract-level NatSpec:** `@title` (line 19), `@notice` (line 20-24). Correct.
- **`sStore` mapping** (line 40). Doc at lines 28-37, untagged `///` only -- valid (implicit `@notice`).
- **`supportsInterface(bytes4)`** public view virtual override (line 43). `@inheritdoc ERC165` (line 42). Correct.
- **`set(StateNamespace, bytes32[])`** external virtual (line 48). `@inheritdoc IInterpreterStoreV3` (line 47). Correct.
- **`get(FullyQualifiedNamespace, bytes32)`** external view virtual (line 66). `@inheritdoc IInterpreterStoreV3` (line 65). Correct.

### RainterpreterParser.sol

- **Contract:** `RainterpreterParser` (line 36), inherits `ERC165`, `IParserToolingV1`
- **Contract-level NatSpec:** `@title` (line 30), `@notice` (line 31), `@dev` (line 32-35). All tagged. Correct.
- **Modifier `checkParseMemoryOverflow`** (line 46). Doc at lines 43-45, untagged `///` only -- valid (implicit `@notice`).
- **`unsafeParse(bytes)`** external view (line 57). Doc at lines 51-56: `@notice` (51-53), `@param data` (54), two `@return` (55-56). Correct.
- **`supportsInterface(bytes4)`** public view virtual override (line 71). `@inheritdoc ERC165` (line 70). Correct.
- **`parsePragma1(bytes)`** external view virtual (line 79). Doc at lines 75-78: `@notice` (75-76), `@param data` (77), `@return` (78). Correct.
- **`parseMeta()`** internal pure virtual (line 92). Doc at line 91, untagged `///` only, no `@return`.
- **`operandHandlerFunctionPointers()`** internal pure virtual (line 97). Doc at line 96, untagged `///` only, no `@return`.
- **`literalParserFunctionPointers()`** internal pure virtual (line 102). Doc at line 101, untagged `///` only, no `@return`.
- **`buildOperandHandlerFunctionPointers()`** external pure override (line 107). Doc at line 106, bare `///`, no `@inheritdoc`.
- **`buildLiteralParserFunctionPointers()`** external pure override (line 112). Doc at line 111, bare `///`, no `@inheritdoc`.

### RainterpreterExpressionDeployer.sol

- **Contract:** `RainterpreterExpressionDeployer` (line 26), inherits `IDescribedByMetaV1`, `IParserV2`, `IParserPragmaV1`, `IIntegrityToolingV1`, `ERC165`
- **Contract-level NatSpec:** `@title` (line 23), `@notice` (line 24-25). Correct.
- **`supportsInterface(bytes4)`** public view virtual override (line 34). `@inheritdoc ERC165` (line 33). Correct.
- **`parse2(bytes)`** external view virtual override (line 41). `@inheritdoc IParserV2` (line 40). Correct.
- **`parsePragma1(bytes calldata)`** external view virtual override (line 66). `@notice` (line 63-64) + `@inheritdoc IParserPragmaV1` (line 65). Correct.
- **`buildIntegrityFunctionPointers()`** external view virtual (line 73). `@inheritdoc IIntegrityToolingV1` (line 72). Correct.
- **`describedByMetaV1()`** external pure override (line 78). `@inheritdoc IDescribedByMetaV1` (line 77). Correct.

### RainterpreterDISPaiRegistry.sol

- **Contract:** `RainterpreterDISPaiRegistry` (line 15), inherits `IDISPaiRegistry`, `ERC165`
- **Contract-level NatSpec:** `@title` (line 9), `@notice` (line 10-14). Correct.
- **`supportsInterface(bytes4)`** public view override (line 17). `@inheritdoc ERC165` (line 16). Correct.
- **`expressionDeployerAddress()`** external pure override (line 22). `@inheritdoc IDISPaiRegistry` (line 21). Correct.
- **`interpreterAddress()`** external pure override (line 27). `@inheritdoc IDISPaiRegistry` (line 26). Correct.
- **`storeAddress()`** external pure override (line 32). `@inheritdoc IDISPaiRegistry` (line 31). Correct.
- **`parserAddress()`** external pure override (line 37). `@inheritdoc IDISPaiRegistry` (line 36). Correct.

### IDISPaiRegistry.sol

- **Interface:** `IDISPaiRegistry` (line 9)
- **Interface-level NatSpec:** `@title` (line 5), `@notice` (line 6-8). Correct.
- **`expressionDeployerAddress()`** (line 12). Doc at lines 10-11: untagged line (10) + `@return` (11).
- **`interpreterAddress()`** (line 16). Doc at lines 14-15: untagged line (14) + `@return` (15).
- **`storeAddress()`** (line 20). Doc at lines 18-19: untagged line (18) + `@return` (19).
- **`parserAddress()`** (line 24). Doc at lines 22-23: untagged line (22) + `@return` (23).

## Findings

### P3-CC-01 (LOW) `Rainterpreter.opcodeFunctionPointers` mixed tagged/untagged NatSpec

**File:** `src/concrete/Rainterpreter.sol`, lines 42-44

The doc block for `opcodeFunctionPointers()` has untagged description lines (42-43) followed by a `@return` tag (44). Per project convention, when any explicit tag is present in a doc block, all entries must be explicitly tagged. The untagged lines are treated as continuation of the previous tag or (when first) as `@notice` by the compiler, but the project convention requires an explicit `@notice` tag.

```solidity
/// Returns the packed 2-byte function pointer table used by the eval loop
/// to dispatch each opcode. Virtual so subclasses can override the table.
/// @return The opcode function pointers for the interpreter.
```

Should be:

```solidity
/// @notice Returns the packed 2-byte function pointer table used by the eval loop
/// to dispatch each opcode. Virtual so subclasses can override the table.
/// @return The opcode function pointers for the interpreter.
```

### P3-CC-02 (LOW) `RainterpreterParser` override functions missing `@inheritdoc`

**File:** `src/concrete/RainterpreterParser.sol`, lines 106-113

`buildOperandHandlerFunctionPointers()` (line 107) and `buildLiteralParserFunctionPointers()` (line 112) are `override` implementations of `IParserToolingV1` but use bare `///` comments instead of `@inheritdoc IParserToolingV1`. Every other override function across all six audited contracts consistently uses `@inheritdoc`. The interface `IParserToolingV1` already has full NatSpec for both functions.

```solidity
/// External function to build the operand handler function pointers.
function buildOperandHandlerFunctionPointers() external pure override returns (bytes memory) {
```

Should be:

```solidity
/// @inheritdoc IParserToolingV1
function buildOperandHandlerFunctionPointers() external pure override returns (bytes memory) {
```

(Same for `buildLiteralParserFunctionPointers`.)

### P3-CC-03 (LOW) `RainterpreterParser` internal virtual functions missing `@return` tags

**File:** `src/concrete/RainterpreterParser.sol`, lines 91-103

Three internal virtual functions (`parseMeta`, `operandHandlerFunctionPointers`, `literalParserFunctionPointers`) each return `bytes memory` but have only a bare `///` description with no `@return` tag. While they are `internal`, their `virtual` visibility means subclasses must understand the return value contract.

```solidity
/// Virtual function to return the parse meta.
function parseMeta() internal pure virtual returns (bytes memory) {
```

Should be:

```solidity
/// @notice Virtual function to return the parse meta.
/// @return The parse meta bytes used to initialize parser state.
function parseMeta() internal pure virtual returns (bytes memory) {
```

(Same pattern for `operandHandlerFunctionPointers` and `literalParserFunctionPointers`.)

### P3-CC-04 (LOW) `IDISPaiRegistry` all four functions have mixed tagged/untagged NatSpec

**File:** `src/interface/IDISPaiRegistry.sol`, lines 10-24

All four interface functions (`expressionDeployerAddress`, `interpreterAddress`, `storeAddress`, `parserAddress`) have an untagged description line followed by a `@return` tag. Per project convention, when any explicit tag is present, all entries must be explicitly tagged.

Example (line 10-11):
```solidity
/// Returns the deterministic deploy address of the expression deployer.
/// @return The expression deployer address.
```

Should be:
```solidity
/// @notice Returns the deterministic deploy address of the expression deployer.
/// @return The expression deployer address.
```

### P3-CC-05 (INFO) `ZeroFunctionPointers` error inconsistent NatSpec style

**File:** `src/error/ErrEval.sol`, lines 13-15

`ZeroFunctionPointers` uses bare `///` with no `@notice` tag, while `InputsLengthMismatch` in the same file (line 8) uses `@notice`. Both are valid NatSpec (no tags means implicit `@notice`), but the inconsistency within a single file is a style issue.
