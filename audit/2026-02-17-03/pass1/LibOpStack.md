# Pass 1 (Security) — LibOpStack.sol

## Evidence of Thorough Reading

**File**: `src/lib/op/00/LibOpStack.sol` (62 lines)

**Library**: `LibOpStack`

**Functions**:
| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 17 | `internal` | `pure` |
| `run` | 33 | `internal` | `pure` |
| `referenceFn` | 47 | `internal` | `pure` |

**Errors/Events/Structs defined in this file**: None (imports `OutOfBoundsStackRead` from `src/error/ErrIntegrity.sol`)

**Imports**:
- `Pointer` from `rain.solmem/lib/LibPointer.sol`
- `InterpreterState` from `../../state/LibInterpreterState.sol`
- `IntegrityCheckState` from `../../integrity/LibIntegrityCheck.sol`
- `OperandV2`, `StackItem` from `rain.interpreter.interface/interface/IInterpreterV4.sol`
- `OutOfBoundsStackRead` from `../../../error/ErrIntegrity.sol`

---

## Findings

### INFO-1: `run()` has no runtime bounds check, relies entirely on integrity

**Location**: `run()`, lines 33-42

**Description**: The `run()` function performs no validation that the operand's read index is within the bounds of the allocated stack. It reads from `stackBottom - 0x20 * (readIndex + 1)` without checking that this address falls within the stack's allocated memory region. If `run()` were invoked on bytecode that was not integrity-checked (e.g., deployed through a mechanism that bypasses `RainterpreterExpressionDeployer`), it would read from arbitrary memory preceding the stack bottom.

**Analysis**: This is consistent with the architecture's design. The expression deployer enforces integrity checking at deployment time, and the interpreter only evaluates bytecode that has passed integrity. The `integrity()` function (line 20) validates that `readIndex < state.stackIndex`, ensuring the read is in bounds. The bytecode hash verification in the deployer prevents using an unvalidated interpreter. This is the same trust model used by all opcodes in the system.

**Severity**: INFO -- this is an intentional design decision, not a vulnerability, given the deployer's role as gatekeeper.

---

### INFO-2: Upper 8 bits of the 3-byte operand are silently ignored

**Location**: `integrity()` line 18, `run()` line 37

**Description**: The operand is a 3-byte value (24 bits, as masked to `0xFFFFFF` by the eval loop), but both `integrity()` and `run()` only use the low 16 bits (`0xFFFF` mask). The upper 8 bits of the operand are silently discarded. If an attacker or bug were to set non-zero bits in the upper 8 bits, they would be ignored without error.

**Analysis**: The operand handler for `stack` is `handleOperandSingleFull` (confirmed in `LibAllStandardOps.operandHandlerFunctionPointers()` at line 374), which writes a single value into the full operand space. The parser enforces that the operand value fits in the available space. At the bytecode level, the IO byte occupies one of the three operand bytes (byte 29 of the 4-byte op word contains the IO byte, not the operand -- see `LibIntegrityCheck.integrityCheck2`). Looking at the eval loop, the operand is the low 3 bytes of the 4-byte op word, and the bytecode structure packs the IO byte in byte position 29 (which is byte index 1 of the 4-byte op). The `0xFFFF` mask correctly extracts only the meaningful read-index portion. No data is truly lost because the operand handler for stack only writes 16 bits.

**Severity**: INFO -- the masking is consistent between `integrity()` and `run()`, and the operand handler constrains what values can be written.

---

### INFO-3: Integrity and run I/O counts are consistent

**Location**: `integrity()` returns `(0, 1)` at line 29; `run()` pushes exactly one value at lines 38-39 and consumes zero stack inputs.

**Description**: Verified that the integrity function declares 0 inputs and 1 output, which matches the runtime behavior: `run()` reads from a specific stack position (not from the top) and pushes one new value onto the stack top. The stack copy reads by absolute index from the stack bottom, not by consuming the top, so 0 inputs is correct.

**Severity**: INFO -- no issue found, confirming correctness.

---

### INFO-4: Assembly is correctly marked `memory-safe`

**Location**: `run()` line 35, `referenceFn()` line 58

**Description**: The assembly block in `run()` reads from `state` (its `stackBottoms` field, which is existing memory), reads from a stack position (existing allocated memory), and writes to `stackTop - 0x20` (the next position in the pre-allocated stack growing downward). It does not allocate new memory or write outside the stack region (assuming valid integrity). The assembly block in `referenceFn()` writes into a freshly allocated Solidity array at a valid offset (`outputs + 0x20` = first element). Both blocks satisfy the `memory-safe` annotation requirements.

**Severity**: INFO -- no issue found.

---

### INFO-5: `referenceFn` uses Solidity checked arithmetic for safety

**Location**: `referenceFn()`, lines 52-60

**Description**: The reference function uses Solidity's default checked arithmetic for computing `readPointer` (line 56: `stackBottom - (readIndex + 1) * 0x20`), which would revert on underflow. Additionally, the array access `state.stackBottoms[state.sourceIndex]` on line 55 is bounds-checked by Solidity. This correctly provides a safer reference implementation for testing. The only assembly is writing the loaded value into the output array.

**Severity**: INFO -- good defensive practice in test reference code.

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW issues were identified in `LibOpStack.sol`. The library is small, focused, and follows the codebase's security model where runtime opcodes rely on deploy-time integrity checking for safety. The assembly is minimal and correct. The operand masking is consistent between `integrity()` and `run()`. All reverts use custom errors (no string reverts).
