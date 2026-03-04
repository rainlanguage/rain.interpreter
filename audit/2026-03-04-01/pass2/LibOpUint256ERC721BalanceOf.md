# LibOpUint256ERC721BalanceOf -- Pass 2 (Test Coverage)

## Source

`src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`

## Functions

| Function | Line | Tested |
|---|---|---|
| `integrity` | 19 | Yes (fuzzed) |
| `run` | 28 | Yes (opReferenceCheck, fuzzed) |
| `referenceFn` | 55 | Yes (via opReferenceCheck) |

## Error Paths

| Error | Line | Tested |
|---|---|---|
| `NotAnAddress(token)` | 38 | **NO** |
| `NotAnAddress(account)` | 41 | **NO** |

## Findings

### A53-1: Missing NotAnAddress revert tests for token and account

**Severity**: LOW

The `run` function (lines 38, 41) reverts with `NotAnAddress` when `token`
or `account` have non-zero upper 96 bits. The test file has no tests that
exercise these revert paths.

Every other opcode in this batch that checks `NotAnAddress` has dedicated
fuzz tests for each checked parameter (e.g. `LibOpERC721BalanceOf.t.sol`
has `testOpERC721BalanceOfNotAnAddressToken` and
`testOpERC721BalanceOfNotAnAddressAccount`). This file is the only one
missing them.
