# Pass 1 (Security) -- LibOpERC5313Owner.sol

Agent: A50

## File

`src/lib/op/erc5313/LibOpERC5313Owner.sol` (67 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpERC5313Owner` (line 14)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 18 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 27 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 50 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `IERC5313` from openzeppelin-contracts (line 5)
- `Pointer` from rain.solmem (line 6)
- `IntegrityCheckState` from LibIntegrityCheck (line 7)
- `OperandV2`, `StackItem` from IInterpreterV4 (line 8)
- `InterpreterState` from LibInterpreterState (line 9)
- `NotAnAddress` from ErrRainType (line 10)

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(1, 1)` -- 1 input, 1 output.

`run()` stack arithmetic:
- Reads `account` at `stackTop` (line 30)
- Writes result at `stackTop` (line 42)

Net effect: 1 value consumed, 1 value written in-place. Stack pointer does not move. This matches integrity's `(1, 1)`.

### Address Validation

Single input (`account`) is validated against `uint160` range at line 36. Values with non-zero upper 96 bits revert with `NotAnAddress`.

### External Calls

1. `IERC5313(account).owner()` (line 40) -- single `view` staticcall. Returns an `address`, which Solidity stores as a clean 160-bit value in the stack slot.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 29-31: reads 1 value from stack. Single `mload`. Correct.
- Lines 41-43: writes result to stack position. Single `mstore`. The `owner` variable is typed `address`, so Solidity guarantees it is zero-extended to 256 bits with clean upper bits. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 50-66) performs the same logic: validates 1 address, calls `owner()`, wraps result as `StackItem`. The wrapping on line 64 uses `bytes32(uint256(uint160(owner)))` which explicitly zero-extends the address. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A50-INFO-1: Return value is an address, not a float

Unlike the ERC20 balance opcodes, this opcode returns an address (the owner). The returned value can be used directly in address comparisons by downstream Rainlang logic.

### A50-INFO-2: ERC5313 is a lightweight interface

ERC5313 defines only `owner() -> address`. Non-compliant contracts that do not implement `owner()` will cause the external call to revert, which is the expected behavior.

## Summary

`LibOpERC5313Owner.sol` is a minimal ERC5313 owner opcode. Stack arithmetic matches integrity (1 input, 1 output). Address input is validated. The single external call is in `view` context. No float conversion needed. No security vulnerabilities found.
