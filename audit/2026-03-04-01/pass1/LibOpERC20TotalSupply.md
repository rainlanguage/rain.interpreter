# Pass 1 (Security) -- LibOpERC20TotalSupply.sol

Agent: A46

## File

`src/lib/op/erc20/LibOpERC20TotalSupply.sol` (83 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpERC20TotalSupply` (line 17)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 21 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 30 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 61 | `internal` | `view` |

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

`integrity()` returns `(1, 1)` -- 1 input, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 33)
- Writes result at `stackTop` (line 53)

Net effect: 1 value consumed, 1 value written in-place. Stack pointer does not move. This matches integrity's `(1, 1)`.

### Address Validation

Single input (`token`) is validated against `uint160` range at line 39. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC20(token).totalSupply()` (line 43) -- `view` staticcall to arbitrary address.

2. `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly(token)` (line 48) -- `view` call to the TOFU singleton. Known false positive for non-compliant tokens.

3. `LibDecimalFloat.fromFixedDecimalLosslessPacked(totalSupply, tokenDecimals)` (line 50) -- pure lossless conversion. Appropriate for total supply values.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 32-34: reads 1 value from stack. Single `mload`. Correct.
- Lines 52-54: writes result to stack position. Single `mstore`. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 61-82) performs the same logic: validates 1 address, calls `totalSupply`, calls `safeDecimalsForTokenReadOnly`, uses `fromFixedDecimalLosslessPacked`. Returns `StackItem[]` of length 1. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A46-INFO-1: External calls to arbitrary token addresses

Same pattern as other ERC20 opcodes. Calls to user-provided token addresses are inherent to the opcode's purpose. Mitigated by `view` context.

## Summary

`LibOpERC20TotalSupply.sol` is a clean ERC20 total supply opcode. Stack arithmetic matches integrity (1 input, 1 output). Address input is validated. External calls are in `view` context. The lossless float conversion is appropriate for total supply. The `decimals()` call on non-compliant tokens is a known false positive. No security vulnerabilities found.
