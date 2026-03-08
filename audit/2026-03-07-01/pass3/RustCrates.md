# Pass 3 -- Rust Crates Documentation Audit (Agent A06)

## Scope

All Rust source files in `crates/` (bindings, cli, dispair, eval, parser, test_fixtures) and the top-level `README.md`.

## Files Reviewed

### crates/bindings
- `crates/bindings/src/lib.rs` -- Module-level `//!` doc present. No pub structs/fns/enums (only `sol!` macro invocations). **OK.**

### crates/cli
- `crates/cli/src/main.rs` -- `Cli` struct is private; no pub items. **OK.**
- `crates/cli/src/lib.rs` -- Module-level `//!` doc present. `pub enum Interpreter` and `pub async fn execute` both have `///` docs. **OK.**
- `crates/cli/src/execute.rs` -- `pub trait Execute` and its method both have `///` docs. **OK.**
- `crates/cli/src/output.rs` -- `pub enum SupportedOutputEncoding` and `pub fn output` both have `///` docs. **OK.**
- `crates/cli/src/fork.rs` -- `pub struct NewForkedEvmCliArgs` has no `///` doc comment. See **A06-2**.
- `crates/cli/src/commands/mod.rs` -- Re-exports only, no pub items to document. **OK.**
- `crates/cli/src/commands/parse.rs` -- `pub struct ForkParseArgsCli` and `pub struct Parse` both have `///` docs. **OK.**
- `crates/cli/src/commands/eval.rs` -- `pub struct ForkEvalCliArgs` and `pub struct Eval` both have `///` docs. **OK.**

### crates/dispair
- `crates/dispair/src/lib.rs` -- Module-level `//!` doc present. `pub struct DISPaiR` and `pub fn new` both have `///` docs. **OK.**

### crates/eval
- `crates/eval/src/lib.rs` -- Module-level `//!` doc present. **OK.**
- `crates/eval/src/eval.rs` -- `pub struct ForkEvalArgs`, `pub struct ForkParseArgs`, `pub async fn fork_parse`, `pub async fn fork_eval` all have `///` docs. **OK.**
- `crates/eval/src/fork.rs` -- `pub struct Forker`, `pub struct ForkTypedReturn`, `pub struct NewForkedEvm`, and all pub methods have `///` docs. **OK.**
- `crates/eval/src/error.rs` -- `pub enum ForkCallError` has `///` doc. `pub enum ReplayTransactionError` has `///` doc. **OK.**
- `crates/eval/src/namespace.rs` -- `pub fn qualify_namespace` has `///` doc. **OK.**
- `crates/eval/src/trace.rs` -- Multiple missing docs. See **A06-3**.

### crates/parser
- `crates/parser/src/lib.rs` -- Module-level `//!` doc present. **OK.**
- `crates/parser/src/v2.rs` -- `pub trait Parser2`, `pub struct ParserV2`, `pub fn new`, and all trait methods have `///` docs. **OK.**
- `crates/parser/src/error.rs` -- `pub enum ParserError` has no `///` doc comment. See **A06-4**.

### crates/test_fixtures
- `crates/test_fixtures/src/lib.rs` -- Module-level `//!` doc present. `pub struct LocalEvm` and all its pub methods have `///` docs. `pub type LocalEvmFillers` and `pub type LocalEvmProvider` use `//` comments instead of `///` doc comments. See **A06-5**.

### README.md
- Stale references to `IInterpreterV1`, `eval`, and `eval2`. Current interfaces are `IInterpreterV4` and `eval4`. No mention of Rust crates. See **A06-6**.

---

## Findings

### A06-2: Missing doc comment on `NewForkedEvmCliArgs`

**Severity:** LOW
**File:** `crates/cli/src/fork.rs:6`

`pub struct NewForkedEvmCliArgs` has no `///` doc comment. All other pub structs in the CLI crate are documented.

---

### A06-3: Multiple missing doc comments in `crates/eval/src/trace.rs`

**Severity:** LOW
**File:** `crates/eval/src/trace.rs`

The following public items lack `///` doc comments:

| Line | Item |
|------|------|
| 14 | `pub const RAIN_TRACER_ADDRESS` |
| 101 | `pub enum RainEvalResultFromRawCallResultError` |
| 141 | `pub enum TraceSearchError` |
| 149 | `pub fn search_trace_by_path` |
| 220 | `pub struct RainEvalResultsTable` |
| 229 | `pub struct RainEvalResults` |
| 240 | `pub fn into_flattened_table` |

These are all significant public API surface items in the eval crate. `RainSourceTrace` and `RainEvalResult` are documented, but closely related types and methods are not.

---

### A06-4: Missing doc comment on `ParserError`

**Severity:** LOW
**File:** `crates/parser/src/error.rs:5`

`pub enum ParserError` has no `///` doc comment. Both error enums in the eval crate (`ForkCallError`, `ReplayTransactionError`) are documented; this one should be consistent.

---

### A06-5: `//` comments instead of `///` doc comments on public type aliases

**Severity:** LOW
**File:** `crates/test_fixtures/src/lib.rs:58-60`

`pub type LocalEvmFillers` and `pub type LocalEvmProvider` have a `//` comment (`// type aliases for LocalEvm fillers and provider`) above them rather than `///` doc comments. This means the comment does not appear in `cargo doc` output.

---

### A06-6: README.md contains stale interface references

**Severity:** LOW
**File:** `README.md`

The README contains several outdated references:

1. **Line 15:** References `IInterpreterV1` -- current interface is `IInterpreterV4`.
2. **Lines 33-35:** References `eval` and `eval2` as examples of versioned methods -- current method is `eval4`. The text implies `eval2` is the latest version.
3. **No Rust crate documentation:** The README only mentions Solidity; there is no mention of the six Rust crates in `crates/` despite them being a significant part of the project.
