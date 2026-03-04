# Pass 3: Rust Crates Documentation Audit

Audit date: 2026-03-01
Auditor: Claude Opus 4.6
Scope: All `.rs` files in `crates/cli/src/`, `crates/dispair/src/`, `crates/eval/src/`, `crates/parser/src/`

---

## Inventory of Public Items

### crates/cli/src/

| File | Item | Line | Has Doc? |
|------|------|------|----------|
| commands/eval.rs | `pub struct ForkEvalCliArgs` | 15 | NO (has clap help attrs) |
| commands/eval.rs | `pub struct Eval` | 105 | NO |
| commands/mod.rs | `pub use Eval` | 4 | NO |
| commands/mod.rs | `pub use Parse` | 5 | NO |
| commands/parse.rs | `pub struct ForkParseArgsCli` | 13 | NO |
| commands/parse.rs | `pub struct Parse` | 25 | NO |
| execute.rs | `pub trait Execute` | 3 | NO |
| execute.rs | `fn execute` | 4 | NO |
| fork.rs | `pub struct NewForkedEvmCliArgs` | 6 | NO |
| lib.rs | `pub enum Interpreter` | 13 | NO |
| lib.rs | `pub async fn execute` | 19 | NO |
| output.rs | `pub enum SupportedOutputEncoding` | 5 | NO |
| output.rs | `pub fn output` | 10 | NO |

Crate-level `//!` docs: MISSING

### crates/dispair/src/

| File | Item | Line | Has Doc? |
|------|------|------|----------|
| lib.rs | `pub struct DISPaiR` | 6 | YES (redundant name) |
| lib.rs | `pub fn new` | 14 | NO |

Crate-level `//!` docs: MISSING

### crates/eval/src/

| File | Item | Line | Has Doc? |
|------|------|------|----------|
| error.rs | `pub enum ForkCallError` | 8 | NO |
| error.rs | `pub enum ReplayTransactionError` | 31 | NO |
| eval.rs | `pub struct ForkEvalArgs` | 10 | YES |
| eval.rs | `pub struct ForkParseArgs` | 35 | YES |
| eval.rs | `pub async fn fork_parse` | 66 | YES |
| eval.rs | `pub async fn fork_eval` | 95 | YES |
| fork.rs | `pub struct Forker` | 26 | YES |
| fork.rs | `pub struct ForkTypedReturn<C>` | 31 | NO |
| fork.rs | `pub struct NewForkedEvm` | 37 | NO |
| fork.rs | `pub fn new` | 60 | YES |
| fork.rs | `pub async fn new_with_fork` | 93 | YES (inaccurate) |
| fork.rs | `pub async fn add_or_select` | 148 | YES |
| fork.rs | `pub async fn alloy_call` | 232 | YES (incomplete) |
| fork.rs | `pub async fn alloy_call_committing` | 275 | YES (incomplete) |
| fork.rs | `pub fn call` | 314 | YES |
| fork.rs | `pub fn call_committing` | 342 | YES |
| fork.rs | `pub fn roll_fork` | 372 | YES |
| fork.rs | `pub async fn replay_transaction` | 413 | YES |
| namespace.rs | `pub fn qualify_namespace` | 6 | YES |
| trace.rs | `pub const RAIN_TRACER_ADDRESS` | 14 | NO |
| trace.rs | `pub struct RainSourceTrace` | 20 | YES |
| trace.rs | `pub struct RainEvalResult` | 60 | YES |
| trace.rs | `pub enum RainEvalResultFromRawCallResultError` | 101 | NO |
| trace.rs | `pub enum TraceSearchError` | 141 | NO |
| trace.rs | `pub fn search_trace_by_path` | 149 | NO |
| trace.rs | `pub struct RainEvalResultsTable` | 220 | NO |
| trace.rs | `pub struct RainEvalResults` | 229 | NO |
| trace.rs | `pub fn into_flattened_table` | 240 | NO |
| trace.rs | `pub fn flattened_trace_path_names` | 272 | YES |

Crate-level `//!` docs: MISSING

### crates/parser/src/

| File | Item | Line | Has Doc? |
|------|------|------|----------|
| error.rs | `pub enum ParserError` | 5 | NO |
| v2.rs | `pub trait Parser2` | 9 | NO |
| v2.rs | `fn parse_text` | 11 | YES |
| v2.rs | `fn parse` | 24 | YES |
| v2.rs | `fn parse_pragma` | 32 | YES |
| v2.rs | `fn parse_pragma_text` | 39 | YES |
| v2.rs | `pub struct ParserV2` | 103 | YES (redundant name) |
| v2.rs | `pub fn new` | 124 | NO |

Crate-level `//!` docs: MISSING

---

## Findings

### P3-RC-01: No crate-level documentation on any Rust crate [LOW]

**Files:**
- `crates/cli/src/lib.rs`
- `crates/dispair/src/lib.rs`
- `crates/eval/src/lib.rs`
- `crates/parser/src/lib.rs`

None of the four Rust crates have crate-level `//!` documentation. Crate-level docs are the
primary entry point for `cargo doc` and describe the crate's purpose, usage, and key types.

**Fix:** `.fixes/P3-RC-01.md`

---

### P3-RC-02: cli crate has zero doc comments on all 13 public items [LOW]

