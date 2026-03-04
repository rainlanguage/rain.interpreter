# A21 -- Pass 2 (Test Coverage) -- LibEval.sol

**Source:** `src/lib/eval/LibEval.sol`
**Test files:**
- `test/src/lib/eval/LibEval.inputsLengthMismatch.t.sol`
- `test/src/lib/eval/LibEval.maxOutputs.t.sol`
- `test/src/lib/eval/LibEval.remainderOnly.t.sol`
- `test/src/lib/eval/LibEval.fBounds.t.sol`
- `test/src/lib/eval/LibEval.opcodeCountEdgeCases.t.sol`
- `test/src/lib/eval/LibEval.multipleSource.t.sol`
- `test/src/concrete/Rainterpreter.eval.t.sol` (integration)
- `test/src/concrete/Rainterpreter.eval.nonZeroSourceIndex.t.sol` (integration)

## Evidence

### Library: `LibEval`

| Function | Line | Coverage |
|----------|------|----------|
| `evalLoop` | 41 | Tested: 0 ops (opcodeCountEdgeCases), 7 ops remainder-only (remainderOnly), 8/16 exact multiples (opcodeCountEdgeCases), 37 ops main+remainder (fBounds), modulo wrapping (fBounds) |
| `eval4` | 191 | Tested: InputsLengthMismatch too-few/too-many/zero (inputsLengthMismatch), maxOutputs truncation (maxOutputs), input copy path (inputsLengthMismatch, integration), multiple sources (multipleSource) |

### Errors

| Error | Line | Coverage |
|-------|------|----------|
| `InputsLengthMismatch` | 213 | Directly tested at library level (3 fixed cases + 1 happy) and fuzzed at integration level |

### Prior findings status

| Finding | Status |
|---------|--------|
| P2-EI-1 (InputsLengthMismatch not tested at library level) | FIXED -- `LibEval.inputsLengthMismatch.t.sol` |
| P2-EI-3 (remainder-only path not tested) | FIXED -- `LibEval.remainderOnly.t.sol` |

## Findings

No LOW+ findings. All significant code paths are covered.

### A21-P2-1 (INFO): Library-level InputsLengthMismatch tests use fixed values only

The three revert tests in `LibEval.inputsLengthMismatch.t.sol` use hardcoded input lengths (1 vs 2, 2 vs 1, 0 vs 3). The integration-level tests in `Rainterpreter.eval.t.sol` DO fuzz the input lengths. No action needed.

### A21-P2-2 (INFO): KV output only tested as empty at library level

All library-level `eval4` tests assert `kvs.length == 0`. Non-empty KV writes are tested through `LibOpSet` and `LibOpGet` integration tests. No action needed -- KV writes originate from opcodes, not from `eval4` itself.
