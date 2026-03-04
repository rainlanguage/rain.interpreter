# Pass 1 (Security) -- LibOpERC721OwnerOf.sol

Agent: A52

## File

`src/lib/op/erc721/LibOpERC721OwnerOf.sol` (71 lines)

## Evidence of Thorough Reading

**Library:** `library LibOpERC721OwnerOf` (line 14)

**Functions:**

| Function | Line | Visibility | Mutability |
|----------|------|------------|------------|
| `integrity(IntegrityCheckState memory, OperandV2) -> (uint256, uint256)` | 18 | `internal` | `pure` |
| `run(InterpreterState memory, OperandV2, Pointer stackTop) -> Pointer` | 27 | `internal` | `view` |
| `referenceFn(InterpreterState memory, OperandV2, StackItem[] memory inputs) -> StackItem[] memory` | 53 | `internal` | `view` |

**Errors/Events/Structs/Constants:** None defined locally.

**Imported errors:** `NotAnAddress(uint256)` from `src/error/ErrRainType.sol`

**Imports:**
- `IERC721` from openzeppelin-contracts (line 5)
- `Pointer` from rain.solmem (line 6)
- `IntegrityCheckState` from LibIntegrityCheck (line 7)
- `OperandV2`, `StackItem` from IInterpreterV4 (line 8)
- `InterpreterState` from LibInterpreterState (line 9)
- `NotAnAddress` from ErrRainType (line 10)

## Security Analysis

### Integrity / Run Consistency

`integrity()` returns `(2, 1)` -- 2 inputs, 1 output.

`run()` stack arithmetic:
- Reads `token` at `stackTop` (line 31)
- Advances `stackTop` by `0x20` (line 32)
- Reads `tokenId` at new `stackTop` (line 33)
- Writes result at `stackTop` (line 45)

Net effect: 2 values consumed, 1 value written. Stack pointer moves up by 1 slot. This matches integrity's `(2, 1)`.

### Address Validation

The `token` input is validated against `uint160` range at line 39. The `tokenId` input is NOT validated as an address, which is correct -- it is a token ID (arbitrary uint256), not an address.

### External Calls

1. `IERC721(token).ownerOf(tokenId)` (line 43) -- `view` staticcall. Returns an `address`. Per ERC721, `ownerOf` reverts if the token does not exist, which is correct behavior.

### Reentrancy

`run()` is `view`. All external calls are `staticcall`. No reentrancy risk.

### Assembly Safety

Two `assembly ("memory-safe")` blocks:
- Lines 30-34: reads 2 values from stack, advances pointer. Only `mload` and pointer arithmetic. Correct.
- Lines 44-46: writes result to stack position. Single `mstore`. The `tokenOwner` variable is typed `address`, so Solidity guarantees clean upper bits. Correct.

### Operand Usage

The operand parameter is unused, correct for a fixed-arity opcode.

### referenceFn Consistency

`referenceFn()` (lines 53-70) performs the same logic: validates token as address, does not validate tokenId (correct), calls `ownerOf`, wraps result. The wrapping on line 68 uses `bytes32(uint256(uint160(tokenOwner)))` which explicitly zero-extends. Consistent with `run()`.

## Findings

No findings at LOW severity or above.

### A52-INFO-1: tokenId is not validated as an address (correct)

The second input (`tokenId`) is an arbitrary uint256 token identifier, not an address. The `NotAnAddress` check is correctly applied only to `token`. Non-existent token IDs cause `ownerOf` to revert per the ERC721 spec.

### A52-INFO-2: Return value is an address

Like `erc5313-owner`, this opcode returns an address (the token owner), not a numeric value. Clean upper bits are guaranteed by Solidity's `address` type.

## Summary

`LibOpERC721OwnerOf.sol` is a clean ERC721 ownerOf opcode. Stack arithmetic matches integrity (2 inputs, 1 output). Only the token contract address is validated (correct -- tokenId is not an address). The single external call is in `view` context. No security vulnerabilities found.
