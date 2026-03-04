# Pass 1 (Security): Rust Eval, Parser, and Test Fixtures Crates

**Date:** 2026-03-04
**Scope:** `crates/eval/src/`, `crates/parser/src/`, `crates/test_fixtures/src/`
**Files:** R11-R20

---

## Evidence of Reading

### R11: `crates/eval/src/error.rs` (55 lines)

- **`ForkCallError`** enum (line 9): 8 variants -- `ExecutorError(String)`, `Failed(Box<RawCallResult>)` (non-wasm), `TypedError(String)`, `AbiDecodeFailed`, `AbiDecodedError`, `DeserializeFailed(String)`, `U64FromUint256`, `Eyre`, `ReplayTransactionError`.
- **`ReplayTransactionError`** enum (line 33): 6 variants -- `TransactionNotFound`, `NoActiveFork`, `DatabaseError` (non-wasm), `NoBlockNumberFound`, `NoFromAddressFound`, `GenesisBlockReplay`.
- `impl From<RawCallResult> for ForkCallError` (line 50): Boxes the result to avoid large enum variant size.
- All error types derive `Debug`, `Error` via `thiserror`.
- **GenesisBlockReplay** variant (line 46) is the fix for the previously reported R02-RUST-01 underflow.

### R12: `crates/eval/src/eval.rs` (268 lines)

- **`ForkEvalArgs`** struct (line 10): Fields -- `rainlang_string`, `source_index: u16`, `deployer`, `interpreter`, `store`, `namespace`, `context: Vec<Vec<U256>>`, `decode_errors`, `inputs`, `state_overlay`.
- **`ForkParseArgs`** struct (line 35): Fields -- `rainlang_string`, `deployer`, `decode_errors`.
- `impl From<ForkEvalArgs> for ForkParseArgs` (line 44).
- **`Forker::fork_parse`** (line 66): Encodes rainlang as bytes, calls `alloy_call` with `Address::default()` as caller.
- **`Forker::fork_eval`** (line 95): Parses then evaluates. Constructs `eval4Call` from parse result and args.
- Tests (lines 142-268): `test_fork_parse`, `test_fork_eval`, `test_fork_eval_parallel` (1000 parallel tasks).

### R13: `crates/eval/src/fork.rs` (950 lines)

- **`Forker`** struct (line 26): Fields `executor: Executor`, `forks: HashMap<ForkId, (LocalForkId, SpecId, BlockNumber)>`.
- **`ForkTypedReturn<C: SolCall>`** struct (line 33): `raw: RawCallResult`, `typed_return: C::Return`.
- **`NewForkedEvm`** struct (line 42): `fork_url: String`, `fork_block_number: Option<BlockNumber>`.
- **`mk_journaled_state`** (line 49): Creates JournaledState with spec_id.
- **`mk_env_mut`** (line 57): Creates `EnvMut` from `&mut Env`.
- **`Forker::new`** (line 67): Creates empty forker with no forks.
- **`Forker::new_with_fork`** (line 100): Creates forker with initial fork. Sets `memory_limit: u64::MAX`, `gas_limit: u64::MAX`. Hardcodes initial fork as `LocalForkId = U256::from(0)`.
- **`Forker::add_or_select`** (line 155): Adds or selects fork. Empty-fork shortcut at line 160. Existing fork selected at line 178. New fork created at line 220 with `LocalForkId = U256::from(self.forks.len())`.
- **`Forker::alloy_call`** (line 240): Non-committing call with error decoding. Checks `InstructionResult::Revert` for error decoding.
- **`Forker::alloy_call_committing`** (line 284): Committing call with same error handling pattern.
- **`Forker::call`** (line 328): Raw call with address length validation (`!= 20`).
- **`Forker::call_committing`** (line 356): Raw committing call with address validation and persistent account removal.
- **`Forker::roll_fork`** (line 386): Resets fork to given or original block number.
- **`Forker::replay_transaction`** (line 427): Replays historical transaction. Uses `checked_sub(1)` for block number (line 465) with `GenesisBlockReplay` error.
- Tests (lines 528-950): Comprehensive tests covering read, write, multi-fork switching, fork rolling, replay, address validation edge cases, and error paths.

### R14: `crates/eval/src/lib.rs` (10 lines)

- Module declarations: `error`, `eval` (non-wasm), `fork` (non-wasm), `namespace`, `trace`.

### R15: `crates/eval/src/namespace.rs` (40 lines)

