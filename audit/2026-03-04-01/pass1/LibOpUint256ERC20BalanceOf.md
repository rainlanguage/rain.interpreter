# Pass 1 (Security) -- LibOpUint256ERC20BalanceOf.sol

Agent: A48

## File

`src/lib/op/erc20/uint256/LibOpUint256ERC20BalanceOf.sol` (83 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpUint256ERC20BalanceOf` (line 14)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 19 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 28 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 57 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `IERC20` from openzeppelin-contracts (line 5)
- `Pointer` from rain.solmem (line 6)
- `IntegrityCheckState` from LibIntegrityCheck (line 7)
- `OperandV2`, `StackItem` from IInterpreterV4 (line 8)
- `InterpreterState` from LibInterpreterState (line 9)
- `NotAnAddress` from ErrRainType (line 10)

No `LibDecimalFloat` or `LibTOFUTokenDecimals` imports.

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(2, 1)` -- 2 inputs, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 32)
- Advances `stackTop` by `0x20` (line 33)
- Reads `account` at new `stackTop` (line 34)
- Writes result at `stackTop` (line 49)

Net effect: 2 values consumed, 1 value written. Stack pointer moves up by 1 slot. This matches integrity's `(2, 1)`.

### Address Validation

Both inputs (`token`, `account`) are validated against `uint160` range at lines 40, 43. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC20(token).balanceOf(account)` (line 47) -- single `view` staticcall. Returns raw uint256.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 31-35: reads 2 values from stack, advances pointer. Only `mload` and pointer arithmetic. Correct.
- Lines 48-50: writes result to stack position. Single `mstore`. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 57-82) performs the same logic: validates 2 addresses, calls `balanceOf`, returns raw uint256. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A48-INFO-1: Minimal external call surface

Single `view` call to `balanceOf`. No `decimals()` dependency. Safe for use with any ERC20-compliant token.

## Summary

`LibOpUint256ERC20BalanceOf.sol` is a minimal uint256 ERC20 balance opcode. Stack arithmetic matches integrity (2 inputs, 1 output). Both address inputs are validated. The single external call is in `view` context. No security vulnerabilities found.