**File:** All files under `crates/cli/src/`

Every public struct, enum, trait, and function in the `cli` crate lacks `///` doc comments:
- `ForkEvalCliArgs` (commands/eval.rs:15)
- `Eval` (commands/eval.rs:105)
- `ForkParseArgsCli` (commands/parse.rs:13)
- `Parse` (commands/parse.rs:25)
- `Execute` trait (execute.rs:3)
- `Execute::execute` (execute.rs:4)
- `NewForkedEvmCliArgs` (fork.rs:6)
- `Interpreter` enum (lib.rs:13)
- `Interpreter::execute` (lib.rs:19)
- `SupportedOutputEncoding` (output.rs:5)
- `output` fn (output.rs:10)

While some structs use clap `#[arg(help = "...")]` annotations, those are CLI help text, not
rustdoc documentation. The two serve different audiences.

**Fix:** `.fixes/P3-RC-02.md`

---

### P3-RC-03: eval crate has 10 undocumented public items [LOW]

**Files:** `crates/eval/src/error.rs`, `crates/eval/src/fork.rs`, `crates/eval/src/trace.rs`

The following public items lack doc comments:
- `ForkCallError` (error.rs:8) -- public error enum, no overview doc
- `ReplayTransactionError` (error.rs:31) -- public error enum, no overview doc
- `ForkTypedReturn<C>` (fork.rs:31) -- key return type, no doc
- `NewForkedEvm` (fork.rs:37) -- configuration struct, no doc
- `RAIN_TRACER_ADDRESS` (trace.rs:14) -- magic constant, no doc
- `RainEvalResultFromRawCallResultError` (trace.rs:101) -- error type, no doc
- `TraceSearchError` (trace.rs:141) -- error type, no doc
- `search_trace_by_path` (trace.rs:149) -- public method, no doc
- `RainEvalResultsTable` (trace.rs:220) -- public struct, no doc
- `RainEvalResults` (trace.rs:229) -- public struct, no doc
- `into_flattened_table` (trace.rs:240) -- public method, no doc

**Fix:** `.fixes/P3-RC-03.md`

---

### P3-RC-04: parser crate has 3 undocumented public items [LOW]

**Files:** `crates/parser/src/error.rs`, `crates/parser/src/v2.rs`

- `ParserError` (error.rs:5) -- public error enum, no doc
- `Parser2` trait (v2.rs:9) -- the trait itself has no doc, though its methods do
- `ParserV2::new` (v2.rs:124) -- constructor, no doc

**Fix:** `.fixes/P3-RC-04.md`

---

### P3-RC-05: dispair crate `DISPaiR::new` has no doc comment [LOW]

**File:** `crates/dispair/src/lib.rs:14`

The only constructor for the main type in this crate lacks a doc comment.

**Fix:** `.fixes/P3-RC-05.md`

---

### P3-RC-06: "Rainalang" typo in `ForkEvalArgs` field doc [LOW]

**File:** `crates/eval/src/eval.rs:11`

```rust
/// The Rainalang string to evaluate
pub rainlang_string: String,
```

"Rainalang" should be "Rainlang" -- every other reference in the codebase uses "Rainlang"
(including the field name itself).

**Fix:** `.fixes/P3-RC-06.md`

---

### P3-RC-07: `new_with_fork` doc describes params that don't match signature [LOW]

**File:** `crates/eval/src/fork.rs:70-92`

The `# Arguments` section documents `fork_url` and `fork_block_number` as separate parameters,
but the actual signature takes `args: NewForkedEvm`. The doc describes fields of the struct as
if they were direct function parameters.

```rust
/// * `fork_url` - The URL of the fork to connect to.
/// * `fork_block_number` - Optional fork block number to start from.
/// * `env` - Optional fork environment.
/// * `gas_limit` - Optional fork gas limit.
```

Actual signature:
```rust
pub async fn new_with_fork(
    args: NewForkedEvm,
    env: Option<Env>,
    gas_limit: Option<u64>,
) -> Result<Forker, ForkCallError>
```

**Fix:** `.fixes/P3-RC-07.md`

---

### P3-RC-08: `alloy_call` and `alloy_call_committing` docs omit `decode_error` parameter [LOW]

**File:** `crates/eval/src/fork.rs:225-231, 267-274`

Both functions have a `decode_error: bool` parameter that is not listed in their `# Arguments`
sections. This parameter controls whether revert errors are decoded via the openchain.xyz
selector registry, which is significant behavior.

**Fix:** `.fixes/P3-RC-08.md`

---

### P3-RC-09: Redundant struct-name-as-first-line in doc comments [INFO]

**Files:**
- `crates/dispair/src/lib.rs:3-4`: `/// DISPaiR\n/// Struct representing...`
- `crates/parser/src/v2.rs:100-101`: `/// ParserV2\n/// Struct representing ParserV2 instances.`

Rustdoc already shows the struct name. The first line of a doc comment should be a summary
sentence describing what the type does, not repeating its name.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 8 |
| INFO | 1 |
| **Total** | **9** |

All findings are documentation quality issues. The codebase has reasonable documentation on the
core `eval` crate's main types and methods, but the `cli` crate is entirely undocumented, and
several key types across other crates lack doc comments. No crate has crate-level `//!`
documentation.
