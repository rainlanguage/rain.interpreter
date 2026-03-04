# Pass 1 (Security) -- LibOpUint256ERC20TotalSupply.sol

Agent: A49

## File

`src/lib/op/erc20/uint256/LibOpUint256ERC20TotalSupply.sol` (69 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpUint256ERC20TotalSupply` (line 14)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 19 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 28 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 51 | `internal` | `view` |

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

`integrity()` returns `(1, 1)` -- 1 input, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 31)
- Writes result at `stackTop` (line 43)

Net effect: 1 value consumed, 1 value written in-place. Stack pointer does not move. This matches integrity's `(1, 1)`.

### Address Validation

Single input (`token`) is validated against `uint160` range at line 37. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC20(token).totalSupply()` (line 41) -- single `view` staticcall. Returns raw uint256.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 30-32: reads 1 value from stack. Single `mload`. Correct.
- Lines 42-44: writes result to stack position. Single `mstore`. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 51-68) performs the same logic: validates 1 address, calls `totalSupply`, returns raw uint256. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A49-INFO-1: Minimal external call surface

Single `view` call to `totalSupply`. No `decimals()` dependency. Safe for use with any ERC20-compliant token.

## Summary

`LibOpUint256ERC20TotalSupply.sol` is a minimal uint256 ERC20 total supply opcode. Stack arithmetic matches integrity (1 input, 1 output). Address input is validated. The single external call is in `view` context. No security vulnerabilities found.
