# Pass 1 (Security) — ERC721, ERC5313, and EVM Opcodes

Auditor: Claude Opus 4.6
Date: 2026-02-17
Namespace: 2026-02-17-03

## Files Reviewed

### 1. `src/lib/op/erc721/LibOpERC721BalanceOf.sol`

**Library:** `LibOpERC721BalanceOf`

**Functions:**
- `integrity` (line 16) — returns `(2, 1)` (2 inputs, 1 output)
- `run` (line 23) — reads token and account from stack, calls `IERC721.balanceOf`, converts result to Float, writes result back
- `referenceFn` (line 45) — reference implementation for testing

**Errors/Events/Structs:** None defined in this file.

---

### 2. `src/lib/op/erc721/LibOpERC721OwnerOf.sol`

**Library:** `LibOpERC721OwnerOf`

**Functions:**
- `integrity` (line 15) — returns `(2, 1)` (2 inputs, 1 output)
- `run` (line 22) — reads token and tokenId from stack, calls `IERC721.ownerOf`, stores owner address back
- `referenceFn` (line 41) — reference implementation for testing

**Errors/Events/Structs:** None defined in this file.

---

### 3. `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol`

**Library:** `LibOpUint256ERC721BalanceOf`

**Functions:**
- `integrity` (line 15) — returns `(2, 1)` (2 inputs, 1 output)
- `run` (line 22) — reads token and account from stack, calls `IERC721.balanceOf`, stores raw uint256 balance back
- `referenceFn` (line 41) — reference implementation for testing

**Errors/Events/Structs:** None defined in this file.

---

### 4. `src/lib/op/erc5313/LibOpERC5313Owner.sol`

**Library:** `LibOpERC5313Owner`

**Functions:**
- `integrity` (line 15) — returns `(1, 1)` (1 input, 1 output)
- `run` (line 22) — reads contract address from stack, calls `IERC5313.owner()`, stores owner address back
- `referenceFn` (line 38) — reference implementation for testing

**Errors/Events/Structs:** None defined in this file.

---

### 5. `src/lib/op/evm/LibOpBlockNumber.sol`

**Library:** `LibOpBlockNumber`

**Functions:**
- `integrity` (line 17) — returns `(0, 1)` (0 inputs, 1 output)
- `run` (line 22) — pushes current block number onto the stack as raw value
- `referenceFn` (line 34) — reference implementation using `fromFixedDecimalLosslessPacked(block.number, 0)`

**Errors/Events/Structs:** None defined in this file.

---

### 6. `src/lib/op/evm/LibOpChainId.sol`

**Library:** `LibOpChainId`

**Functions:**
- `integrity` (line 17) — returns `(0, 1)` (0 inputs, 1 output)
- `run` (line 22) — pushes current chain ID onto the stack as raw value
- `referenceFn` (line 34) — reference implementation using `fromFixedDecimalLosslessPacked(block.chainid, 0)`

**Errors/Events/Structs:** None defined in this file.

---

### 7. `src/lib/op/evm/LibOpTimestamp.sol`

**Library:** `LibOpTimestamp`

**Functions:**
- `integrity` (line 17) — returns `(0, 1)` (0 inputs, 1 output)
- `run` (line 22) — pushes current block timestamp onto the stack as raw value
- `referenceFn` (line 34) — reference implementation using `fromFixedDecimalLosslessPacked(block.timestamp, 0)`

**Errors/Events/Structs:** None defined in this file.

---

## Findings

### Finding 1: External calls to untrusted addresses without reentrancy protection

**Severity:** LOW

**Files:**
- `src/lib/op/erc721/LibOpERC721BalanceOf.sol` (line 34)
- `src/lib/op/erc721/LibOpERC721OwnerOf.sol` (line 33)
- `src/lib/op/erc721/uint256/LibOpUint256ERC721BalanceOf.sol` (line 33)
- `src/lib/op/erc5313/LibOpERC5313Owner.sol` (line 30)

**Description:** All four of these opcodes make external calls (`balanceOf`, `ownerOf`, `owner()`) to addresses supplied by the Rainlang author via the stack. These are `view` calls (the functions are marked `internal view`), so the interpreter's own state cannot be modified during the callback. However, the called contract address is entirely user-controlled, and a malicious contract could:
1. Observe the calling context (gas, caller) for information leakage
2. Revert with crafted error data to influence error handling upstream
3. Consume excessive gas if the target contract has complex `view` logic

**Mitigating factors:** The `run` functions are all `internal view`, which means the calling context is view-only within these library calls. The interpreter's eval loop handles reverts from external calls. The responsibility for providing valid addresses is documented as being on the Rainlang author. This is consistent with the pattern used in ERC20 opcodes and is a design-level tradeoff rather than a bug.

---

### Finding 2: Integrity input/output counts are correct for all reviewed opcodes

**Severity:** INFO

**Files:** All 7 files.

**Description:** Verified that `integrity` declarations match `run` behavior:

| Opcode | integrity | run reads | run writes | Match? |
|--------|-----------|-----------|------------|--------|
| `erc721-balance-of` | (2, 1) | 2 (token, account) | 1 (balance as Float) | Yes |
| `erc721-owner-of` | (2, 1) | 2 (token, tokenId) | 1 (owner address) | Yes |
| `uint256-erc721-balance-of` | (2, 1) | 2 (token, account) | 1 (balance as uint256) | Yes |
| `erc5313-owner` | (1, 1) | 1 (contract address) | 1 (owner address) | Yes |
| `block-number` | (0, 1) | 0 | 1 (block number) | Yes |
| `chain-id` | (0, 1) | 0 | 1 (chain ID) | Yes |
| `block-timestamp` | (0, 1) | 0 | 1 (timestamp) | Yes |

