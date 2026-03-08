# Pass 2 -- Test Coverage Audit: LibEval, LibIntegrityCheck, LibInterpreterState, LibInterpreterStateDataContract

Agent: A03

## Source Files Reviewed

### 1. `src/lib/eval/LibEval.sol`

- **Library:** `LibEval`
- **Functions:**
  - `evalLoop` (line 41) -- internal view, dispatches opcodes from bytecode in 8-at-a-time unrolled loop plus remainder loop
  - `eval4` (line 191) -- internal view, top-level entry point; validates inputs length, copies inputs, calls evalLoop, constructs output array

### 2. `src/lib/integrity/LibIntegrityCheck.sol`

- **Library:** `LibIntegrityCheck`
- **Struct:** `IntegrityCheckState` (line 35)
- **Functions:**
  - `newState` (line 56) -- internal pure, builds fresh IntegrityCheckState with stackIndex/stackMaxIndex/readHighwater all set to inputs count
  - `integrityCheck2` (line 91) -- internal view, walks every opcode in every source checking IO, stack bounds, highwater, allocation, and outputs; returns packed `io` bytes

### 3. `src/lib/state/LibInterpreterState.sol`

- **Library:** `LibInterpreterState`
- **Struct:** `InterpreterState` (line 42)
- **Constant:** `STACK_TRACER` (line 17)
- **Functions:**
  - `stackBottoms` (line 62) -- internal pure, converts pre-allocated stack arrays into bottom-pointer array
  - `stackTrace` (line 126) -- internal view, emits stack trace via staticcall to STACK_TRACER

### 4. `src/lib/state/LibInterpreterStateDataContract.sol`

- **Library:** `LibInterpreterStateDataContract`
- **Functions:**
  - `serializeSize` (line 26) -- internal pure, computes byte size for serialization
  - `unsafeSerialize` (line 39) -- internal pure, writes constants+bytecode into memory region
  - `unsafeDeserialize` (line 69) -- internal pure, reconstructs InterpreterState from serialized bytes

## Test Files Reviewed

### LibEval tests (6 files):
| File | What it tests |
|------|---------------|
| `test/src/lib/eval/LibEval.fBounds.t.sol` | Mod wrapping of opcode indices in function pointer table (37 ops = 4x8 + 5 remainder) |
| `test/src/lib/eval/LibEval.opcodeCountEdgeCases.t.sol` | Zero opcodes, zero with inputs, exactly 8, exactly 16 opcodes |
| `test/src/lib/eval/LibEval.remainderOnly.t.sol` | 7 opcodes (remainder-only path, fuzzed constants) |
| `test/src/lib/eval/LibEval.maxOutputs.t.sol` | maxOutputs truncation in eval4 (fuzzed 0-2 against 3-output source) |
| `test/src/lib/eval/LibEval.inputsLengthMismatch.t.sol` | InputsLengthMismatch revert: too few, too many, zero, correct match |
| `test/src/lib/eval/LibEval.multipleSource.t.sol` | Evaluating different source indices in multi-source bytecode |

### LibIntegrityCheck tests (7 files):
| File | What it tests |
|------|---------------|
| `test/src/lib/integrity/LibIntegrityCheck.newState.t.sol` | newState field initialization (fuzzed) |
| `test/src/lib/integrity/LibIntegrityCheck.t.sol` | OpcodeOutOfRange, StackUnderflow, StackUnderflowHighwater, StackAllocationMismatch, StackOutputsMismatch |
| `test/src/lib/integrity/LibIntegrityCheck.badOpIO.t.sol` | BadOpInputsLength, BadOpOutputsLength via surgical bytecode corruption |
| `test/src/lib/integrity/LibIntegrityCheck.highwater.t.sol` | Highwater advancement after multi-output call opcode |
| `test/src/lib/integrity/LibIntegrityCheck.multiSource.t.sol` | Multi-source integrity (2 and 3 sources) |
| `test/src/lib/integrity/LibIntegrityCheck.zeroSource.t.sol` | Zero-source bytecode |
| `test/src/lib/integrity/LibIntegrityCheck.stackMaxIndex.t.sol` | Peak stack height tracking vs. final output count |

### LibInterpreterState tests (3 files + 1 helper):
| File | What it tests |
|------|---------------|
| `test/src/lib/state/LibInterpreterState.stackBottoms.t.sol` | Empty, single (fuzzed), multiple (fuzzed) stack bottom pointer computation |
| `test/src/lib/state/LibInterpreterState.stackTrace.t.sol` | Stack trace calldata verification, upper-bits masking, memory restoration |
| `test/src/lib/state/LibInterpreterState.fingerprint.t.sol` | Test-only fingerprint helper (not source code) |

### LibInterpreterStateDataContract tests (1 file):
| File | What it tests |
|------|---------------|
| `test/src/lib/state/LibInterpreterStateDataContract.t.sol` | serializeSize (fuzzed + empty), round-trip serialize/deserialize (single/two-source, fuzzed constants, empty constants), passthrough of sourceIndex/namespace/store/context/fs, stack allocation verification |

## Coverage Analysis

### LibEval.evalLoop

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| Main 8-at-a-time loop | Yes | opcodeCountEdgeCases (8, 16 ops), fBounds (37 ops) |
| Remainder loop | Yes | remainderOnly (7 ops), fBounds (37 ops) |
| Zero opcodes (neither loop) | Yes | opcodeCountEdgeCases |
| Mod wrapping of opcode index | Yes | fBounds |
| stackTrace call | Yes | stackTrace.t.sol (direct), evalLoop (indirect) |

