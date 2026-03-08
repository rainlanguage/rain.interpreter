# Pass 2 -- Test Coverage: Core Concrete Contracts (Agent A01)

## Source Files Reviewed

### 1. `src/abstract/BaseRainterpreterExtern.sol`

**Contract:** `BaseRainterpreterExtern` (abstract)

| Line | Item | Type |
|------|------|------|
| 34-43 | `constructor()` | function |
| 46-80 | `extern(ExternDispatchV2, StackItem[])` | function |
| 83-109 | `externIntegrity(ExternDispatchV2, uint256, uint256)` | function |
| 112-116 | `supportsInterface(bytes4)` | function |
| 121-123 | `opcodeFunctionPointers()` | function (virtual) |
| 128-130 | `integrityFunctionPointers()` | function (virtual) |

**Errors used:**
- `ExternOpcodePointersEmpty` (line 37)
- `ExternPointersMismatch` (line 41)
- `ExternOpcodeOutOfRange` (line 99)

**Test files:**
- `test/src/abstract/BaseRainterpreterExtern.construction.t.sol`
- `test/src/abstract/BaseRainterpreterExtern.ierc165.t.sol`
- `test/src/abstract/BaseRainterpreterExtern.integrityOpcodeRange.t.sol`
- `test/src/concrete/RainterpreterReferenceExtern.intInc.t.sol` (exercises `extern()` and `externIntegrity()` indirectly via concrete subclass)

**Coverage summary:**
- `constructor()`: ExternOpcodePointersEmpty tested, ExternPointersMismatch tested (both directions), valid construction tested. COVERED.
- `extern()`: Tested via RainterpreterReferenceExtern (direct call with valid opcode, mod-wrap with out-of-range opcode). COVERED.
- `externIntegrity()`: Out-of-range revert tested. Boundary (highest valid opcode) tested. Direct dispatch tested via RainterpreterReferenceExtern. COVERED.
- `supportsInterface()`: All four interface IDs tested plus negative fuzz. COVERED.
- `opcodeFunctionPointers()`: Tested via override in test contracts. COVERED.
- `integrityFunctionPointers()`: Tested via override in test contracts. COVERED.

---

### 2. `src/abstract/BaseRainterpreterSubParser.sol`

**Contract:** `BaseRainterpreterSubParser` (abstract)

| Line | Item | Type |
|------|------|------|
| 93-95 | `subParserParseMeta()` | function (virtual) |
| 100-102 | `subParserWordParsers()` | function (virtual) |
| 107-109 | `subParserOperandHandlers()` | function (virtual) |
| 114-116 | `subParserLiteralParsers()` | function (virtual) |
| 139-149 | `matchSubParseLiteralDispatch(uint256, uint256)` | function (virtual) |
| 159-178 | `subParseLiteral2(bytes)` | function |
| 188-212 | `subParseWord2(bytes)` | function |
| 215-219 | `supportsInterface(bytes4)` | function |

**Errors used:**
- `SubParserIndexOutOfBounds` (lines 169, 203)

**Test files:**
- `test/src/abstract/BaseRainterpreterSubParser.ierc165.t.sol`
- `test/src/abstract/BaseRainterpreterSubParser.subParseLiteral2.t.sol`
- `test/src/abstract/BaseRainterpreterSubParser.subParseWord2.t.sol`

**Coverage summary:**
- `subParseLiteral2()`: Happy path tested, no-match path tested, index-out-of-bounds revert tested. COVERED.
- `subParseWord2()`: Index-out-of-bounds revert tested (both mismatched length and empty parsers table). Happy path (word found, parser dispatched successfully) NOT directly tested. No-match path (word not found, returns `(false, "", new bytes32[](0))`) NOT directly tested. These paths ARE tested on the concrete RainterpreterReferenceExtern but not on the base abstract contract's test file.
- `supportsInterface()`: All five interface IDs tested plus negative fuzz. COVERED.
- `matchSubParseLiteralDispatch()`: Default implementation (returns false) tested via NoMatchLiteralSubParser. COVERED.

---

### 3. `src/concrete/Rainterpreter.sol`

**Contract:** `Rainterpreter`

| Line | Item | Type |
|------|------|------|
| 38-40 | `constructor()` | function |
| 49-51 | `opcodeFunctionPointers()` | function (virtual) |
| 54-74 | `eval4(EvalV4)` | function |
| 77-80 | `supportsInterface(bytes4)` | function |
| 83-85 | `buildOpcodeFunctionPointers()` | function |

**Errors used:**
- `ZeroFunctionPointers` (line 39)
- `OddSetLength` (line 64)

**Test files:**
- `test/src/concrete/Rainterpreter.pointers.t.sol`
- `test/src/concrete/Rainterpreter.zeroFunctionPointers.t.sol`
- `test/src/concrete/Rainterpreter.extrospect.t.sol`
- `test/src/concrete/Rainterpreter.eval.nonZeroSourceIndex.t.sol`
- `test/src/concrete/Rainterpreter.eval.t.sol`
- `test/src/concrete/Rainterpreter.stateOverlay.t.sol`
- `test/src/concrete/Rainterpreter.ierc165.t.sol`

