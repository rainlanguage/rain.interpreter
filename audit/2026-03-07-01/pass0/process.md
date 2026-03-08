# Pass 0: Process Review

## Documents Reviewed

- `CLAUDE.md` (139 lines)
- `TESTING.md` (46 lines)
- `foundry.toml` (64 lines)
- `audit/known-false-positives.md` (30 lines)

## Findings

### P0-1 (LOW): CLAUDE.md optimizer_runs value contradicts foundry.toml

**File:** `CLAUDE.md` line 102

CLAUDE.md states "Optimizer: enabled, 1000 runs" but `foundry.toml` line 20 has `optimizer_runs = 1000000`. CLAUDE.md line 104 correctly says "Source of truth for these settings is `foundry.toml`", but stating a wrong value alongside that caveat invites confusion — a future session may quote the wrong number without checking foundry.toml.

### P0-2 (LOW): CLAUDE.md omits /audit-pass5 from audit review section

**File:** `CLAUDE.md` line 139

The audit review section lists `/audit-pass0` through `/audit-pass4` but omits `/audit-pass5` (Correctness / Intent Verification). A future session restoring from a compressed summary could believe only passes 0-4 exist and skip pass 5.

### P0-3 (LOW): CLAUDE.md says "all four contracts" but test_fixtures deploys five

**File:** `CLAUDE.md` line 116

The Test Conventions section says Rust test fixtures "deploy all four contracts on a local Anvil instance." The test_fixtures crate (`crates/test_fixtures/src/lib.rs`) actually deploys five: Interpreter, Store, Parser, Deployer, and DISPaiRegistry. The prior audit (P0-7) added DISPaiRegistry to the Architecture section but this line was not updated.
