# Pass 1 (Security) -- LibOpUint256ERC20Allowance.sol

Agent: A47

## File

`src/lib/op/erc20/uint256/LibOpUint256ERC20Allowance.sol` (97 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpUint256ERC20Allowance` (line 14)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 19 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 28 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 63 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `IERC20` from openzeppelin-contracts (line 5)
- `Pointer` from rain.solmem (line 6)
- `IntegrityCheckState` from LibIntegrityCheck (line 7)
- `OperandV2`, `StackItem` from IInterpreterV4 (line 8)
- `InterpreterState` from LibInterpreterState (line 9)
- `NotAnAddress` from ErrRainType (line 10)

No `LibDecimalFloat` or `LibTOFUTokenDecimals` imports -- this is the uint256 variant that returns raw values.

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(3, 1)` -- 3 inputs, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 33)
- Reads `owner` at `stackTop + 0x20` (line 34)
- Advances `stackTop` by `0x40` (line 35)
- Reads `spender` at new `stackTop` (line 36)
- Writes result at `stackTop` (line 55)

Net effect: 3 values consumed, 1 value written. Stack pointer moves up by 2 slots. This matches integrity's `(3, 1)`.

### Address Validation

All three inputs (`token`, `owner`, `spender`) are validated against `uint160` range at lines 42, 45, 48. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC20(token).allowance(owner, spender)` (line 53) -- single `view` staticcall to arbitrary address. No float conversion, no `decimals()` call. Returns the raw uint256 value directly.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 32-37: reads 3 values from stack, advances pointer. Only `mload` and pointer arithmetic. Correct.
- Lines 54-56: writes result to stack position. Single `mstore`. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 63-96) performs the same logic: validates all 3 addresses, calls `allowance`, returns raw uint256 wrapped in `StackItem`. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A47-INFO-1: Simpler than float variant -- no decimals() call needed

This uint256 variant avoids the `decimals()` call entirely, making it safe for use with non-compliant ERC20 tokens. The tradeoff is that the caller receives a raw uint256 rather than a normalized float.

## Summary

`LibOpUint256ERC20Allowance.sol` is a minimal uint256 ERC20 allowance opcode. Stack arithmetic matches integrity (3 inputs, 1 output). All address inputs are validated. The single external call is in `view` context. No float conversion or `decimals()` dependency. No security vulnerabilities found.
