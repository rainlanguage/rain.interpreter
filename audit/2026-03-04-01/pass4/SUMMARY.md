# Pass 4 (Code Quality) Summary — 2026-03-04-01

## Coverage

127 source files reviewed across 8 agent batches covering all non-generated Solidity (107 files) and all Rust source files (20 files). Build toolchain warnings checked for both Solidity (`forge build`) and Rust (`cargo check`).

## Build Warnings

### Solidity (3 warnings)

| File | Warning |
|------|---------|
| `test/src/lib/eval/LibEval.inputsLengthMismatch.t.sol:33` | Function state mutability can be restricted to `pure` |
| `test/src/lib/parse/LibParse.lhsOverflow.t.sol:29` | Function state mutability can be restricted to `view` |
| `test/src/lib/parse/literal/LibParseLiteral.dispatch.t.sol:251` | Function state mutability can be restricted to `view` |

All 3 warnings are in test files. Per audit rules, build warnings are LOW or higher.

### Rust

No warnings from `cargo check`.

## Findings

### LOW Findings (6)

| ID | File | Description |
|----|------|-------------|
| BUILD-P4-1 | `test/src/lib/eval/LibEval.inputsLengthMismatch.t.sol` | Build warning: function can be restricted to `pure` |
| BUILD-P4-2 | `test/src/lib/parse/LibParse.lhsOverflow.t.sol` | Build warning: function can be restricted to `view` |
| BUILD-P4-3 | `test/src/lib/parse/literal/LibParseLiteral.dispatch.t.sol` | Build warning: function can be restricted to `view` |
| A02-P4-1 | `src/abstract/BaseRainterpreterSubParser.sol` | Two unused `using` directives (`LibParse`, `LibParseMeta` for `ParseState`) — dead code |
| A42-P4-1 | `src/lib/op/call/LibOpCall.sol` | Missing `& 0x0F` mask on `outputs` extraction, inconsistent with `LibOpExtern` and `inputs` in same file |
| A115-P4-1 | `src/lib/parse/literal/LibParseLiteralSubParseable.sol` | Unused import and `using` directive for `LibParse` — dead code |
| R12-P4-1 | `crates/cli/src/commands/eval.rs` | Misleading CLI help text for `--context` (says "key=value" but code parses comma-separated U256s) |
| R13-P4-1 | `Cargo.toml` / `crates/eval/Cargo.toml` | `revm` version mismatch: workspace `24.0.1` vs eval crate wasm target `25.0.0` |

### INFO Findings (15)

| ID | File | Description |
|----|------|-------------|
| A09-P4-1 | `src/error/ErrBitwise.sol` | Ambiguous NatSpec on `UnsupportedBitwiseShiftAmount` |
| A13-P4-1 | `src/error/ErrIntegrity.sol` | Mixed NatSpec styles within same file |
| A15-P4-1 | `src/error/ErrParse.sol` | Two `@param offset` descriptions missing "byte" qualifier |
| A22-P4-1 | `src/lib/extern/LibExtern.sol` | Parameter name `dispatch` reused for two different types |
| A28-P4-1 | `src/lib/extern/reference/op/LibExternOpStackOperand.sol` | Unnamed parameter inconsistent with sibling subParsers |
| A31-P4-1 | `src/lib/op/00/LibOpContext.sol` | Redundant explicit return with named return variable |
| A32-P4-1 | `src/lib/op/00/LibOpExtern.sol` | Duplicate import path in two statements |
| A42-P4-2 | `src/lib/op/call/LibOpCall.sol` | Single `@return` for two return values |
| A44-P4-1 | `src/lib/op/erc20/LibOpERC20Allowance.sol` | Split imports from same module (inconsistent with peers) |
| A53-P4-1 | `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` | Missing safe-cast comment |
| A83-P4-1 | `src/lib/op/math/LibOpMaxNegativeValue.sol` | Unused `using LibDecimalFloat for Float` |
| A85-P4-1 | `src/lib/op/math/LibOpMin.sol` | Misleading `unchecked` block comment about overflow in `min` |
| A96-P4-1 | `src/lib/op/math/uint256/LibOpUint256MaxValue.sol` | NatSpec word name mismatch |
| A102-P4-1 | `src/lib/parse/LibParse.sol` | "ying" misspelling (should be "yin") |
| A105-P4-1 | `src/lib/parse/LibParseOperand.sol` | Duplicated Float-to-uint conversion logic |
| A08-P4-2 | `src/concrete/extern/RainterpreterReferenceExtern.sol` | Inconsistent `virtual` on one of 6 sibling overrides |
| R02-P4-1 | `crates/cli/Cargo.toml` | Unused `tracing` dependency |
| R02-P4-2 | `crates/cli/src/commands/eval.rs` | Tentative comments left in production code |
| R08-P4-1 | `crates/cli/src/main.rs` | Stale tracing filter directives from ethers migration |
| R12-P4-2 | `crates/eval/Cargo.toml` | Unused `tracing` dev-dependency |
| R13-P4-2 | Various `Cargo.toml` | Inconsistent crate naming convention |
| R19-P4-1 | `crates/parser/src/v2.rs` | Near-duplicate `Parser2` trait for wasm/non-wasm |

## Files with No Findings

109 of 127 files had no LOW+ findings. The codebase is well-structured with consistent patterns across opcode libraries, clean assembly usage, and proper encapsulation.
