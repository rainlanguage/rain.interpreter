# Pass 1: Security Review -- LibOpCore

Agent: A15
Date: 2026-03-07

## Files Reviewed

### 1. LibAllStandardOps.sol
`/Users/thedavidmeister/Code/rain.interpreter/src/lib/op/LibAllStandardOps.sol`

- **Library**: `LibAllStandardOps`
- **Constant**: `ALL_STANDARD_OPS_LENGTH = 72` (line 105)
- **Functions**:
  - `authoringMetaV2()` (line 120) -- builds authoring meta for all 72 standard opcodes
  - `literalParserFunctionPointers()` (line 344) -- builds literal parser function pointer array
  - `operandHandlerFunctionPointers()` (line 377) -- builds operand handler function pointer array
  - `integrityFunctionPointers()` (line 549) -- builds integrity check function pointer array
  - `opcodeFunctionPointers()` (line 653) -- builds runtime opcode function pointer array
- **Observations**:
  - All four opcode arrays (authoring meta, operand handlers, integrity, runtime) have 72 entries each, matching `ALL_STANDARD_OPS_LENGTH`.
  - The `now` alias correctly uses `LibOpBlockTimestamp.integrity` and `LibOpBlockTimestamp.run` at the same array index in all four arrays.
  - Each array uses the same fixed-to-dynamic reinterpretation pattern with a length placeholder at index 0, sanity-checked by `BadDynamicLength`.
  - Assembly blocks reinterpret fixed-size arrays as dynamic arrays by overwriting the length slot. This is the standard pattern used throughout the codebase.

### 2. LibOpCall.sol
`/Users/thedavidmeister/Code/rain.interpreter/src/lib/op/call/LibOpCall.sol`

