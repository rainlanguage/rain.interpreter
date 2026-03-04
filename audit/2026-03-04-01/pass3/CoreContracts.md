# Pass 3 -- Core Contracts NatSpec Audit

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

## Findings

### A01-P3-1 [INFO] Missing `@title` on `BaseRainterpreterExtern`

**File:** `src/abstract/BaseRainterpreterExtern.sol`, line 26

The contract-level NatSpec block for `BaseRainterpreterExtern` has no `@title` tag. All other contracts and libraries in the audited set (`Rainterpreter`, `RainterpreterDISPaiRegistry`, `RainterpreterExpressionDeployer`, `RainterpreterParser`, `RainterpreterStore`, `RainterpreterReferenceExtern`, `LibRainterpreterReferenceExtern`) have `@title`.

Current:
```solidity
/// Base implementation of `IInterpreterExternV4`. Inherit from this contract,
/// and override `opcodeFunctionPointers` and `integrityFunctionPointers` to
/// provide lists of function pointers.
abstract contract BaseRainterpreterExtern is ...
```

Suggested:
```solidity
/// @title BaseRainterpreterExtern
/// @notice Base implementation of `IInterpreterExternV4`. Inherit from this
/// contract, and override `opcodeFunctionPointers` and
/// `integrityFunctionPointers` to provide lists of function pointers.
abstract contract BaseRainterpreterExtern is ...
```

---

### A01-P3-2 [INFO] Missing `@return` on `integrityFunctionPointers()`

**File:** `src/abstract/BaseRainterpreterExtern.sol`, line 125

The internal virtual function `integrityFunctionPointers()` returns `bytes memory` but its NatSpec block lacks a `@return` tag. The sibling function `opcodeFunctionPointers()` (line 118) has both `@notice` and `@return`.

Current:
```solidity
/// Overrideable function to provide the list of function pointers for
/// integrity checks.
function integrityFunctionPointers() internal pure virtual returns (bytes memory) {
```

Suggested:
```solidity
/// @notice Overrideable function to provide the list of function pointers
/// for integrity checks.
/// @return The integrity function pointers for the extern.
function integrityFunctionPointers() internal pure virtual returns (bytes memory) {
```

---

### A02-P3-1 [INFO] Missing `@title` on `BaseRainterpreterSubParser`

**File:** `src/abstract/BaseRainterpreterSubParser.sol`, line 42

The contract-level NatSpec block for `BaseRainterpreterSubParser` has no `@title` tag. The block is lengthy (lines 42-77) and uses no explicit tags, making the entire block an implicit `@notice`. Adding `@title` would also require explicitly tagging the remaining content as `@notice` per the project NatSpec convention.

Current (first two lines):
```solidity
/// Base implementation of `ISubParserV4`. Inherit from this contract and
/// override the virtual functions to align all the relevant pointers and
```

Suggested (first three lines):
```solidity
/// @title BaseRainterpreterSubParser
/// @notice Base implementation of `ISubParserV4`. Inherit from this contract
/// and override the virtual functions to align all the relevant pointers and
```

---

### A02-P3-2 [INFO] Missing `@return` on four internal virtual functions

**File:** `src/abstract/BaseRainterpreterSubParser.sol`, lines 90, 97, 104, 111

Four internal virtual functions all return `bytes memory` but lack `@return` documentation:

- `subParserParseMeta()` (line 90)
- `subParserWordParsers()` (line 97)
- `subParserOperandHandlers()` (line 104)
- `subParserLiteralParsers()` (line 111)

The sibling function `matchSubParseLiteralDispatch()` (line 118) has full NatSpec including `@notice`, `@param`, and `@return` for all three return values.

## No Findings

The following files had no NatSpec issues:

- **A03** (`Rainterpreter.sol`): All public/external functions use `@inheritdoc` or have complete NatSpec. Contract has `@title` and `@notice`. Internal `opcodeFunctionPointers()` has `@notice` and `@return`.
- **A04** (`RainterpreterDISPaiRegistry.sol`): All functions use `@inheritdoc`. Contract has `@title` and `@notice`.
- **A05** (`RainterpreterExpressionDeployer.sol`): All functions use `@inheritdoc` or have `@notice` + `@inheritdoc`. Contract has `@title` and `@notice`.
- **A06** (`RainterpreterParser.sol`): All public/external functions have complete NatSpec or use `@inheritdoc`. Contract has `@title`, `@notice`, and `@dev`. Internal functions have `@notice` and `@return`.
- **A07** (`RainterpreterStore.sol`): All functions use `@inheritdoc`. Contract has `@title` and `@notice`. State variable has untagged (implicit `@notice`) NatSpec.
- **A08** (`RainterpreterReferenceExtern.sol`): All public/external functions have complete NatSpec with `@notice`/`@return` or use `@inheritdoc`. Both the library and contract have `@title` and `@notice`.
