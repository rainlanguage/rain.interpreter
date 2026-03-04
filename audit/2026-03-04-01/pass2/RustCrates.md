# Pass 2 -- Rust Crates Test Coverage

Audit of all 20 Rust source files across 5 crates: cli, bindings, dispair, eval, parser, test_fixtures.

## Files Reviewed

### CLI Crate (`crates/cli/src/`)

| File | Functions | Test Coverage |
|---|---|---|
| `main.rs` | `main()` | No tests -- binary entry point, trivial dispatch |
| `commands/mod.rs` | (re-exports) | No tests -- re-exports only |
| `commands/eval.rs` | `TryFrom<ForkEvalCliArgs>`, `parse_int_or_hex`, `Execute for Eval` | `test_parse_int_or_hex`, `test_execute` |
| `commands/parse.rs` | `From<ForkParseArgsCli>`, `Execute for Parse` | `test_execute` |
| `execute.rs` | `Execute` trait | No tests -- trait definition only |
| `fork.rs` | `From<NewForkedEvmCliArgs>` | No direct test -- exercised indirectly via eval/parse tests |
| `lib.rs` | `Interpreter::execute` | No direct test -- individual subcommands tested |
| `output.rs` | `output()` | No tests |

### Bindings Crate (`crates/bindings/src/`)

| File | Functions | Test Coverage |
|---|---|---|
| `lib.rs` | (sol! macros) | No tests -- generated bindings only |

### DISPaiR Crate (`crates/dispair/src/`)

| File | Functions | Test Coverage |
|---|---|---|
| `lib.rs` | `DISPaiR::new`, `Default` derive | `test_new` |

### Eval Crate (`crates/eval/src/`)

| File | Functions | Test Coverage |
|---|---|---|
| `lib.rs` | (module declarations) | No tests -- module declarations only |
| `error.rs` | `ForkCallError`, `ReplayTransactionError`, `From<RawCallResult>` | No direct tests -- errors exercised through fork.rs tests |
| `eval.rs` | `From<ForkEvalArgs> for ForkParseArgs`, `fork_parse`, `fork_eval` | `test_fork_parse`, `test_fork_eval`, `test_fork_eval_parallel` |
| `fork.rs` | `Forker::new`, `new_with_fork`, `add_or_select`, `alloy_call`, `alloy_call_committing`, `call`, `call_committing`, `roll_fork`, `replay_transaction` | Extensive tests for all methods including error paths |
| `namespace.rs` | `qualify_namespace` | `test_new` |
| `trace.rs` | `RainSourceTrace::from_data`, `RainEvalResult::try_from` (2 impls), `search_trace_by_path`, `RainEvalResults::into_flattened_table`, `flattened_trace_path_names`, `From<Vec<RainEvalResult>>` | Extensive tests -- see findings for gaps |

### Parser Crate (`crates/parser/src/`)

| File | Functions | Test Coverage |
|---|---|---|
| `lib.rs` | (re-exports) | No tests -- re-exports only |
| `error.rs` | `ParserError` | No tests -- error type with `#[from]` variants only |
| `v2.rs` | `ParserV2::new`, `From<DISPaiR>`, `From<Address>`, `Parser2::parse`, `parse_text`, `parse_pragma`, `parse_pragma_text` | `test_from_dispair`, `test_parse`, `test_parse_text`, `test_parse_pragma_text` |

### Test Fixtures Crate (`crates/test_fixtures/src/`)

| File | Functions | Test Coverage |
|---|---|---|
| `lib.rs` | `LocalEvm::new`, `new_with_tokens`, `url`, `deploy_new_token`, `send_contract_transaction`, `send_transaction`, `call_contract`, `call` | No tests -- test utility, exercised as fixture in other crate tests |

## Findings

### A28-1 (LOW): `output.rs` hex encoding path untested

**File**: `crates/cli/src/output.rs`, line 22-25

The `output()` function has two encoding paths: `Binary` and `Hex`. Both `Eval::execute` (line 135) and `Parse::execute` (line 60) tests only exercise the `Binary` path. The `Hex` encoding branch (which calls `alloy::primitives::hex::encode_prefixed`) and the file-write branch (line 28) are never exercised by any test.

The `Hex` encoding path involves a non-trivial transformation (`encode_prefixed` produces a `0x`-prefixed hex string), and the file-write path involves filesystem I/O with a different code path than stdout.

### A28-2 (LOW): `flattened_trace_path_names` fallback path untested

**File**: `crates/eval/src/trace.rs`, lines 292-295

The `flattened_trace_path_names` function has a fallback when a trace's parent cannot be resolved in the `source_paths` history. It produces a path in `"parent?.child"` format (note the `?` indicating an unresolved parent). This fallback is never exercised by any test.

The existing `test_rain_eval_result_into_flattened_table` test (line 625) only tests traces where parent paths resolve normally. Constructing a `RainSourceTrace` with a `parent_source_index` that does not match any previously seen `source_index` would exercise the fallback.

### A28-3 (LOW): `into_flattened_table` empty-results path untested

**File**: `crates/eval/src/trace.rs`, lines 241-245

The `into_flattened_table` method has an explicit early-return guard for empty results that returns empty column names and rows. This path has no test. The only existing test (`test_rain_eval_result_into_flattened_table`) provides a single non-empty result.

### A28-4 (LOW): `search_trace_by_path` stack index out-of-bounds untested

**File**: `crates/eval/src/trace.rs`, lines 200-205

The `search_trace_by_path` method handles the case where the requested stack index exceeds the trace's stack length via `checked_sub` (line 200). This error path is never tested.

The existing test at line 456 tests `"0.1.12"` which fails because trace with source index 12 does not exist -- a `TraceNotFound` error from the trace lookup, not from the stack index bounds check. To exercise lines 200-205, a test would need to request a valid trace path but with a stack index >= the stack length (e.g., `"0.4"` when trace 0 has only 4 stack items, so index 4 is out of bounds since indexing is 0-based).
