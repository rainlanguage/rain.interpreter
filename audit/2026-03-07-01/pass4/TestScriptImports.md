# Pass 4: Code Quality — Test & Script Files (Bare `src/` Imports)

**Scope:** All `.sol` files under `test/` (226 files) and `script/` (3 files)

## Checks Performed

### Bare `src/` import paths
**Result:** 525 occurrences across 226 test files, plus 7 occurrences in `script/BuildPointers.sol`.

Every test and script file that imports from the project's own source tree uses bare `src/` paths (e.g., `from "src/lib/parse/LibParse.sol"`). These break when the project is consumed as a git submodule because `src/` resolves to the consuming project's source directory, not the submodule's.

### Other pass 4 checks (style, commented-out code, etc.)
Already covered by prior pass 4 agents (CoreConcrete.md, LibEvalParse.md, LibOpAll.md, RustCrates.md) for all `src/` and `crates/` files. No re-review needed for those scopes.

---

## Findings

### P4-TEST-01 (LOW): 525 bare `src/` imports across 226 test files

**Files:** All 226 `.sol` files under `test/` that import from `src/`.

**Description:** Every test file uses bare `src/` import paths. Example from `test/src/lib/parse/LibParse.operandDoublePerByteNoDefault.t.sol`:

```solidity
import {ExpectedOperand, UnclosedOperand, UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParse} from "src/lib/parse/LibParse.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";
```

These should use relative paths or remapped paths to work correctly when the repo is a submodule dependency.

**Proposed fix:** Replace all `from "src/` with relative paths (e.g., `from "../../src/`) computed from each file's location, or add a foundry remapping.

---

### P4-SCRIPT-01 (LOW): 7 bare `src/` imports in `script/BuildPointers.sol`

**File:** `script/BuildPointers.sol` (lines 6-16)

**Description:** All 7 imports in this script file use bare `src/` paths:

```solidity
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParser, PARSE_META_BUILD_DEPTH} from "src/concrete/RainterpreterParser.sol";
import {RainterpreterExpressionDeployer} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterDISPaiRegistry} from "src/concrete/RainterpreterDISPaiRegistry.sol";
...
import {LibAllStandardOps} from "src/lib/op/LibAllStandardOps.sol";
```

Same issue as P4-TEST-01: these paths break under submodule usage.

**Proposed fix:** Replace with relative paths or remapped paths.

---

## Summary

| ID | Severity | Category | Description |
|----|----------|----------|-------------|
| P4-TEST-01 | LOW | Bare `src/` imports | 525 bare `src/` imports across 226 test files |
| P4-SCRIPT-01 | LOW | Bare `src/` imports | 7 bare `src/` imports in `script/BuildPointers.sol` |