### LibEval.eval4

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| InputsLengthMismatch (too few) | Yes | inputsLengthMismatch |
| InputsLengthMismatch (too many) | Yes | inputsLengthMismatch |
| InputsLengthMismatch (zero) | Yes | inputsLengthMismatch |
| Inputs match (no revert) | Yes | inputsLengthMismatch, opcodeCountEdgeCases |
| Inputs copy (length > 0) | Yes | opcodeCountEdgeCases (testEvalZeroOpcodeSourceWithInputs) |
| maxOutputs < sourceOutputs | Yes | maxOutputs |
| maxOutputs >= sourceOutputs | Yes | fBounds, remainderOnly, opcodeCountEdgeCases |
| stateKV return | Yes | fBounds, maxOutputs (assert kvs.length == 0) |

### LibIntegrityCheck.newState

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| All fields initialized | Yes | newState (fuzzed) |

### LibIntegrityCheck.integrityCheck2

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| OpcodeOutOfRange revert | Yes | LibIntegrityCheck.t.sol |
| BadOpInputsLength revert | Yes | badOpIO |
| BadOpOutputsLength revert | Yes | badOpIO |
| StackUnderflow revert | Yes | LibIntegrityCheck.t.sol |
| StackUnderflowHighwater revert | Yes | LibIntegrityCheck.t.sol |
| StackAllocationMismatch revert | Yes | LibIntegrityCheck.t.sol |
| StackOutputsMismatch revert | Yes | LibIntegrityCheck.t.sol |
| Multi-source loop | Yes | multiSource |
| Zero-source | Yes | zeroSource |
| Highwater advancement (multi-output) | Yes | highwater, LibIntegrityCheck.t.sol |
| `io` return value encoding | No | (see A03-1) |

### LibInterpreterState.stackBottoms

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| Empty stacks | Yes | stackBottoms |
| Single stack (fuzzed) | Yes | stackBottoms |
| Multiple stacks (fuzzed) | Yes | stackBottoms |

### LibInterpreterState.stackTrace

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| Calldata encoding | Yes | stackTrace |
| Upper-bits masking | Yes | stackTrace |
| Memory restoration | Yes | stackTrace |

### LibInterpreterStateDataContract.serializeSize

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| Fuzzed inputs | Yes | testSerializeSize |
| Empty inputs | Yes | testSerializeSizeEmpty |

### LibInterpreterStateDataContract.unsafeSerialize

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| Round-trip with constants | Yes | testSerializeDeserializeRoundTrip (and fuzzed variant) |
| Round-trip two sources | Yes | testSerializeDeserializeTwoSourceRoundTrip |
| Empty constants | Yes | testSerializeDeserializeEmptyConstants |

### LibInterpreterStateDataContract.unsafeDeserialize

| Code path | Tested | Test file(s) |
|-----------|--------|---------------|
| Constants reconstruction | Yes | round-trip tests |
| Bytecode reconstruction | Yes | round-trip tests |
| sourceIndex passthrough | Yes | testUnsafeDeserializeSourceIndex |
| namespace passthrough | Yes | testUnsafeDeserializeNamespace |
| store passthrough | Yes | testUnsafeDeserializeStore |
| context passthrough | Yes | testUnsafeDeserializeContext |
| fs passthrough | Yes | testUnsafeDeserializeFs |
| Stack allocation (single source) | Yes | testUnsafeDeserializeStackAllocation |
| Stack allocation (two sources) | Yes | testUnsafeDeserializeTwoSourceStackAllocation |
| stateKV initialized to zero | No | (see A03-2) |

## Findings

### A03-1 (LOW) `integrityCheck2` return value `io` encoding not directly tested

**Description:** `integrityCheck2` (line 91 of `LibIntegrityCheck.sol`) constructs a packed `io` byte array at lines 114-131. Each source gets two bytes: `(inputsLength, outputsLength)`. None of the seven test files for `LibIntegrityCheck` assert on the returned `io` value. Every test either expects a revert or discards the return value.

In production, the `io` return value is also discarded -- `RainterpreterExpressionDeployer.sol` line 58 explicitly suppresses the unused variable. This means the encoding logic at lines 128-131 is exercised but never verified for correctness. If the encoding were wrong (e.g., swapped inputs/outputs, wrong cursor increment), no test would catch it.

The risk is LOW because the encoding is straightforward assembly and the value is currently unused in production. However, if a future consumer relies on the `io` return value, the lack of tests means a latent bug could go undetected.

### A03-2 (LOW) `unsafeDeserialize` does not have a direct test verifying `stateKV` is initialized to zero

**Description:** `unsafeDeserialize` (line 69 of `LibInterpreterStateDataContract.sol`) constructs an `InterpreterState` with `MemoryKV.wrap(0)` at line 139. None of the tests in `LibInterpreterStateDataContract.t.sol` assert that `state.stateKV` is `MemoryKV.wrap(0)` after deserialization.

The risk is LOW because the initialization is a simple constant (`MemoryKV.wrap(0)`) and is visible in the source, but a direct assertion would guard against accidental changes to the struct construction order or the default value.
