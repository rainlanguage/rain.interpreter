# Pass 5: Correctness / Intent Verification -- Rust Crates (R01-R20)

## R12-P5-1 [LOW] `fork_parse` doc comment references non-existent `deployExpression2` call

**File:** `crates/eval/src/eval.rs`, line 65

**Evidence:**

The doc comment on `fork_parse` says:

```
/// The typed return of the parse and deployExpression2, plus Foundry's RawCallResult struct.
```

The function only calls `parse2Call` on the deployer address. There is no `deployExpression2` call anywhere in the function body. The return type is `ForkTypedReturn<parse2Call>`, confirming only parsing occurs.

**Impact:** Misleading documentation could cause callers to believe the function also deploys an expression, when it only parses.

---

## R20-P5-1 [LOW] `LocalEvm` doc comment says "transaction's 'to' field" when it means "from" field

**File:** `crates/test_fixtures/src/lib.rs`, line 64-65

**Evidence:**

The doc comment reads:

```
/// The first signer wallet is the main wallet that would sign any transactions
/// that dont specify a sender (transaction's 'to' field)
```

The `to` field in a transaction is the destination/recipient address, not the sender. The sender is the `from` field. The comment is describing the default signing wallet (i.e., the `from` address), so it should say "transaction's 'from' field".

**Impact:** Misleading documentation could confuse developers about which transaction field is being discussed.

---

## R19-P5-1 [INFO] Swapped "offset" and "length" comments in `test_parse_text`

**File:** `crates/parser/src/v2.rs`, lines 224-226

**Evidence:**

In `test_parse_text`, the inline comments on the mock response are swapped:

```rust
"0x0000000000000000000000000000000000000000000000000000000000000020", // length of bytecode  <-- actually offset
"000000000000000000000000000000000000000000000000000000000000000b", // offset to start of bytecode  <-- actually length
```

Compare with `test_parse` (lines 200-201) which has the comments correct:

```rust
"0x0000000000000000000000000000000000000000000000000000000000000020", // offset to start of bytecode
"0000000000000000000000000000000000000000000000000000000000000002", // length of bytecode
```

The value `0x20` (32) is the standard ABI offset to dynamic data, and `0x0b` (11) is the length of "my rainlang". The labels are swapped in the second test.

**Impact:** Test-only comment inaccuracy; no behavioral effect.

---

## R02-P5-1 [INFO] Eval CLI help text says "parse" instead of "evaluate"

**File:** `crates/cli/src/commands/eval.rs`, line 17

**Evidence:**

```rust
#[arg(short, long, help = "The Rainlang string to parse")]
pub rainlang_string: String,
```

This field is part of `ForkEvalCliArgs` used by the `Eval` subcommand. The help says "to parse" but the user is invoking `eval`, not `parse`. While parsing is an internal substep, the user-facing help text for the eval command should say "to evaluate" for clarity.

**Impact:** Minor UX inconsistency in CLI help output.

---

## R02-P5-2 [INFO] Eval command hardcodes `Binary` output encoding but writes debug-formatted text

**File:** `crates/cli/src/commands/eval.rs`, lines 133-137

**Evidence:**

```rust
crate::output::output(
    &self.output_path,
    SupportedOutputEncoding::Binary,
    format!("{:#?}", rain_eval_result).as_bytes(),
)
```

The output encoding is hardcoded to `SupportedOutputEncoding::Binary`, which is meant for raw binary bytes. However, the actual content being written is `format!("{:#?}", rain_eval_result)` -- a human-readable debug string. The `Binary` encoding path in `output()` writes bytes as-is, so the end result is correct (the debug string is written), but the semantic intent of "Binary" does not match the actual content being text.

By contrast, the `Parse` command allows the user to choose between `Binary` and `Hex` encoding and writes actual bytecode.

**Impact:** The eval output works but the encoding label is semantically misleading. No user-facing configurability for eval output format.
