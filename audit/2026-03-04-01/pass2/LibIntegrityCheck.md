# A29 -- Pass 2 (Test Coverage) -- LibIntegrityCheck.sol

**Source:** `src/lib/integrity/LibIntegrityCheck.sol`
**Test files:**
- `test/src/lib/integrity/LibIntegrityCheck.t.sol`
- `test/src/lib/integrity/LibIntegrityCheck.badOpIO.t.sol`
- `test/src/lib/integrity/LibIntegrityCheck.highwater.t.sol`
- `test/src/lib/integrity/LibIntegrityCheck.multiSource.t.sol`
- `test/src/lib/integrity/LibIntegrityCheck.newState.t.sol`
- `test/src/lib/integrity/LibIntegrityCheck.stackMaxIndex.t.sol`
- `test/src/lib/integrity/LibIntegrityCheck.zeroSource.t.sol`

## Evidence

### Struct: `IntegrityCheckState` (line 35)

6 fields: `stackIndex`, `stackMaxIndex`, `readHighwater`, `constants`, `opIndex`, `bytecode`. All initialized and tested via `newState` fuzz test.

### Library: `LibIntegrityCheck`

| Function | Line | Coverage |
|----------|------|----------|
| `newState` | 56 | Fuzz tested -- all 6 fields verified (`newState.t.sol`) |
| `integrityCheck2` | 91 | All 7 error paths directly tested, multi-source tested, zero-source tested |

### Error paths in `integrityCheck2`

| Error | Line | Coverage |
|-------|------|----------|
| `OpcodeOutOfRange` | 157 | Fuzz tested (`t.sol::testOpcodeOutOfRange`) |
| `BadOpInputsLength` | 164 | Direct test (`badOpIO.t.sol::testBadOpInputsLength`) |
| `BadOpOutputsLength` | 167 | Direct test (`badOpIO.t.sol::testBadOpOutputsLength`) |
| `StackUnderflow` | 171 | Direct test (`t.sol::testStackUnderflow`) |
| `StackUnderflowHighwater` | 177 | Direct test (`t.sol::testStackUnderflowHighwater`) |
| `StackAllocationMismatch` | 200 | Direct test (`t.sol::testStackAllocationMismatch`) |
| `StackOutputsMismatch` | 204 | Direct test (`t.sol::testStackOutputsMismatch`) |

### Logic branches

| Branch | Line | Coverage |
|--------|------|----------|
| `calcOpOutputs > 1` advances highwater | 190-192 | Tested (`highwater.t.sol`) |
| `stackMaxIndex` tracks peak, not final | 185-187 | Tested (`stackMaxIndex.t.sol`) |
| Zero-source bytecode | 124 (loop skipped) | Tested (`zeroSource.t.sol`) |
| Multi-source iteration | 124 | Tested with 2 and 3 sources (`multiSource.t.sol`) |
| `io` return value encoding | 128-131 | Not directly asserted (see INFO below) |

### Prior findings status

| Finding | Status |
|---------|--------|
| P2-EI-2 (BadOpInputsLength/BadOpOutputsLength not tested directly) | FIXED -- `LibIntegrityCheck.badOpIO.t.sol` |

## Findings

No LOW+ findings. All error paths are directly tested.

### A29-P2-1 (INFO): `io` return value never asserted

The packed `io` byte array returned by `integrityCheck2` is never asserted in any test. In production, the return value is unused (`RainterpreterExpressionDeployer.sol` line 58: `(io);`). No action needed while the return value remains dead.

### A29-P2-2 (INFO): Most error path tests use fixed values rather than fuzz

`OpcodeOutOfRange` is the only fuzz-tested error path. The remaining 6 error paths use fixed hand-built bytecode. Fuzz testing these would require generating structurally valid bytecode with controlled corruption, which adds complexity without proportional coverage improvement since the checks are simple comparisons.