For 2-input opcodes (`erc721-balance-of`, `erc721-owner-of`, `uint256-erc721-balance-of`): `run` reads the first input at `stackTop`, advances by `0x20`, reads the second input, then writes the result at the second position. Net effect: consumes 2 stack slots, produces 1 — the returned `stackTop` points to where the second input was, now containing the output. This correctly matches `(2, 1)`.

For the 1-input opcode (`erc5313-owner`): `run` reads input at `stackTop`, writes the result at the same position, returns same `stackTop`. Consumes 1, produces 1. Matches `(1, 1)`.

For 0-input opcodes (`block-number`, `chain-id`, `block-timestamp`): `run` decrements `stackTop` by `0x20` then writes. Consumes 0, produces 1. Matches `(0, 1)`.

---

### Finding 3: Assembly blocks are correctly marked `memory-safe`

**Severity:** INFO

**Files:** All 7 files.

**Description:** All assembly blocks in the reviewed files are marked `"memory-safe"`. Each block either:
- Reads/writes to the stack area via `stackTop` pointer (which is managed memory within the interpreter's stack), or
- Writes to a position that was just read from (in-place replacement for 1-input/1-output opcodes), or
- Decrements `stackTop` by `0x20` and writes to the newly allocated position (for 0-input/1-output opcodes using the stack growth pattern).

None of these access free memory or modify the free memory pointer. The `memory-safe` annotation is accurate.

---

### Finding 4: No unchecked arithmetic concerns

**Severity:** INFO

**Files:** All 7 files.

**Description:** The arithmetic operations in the assembly blocks are:
- `add(stackTop, 0x20)` — advancing the stack pointer. Overflow is impossible because the stack pointer is within EVM memory bounds.
- `sub(stackTop, 0x20)` — decrementing the stack pointer to grow the stack. Underflow would mean writing to very high memory (near address 0), but this is prevented by the integrity check guaranteeing there is stack space available before `run` is called.
- `uint160(token)` — truncation is intentional and documented with forge-lint suppression comments.

No unchecked arithmetic issues found.

---

### Finding 5: No custom error usage (correct — no error paths exist)

**Severity:** INFO

**Files:** All 7 files.

**Description:** None of the reviewed files define or use revert statements. All error conditions are handled either by:
- The integrity check (which would catch wrong input counts before `run` is called)
- The external call itself reverting (e.g., `ownerOf` reverts for nonexistent tokens per ERC721 spec)
- The Float conversion function (`fromFixedDecimalLosslessPacked`) reverting with its own custom errors if the value is too large

No string revert errors (`revert("...")`) are present. This is correct.

---

### Finding 6: EVM opcodes store raw values relying on identity with Float packing

**Severity:** INFO

**Files:**
- `src/lib/op/evm/LibOpBlockNumber.sol` (line 24-25)
- `src/lib/op/evm/LibOpChainId.sol` (line 24-25)
- `src/lib/op/evm/LibOpTimestamp.sol` (line 24-25)

**Description:** The `run()` functions for `block-number`, `chain-id`, and `block-timestamp` store raw EVM values directly onto the stack using assembly (`number()`, `chainid()`, `timestamp()`), without going through `fromFixedDecimalLosslessPacked`. The `referenceFn()` implementations do use `fromFixedDecimalLosslessPacked(value, 0)` and the NatSpec comments explicitly state this is to "verify that `fromFixedDecimalLosslessPacked(value, 0)` is identity."

This identity holds because the Float packing format stores a signed int224 coefficient in the lower 224 bits and a signed int32 exponent in the upper 32 bits. For `fromFixedDecimalLosslessPacked(value, 0)`:
- The exponent is 0, so the upper 32 bits are zero
- The coefficient equals `value`, and for block numbers, chain IDs, and timestamps (all well below 2^223), it fits in int224
- Therefore `pack(value, 0) = (0 << 224) | value = value`

This identity is a valid gas optimization. The only theoretical concern would be if any of these values exceeded `int224.max` (~2.69 * 10^67), which is physically impossible for block numbers, chain IDs, or timestamps.

---

### Finding 7: `LibOpERC721OwnerOf` tokenId passed as raw uint256

**Severity:** INFO

**Files:** `src/lib/op/erc721/LibOpERC721OwnerOf.sol` (line 28, 33)

**Description:** The `tokenId` is read from the stack as a raw `uint256` and passed directly to `IERC721.ownerOf(tokenId)`. Since Rainlang values on the stack are Float-encoded, a Rainlang author writing `erc721-owner-of(token-addr, token-id)` would have `token-id` as a packed Float. The raw uint256 of a packed Float for a small integer (e.g., token ID 5) equals 5 due to the identity property described in Finding 6. However, for token IDs that are very large or that have been computed through float arithmetic, the packed Float representation could differ from the intended raw integer token ID.

This is consistent with the design: `erc721-owner-of` is a "raw" opcode (not in a `uint256/` subdirectory but also not doing Float conversion). The `referenceFn` also passes `uint256(StackItem.unwrap(tokenId))` directly without float conversion, confirming this is intentional behavior. Rainlang authors must understand that this opcode operates on raw stack values.
