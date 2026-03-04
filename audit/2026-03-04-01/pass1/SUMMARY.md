# Pass 1 (Security) Summary — 2026-03-04-01

## Coverage

127 source files reviewed across 27 agent assignments covering all non-generated Solidity (107 files) and all Rust source files (20 files).

## Findings

### New Findings

| ID | Severity | File | Description |
|----|----------|------|-------------|
| R11-RUST-01 | LOW | `crates/eval/src/fork.rs` | `LocalForkId` tracking assumes backend assigns sequential IDs; actual return value from `create_select_fork` is discarded |

### Carried Forward (Previously Triaged)

| ID | Severity | File | Prior Status |
|----|----------|------|--------------|
| A05-1 | LOW | `src/concrete/RainterpreterExpressionDeployer.sol` | DISMISSED — serializeSize overflow practically unreachable |
| A21-1 | LOW | `src/lib/eval/LibEval.sol` | DISMISSED — sourceIndex trust assumption documented |
| A21-2 | LOW | `src/lib/eval/LibEval.sol` | DISMISSED — empty fs guarded by constructor |

### Prior Fix Verifications

All previously-fixed findings verified in place:
- A43-1 (endSource ops-count overflow) — FIXED
- EXT-M01 (OOB second-byte read) — FIXED
- EXT-M02 (OOB memory read in pragma) — FIXED
- EXT-M03 (silent truncation in sub-parse) — FIXED
- EXT-L01 (uppercase hex prefix bypass) — FIXED
- R02-RUST-01 (genesis block underflow) — FIXED
- A49-6 (dispatch cursor in ReferenceExtern) — FIXED
- A44-1 (unaligned free memory pointer) — FIXED

## Files with No Findings

All remaining files (123 of 127) had no LOW+ findings. Key security properties verified across the codebase:
- Assembly memory safety in all ~50 assembly blocks
- Function pointer table bounds checking via modulo or explicit range checks
- Integrity/run consistency across all 72 standard opcodes
- Namespace isolation in store via msg.sender qualification
- All system reverts use custom errors (conditions/ensure string reverts are user-facing by design)
- No unsafe Rust code
- No command injection or path traversal risks in CLI