- **`qualify_namespace`** (line 6): Combines 32-byte namespace + 20-byte address into 64-byte array (12 zero-padded bytes between), hashes with keccak256. Layout: `[namespace(32)][zeros(12)][address(20)]`.
- Matches Solidity `LibNamespace.qualifyNamespace` which does `mstore(0, stateNamespace)`, `mstore(0x20, sender)`, `keccak256(0, 0x40)`.
- Test (line 24): Verifies against known chisel output.

### R16: `crates/eval/src/trace.rs` (657 lines)

- **`RAIN_TRACER_ADDRESS`** constant (line 14): `0xF06Cd48c98d7321649dB7D8b2C396A81A2046555`.
- **`RainSourceTrace`** struct (line 20): `parent_source_index: u16`, `source_index: u16`, `stack: Vec<U256>`.
- **`RainSourceTrace::from_data`** (line 28): Parses 4-byte header + 32-byte stack words. Returns `None` if data < 4 bytes. Silently drops trailing partial words.
- **`RainEvalResult`** struct (line 60): `reverted`, `stack`, `writes`, `traces`.
- `impl TryFrom<ForkTypedReturn<eval4Call>> for RainEvalResult` (line 68): Extracts traces from call trace arena, filters by tracer address, reverses order.
- `impl TryFrom<RawCallResult> for RainEvalResult` (line 109): Similar but leaves `stack`/`writes` empty.
- **`RainEvalResultFromRawCallResultError`** enum (line 101): Single variant `MissingTraces`.
- **`TraceSearchError`** enum (line 141): `BadTracePath(String)`, `TraceNotFound(String)`.
- **`RainEvalResult::search_trace_by_path`** (line 149): Parses dot-separated path, navigates parent-child trace relationships, accesses reversed stack index. Uses `checked_sub` for stack indexing (line 200).
- **`RainEvalResultsTable`** struct (line 220): `column_names`, `rows`.
- **`RainEvalResults`** struct (line 229): Wrapper for `Vec<RainEvalResult>`.
- **`RainEvalResults::into_flattened_table`** (line 240): Flattens traces into tabular format.
- **`flattened_trace_path_names`** (line 272): Generates path names with `?` fallback for unresolved parents.
- Tests (lines 308-656): Comprehensive trace parsing, path search, from_data edge cases, flattened table tests.

### R17: `crates/parser/src/error.rs` (10 lines)

- **`ParserError`** enum (line 4): 2 variants -- `ReadableClientError`, `ReadContractParametersBuilderError`. Both use `#[from]`.

### R18: `crates/parser/src/lib.rs` (8 lines)

- Module declarations and re-exports for `error` and `v2`.

### R19: `crates/parser/src/v2.rs` (271 lines)

- **`Parser2`** trait (line 10, non-wasm; line 57, wasm): Methods `parse_text`, `parse`, `parse_pragma`, `parse_pragma_text`.
- **`ParserV2`** struct (line 105): `deployer_address: Address`.
- `impl From<DISPaiR>` (line 110), `impl From<Address>` (line 118).
- `impl Parser2 for ParserV2` (line 133): `parse` uses `ReadContractParametersBuilder` to call on-chain parser. `parse_pragma` similarly.
- Tests (lines 173-270): Uses mocked `Asserter` to verify parse, parse_text, parse_pragma_text.

### R20: `crates/test_fixtures/src/lib.rs` (269 lines)

- Type aliases: `LocalEvmFillers`, `LocalEvmProvider` (lines 59-60).
- **`LocalEvm`** struct (line 66): `anvil`, `provider`, `interpreter`, `store`, `parser`, `deployer`, `tokens`, `zoltu_*` addresses, `signer_wallets`.
- **`LocalEvm::new`** (line 101): Spawns Anvil, sets up signers, deploys contracts, copies code to Zoltu addresses.
- **`LocalEvm::new_with_tokens`** (line 177): Deploys ERC20 tokens with 1M supply.
- **`LocalEvm::url`** (line 196): Returns anvil endpoint.
- **`LocalEvm::deploy_new_token`** (line 201): Deploys ERC20 with specified params.
- **`LocalEvm::send_contract_transaction`** (line 224): Sends write tx and returns receipt.
- **`LocalEvm::send_transaction`** (line 237): Sends raw tx and returns receipt.
- **`LocalEvm::call_contract`** (line 250): Read-only contract call.
- **`LocalEvm::call`** (line 263): Raw read-only call.

---

## Security Audit Checks

### 1. Unsafe Code
No `unsafe` blocks in any file across all three crates. Clean.

### 2. Panic/Unwrap in Production Code
- `trace.rs:158`: `.pop().unwrap()` is safe -- guarded by `parts.len() < 2` check at line 152.
- All other `.unwrap()` calls are in `#[cfg(test)]` blocks or the `test_fixtures` crate (test-only).
- No `panic!`, `expect()`, `todo!`, or `unimplemented!` in production code.

