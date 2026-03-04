# Pass 1 (Security) -- LibOpERC20BalanceOf.sol

Agent: A45

## File

`src/lib/op/erc20/LibOpERC20BalanceOf.sol` (98 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpERC20BalanceOf` (line 17)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 21 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 30 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 67 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `IERC20` from openzeppelin-contracts (line 4)
- `Pointer` from rain.solmem (line 6)
- `IntegrityCheckState` from LibIntegrityCheck (line 7)
- `OperandV2` from IInterpreterV4 (line 8)
- `InterpreterState` from LibInterpreterState (line 9)
- `LibDecimalFloat`, `Float` from rain.math.float (line 10)
- `LibTOFUTokenDecimals` from rain.tofu.erc20-decimals (line 11)
- `StackItem` from IInterpreterV4 (line 12)
- `NotAnAddress` from ErrRainType (line 13)

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(2, 1)` -- 2 inputs, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 34)
- Advances `stackTop` by `0x20` (line 35)
- Reads `account` at new `stackTop` (line 36)
- Writes result at `stackTop` (line 59)

Net effect: 2 values consumed, 1 value written. The stack pointer moves up by 1 slot (0x20), converting 2 inputs into 1 output. This matches integrity's `(2, 1)`.

### Address Validation

Both inputs (`token`, `account`) are validated against `uint160` range at lines 42, 45. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC20(token).balanceOf(account)` (line 49) -- `view` staticcall to arbitrary address.

2. `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly(token)` (line 54) -- `view` call to the TOFU singleton. Known false positive for non-compliant tokens (see `audit/known-false-positives.md`).

3. `LibDecimalFloat.fromFixedDecimalLosslessPacked(tokenBalance, tokenDecimals)` (line 56) -- pure conversion. Uses the lossless variant (unlike Allowance), which will revert if the balance cannot be exactly represented as a decimal float. ERC20 balances are typically representable.

### Reentrancy

`run()` is `view`, so all external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 33-37: reads 2 values from stack, advances pointer. Only `mload` and pointer arithmetic. Correct.
- Lines 58-60: writes result to stack position. Single `mstore`. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 67-97) performs the same logic: validates 2 addresses, calls `balanceOf`, calls `safeDecimalsForTokenReadOnly`, uses `fromFixedDecimalLosslessPacked`. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A45-INFO-1: Lossless float conversion may revert for exotic token balances

`fromFixedDecimalLosslessPacked` is used for balance conversion. If an ERC20 token has a balance that cannot be exactly represented in a decimal float, this will revert. This is the correct behavior -- silent precision loss would be a greater risk. The `uint256-erc20-balance-of` variant exists for callers who need raw uint256 values.

### A45-INFO-2: External calls to arbitrary token addresses

Same as A44-INFO-2. Calls to user-provided token addresses are inherent to the opcode's purpose. Mitigated by `view` context.

## Summary

`LibOpERC20BalanceOf.sol` is a clean ERC20 balance opcode. Stack arithmetic matches integrity (2 inputs, 1 output). Both address inputs are validated. External calls are in `view` context. The lossless float conversion is appropriate for balances. The `decimals()` call on non-compliant tokens is a known false positive. No security vulnerabilities found.
