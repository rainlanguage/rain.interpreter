# Pass 2 (Test Coverage) -- ERC20 Operations

## Evidence of Thorough Reading

### Source Files
- `LibOpERC20Allowance` -- `integrity` (line 18), `run` (line 25), `referenceFn` (line 64)
- `LibOpERC20BalanceOf` -- `integrity` (line 18), `run` (line 25), `referenceFn` (line 51)
- `LibOpERC20TotalSupply` -- `integrity` (line 18), `run` (line 25), `referenceFn` (line 48)
- `LibOpUint256ERC20Allowance` -- `integrity` (line 15), `run` (line 22), `referenceFn` (line 44)
- `LibOpUint256ERC20BalanceOf` -- `integrity` (line 15), `run` (line 22), `referenceFn` (line 41)
- `LibOpUint256ERC20TotalSupply` -- `integrity` (line 15), `run` (line 22), `referenceFn` (line 38)

### Test Files
All six opcodes have comprehensive test files covering: integrity, run via opReferenceCheck, eval happy path, bad inputs/outputs, operand disallowed. BalanceOf and TotalSupply float variants also test overflow/revert for lossless conversion.

## Findings

### A20-1: No test verifying `erc20-allowance` handles infinite approvals without revert
**Severity:** LOW

`LibOpERC20Allowance.run` intentionally uses `fromFixedDecimalLossyPacked` instead of `fromFixedDecimalLosslessPacked` to avoid reverting on infinite approvals (`type(uint256).max`). The source documents this at lines 45-53. However, no test explicitly passes `type(uint256).max` as the allowance value. By contrast, `erc20-balance-of` and `erc20-total-supply` have explicit overflow tests.

### A20-2: No test for `decimals()` revert when token does not implement `IERC20Metadata`
**Severity:** LOW

All three float-variant ERC20 opcodes call `IERC20Metadata(token).decimals()`. The source explicitly documents that `decimals()` is optional in ERC20. No tests exercise the revert path when a token does not implement `decimals()`. All tests mock `decimals()` to succeed.

### A20-3: `testOpERC20AllowanceRun` uses hardcoded operand data instead of fuzz parameter
**Severity:** INFO

The allowance tests use hardcoded `0` for operand data while balance-of and total-supply fuzz the operand data. Since the operand is disallowed, impact is minimal, but the inconsistency means allowance tests never exercise non-zero operand data bits.

### A20-4: No test for input values with upper 96 bits set (address truncation)
**Severity:** LOW

All six opcodes truncate stack inputs to `address` via `address(uint160(value))`, discarding upper 96 bits. No test provides a value with non-zero upper bits to verify the truncation behavior.
