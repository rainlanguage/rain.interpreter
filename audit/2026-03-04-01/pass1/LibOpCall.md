# A42 -- Pass 1 (Security) -- LibOpCall.sol

**File:** `src/lib/op/call/LibOpCall.sol`

## Evidence

### Library
- `LibOpCall` (line 69)

### Functions
| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity` | 85 | `internal` | `pure` |
| `run` | 122 | `internal` | `view` |

### Types / Errors / Constants
- Import: `CallOutputsExceedSource` (from `src/error/ErrIntegrity.sol`)
- Import: `OperandV2` (user-defined value type wrapping `bytes32`)
- Import: `InterpreterState` (struct from `LibInterpreterState.sol`)
- Import: `IntegrityCheckState` (struct from `LibIntegrityCheck.sol`)
- Import: `Pointer` (user-defined value type from `rain.solmem`)
- Import: `LibBytecode` (from `rain.interpreter.interface`)
- Import: `LibEval` (from `src/lib/eval/LibEval.sol`)

### Assembly Blocks
1. Lines 135-143: Copy inputs from caller stack to callee stack (reverse order). Tagged `memory-safe`.
2. Lines 159-167: Copy outputs from callee stack to caller stack. Tagged `memory-safe`.

## Security Review

### 1. Assembly Memory Safety

**Block 1 (lines 135-143) -- input copy:**
- Reads `evalStackBottom` from `stackBottoms[sourceIndex]` via unchecked pointer arithmetic: `mload(add(stackBottoms, mul(add(sourceIndex, 1), 0x20)))`.
- Writes to `evalStackTop` region (callee's pre-allocated stack, growing downward from `evalStackBottom`).
- Reads from `stackTop` region (caller's stack, growing upward toward the stack bottom).
- Both regions are within previously allocated memory. The callee's stack allocation (from `LibBytecode.sourceStackAllocation`) accounts for `sourceInputs` slots. The integrity check guarantees `inputs == sourceInputs` (via the IO byte in bytecode, validated by `integrityCheck2` against the return value of `integrity`).
- `memory-safe` annotation is correct: no allocation, reads/writes within known bounds.

**Block 2 (lines 159-167) -- output copy:**
- Adjusts `stackTop` downward by `outputs * 0x20` (making room on caller stack).
- Copies `outputs` values from `evalStackTop` (callee's final stack) to `stackTop` region.
- The integrity check ensures `outputs <= sourceOutputs` (line 92-94), so the read from the callee's stack cannot exceed the values actually produced by `evalLoop`.
- `memory-safe` annotation is correct.

### 2. Unchecked `stackBottoms` Array Access

`stackBottoms[sourceIndex]` is accessed via raw pointer arithmetic without Solidity bounds checking. This is safe because:
- `integrity` calls `LibBytecode.sourceInputsOutputsLength(state.bytecode, sourceIndex)`, which internally calls `sourceRelativeOffset`, which reverts with `SourceIndexOutOfBounds` if `sourceIndex >= sourceCount(bytecode)`.
- The `stackBottoms` array is built from the same bytecode (in `LibInterpreterState.stackBottoms`), so `stackBottoms.length == sourceCount(bytecode)`.
- Bytecode is immutable once serialized. The integrity check runs at deploy time, and the bytecode cannot be modified after.
- Documented in NatSpec at lines 111-116.

### 3. Operand Decoding Consistency

The operand encoding is:
- Bits 0-15: `sourceIndex` (from parser's `handleOperandSingleFull`)
- Bits 16-19: `inputs` (from parser's IO byte, low nibble)
- Bits 20-23: `outputs` (from parser's IO byte, high nibble)

In `integrity`, `sourceIndex` and `outputs` are extracted from the operand. The function returns `(sourceInputs, outputs)` where `sourceInputs` comes from the bytecode's declared inputs for the target source. `integrityCheck2` then validates that `sourceInputs` matches the IO byte's input count (`bytecodeOpInputs`), ensuring consistency.

In `run`, `inputs` is extracted from bits 16-19 (the IO byte low nibble) and `outputs` from bits 20+ (IO byte high nibble). Since the operand is always 24 bits (3-byte mask in `evalLoop`), `outputs` is bounded to 0-15. These values were validated at deploy time by the integrity check. No discrepancy exists between integrity-time and runtime operand interpretation.

### 4. Recursive Call Risk

Recursion (direct or mutual) leads to unbounded gas consumption and eventual OOG revert. There is no explicit recursion guard. This is documented behavior (NatSpec lines 50-53) and tested (`testOpCallRunRecursive`). The interpreter operates in a `view` context, so there are no state-changing side effects from the failed recursive call. The gas limit provides the termination guarantee.

### 5. `CallOutputsExceedSource` Error

Correctly reverts when caller requests more outputs than the callee source provides (line 92-94). The error includes both values for diagnostics.

### 6. `state.sourceIndex` Save/Restore

Lines 147-156 save `state.sourceIndex`, set it to the callee's source index, run `evalLoop`, then restore the original. If the callee itself calls another source, the same save/restore pattern applies via nested `run` invocations. The restore at line 156 always executes because `evalLoop` either returns normally or reverts (no silent failure path). Correct.

## Findings

No LOW+ findings. All assembly is memory-safe and operates within pre-allocated stack regions. Operand decoding is consistent between integrity and runtime. The unchecked array access into `stackBottoms` is protected by deploy-time integrity validation of `sourceIndex`. Recursive calls are bounded by gas and documented as unsupported. Custom errors are used for all revert paths.