### 3. Arithmetic Safety
- `fork.rs:465`: `checked_sub(1)` used for block number decrement with proper `GenesisBlockReplay` error. (Previously reported R02-RUST-01 is FIXED.)
- `trace.rs:200`: `checked_sub(stack_index + 1)` used for reversed stack indexing with proper error.
- `namespace.rs`: No arithmetic; byte-level copy operations only.
- `fork.rs:214`: `U256::from(self.forks.len())` -- `usize` to `U256` conversion cannot overflow.

### 4. Input Validation
- `fork.rs:334,363`: Address length validated (`!= 20`) in `call` and `call_committing`.
- `trace.rs:29`: `from_data` validates minimum 4-byte header before parsing.
- `trace.rs:152`: `search_trace_by_path` validates minimum 2-part path.
- `v2.rs`: Parser input is passed through to on-chain contract; validation is on-chain.

### 5. Error Handling
- All production error paths return `Result` types.
- Error chains preserved via `thiserror` `#[from]` annotations.
- String-wrapped errors in `ForkCallError::ExecutorError` lose type information (previously reported as INFO, still present).

### 6. Resource Management
- `memory_limit: u64::MAX` in `new_with_fork` and `add_or_select` -- effectively unlimited EVM memory. This is intentional for a local fork evaluation tool.
- `gas_limit: u64::MAX` similarly intentional.
- No file handles, network connections, or other resources left open.

### 7. Denial-of-Service Vectors
- `from_data` (trace.rs) processes arbitrary-length byte slices but only in 32-byte increments. No amplification vector.
- `search_trace_by_path` processes dot-separated paths. The path length is bounded by the number of traces (finite). No amplification.
- `context: Vec<Vec<U256>>` in `ForkEvalArgs` is unbounded in size, but this is consumed by the EVM which has its own gas/memory limits.

---

## Findings

### R11-RUST-01: `LocalForkId` tracking assumes sequential backend-assigned IDs (LOW)

**File:** `/Users/thedavidmeister/Code/rain.interpreter/crates/eval/src/fork.rs`
**Lines:** 146, 211-214

**Description:** The `Forker` maintains a `HashMap<ForkId, (LocalForkId, SpecId, BlockNumber)>` to track fork IDs. The initial fork is hardcoded as `LocalForkId = U256::from(0)` (line 146), and subsequent forks use `U256::from(self.forks.len())` (line 214). However, the actual `LocalForkId` returned by `Backend::create_select_fork` is discarded (line 220-228, the return value is mapped away with `.map(|_| ())`).

This creates a fragile coupling: the code assumes the backend assigns sequential IDs starting from 0, matching the insertion order. If the foundry backend's ID assignment strategy ever changes (e.g., due to a dependency upgrade), fork selection via `is_active_fork` and `select_fork` would use stale/wrong IDs, leading to either:
- Selecting the wrong fork (silent data corruption)
- A backend error (noisy but safe)

**Impact:** Currently works correctly because foundry's Backend does use sequential U256 IDs. The risk is a future dependency upgrade silently breaking fork selection.

**Severity:** LOW -- The assumption holds today and is tested, but the coupling is implicit rather than verified.

### R11-RUST-02: `NoFromAddressFound` error variant is unused (INFO)

**File:** `/Users/thedavidmeister/Code/rain.interpreter/crates/eval/src/error.rs`
**Line:** 44

**Description:** The `ReplayTransactionError::NoFromAddressFound` variant is defined but never constructed anywhere in the codebase. In `replay_transaction` (fork.rs), the `from` address is obtained via `tx.inner.signer()` which always returns an `Address` (derived from the signature), so the error variant is unnecessary.

**Impact:** Dead code. No security impact but adds confusion about possible error paths.

**Severity:** INFO

---

## Summary

| ID | Severity | File | Description |
|---|---|---|---|
| R11-RUST-01 | LOW | fork.rs | `LocalForkId` tracking assumes sequential backend-assigned IDs; discards actual return value |
| R11-RUST-02 | INFO | error.rs | `NoFromAddressFound` error variant is defined but never used |

**Overall assessment:** These three crates are well-structured with thorough error handling. The genesis block underflow (R02-RUST-01) from the prior audit is confirmed FIXED with `checked_sub` + `GenesisBlockReplay` error. No `unsafe` code, no production panics, proper input validation on address lengths and trace data parsing. The single LOW finding is a maintainability/correctness risk tied to an implicit assumption about a dependency's internal behavior.
