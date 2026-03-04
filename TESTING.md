# Testing Conventions

## Base Contracts

Test base contracts in `test/abstract/`:

- **`RainterpreterExpressionDeployerDeploymentTest`** (`test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol`) — Full stack deployment. Exposes `I_PARSER`, `I_INTERPRETER`, `I_STORE`, `I_DEPLOYER`.
- **`OpTest`** (`test/abstract/OpTest.sol`) — Opcode tests. Provides `opReferenceCheck()`, `checkHappy()`, `checkUnhappy()`.
- **`ParseTest`** (`test/abstract/ParseTest.sol`) — Parser tests. Provides `parseExternal()`.
- **`OperandTest`** (`test/abstract/OperandTest.sol`) — Operand handler tests. Provides `checkOperandParse()`.
- **`ParseLiteralTest`** (`test/abstract/ParseLiteralTest.sol`) — Literal parsing tests. Provides `checkLiteralBounds()`.

## Fuzz Testing

- Use `bound()` to constrain fuzz inputs, not `vm.assume()`. `vm.assume()` wastes runs by discarding inputs. `vm.assume()` is acceptable when the rejection rate is low or `bound()` cannot express the constraint.
- When fuzzing over a non-contiguous set (e.g., non-hex bytes), `bound()` to the count of valid values, then map with arithmetic to skip excluded ranges.
- When a fuzz parameter affects expression structure, build rainlang dynamically. The fuzz variable must match what the rainlang produces.

## Library Internals

Internal library functions need an external wrapper in the test contract. Construct `ParseState` inside the wrapper so memory pointers are valid. Call via `this.externalFoo()`.

## Revert Paths

Use `vm.expectRevert` with `abi.encodeWithSelector` and the custom error type. Call through `this.externalFoo()` for library functions or directly on `I_PARSER`/`I_INTERPRETER` for integration tests.

## Bytecode Construction

Use the parse library to generate bytecode from rainlang when the test needs valid bytecode. Only hand-encode bytecode when the test intentionally needs invalid or malformed bytecode that the parser cannot produce.

## Bytecode Inspection

Use `LibBytecode` from `rain.interpreter.interface/lib/bytecode/LibBytecode.sol`. Do not manually index into bytecode bytes.

## Opcode Testing

Use `opReferenceCheck` to validate that `run` output matches a pure reference implementation and that `integrity` correctly declares inputs/outputs.

## Boundary Tests

Always test both sides: the max valid value (should succeed) and one past it (should revert).

## One Test at a Time

Write one test function per edit-compile-run cycle. Do not batch multiple new tests into a single edit. Writing one test at a time produces higher quality code — each test gets full attention, compilation errors are caught immediately, and failures are unambiguous.

# Rust Testing Conventions

## Test Location

Tests are collocated with source code using `#[cfg(test)] mod tests { }` blocks. No separate `tests/` directory.

## Shared Test Fixtures

`crates/test_fixtures` provides `LocalEvm` — an Anvil instance with all Rain contracts pre-deployed.

- `LocalEvm::new().await` — empty instance with interpreter, store, parser, deployer
- `LocalEvm::new_with_tokens(count).await` — also pre-deploys ERC20 tokens
- Exposed fields: `interpreter`, `store`, `parser`, `deployer`, `tokens`, `signer_wallets`
- Fork URL: `local_evm.url()`

## Async Tests

Use `tokio::test` for async tests (anything using `LocalEvm` or `Forker`):

- Sequential: `#[tokio::test(flavor = "multi_thread", worker_threads = 1)]`
- Parallel: `#[tokio::test(flavor = "multi_thread", worker_threads = 10)]`

Use `#[test]` for synchronous unit tests that don't need EVM interaction.

## Naming

Prefix all tests with `test_`. Use descriptive names: `test_fork_parse`, `test_fork_eval_parallel`.

## Assertions

Use `assert_eq!()` for equality, `assert!()` for boolean conditions. Use `.unwrap()` for expected successes — the panic on failure is the test assertion.
