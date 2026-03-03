# Pass 1 (Security) -- ERC721/ERC5313/EVM/Crypto Ops

**Auditor**: A22
**Date**: 2026-03-01

## Files Reviewed

1. `src/lib/op/erc721/LibOpERC721BalanceOf.sol` (89 lines)
2. `src/lib/op/erc721/LibOpERC721OwnerOf.sol` (71 lines)
3. `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` (76 lines)
4. `src/lib/op/erc5313/LibOpERC5313Owner.sol` (67 lines)
5. `src/lib/op/evm/LibOpBlockNumber.sol` (48 lines)
6. `src/lib/op/evm/LibOpChainId.sol` (48 lines)
7. `src/lib/op/evm/LibOpTimestamp.sol` (48 lines)
8. `src/lib/op/crypto/LibOpHash.sol` (49 lines)

---

## Evidence of Thorough Reading

### LibOpERC721BalanceOf.sol

**Library**: `LibOpERC721BalanceOf` (line 15)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 19 | internal | pure |
| `run` | 28 | internal | view |
| `referenceFn` | 60 | internal | view |

**Imports**: `InterpreterState` (line 5), `OperandV2`, `StackItem` (line 6), `Pointer` (line 7), `IERC721` (line 8), `LibDecimalFloat`, `Float` (line 9), `IntegrityCheckState` (line 10), `NotAnAddress` (line 11).

**Integrity**: Returns (2, 1). Two inputs (token, account), one output (balance as float).

**Run logic**: Reads `token` and `account` from stack (lines 31-35). Validates both are valid addresses via `NotAnAddress` (lines 40, 43). Calls `IERC721(token).balanceOf(account)` (line 47). Converts result to `Float` via `fromFixedDecimalLosslessPacked(tokenBalance, 0)` (line 49). Writes float to stack (line 52).

**referenceFn**: Same logic using `StackItem[]` array access. Validates addresses, calls `balanceOf`, converts to float. Returns via `StackItem[]` array.

### LibOpERC721OwnerOf.sol

**Library**: `LibOpERC721OwnerOf` (line 14)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 18 | internal | pure |
| `run` | 27 | internal | view |
| `referenceFn` | 53 | internal | view |

**Imports**: `IERC721` (line 5), `Pointer` (line 6), `IntegrityCheckState` (line 7), `OperandV2`, `StackItem` (line 8), `InterpreterState` (line 9), `NotAnAddress` (line 10).

**Integrity**: Returns (2, 1). Two inputs (token, tokenId), one output (owner address).

**Run logic**: Reads `token` and `tokenId` from stack (lines 30-33). Validates `token` is a valid address (line 39). Does NOT validate `tokenId` (raw uint256 pass-through to `ownerOf`). Calls `IERC721(token).ownerOf(tokenId)` (line 43). Writes owner address to stack (line 45).

**referenceFn**: Same logic. Validates `token` address, passes `tokenId` directly. Returns owner wrapped as `bytes32(uint256(uint160(owner)))`.

### LibOpUint256ERC721BalanceOf.sol

**Library**: `LibOpUint256ERC721BalanceOf` (line 14)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 16 | internal | pure |
| `run` | 25 | internal | view |
| `referenceFn` | 52 | internal | view |

**Imports**: `IERC721` (line 5), `Pointer` (line 6), `IntegrityCheckState` (line 7), `OperandV2`, `StackItem` (line 8), `InterpreterState` (line 9), `NotAnAddress` (line 10).

**Integrity**: Returns (2, 1). Two inputs (token, account), one output (raw uint256 balance).

**Run logic**: Same as `LibOpERC721BalanceOf` except result is stored as raw `uint256` instead of float. No `fromFixedDecimalLosslessPacked` conversion.

**referenceFn**: Validates addresses, calls `balanceOf`, wraps raw balance as `bytes32(tokenBalance)`.

### LibOpERC5313Owner.sol

**Library**: `LibOpERC5313Owner` (line 14)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 18 | internal | pure |
| `run` | 27 | internal | view |
| `referenceFn` | 50 | internal | view |

**Imports**: `IERC5313` (line 5), `Pointer` (line 6), `IntegrityCheckState` (line 7), `OperandV2`, `StackItem` (line 8), `InterpreterState` (line 9), `NotAnAddress` (line 10).

**Integrity**: Returns (1, 1). One input (contract address), one output (owner address).

**Run logic**: Reads `account` from stack (line 30). Validates address (line 36). Calls `IERC5313(account).owner()` (line 40). Writes owner to stack (line 42).

**referenceFn**: Same logic, validates address, calls `owner()`, returns wrapped address.

### LibOpBlockNumber.sol

**Library**: `LibOpBlockNumber` (line 13), `using LibDecimalFloat for Float` (line 14)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 19 | internal | pure |
| `run` | 26 | internal | view |
| `referenceFn` | 39 | internal | view |

