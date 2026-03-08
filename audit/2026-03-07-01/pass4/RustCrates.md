# Pass 4 -- Rust Crates Audit

**Agent:** A04
**Date:** 2026-03-07
**Scope:** All Rust source files in `crates/`, Cargo.toml files, `foundry.toml`

## Files Reviewed

### Cargo.toml files
- `/Cargo.toml` (workspace root)
- `crates/bindings/Cargo.toml`
- `crates/cli/Cargo.toml`
- `crates/dispair/Cargo.toml`
- `crates/eval/Cargo.toml`
- `crates/parser/Cargo.toml`
- `crates/test_fixtures/Cargo.toml`

### Rust source files (20 files)
- `crates/bindings/src/lib.rs`
- `crates/cli/src/main.rs`
- `crates/cli/src/lib.rs`
- `crates/cli/src/commands/mod.rs`
- `crates/cli/src/commands/parse.rs`
- `crates/cli/src/commands/eval.rs`
- `crates/cli/src/execute.rs`
- `crates/cli/src/fork.rs`
- `crates/cli/src/output.rs`
- `crates/dispair/src/lib.rs`
- `crates/eval/src/lib.rs`
- `crates/eval/src/eval.rs`
- `crates/eval/src/error.rs`
- `crates/eval/src/fork.rs`
- `crates/eval/src/namespace.rs`
- `crates/eval/src/trace.rs`
- `crates/parser/src/lib.rs`
- `crates/parser/src/error.rs`
- `crates/parser/src/v2.rs`
- `crates/test_fixtures/src/lib.rs`

## Clippy

Clippy was not executed during this pass (Bash permission denied). Findings below are from manual review.

## Findings

### P4-RUST-01: `revm` version mismatch between workspace and wasm target [LOW]

**File:** `Cargo.toml` (workspace root, line 18) vs `crates/eval/Cargo.toml` (line 22)

The workspace root declares `revm = { version = "24.0.1", ... }`. The `eval` crate uses `revm = { workspace = true }` for non-wasm, but for the wasm target overrides with `revm = { version = "25.0.0", ... }`. This means the wasm build uses a different major-ish semver version than the non-wasm build. If this is intentional (e.g., wasm-specific features only available in 25.x), it should be documented. If not, it is a latent compatibility risk where behavior could diverge between targets.

### P4-RUST-02: `tokio` not declared as workspace dependency [LOW]

**Files:** `crates/parser/Cargo.toml`, `crates/cli/Cargo.toml`, `crates/eval/Cargo.toml`

`tokio = { version = "1.28.0" }` is repeated in three crates with identical version but is not declared in `[workspace.dependencies]`. The Cargo workspace dependency mechanism exists to deduplicate version pins. The version and feature sets are identical across all three crates for each target, so this should be a workspace dependency.

### P4-RUST-03: Wildcard imports in non-test production code [INFO]

**File:** `crates/parser/src/v2.rs` (lines 4-5)

```rust
use rain_interpreter_bindings::IParserPragmaV1::*;
use rain_interpreter_bindings::IParserV2::*;
```

These are wildcard imports in production code (not `#[cfg(test)]`). For generated bindings modules this is a common and acceptable pattern since the exact set of generated items is not easily enumerated. The other wildcard imports (`use super::*`) are all inside `#[cfg(test)]` modules, which is standard Rust test convention. Noting for completeness; no action required.

### P4-RUST-04: `pub use crate::*` re-exports in parser crate root [INFO]

**File:** `crates/parser/src/lib.rs` (lines 6-7)

```rust
pub use crate::error::*;
pub use crate::v2::*;
```

The parser crate re-exports everything from its two submodules via glob. This is a deliberate API surface choice (flat re-export). Noting for completeness; acceptable for a small crate with two submodules.

### P4-RUST-05: `Parser2` trait duplicated between wasm and non-wasm [INFO]

**File:** `crates/parser/src/v2.rs` (lines 9-53 and 56-100)

The `Parser2` trait is defined twice -- once with `#[cfg(not(target_family = "wasm"))]` (adding `+ Send` bounds) and once with `#[cfg(target_family = "wasm")]` (without `Send` bounds). The two definitions are otherwise identical. This is a known pattern required because Rust's async trait methods with conditional `Send` bounds cannot be expressed in a single definition without trait aliases or helper macros. No action required.

### P4-RUST-06: Stale tracing filter directives [INFO]

**File:** `crates/cli/src/main.rs` (lines 19-20)

```rust
.add_directive("ethers_signer=off".parse()?)
.add_directive("coins_ledger=off".parse()?)
```

These filter out log output from `ethers_signer` and `coins_ledger` crates. The project uses `alloy` (not `ethers`) as its EVM library. These directives may be vestigial from a pre-alloy migration era. They are harmless (filtering a non-existent log target is a no-op) but should be reviewed for removal.

## Evidence of No Further Issues

- **Commented-out code:** No commented-out Rust code found. All `//` comments are explanatory.
- **`#[allow(...)]` directives:** None found in any crate.
- **TODO/FIXME/HACK markers:** None found.
- **Dependency versions:** All workspace dependencies use `workspace = true` consistently, except `tokio` (P4-RUST-02) and the wasm `revm` override (P4-RUST-01). `getrandom` in `test_fixtures` is only used for wasm and is appropriately scoped.
- **Unused imports:** No obvious unused imports found via manual review.
- **Style consistency:** Code follows consistent formatting with doc comments on public items. Error types use `thiserror` throughout.