**Coverage summary:**
- `constructor()`: ZeroFunctionPointers revert tested, standard deploy tested. COVERED.
- `opcodeFunctionPointers()`: Verified against buildOpcodeFunctionPointers() output. COVERED.
- `eval4()`: Tested with matching inputs, too-many inputs (revert), too-few inputs (revert), non-zero source index, state overlay (odd-length revert, single pair, multiple pairs, duplicate keys, overriding via set). COVERED.
- `supportsInterface()`: All three interface IDs tested plus negative fuzz. COVERED.
- `buildOpcodeFunctionPointers()`: Tested in pointers test. COVERED.
- Extrospection: No disallowed EVM opcodes in bytecode. COVERED.

---

### 4. `src/concrete/RainterpreterStore.sol`

**Contract:** `RainterpreterStore`

| Line | Item | Type |
|------|------|------|
| 40 | `sStore` mapping | state variable |
| 43-45 | `supportsInterface(bytes4)` | function |
| 48-63 | `set(StateNamespace, bytes32[])` | function |
| 66-68 | `get(FullyQualifiedNamespace, bytes32)` | function |

**Errors used:**
- `OddSetLength` (line 52)

**Test files:**
- `test/src/concrete/RainterpreterStore.ierc165.t.sol`
- `test/src/concrete/RainterpreterStore.t.sol`
- `test/src/concrete/RainterpreterStore.getUninitialized.t.sol`
- `test/src/concrete/RainterpreterStore.namespaceIsolation.t.sol`
- `test/src/concrete/RainterpreterStore.overwriteKey.t.sol`
- `test/src/concrete/RainterpreterStore.setEmpty.t.sol`
- `test/src/concrete/RainterpreterStore.setEvent.t.sol`

**Coverage summary:**
- `supportsInterface()`: Both interface IDs tested plus negative fuzz. COVERED.
- `set()`: Odd-length revert tested (fuzz). Empty array tested (no revert, no events). Single pair tested. Multiple pairs tested. Duplicate keys tested (last-write-wins). Events tested (single, multiple, fuzz FQN). COVERED.
- `get()`: Uninitialized key returns zero tested (fixed + fuzz). After setting different key, uninitialized key still zero. Namespace isolation tested (different sender, different namespace, bidirectional). COVERED.
- `sStore` mapping: Tested via set/get. COVERED.

---

## Findings

### A01-1

- **Severity:** LOW
- **Title:** No direct test for `subParseWord2` no-match path on `BaseRainterpreterSubParser`
- **Affected file:** `src/abstract/BaseRainterpreterSubParser.sol`
- **Affected lines:** 209-211
- **Description:** The `subParseWord2` function has a code path where the word is not found in the parse meta (`exists == false`), returning `(false, "", new bytes32[](0))`. This path has no direct test in `test/src/abstract/BaseRainterpreterSubParser.subParseWord2.t.sol`. The only test covering this path is on the concrete `RainterpreterReferenceExtern` subclass (`testRainterpreterReferenceExternIntIncSubParseUnknownWord`), which is not a direct test of the base contract logic. A direct test would construct a `BaseRainterpreterSubParser` derivative with valid parse meta and then call `subParseWord2` with a word that does not appear in the meta, verifying the `(false, "", new bytes32[](0))` return.

### A01-2

- **Severity:** LOW
- **Title:** No direct test for `subParseWord2` happy path on `BaseRainterpreterSubParser`
- **Affected file:** `src/abstract/BaseRainterpreterSubParser.sol`
- **Affected lines:** 197-208
- **Description:** The `subParseWord2` function's happy path -- where a word IS found in the parse meta and is dispatched to the corresponding word parser function pointer -- has no direct test in `test/src/abstract/BaseRainterpreterSubParser.subParseWord2.t.sol`. The existing tests only cover the error path (`SubParserIndexOutOfBounds`). The happy path IS tested via the concrete `RainterpreterReferenceExtern` (`testRainterpreterReferenceExternIntIncSubParseKnownWord`), but a direct test on a minimal base contract derivative would provide isolated coverage of the base dispatch logic. Compare with `subParseLiteral2`, which has a dedicated happy-path test (`testSubParseLiteral2HappyPath`).

### A01-3

- **Severity:** INFO
- **Title:** No test for `subParseLiteral2` with empty literal parsers table when dispatch matches
- **Affected file:** `src/abstract/BaseRainterpreterSubParser.sol`
- **Affected lines:** 166-169
- **Description:** The `subParseLiteral2` function guards against an out-of-range index with `SubParserIndexOutOfBounds`. The existing test (`MismatchedLiteralSubParser`) covers index 1 with a table of length 1. There is no test where the dispatch matches (returns `success == true`) but the literal parsers table is empty (`parsersLength == 0`), which would trigger `SubParserIndexOutOfBounds(0, 0)`. This is the boundary case analogous to `testSubParseWord2RevertsEmptyWordParsers` which does exist for `subParseWord2`. Coverage is symmetry-incomplete, though the code path is equivalent.
