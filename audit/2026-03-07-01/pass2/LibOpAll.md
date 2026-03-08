# Pass 2: Test Coverage Audit - All Opcode Files

Agent: A06
Scope: All opcode source files in `src/lib/op/` (excluding `LibAllStandardOps.sol`) and their corresponding test files in `test/src/lib/op/`.

## Methodology

Systematically checked every opcode source file against its test file for:
1. `opReferenceCheck` or equivalent parity test between `run()` and `referenceFn()`
2. Integrity function tests
3. Operand handler tests (disallowed or valid operand parsing)
4. Error path coverage (all `revert` statements in source have corresponding test)
5. Bad input/output boundary tests

## Summary

69 of 69 non-structural opcode test files contain `opReferenceCheck` or an equivalent reference parity test. All test files that correspond to opcodes with `handleOperandDisallowed` in `LibAllStandardOps.operandHandlerFunctionPointers()` have operand disallowed tests (either via `checkDisallowedOperand` or `checkUnhappyParse` with `UnexpectedOperand`). 67 files use the standard `checkBadInputs`/`checkBadOutputs` helpers; the remaining special opcodes (stack, constant, extern, call) test their custom error paths directly.

One coverage gap was found.

## Findings

### A06-1: Missing NotAnAddress error path tests in LibOpUint256ERC721BalanceOf

- **Severity**: LOW
- **File**: `test/src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.t.sol`
- **Source**: `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`
- **Description**: The source `run()` function reverts with `NotAnAddress` when the token input (line 38) or account input (line 41) exceeds `uint160`. However, the test file has no tests for these error paths. The `testOpERC721BalanceOfRun` fuzz test always provides valid addresses by casting through `uint160` (lines 45-46), so the NotAnAddress guard is never exercised. The float counterpart (`LibOpERC721BalanceOf.t.sol`) correctly tests both `NotAnAddress` paths with dedicated fuzz tests (`testOpERC721BalanceOfNotAnAddressToken` and `testOpERC721BalanceOfNotAnAddressAccount`), as do all other ERC20/ERC721 uint256 variant test files (`LibOpUint256ERC20Allowance.t.sol`, `LibOpUint256ERC20BalanceOf.t.sol`, `LibOpUint256ERC20TotalSupply.t.sol`).
