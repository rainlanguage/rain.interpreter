# Pass 1: Security Review -- ERC Opcode Libraries

## Evidence of Reading

### 1. LibOpERC20Allowance.sol
- **Library:** `LibOpERC20Allowance` (line 17)
- `integrity` (line 21) -- returns (3, 1)
- `run` (line 30) -- reads token/owner/spender, calls `IERC20.allowance`, converts via `fromFixedDecimalLossyPacked`
- `referenceFn` (line 83) -- mirror of `run` using `StackItem[]`

### 2. LibOpERC20BalanceOf.sol
- **Library:** `LibOpERC20BalanceOf` (line 17)
- `integrity` (line 21) -- returns (2, 1)
- `run` (line 30) -- reads token/account, calls `IERC20.balanceOf`, converts via `fromFixedDecimalLosslessPacked`
- `referenceFn` (line 67) -- mirror of `run` using `StackItem[]`

### 3. LibOpERC20TotalSupply.sol
- **Library:** `LibOpERC20TotalSupply` (line 17)
- `integrity` (line 21) -- returns (1, 1)
- `run` (line 30) -- reads token, calls `IERC20.totalSupply`, converts via `fromFixedDecimalLosslessPacked`
- `referenceFn` (line 61) -- mirror of `run` using `StackItem[]`

### 4. LibOpUint256ERC20Allowance.sol
- **Library:** `LibOpUint256ERC20Allowance` (line 14)
- `integrity` (line 19) -- returns (3, 1)
- `run` (line 28) -- reads token/owner/spender, calls `IERC20.allowance`, stores raw uint256
- `referenceFn` (line 63) -- mirror of `run` using `StackItem[]`

### 5. LibOpUint256ERC20BalanceOf.sol
- **Library:** `LibOpUint256ERC20BalanceOf` (line 14)
- `integrity` (line 19) -- returns (2, 1)
- `run` (line 28) -- reads token/account, calls `IERC20.balanceOf`, stores raw uint256
- `referenceFn` (line 57) -- mirror of `run` using `StackItem[]`

### 6. LibOpUint256ERC20TotalSupply.sol
- **Library:** `LibOpUint256ERC20TotalSupply` (line 14)
- `integrity` (line 19) -- returns (1, 1)
- `run` (line 28) -- reads token, calls `IERC20.totalSupply`, stores raw uint256
- `referenceFn` (line 51) -- mirror of `run` using `StackItem[]`

### 7. LibOpERC721BalanceOf.sol
- **Library:** `LibOpERC721BalanceOf` (line 15)
- `integrity` (line 19) -- returns (2, 1)
- `run` (line 28) -- reads token/account, calls `IERC721.balanceOf`, converts via `fromFixedDecimalLosslessPacked` with decimals=0
- `referenceFn` (line 60) -- mirror of `run` using `StackItem[]`

### 8. LibOpERC721OwnerOf.sol
- **Library:** `LibOpERC721OwnerOf` (line 14)
- `integrity` (line 18) -- returns (2, 1)
- `run` (line 27) -- reads token/tokenId, calls `IERC721.ownerOf`, stores address as uint256
- `referenceFn` (line 53) -- mirror of `run` using `StackItem[]`

### 9. LibOpUint256ERC721BalanceOf.sol
- **Library:** `LibOpUint256ERC721BalanceOf` (line 14)
- `integrity` (line 19) -- returns (2, 1)
- `run` (line 28) -- reads token/account, calls `IERC721.balanceOf`, stores raw uint256
- `referenceFn` (line 55) -- mirror of `run` using `StackItem[]`

### 10. LibOpERC5313Owner.sol
- **Library:** `LibOpERC5313Owner` (line 14)
- `integrity` (line 18) -- returns (1, 1)
- `run` (line 27) -- reads account, calls `IERC5313.owner()`, stores address as uint256
- `referenceFn` (line 50) -- mirror of `run` using `StackItem[]`

## Security Analysis

### Reentrancy
All `run` functions are `internal view`. External calls are read-only (`balanceOf`, `allowance`, `totalSupply`, `ownerOf`, `owner`). No state mutations occur, so reentrancy is not a concern for these opcodes. The interpreter's `eval4` is also `view`.

### Memory Safety in Assembly
All assembly blocks are annotated `memory-safe`. The pattern across all files is:
- Read inputs from `stackTop` upward (each 0x20 apart).
- Advance `stackTop` by `(inputs - 1) * 0x20`.
- Write the single output at the new `stackTop`.

This pattern correctly consumes N stack slots and produces 1, matching the integrity declarations. No out-of-bounds memory access occurs because the integrity check guarantees sufficient stack depth before `run` is called.

### Stack Underflow/Overflow
Integrity functions declare exact input/output counts that match the assembly reads/writes:
- 3-input opcodes (allowance): read at offsets 0x00, 0x20, 0x40; advance by 0x40; write at new stackTop. Correct.
- 2-input opcodes (balanceOf, ownerOf): read at offsets 0x00, 0x20; advance by 0x20; write at new stackTop. Correct.
- 1-input opcodes (totalSupply, owner): read at 0x00; no advance; write at stackTop. Correct.

### Integrity Matching Run
All 10 files have integrity input/output counts that exactly match the stack manipulation in `run`. No mismatches found.

### Operand Validation
None of these opcodes use the operand (it is an unused parameter). This is correct -- they have fixed arity with no configurable behavior.

### Address Validation
All address-type inputs are validated with `NotAnAddress` custom error before use. The `tokenId` parameter in `LibOpERC721OwnerOf` is correctly not validated as an address (it is a uint256 token ID).

### Custom Errors
All error handling uses the custom `NotAnAddress` error type. No string revert messages.

### Known False Positive
The float ERC20 opcodes calling optional `decimals()` via `LibTOFUTokenDecimals.safeDecimalsForTokenReadOnly` is documented in `audit/known-false-positives.md` and is not re-flagged.

## Findings

No findings.

All 10 ERC opcode libraries follow a consistent, correct pattern for stack manipulation, integrity declaration, address validation, and external calls. The code is well-structured with appropriate memory-safety annotations and custom error types.
