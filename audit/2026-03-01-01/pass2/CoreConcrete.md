# Pass 2: Test Coverage — Core Concrete Contracts

**Audit:** 2026-03-01-01
**Agent IDs:** A45, A46, A47, A48, A13

## Findings

### P2-CC-01 (LOW) `Rainterpreter.supportsInterface` omits `IOpcodeToolingV1` (A45)

`Rainterpreter` inherits `IOpcodeToolingV1` and implements `buildOpcodeFunctionPointers()`, but its `supportsInterface()` does not return `true` for `IOpcodeToolingV1.interfaceId`. This is inconsistent with `RainterpreterParser` (which includes `IParserToolingV1`) and `RainterpreterExpressionDeployer` (which includes `IIntegrityToolingV1`). The ERC165 test at `test/src/concrete/Rainterpreter.ierc165.t.sol` reflects the current (incomplete) code — it only checks `IERC165` and `IInterpreterV4`.

### P2-CC-02 (LOW) `RainterpreterExpressionDeployer` missing dedicated pointer consistency test (A47)

Both `Rainterpreter` and `RainterpreterParser` have dedicated `*.pointers.t.sol` test files. `RainterpreterExpressionDeployer` does not. Its `INTEGRITY_FUNCTION_POINTERS` is only checked as a sanity assertion inside the `RainterpreterExpressionDeployerDeploymentTest` abstract constructor (line 123-128), which produces an unclear revert rather than a named test failure.

### P2-CC-03 (LOW) Missing direct test for `StateNamespace` isolation (same sender) (A48)

The namespace isolation tests in `RainterpreterStore.namespaceIsolation.t.sol` verify different `msg.sender` addresses are isolated. The complementary case — same `msg.sender`, different `StateNamespace` — is not directly tested. It's indirectly covered by fuzz tests but not by a named test.

### P2-CC-04 (INFO) `DISPaiRegistry` does not test that returned addresses are mutually distinct

Each getter is tested individually to match its constant and be non-zero, but there's no assertion that all four returned addresses are distinct from each other.