**Integrity**: Returns (0, 1). No inputs, one output.

**Run logic**: Assembly pushes `number()` (EVM block number opcode) to stack by decrementing `stackTop` by 0x20 and writing value (lines 27-30).

**referenceFn**: Uses `LibDecimalFloat.fromFixedDecimalLosslessPacked(block.number, 0)` and wraps as `StackItem`. Comment documents that `run` stores raw value directly as gas optimization, and the reference function verifies `fromFixedDecimalLosslessPacked(value, 0)` is identity (lines 35-37).

### LibOpChainId.sol

**Library**: `LibOpChainId` (line 13), `using LibDecimalFloat for Float` (line 14)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 19 | internal | pure |
| `run` | 26 | internal | view |
| `referenceFn` | 39 | internal | view |

Structurally identical to `LibOpBlockNumber` but uses `chainid()` instead of `number()`.

### LibOpTimestamp.sol

**Library**: `LibOpTimestamp` (line 13), `using LibDecimalFloat for Float` (line 14)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 19 | internal | pure |
| `run` | 26 | internal | view |
| `referenceFn` | 39 | internal | view |

Structurally identical to `LibOpBlockNumber` but uses `timestamp()` instead of `number()`.

### LibOpHash.sol

**Library**: `LibOpHash` (line 12)

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `integrity` | 17 | internal | pure |
| `run` | 28 | internal | pure |
| `referenceFn` | 41 | internal | pure |

**Imports**: `Pointer` (line 5), `OperandV2`, `StackItem` (line 6), `InterpreterState` (line 7), `IntegrityCheckState` (line 8).

**Integrity**: Extracts input count from operand bits 16-19 via `(OperandV2.unwrap(operand) >> 0x10) & 0x0F`, yielding 0-15. Returns `(inputs, 1)`.

**Run logic**: Assembly extracts same input count. Computes `keccak256(stackTop, length)` where `length = inputs * 0x20`. Adjusts stackTop: `sub(add(stackTop, length), 0x20)` consumes `inputs` slots and produces 1 output. Writes hash to new stackTop.

**referenceFn**: Uses `keccak256(abi.encodePacked(inputs))`. Since `StackItem` is `bytes32`, `abi.encodePacked` produces the same byte sequence as the contiguous stack memory.

---

## Security Analysis

### External Call Safety

All four libraries making external calls (`LibOpERC721BalanceOf`, `LibOpERC721OwnerOf`, `LibOpUint256ERC721BalanceOf`, `LibOpERC5313Owner`) use typed Solidity interface calls (`IERC721(addr).balanceOf(...)`, `IERC721(addr).ownerOf(...)`, `IERC5313(addr).owner()`). These are compiled to `STATICCALL` (all functions are `view`) with:

1. ABI-encoded calldata generated by the compiler.
2. Automatic revert propagation on call failure.
3. ABI-decoded return value with implicit length/type validation.

If the target address is an EOA or non-contract, the STATICCALL succeeds with empty returndata, and Solidity's ABI decoder reverts when attempting to decode the expected return type from empty bytes.

**Conclusion**: External calls are safe. Return values are implicitly validated by Solidity's ABI decoder.

### Address Validation

All address inputs are validated with `NotAnAddress`:
- `LibOpERC721BalanceOf`: validates `token` (line 40) and `account` (line 43)
- `LibOpERC721OwnerOf`: validates `token` (line 39)
- `LibOpUint256ERC721BalanceOf`: validates `token` (line 35) and `account` (line 38)
- `LibOpERC5313Owner`: validates `account` (line 36)

The validation pattern `if (value != uint256(uint160(value))) revert NotAnAddress(value)` correctly detects values with non-zero upper 96 bits.

`LibOpERC721OwnerOf` does NOT validate `tokenId` -- this is correct because `tokenId` is a raw `uint256`, not an address.

**Conclusion**: Address validation is complete and correct.

### Assembly Memory Safety

All assembly blocks are annotated `"memory-safe"`. Analysis of each:

1. **ERC721/ERC5313 stack reads** (e.g., lines 31-35 of `LibOpERC721BalanceOf`): Read from `stackTop` and `stackTop + 0x20`. These are within the interpreter's allocated stack region (bounds enforced by the integrity check). No free memory pointer modification.

2. **ERC721/ERC5313 stack writes** (e.g., lines 51-53 of `LibOpERC721BalanceOf`): Write to `stackTop`, which is within the consumed stack region. No allocation.

