# Pass 1 (Security) -- LibOpBitwiseCountOnes (A36)

**File:** `src/lib/op/bitwise/LibOpBitwiseCountOnes.sol` (52 lines)

## Evidence Inventory

| Item | Kind | Line |
|------|------|------|
| `LibOpBitwiseCountOnes` | library | 15 |
| `integrity` | internal pure function | 19 |
| `run` | internal pure function | 27 |
| `referenceFn` | internal pure function | 44 |

**Imports:**
- `Pointer` from `rain.solmem/lib/LibPointer.sol` (line 5)
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol` (line 6)
- `InterpreterState` from `../../state/LibInterpreterState.sol` (line 7)
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol` (line 8)
- `LibCtPop` from `rain.math.binary/lib/LibCtPop.sol` (line 9)

No custom errors, constants, or types defined.

## Analysis

### Integrity inputs/outputs

Returns `(1, 1)` -- one input consumed, one output produced. Matches the runtime behavior: `run` reads one stack item, computes ctpop, writes result back in-place. Stack pointer unchanged.

### Assembly memory safety

**Block 1 (lines 29-31):** Reads `mload(stackTop)` into `value`. Read-only, correctly `memory-safe`.

**Block 2 (lines 35-37):** Writes `value` back to `mstore(stackTop, value)`. In-place modification of pre-existing stack slot. Correctly `memory-safe`.

### Unchecked block (lines 32-34)

`LibCtPop.ctpop(value)` is called inside `unchecked`. The ctpop function performs bit manipulation (population count) that cannot overflow -- it returns a value in [0, 256]. Safe.

### Stack underflow/overflow

Integrity declares (1, 1). Run consumes 1 and produces 1 in-place. No risk.

### Operand validation

The operand is unused. No validation needed.

### Reference function consistency

`referenceFn` uses `LibCtPop.ctpopSlow` (naive loop implementation) while `run` uses `LibCtPop.ctpop` (optimized). Both compute population count. The use of different implementations strengthens testing by cross-validating the optimized path against a trivially-correct slow path.

## Findings

No findings.
