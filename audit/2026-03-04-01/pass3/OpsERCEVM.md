# Pass 3 -- ERC20/ERC721/ERC5313/EVM Opcode Libraries (A44-A56)

## Scope

| Agent ID | File |
|----------|------|
| A44 | `src/lib/op/erc20/LibOpERC20Allowance.sol` |
| A45 | `src/lib/op/erc20/LibOpERC20BalanceOf.sol` |
| A46 | `src/lib/op/erc20/LibOpERC20TotalSupply.sol` |
| A47 | `src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol` |
| A48 | `src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol` |
| A49 | `src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol` |
| A50 | `src/lib/op/erc5313/LibOpERC5313Owner.sol` |
| A51 | `src/lib/op/erc721/LibOpERC721BalanceOf.sol` |
| A52 | `src/lib/op/erc721/LibOpERC721OwnerOf.sol` |
| A53 | `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` |
| A54 | `src/lib/op/evm/LibOpBlockNumber.sol` |
| A55 | `src/lib/op/evm/LibOpBlockTimestamp.sol` |
| A56 | `src/lib/op/evm/LibOpChainId.sol` |

## Findings

### A53-P3-1 (INFO): Missing safety justification comment on `account` address cast in `referenceFn`

**File:** `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`
**Lines:** 72-73

In the `referenceFn` function, the cast of `accountValue` to `address` at line 73 has only a `forge-lint` suppression comment but is missing the standard safety justification comment. Every other equivalent cast across all peer files (A44-A52, and the `tokenValue` cast at lines 69-71 in the same file) includes:

```
// Casting to `uint160` is safe because `NotAnAddress` above
// ensures the value fits in 160 bits.
```

Current code (lines 69-73):
```solidity
        //forge-lint: disable-next-line(unsafe-typecast)
        address token = address(uint160(tokenValue));
        //forge-lint: disable-next-line(unsafe-typecast)
        address account = address(uint160(accountValue));
```

The `token` cast at lines 69-71 is also missing the safety comment, unlike the pattern in A47 (`LibOpUint256ERC20Allowance.sol`) and A48 (`LibOpUint256ERC20BalanceOf.sol`) where every such cast has the full safety justification.

**Severity:** INFO -- inline comment consistency, not a NatSpec tag violation.

## No-Finding Summary

All 13 files were reviewed for:
1. `@title` on each library -- all present.
2. `@notice` on each library -- all present.
3. `@notice` on every function -- all present on `integrity`, `run`, and `referenceFn` across all files.
4. `@param` for each named parameter -- all present (`stackTop` on `run`, `inputs` on `referenceFn`). Unnamed parameters (e.g., `IntegrityCheckState memory`, `OperandV2`, `InterpreterState memory`) correctly have no `@param` tags.
5. `@return` for each return value -- all present.
6. NatSpec tag rule compliance -- all blocks that use explicit tags have all entries explicitly tagged. No untagged continuation lines found.
7. NatSpec accuracy vs implementation -- all checked and correct:
   - Input/output counts in `integrity` NatSpec match return values.
   - Float conversion descriptions match actual function calls (`fromFixedDecimalLossyPacked` for allowance, `fromFixedDecimalLosslessPacked` for balance/supply).
   - EVM opcode `referenceFn` NatSpec correctly describes the identity property of `fromFixedDecimalLosslessPacked(value, 0)`.
