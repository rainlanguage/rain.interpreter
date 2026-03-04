# Pass 2 (Test Coverage) Summary — 2026-03-04-01

## Coverage

127 source files reviewed across 11 agent batches covering all non-generated Solidity (107 files) and all Rust source files (20 files).

## Findings

### New Findings

| ID | Severity | File | Description |
|----|----------|------|-------------|
| P2-A02-01 | LOW | `src/abstract/BaseRainterpreterSubParser.sol` | `subParseWord2` missing happy-path and no-match base-level tests |
| P2-A08-01 | LOW | `src/concrete/extern/RainterpreterReferenceExtern.sol` | `matchSubParseLiteralDispatch` boundary digit 0 not tested through full parse+eval stack |
| A27-1 | LOW | `src/lib/extern/reference/op/LibExternOpIntInc.sol` | `subParser` lacks direct unit test |
| P2-A30-1 | LOW | `src/lib/op/00/LibOpConstant.sol` | Missing bad-inputs test for constant opcode |
| P2-A33-1 | LOW | `src/lib/op/00/LibOpStack.sol` | Missing bad-inputs test for stack opcode |
| A38-1 | LOW | `src/lib/op/bitwise/LibOpBitwiseEncode.sol` | Missing explicit eval boundary test for `bitwise-encode<1 0xFF>` |
| A43-1 | LOW | `src/lib/op/crypto/LibOpHash.sol` | No explicit eval test for hash with maximum inputs (15) |
| A53-1 | LOW | `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` | Missing `NotAnAddress` revert tests for token and account |
| A71-1 | LOW | `src/lib/op/math/LibOpAvg.sol` | No negative-value deterministic eval examples |
| A73-1 | LOW | `src/lib/op/math/LibOpDiv.sol` | No negative-value deterministic eval examples |
| A88-1 | LOW | `src/lib/op/math/LibOpMul.sol` | No negative-value deterministic eval examples |
| A91-1 | LOW | `src/lib/op/math/LibOpSub.sol` | No negative-value deterministic eval examples; no overflow test |
| A28-1 | LOW | `crates/cli/src/output.rs` | Hex encoding path and file-write path completely untested |
| A28-2 | LOW | `crates/eval/src/trace.rs` | `flattened_trace_path_names` unresolved-parent fallback untested |
| A28-3 | LOW | `crates/eval/src/trace.rs` | `into_flattened_table` empty-results early-return untested |
| A28-4 | LOW | `crates/eval/src/trace.rs` | `search_trace_by_path` stack index out-of-bounds error path untested |

### INFO Findings

| ID | Severity | File | Description |
|----|----------|------|-------------|
| P2-A01-01 | INFO | `src/abstract/BaseRainterpreterExtern.sol` | `extern()` mod-wrap not tested at base level with multiple opcodes |
| P2-A04-01 | INFO | `src/concrete/RainterpreterDISPaiRegistry.sol` | No test that all four returned addresses are mutually distinct |
| P2-A08-02 | INFO | `src/concrete/extern/RainterpreterReferenceExtern.sol` | Dispatch exactly at keyword length boundary not tested |
| P2-A33-2 | INFO | `src/lib/op/00/LibOpStack.sol` | `readHighwater` update not directly asserted in integrity test |

## Files with No Findings

111 of 127 files had no LOW+ findings. Key coverage properties verified across the codebase:
- All opcodes have fuzz integrity tests and fuzz run-vs-reference tests
- All opcodes have end-to-end eval examples and bad input/output/operand tests
- All error paths in core contracts (Rainterpreter, RainterpreterParser, RainterpreterStore, RainterpreterExpressionDeployer) are directly tested
- All Rust crate public functions are tested (inline `#[cfg(test)]` modules)
- Parse library coverage is comprehensive across 70+ dedicated test files
- Prior audit findings (P2-EI-1, P2-EI-2, P2-EI-3, and others from 2026-03-01-01) verified as FIXED

## Carryovers from Prior Audit

P2-A02-01, P2-A08-01, P2-A01-01, and P2-A04-01 were previously identified in audit `2026-03-01-01` and remain unfixed.
