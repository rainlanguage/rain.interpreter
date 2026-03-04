# Pass 2: Test Coverage -- RainterpreterDISPaiRegistry

**Audit:** 2026-03-04-01
**Source:** `src/concrete/RainterpreterDISPaiRegistry.sol`
**Agent ID:** A04

## Evidence

### Functions and line numbers

| Function | Line | Tested |
|---|---|---|
| `supportsInterface()` | 17 | Fuzz tested |
| `expressionDeployerAddress()` | 22 | Tested; value matches constant, non-zero |
| `interpreterAddress()` | 27 | Tested; value matches constant, non-zero |
| `storeAddress()` | 32 | Tested; value matches constant, non-zero |
| `parserAddress()` | 37 | Tested; value matches constant, non-zero |

### Test files

- `test/src/concrete/RainterpreterDISPaiRegistry.ierc165.t.sol`
- `test/src/concrete/RainterpreterDISPaiRegistry.t.sol`
- `test/src/lib/deploy/LibInterpreterDeploy.t.sol`

## Findings

### P2-A04-01 (INFO) No test verifying all four returned addresses are mutually distinct

Each getter is tested individually to match its constant and be non-zero. However there is no test asserting that all four addresses are distinct from each other. If a constant-cascading bug caused two components to resolve to the same address, no test would catch it.

Carryover from audit `2026-03-01-01` finding `P2-CC-04`.
