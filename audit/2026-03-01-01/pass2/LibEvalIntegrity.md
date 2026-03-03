# Pass 2: Test Coverage — LibEval, LibIntegrityCheck, LibInterpreterState, LibInterpreterStateDataContract

**Audit:** 2026-03-01-01
**Agent IDs:** A05, A12, A14, A15

## Findings

### P2-EI-1 (LOW) `eval2` `InputsLengthMismatch` not tested at library level (A05)

The `InputsLengthMismatch` error at `src/lib/eval/LibEval.sol:212-213` is only tested through the full `Rainterpreter.eval4` integration path. No test in `test/src/lib/eval/` calls `LibEval.eval2` directly with mismatched input lengths.

### P2-EI-2 (LOW) `integrityCheck2` `BadOpInputsLength` and `BadOpOutputsLength` not tested directly (A12)

Of 7 revert paths in `integrityCheck2`, five are directly tested. `BadOpInputsLength` (line 160) and `BadOpOutputsLength` (line 163) are only tested indirectly through opcode tests via `OpTest.checkBadOp`.

### P2-EI-3 (LOW) `evalLoop` remainder-only path (1-7 opcodes) not directly tested (A05)

Tests exist for 0, 8, 16, and 37 opcodes. No test exercises opcode counts 1-7 where ONLY the remainder loop executes without the main unrolled loop.
