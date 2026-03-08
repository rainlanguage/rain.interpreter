# Pass 2: Rust Crate Test Coverage Audit (Agent A07)

## Scope

All Rust source files under `crates/`:
- `crates/cli/src/` (main.rs, lib.rs, execute.rs, fork.rs, output.rs, commands/*.rs)
- `crates/eval/src/` (lib.rs, eval.rs, fork.rs, error.rs, namespace.rs, trace.rs)
- `crates/parser/src/` (lib.rs, v2.rs, error.rs)
- `crates/dispair/src/lib.rs`
- `crates/bindings/src/lib.rs`
- `crates/test_fixtures/src/lib.rs`

## Inventory

### crates/bindings/src/lib.rs
- `sol!` macro invocations only (IInterpreterV4, IInterpreterStoreV3, IParserV2, IParserPragmaV1, IExpressionDeployerV3, RainterpreterDISPaiRegistry)
- No testable logic; generated bindings from JSON ABIs.

### crates/dispair/src/lib.rs
- Struct: `DISPaiR` (deployer, interpreter, store, parser)
- Functions: `DISPaiR::new()`
- Derives: `Debug, Clone, Default`
- Tests: `test_new` -- covers constructor and field access.
- Coverage: adequate.

### crates/test_fixtures/src/lib.rs
- Struct: `LocalEvm`
- Functions: `new()`, `new_with_tokens()`, `url()`, `deploy_new_token()`, `send_contract_transaction()`, `send_transaction()`, `call_contract()`, `call()`
- This is test infrastructure; not itself an audit target.

### crates/parser/src/lib.rs
- Re-exports only. No logic.

### crates/parser/src/error.rs
- Enum: `ParserError` (ReadableClientError, ReadContractParametersBuilderError)
- Pure thiserror derives. No testable logic.

### crates/parser/src/v2.rs
- Trait: `Parser2` (parse, parse_text, parse_pragma, parse_pragma_text)
- Struct: `ParserV2` (deployer_address)
- Impls: `From<DISPaiR>`, `From<Address>`, `ParserV2::new()`, `Parser2 for ParserV2`
- Tests: `test_from_dispair`, `test_parse`, `test_parse_text`, `test_parse_pragma_text`
- Coverage: adequate. All trait methods and From impls are exercised.

### crates/eval/src/lib.rs
- Module declarations only.

### crates/eval/src/error.rs
- Enums: `ForkCallError`, `ReplayTransactionError`
- Impl: `From<RawCallResult> for ForkCallError`
- Pure error types with thiserror derives. Variants exercised indirectly through fork.rs tests.

### crates/eval/src/namespace.rs
- Function: `qualify_namespace()`
- Tests: `test_new` -- verifies against a known Chisel output.
- Coverage: adequate.

### crates/eval/src/fork.rs
- Struct: `Forker` (executor, forks)
- Struct: `ForkTypedReturn<C: SolCall>`
- Struct: `NewForkedEvm`
- Functions: `mk_journaled_state()`, `mk_env_mut()`, `Forker::new()`, `Forker::new_with_fork()`, `Forker::add_or_select()`, `Forker::alloy_call()`, `Forker::alloy_call_committing()`, `Forker::call()`, `Forker::call_committing()`, `Forker::roll_fork()`, `Forker::replay_transaction()`
- Tests: `test_forker_read`, `test_forker_write`, `test_multi_fork_read_write_switch_reset`, `test_fork_rolls`, `test_fork_replay`, `test_call_invalid_from_address_too_short`, `test_call_invalid_from_address_too_long`, `test_call_invalid_from_address_empty`, `test_call_invalid_to_address_too_short`, `test_call_invalid_to_address_too_long`, `test_call_invalid_to_address_empty`, `test_call_committing_invalid_from_address`, `test_call_committing_invalid_to_address`, `test_call_committing_both_addresses_invalid`, `test_roll_fork_no_active_fork`, `test_roll_fork_no_active_fork_with_block_number`, `test_forker_new_then_add_or_select`
- Coverage: thorough. All public methods and error paths exercised.

### crates/eval/src/eval.rs
- Structs: `ForkEvalArgs`, `ForkParseArgs`
- Impls: `From<ForkEvalArgs> for ForkParseArgs`, `Forker::fork_parse()`, `Forker::fork_eval()`
- Tests: `test_fork_parse`, `test_fork_eval`, `test_fork_eval_parallel`
- Coverage: adequate.

### crates/eval/src/trace.rs
- Struct: `RainSourceTrace` (parent_source_index, source_index, stack)
- Struct: `RainEvalResult` (reverted, stack, writes, traces)
- Struct: `RainEvalResults` (results)
- Struct: `RainEvalResultsTable` (column_names, rows)
- Enum: `RainEvalResultFromRawCallResultError`
- Enum: `TraceSearchError`
- Functions: `RainSourceTrace::from_data()`, `RainEvalResult::try_from(ForkTypedReturn<eval4Call>)`, `RainEvalResult::try_from(RawCallResult)`, `RainEvalResult::search_trace_by_path()`, `RainEvalResults::into_flattened_table()`, `flattened_trace_path_names()`
- Tests: `test_fork_trace`, `test_search_trace_by_path`, `test_try_from_raw_call_result`, `test_try_from_raw_call_result_missing_traces`, `test_from_data_empty`, `test_from_data_one_byte`, `test_from_data_three_bytes`, `test_from_data_exactly_four_bytes`, `test_from_data_trailing_partial_word`, `test_from_data_one_full_word`, `test_from_data_one_full_word_plus_partial`, `test_from_data_two_full_words`, `test_rain_eval_result_into_flattened_table`
- Coverage: thorough.

### crates/cli/src/main.rs
- Entry point. Not unit-testable.

### crates/cli/src/lib.rs
- Enum: `Interpreter` (Parse, Eval)
- Function: `Interpreter::execute()`
- No direct tests. Tested transitively through command tests.

### crates/cli/src/execute.rs
- Trait: `Execute` (async fn execute)
- Trait definition only.

### crates/cli/src/fork.rs
- Struct: `NewForkedEvmCliArgs` (fork_url, fork_block_number)
- Impl: `From<NewForkedEvmCliArgs> for NewForkedEvm`
- No direct tests. Trivial conversion; tested transitively.

### crates/cli/src/output.rs
- Enum: `SupportedOutputEncoding` (Binary, Hex)
- Function: `output(output_path, output_encoding, bytes)`
- **No tests at all.** This function has four code paths (binary+stdout, binary+file, hex+stdout, hex+file).

### crates/cli/src/commands/mod.rs
- Re-exports only.

### crates/cli/src/commands/parse.rs
- Struct: `ForkParseArgsCli`
- Struct: `Parse`
- Impl: `From<ForkParseArgsCli> for ForkParseArgs`
- Impl: `Execute for Parse`
- Tests: `test_execute`
- Coverage: adequate.

### crates/cli/src/commands/eval.rs
- Struct: `ForkEvalCliArgs`
- Struct: `Eval`
- Function: `parse_int_or_hex()`
- Impl: `TryFrom<ForkEvalCliArgs> for ForkEvalArgs`
- Impl: `Execute for Eval`
- Tests: `test_parse_int_or_hex`, `test_execute`
- Coverage: adequate for happy paths. See finding A07-2.

---

## Findings

### A07-1

- **Severity:** LOW
- **Title:** `output()` function in `crates/cli/src/output.rs` has no unit tests
- **Description:** The `output()` function handles four distinct code paths: binary encoding to stdout, binary encoding to file, hex encoding to stdout, and hex encoding to file. None of these paths have direct test coverage. The `SupportedOutputEncoding::Hex` variant is particularly notable: it performs a `0x`-prefixed hex encoding via `alloy::primitives::hex::encode_prefixed`, and there are no tests verifying the encoding is correct or that the file-write path works. While the binary+stdout path is exercised indirectly by the `Parse::execute()` test, the hex encoding and file output paths are never exercised anywhere in the test suite.

### A07-2

- **Severity:** LOW
- **Title:** `TryFrom<ForkEvalCliArgs>` error paths are untested
- **Description:** The `TryFrom<ForkEvalCliArgs> for ForkEvalArgs` implementation in `crates/cli/src/commands/eval.rs` has two fallible operations: namespace parsing (via `parse_int_or_hex`) and context value parsing (splitting on commas then parsing each value via `parse_int_or_hex`). While the underlying `parse_int_or_hex` function has basic error tests, the `TryFrom` conversion itself is never tested with invalid namespace or invalid context values. The error wrapping with `.context("Invalid namespace format")` and `.context("Invalid context value")` is unverified. The happy path is only tested indirectly through `test_execute`.

### A07-3

- **Severity:** LOW
- **Title:** `RainEvalResults::into_flattened_table` empty-results branch untested
- **Description:** The `into_flattened_table()` method in `crates/eval/src/trace.rs` has an early-return branch at line 241-245 that handles the case where `self.results` is empty, returning an empty `RainEvalResultsTable`. This branch is never exercised by any test. The existing `test_rain_eval_result_into_flattened_table` only tests a non-empty results vector with multiple traces.
