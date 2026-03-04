# Pass 1 (Security) -- LibOpERC721BalanceOf.sol

Agent: A51

## File

`src/lib/op/erc721/LibOpERC721BalanceOf.sol` (89 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpERC721BalanceOf` (line 15)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 19 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 28 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 60 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `InterpreterState` from LibInterpreterState (line 5)
- `OperandV2`, `StackItem` from IInterpreterV4 (line 6)
- `Pointer` from rain.solmem (line 7)
- `IERC721` from openzeppelin-contracts (line 8)
- `LibDecimalFloat`, `Float` from rain.math.float (line 9)
- `IntegrityCheckState` from LibIntegrityCheck (line 10)
- `NotAnAddress` from ErrRainType (line 11)

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(2, 1)` -- 2 inputs, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 32)
- Advances `stackTop` by `0x20` (line 33)
- Reads `account` at new `stackTop` (line 34)
- Writes result at `stackTop` (line 52)

Net effect: 2 values consumed, 1 value written. Stack pointer moves up by 1 slot. This matches integrity's `(2, 1)`.

### Address Validation

Both inputs (`token`, `account`) are validated against `uint160` range at lines 40, 43. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC721(token).balanceOf(account)` (line 47) -- `view` staticcall to arbitrary address.

2. `LibDecimalFloat.fromFixedDecimalLosslessPacked(tokenBalance, 0)` (line 49) -- pure conversion with 0 decimals. ERC721 balances are integers, so passing `0` for decimals is correct. The lossless conversion will not lose precision for integer values within the representable range.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 31-35: reads 2 values from stack, advances pointer. Only `mload` and pointer arithmetic. Correct.
- Lines 51-53: writes result to stack position. Single `mstore`. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### No TOFU Dependency

Unlike the ERC20 float variants, this opcode does not call `decimals()`. ERC721 tokens do not have decimals, so the hardcoded `0` is correct.

### referenceFn Consistency

`referenceFn()` (lines 60-88) performs the same logic: validates 2 addresses, calls `balanceOf`, uses `fromFixedDecimalLosslessPacked(tokenBalance, 0)`. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A51-INFO-1: Float conversion with 0 decimals for ERC721 integer balances

ERC721 balances are whole numbers. The `fromFixedDecimalLosslessPacked(tokenBalance, 0)` call correctly treats them as integers with no decimal places.

## Summary

`LibOpERC721BalanceOf.sol` is a clean ERC721 balance opcode. Stack arithmetic matches integrity (2 inputs, 1 output). Both address inputs are validated. External calls are in `view` context. Float conversion with 0 decimals is correct for ERC721. No security vulnerabilities found.
