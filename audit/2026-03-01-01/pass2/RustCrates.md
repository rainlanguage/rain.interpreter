# Pass 2: Test Coverage — Rust Crates

**Audit:** 2026-03-01-01
**Agent ID:** R02

## Findings

### R02-PASS2-01 (LOW) No tests for error paths in `Forker` methods (R02)

**Files:** `crates/eval/src/fork.rs`, `crates/eval/src/error.rs`

The `Forker` methods (`alloy_call`, `alloy_call_committing`, `call`, `call_committing`, `roll_fork`, `replay_transaction`) have numerous error return paths with only happy paths tested. Key untested paths:

1. `call()` / `call_committing()` with invalid address length (lines 320-322, 349-351)
2. `alloy_call()` revert with `decode_error: true` (line 245-250)
3. `alloy_call()` non-ok non-revert exit (line 252-254)
4. `alloy_call()` / `alloy_call_committing()` ABI decode failure (lines 256-263, 301-303)
5. `roll_fork()` with no active fork (line 381)
6. `replay_transaction()` error paths: no active fork, tx not found, no block number, DB errors
7. `replay_transaction()` with `TxKind::Create` (line 494-496)

### R02-PASS2-02 (LOW) `Forker::new()` has no test (R02)

**File:** `crates/eval/src/fork.rs`, lines 60-68

`Forker::new()` creates an empty forker without any fork. No test calls this constructor. The `add_or_select()` `self.forks.is_empty()` branch (line 153) that handles an initially-empty forker is also untested.

### R02-PASS2-04 (LOW) `RainSourceTrace::from_data()` edge cases untested (R02)

**File:** `crates/eval/src/trace.rs`, lines 28-55

Edge cases with no test: data < 4 bytes (returns `None`), exactly 4 bytes (empty stack), trailing partial word (silently dropped). A trace with 35 bytes (4 header + 31 payload) produces an empty stack, silently losing the partial word.

### R02-PASS2-07 (LOW) CLI `Parse` command entirely untested (R02)

**File:** `crates/cli/src/commands/parse.rs`

No tests at all. Asymmetric with `Eval` command which has `test_execute`.

## Summary

| ID | Severity | Crate | Description |
|----|----------|-------|-------------|
| R02-PASS2-01 | LOW | eval | Error paths in `Forker` methods have no tests |
| R02-PASS2-02 | LOW | eval | `Forker::new()` and empty-forks `add_or_select` untested |
| R02-PASS2-04 | LOW | eval | `RainSourceTrace::from_data()` edge cases untested |
| R02-PASS2-07 | LOW | cli | CLI `Parse` command entirely untested |

**Overall:** 4 LOW, 6 INFO (INFO findings omitted from this report). Happy paths are well-tested. The primary gap is systematic: error paths and edge cases are largely untested, concentrated in the `eval` crate's `Forker` methods.