3. **EVM opcode pushes** (e.g., lines 27-30 of `LibOpBlockNumber`): `sub(stackTop, 0x20)` moves the pointer to the slot immediately below the current top, then writes. This is the standard push pattern. The stack region was pre-allocated by the interpreter with sufficient space (sized by the integrity check's max-stack analysis).

4. **Hash opcode** (lines 29-35 of `LibOpHash`): Reads `inputs * 0x20` bytes from `stackTop`. Writes 1 value to `stackTop + length - 0x20`, which is within the consumed stack region. Correctly bounded.

**Conclusion**: All assembly is memory-safe.

### Integrity/Run Consistency

All eight opcodes have consistent integrity declarations and runtime behavior:

| Opcode | Integrity | Run net stack effect |
|---|---|---|
| `erc721-balance-of` | (2, 1) | Consumes 2 (token, account), produces 1 (float balance) |
| `erc721-owner-of` | (2, 1) | Consumes 2 (token, tokenId), produces 1 (owner address) |
| `uint256-erc721-balance-of` | (2, 1) | Consumes 2 (token, account), produces 1 (raw balance) |
| `erc5313-owner` | (1, 1) | Consumes 1 (contract), produces 1 (owner address) |
| `block-number` | (0, 1) | Consumes 0, produces 1 (raw block number) |
| `chain-id` | (0, 1) | Consumes 0, produces 1 (raw chain id) |
| `block-timestamp` | (0, 1) | Consumes 0, produces 1 (raw timestamp) |
| `hash` | (N, 1) where N=0..15 | Consumes N, produces 1 (keccak256 hash) |

**Conclusion**: All integrity declarations match runtime behavior.

### referenceFn Consistency

All `referenceFn` implementations produce the same outputs as `run` for the same inputs:

- **ERC721/ERC5313 ops**: Same external calls, same address validation, same return value handling.
- **EVM ops**: Use `LibDecimalFloat.fromFixedDecimalLosslessPacked(value, 0)` where `run` stores `value` directly. The NatSpec documents this is because `fromFixedDecimalLosslessPacked(value, 0)` is identity for these values -- confirmed by the `opReferenceCheck` fuzz tests.
- **Hash op**: `keccak256(abi.encodePacked(inputs))` produces the same bytes as `keccak256(stackTop, length)` because `StackItem` is `bytes32` and `abi.encodePacked` on a `bytes32[]` concatenates elements without padding.

**Conclusion**: All reference functions are consistent with runtime functions.

### Reentrancy

The external calls in ERC721/ERC5313 opcodes are `STATICCALL` (all `run` functions are `view`). `STATICCALL` prevents the callee from modifying state, eliminating reentrancy risk.

**Conclusion**: No reentrancy risk.

---

## Findings

### A22-1 -- INFO: `LibOpUint256ERC721BalanceOf.integrity` NatSpec missing `@notice` tag

**Severity**: INFO

**Location**: `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`, line 15

**Description**: The `integrity` function's NatSpec comment on line 15 reads `/// \`uint256-erc721-balance-of\` integrity check...` without an explicit `@notice` tag. All other `integrity` functions across the seven other files in this review use explicit `@notice` tags. While technically valid Solidity NatSpec (implicit `@notice` when no tags are present in a doc block), it is inconsistent with the project's convention.

### A22-2 -- INFO: EVM ops store raw values relying on `fromFixedDecimalLosslessPacked(v, 0)` being identity

**Severity**: INFO

**Location**: `src/lib/op/evm/LibOpBlockNumber.sol` line 29, `LibOpChainId.sol` line 29, `LibOpTimestamp.sol` line 29

**Description**: The three EVM opcode `run` functions store raw `number()`, `chainid()`, and `timestamp()` values directly on the stack without float conversion, while their `referenceFn` implementations use `LibDecimalFloat.fromFixedDecimalLosslessPacked(value, 0)`. The NatSpec explicitly documents this optimization and states that `fromFixedDecimalLosslessPacked(value, 0)` is identity for these values. The `opReferenceCheck` fuzz tests validate this invariant. This is noted for completeness -- the optimization is correct and well-documented.

### A22-3 -- INFO: Hash opcode input count limited to 15 by 4-bit mask

**Severity**: INFO

**Location**: `src/lib/op/crypto/LibOpHash.sol`, lines 20 and 30

**Description**: The input count is extracted with `& 0x0F`, limiting the hash opcode to at most 15 inputs (480 bytes of data). This is a shared design constraint across all multi-input opcodes in the codebase and is explicitly documented in the comment on line 19. Rainlang authors needing to hash more data would need to chain multiple hash operations.

---

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings across all eight files.

All external calls use typed Solidity interface calls compiled to `STATICCALL`, with implicit return value validation via the ABI decoder. Address inputs are consistently validated with `NotAnAddress`. All assembly blocks are correctly annotated `"memory-safe"` and operate within the interpreter's managed stack region. Integrity declarations match runtime behavior in all cases. Reference functions are semantically equivalent to runtime functions, confirmed by fuzz tests.