- **Library**: `LibOpCall`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` (line 85) -- validates source index, checks outputs do not exceed callee's source outputs
  - `run(InterpreterState memory, OperandV2, Pointer)` (line 122) -- executes a call to another source, copies inputs/outputs between stacks
- **Operand layout** (24-bit):
  - bits [0,16): sourceIndex
  - bits [16,20): inputs (4 bits, from IO byte)
  - bits [20,24): outputs (4 bits, from IO byte)
- **Observations**:
  - `integrity` extracts `sourceIndex` and `outputs` from the operand, delegates source validation to `LibBytecode.sourceInputsOutputsLength` (which reverts with `SourceIndexOutOfBounds`).
  - `run` accesses `stackBottoms[sourceIndex]` via unchecked assembly pointer arithmetic (line 136). Safety depends on integrity having validated `sourceIndex`.
  - Input copy loop (lines 138-142) copies values in reverse order from caller to callee stack. Output copy loop (lines 159-166) copies in forward order from callee to caller.
  - `state.sourceIndex` is saved and restored around the `evalLoop` call (lines 147, 156).
  - No recursion guard: a source can `call` itself, leading to infinite recursion and gas exhaustion. This is documented in the NatSpec (line 51) as unsupported but not prevented.

### 3. LibOpConstant.sol
`/Users/thedavidmeister/Code/rain.interpreter/src/lib/op/00/LibOpConstant.sol`

- **Library**: `LibOpConstant`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` (line 21) -- validates constant index is within bounds, reverts with `OutOfBoundsConstantRead`
  - `run(InterpreterState memory, OperandV2, Pointer)` (line 37) -- copies constant to stack via assembly
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` (line 52) -- reference implementation for testing
- **Observations**:
  - `integrity` provides an explicit bounds check with descriptive error before the runtime's unchecked access.
  - `run` uses unchecked assembly to index into `constants` (line 41). Safety relies on `integrity` having validated the index.
  - The operand mask `and(operand, 0xFFFF)` extracts the low 16 bits as the constant index.

### 4. LibOpContext.sol
`/Users/thedavidmeister/Code/rain.interpreter/src/lib/op/00/LibOpContext.sol`

- **Library**: `LibOpContext`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` (line 16) -- returns (0, 1), no bounds checking possible since context shape is unknown at deploy time
  - `run(InterpreterState memory, OperandV2, Pointer)` (line 28) -- reads from context matrix using Solidity bounds-checked access
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` (line 47) -- reference implementation
- **Observations**:
  - Row and column indices are 8 bits each (lines 29-30), extracted from the low two bytes of the operand.
  - Context access at line 35 (`state.context[i][j]`) uses Solidity array indexing, which provides automatic OOB revert. This is correct since context shape is unknown at compile time.
  - The assembly block only writes the already-loaded value to the stack.

### 5. LibOpExtern.sol
`/Users/thedavidmeister/Code/rain.interpreter/src/lib/op/00/LibOpExtern.sol`

- **Library**: `LibOpExtern`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` (line 29) -- validates extern interface via ERC165, delegates to extern's own integrity check
  - `run(InterpreterState memory, OperandV2, Pointer)` (line 49) -- constructs in-place input array, calls extern, copies outputs to stack
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` (line 102) -- reference implementation with output reversal
- **Operand layout** (24-bit):
  - bits [0,16): encodedExternDispatchIndex
  - bits [16,20): inputs (4 bits)
  - bits [20,24): outputs (4 bits)
- **Observations**:
  - `integrity` accesses `state.constants[encodedExternDispatchIndex]` with Solidity bounds checking (line 33). OOB reverts with a generic Solidity panic rather than a descriptive custom error.
  - `run` constructs an in-place array by temporarily overwriting the word before `stackTop` (lines 59-70). The original value is saved in `head` and restored at line 79. This is safe because `extern.extern()` is an external call (isolated memory context) and the mutation is reversed after.
  - Output copy loop (lines 89-92) iterates forward through extern outputs but writes to the stack top-down, effectively reversing the output order. This matches `referenceFn` which explicitly reverses outputs.
  - `BadOutputsLength` check at line 72-73 ensures the extern returned the expected number of outputs.
  - Both `inputs` and `outputs` extraction (lines 51-52) use `& 0x0F` to mask to 4 bits. In `integrity` (lines 38-39), the same masking is applied. Consistent.

### 6. LibOpStack.sol
`/Users/thedavidmeister/Code/rain.interpreter/src/lib/op/00/LibOpStack.sol`

- **Library**: `LibOpStack`
- **Functions**:
  - `integrity(IntegrityCheckState memory, OperandV2)` (line 21) -- validates read index against current stack depth, updates read highwater
  - `run(InterpreterState memory, OperandV2, Pointer)` (line 41) -- copies value from stack position to stack top via assembly
  - `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory)` (line 58) -- reference implementation with Solidity bounds-checked access
- **Observations**:
  - `integrity` checks `readIndex >= state.stackIndex` (line 24) and reverts with `OutOfBoundsStackRead`. Updates `readHighwater` if needed (lines 29-31).
  - `run` loads `stackBottoms` from `state` via assembly (`mload(state)` at line 44), then indexes into it unchecked. Safety depends on `sourceIndex` and `readIndex` being validated at integrity time.
  - The read is relative to `stackBottom`: `stackBottom - (readIndex + 1) * 0x20`. Item 0 is the first value pushed (closest to bottom), which is the lexically earliest value in the source.

## Security Analysis

### Memory Safety
- All assembly blocks are marked `memory-safe`.
- `LibOpConstant.run` and `LibOpStack.run` perform unchecked memory reads, but these are bounded by integrity checks that validate indices at deploy time.
- `LibOpExtern.run` temporarily mutates memory before `stackTop` to construct an array header. The original value is saved and restored. The external call provides memory isolation.
- `LibOpCall.run` copies between caller/callee stacks using unchecked assembly. Stack allocation is validated by `integrityCheck2` ensuring sufficient space.

### Stack Underflow/Overflow
- `LibIntegrityCheck.integrityCheck2` validates that each opcode's declared inputs do not exceed the current stack depth (line 170-171) and that the stack index never drops below the read highwater (lines 176-178).
- Stack allocation is validated to match bytecode declarations (line 199).
- Final stack depth is validated to match declared outputs (line 204).
- All four core opcodes (stack, constant, context, extern) correctly report their inputs and outputs in integrity, matching their runtime behavior.

### Integrity vs. Run Consistency
- `LibOpConstant`: integrity validates `constantIndex < constants.length`; run uses the same index unchecked. Consistent.
- `LibOpContext`: integrity cannot validate (context shape unknown); run uses Solidity bounds checking. Correct design.
- `LibOpStack`: integrity validates `readIndex < stackIndex`; run uses the same index unchecked. Consistent.
- `LibOpExtern`: integrity validates extern interface and delegates to extern's integrity; run calls the extern. Consistent.
- `LibOpCall`: integrity validates `sourceIndex` via `sourceInputsOutputsLength` and checks `outputs <= sourceOutputs`; run uses the same fields. Consistent.

### Function Pointer Table Safety
- `LibAllStandardOps` builds four parallel arrays with the same ordering, each validated by `BadDynamicLength` sanity checks.
- `integrityCheck2` bounds-checks opcode indices against `fsCount` before function pointer lookup (line 156-158).
- The eval loop uses `mod(opcodeIndex, fsCount)` for function pointer lookup, preventing OOB reads into the pointer table.

### Input Validation
- `LibOpCall.integrity` does not extract `inputs` from the operand -- it gets `sourceInputs` from bytecode metadata. The integrity checker then validates that this matches the bytecode's IO byte, which is the same value `run` extracts from bits 16-19 of the operand. Consistent.
- `LibOpExtern.integrity` passes `expectedInputsLength` and `expectedOutputsLength` to the extern's own integrity check. A malicious extern could return incorrect values, but these would fail the IO byte cross-check in `integrityCheck2`.

## Findings

No findings.

All six files demonstrate consistent integrity-vs-runtime validation patterns, correct memory safety practices in assembly blocks, and proper bounds checking. The trust model (integrity must be run before eval) is consistently maintained. The `LibAllStandardOps` parallel arrays are correctly sized and ordered. No exploitable security issues were identified.
