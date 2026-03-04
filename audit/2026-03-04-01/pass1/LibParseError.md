# Pass 1 — Security: LibParseError (A103)

**File:** `src/lib/parse/LibParseError.sol`

## Evidence

### Library
- `LibParseError` (line 7)

### Functions
| Function | Line | Visibility |
|---|---|---|
| `parseErrorOffset(ParseState memory, uint256)` | 13 | internal pure |
| `handleErrorSelector(ParseState memory, uint256, bytes4)` | 26 | internal pure |

### Types / Errors / Constants
- None defined in this file (uses `ParseState` from `LibParseState.sol`)

## Assembly Review

### `parseErrorOffset` (line 15-17)
```solidity
assembly ("memory-safe") {
    offset := sub(cursor, add(data, 0x20))
}
```
- Marked `memory-safe`. No memory writes; only computes a subtraction. Correct.
- `data` is a `bytes memory` reference. `add(data, 0x20)` skips the length prefix to get the start of content. `sub(cursor, ...)` computes the byte offset. This is arithmetic only, no memory access.

### `handleErrorSelector` (line 29-32)
```solidity
assembly ("memory-safe") {
    mstore(0, errorSelector)
    mstore(4, errorOffset)
    revert(0, 0x24)
}
```
- Writes to scratch space (0x00-0x3F), which is permitted under the `memory-safe` annotation.
- Constructs a standard 4-byte selector + 32-byte argument revert payload at offset 0, total 0x24 bytes. Correct ABI error encoding.
- Immediately reverts, so no downstream memory corruption possible.

## Security Assessment

No findings. Both functions are pure arithmetic or revert-only, with no memory allocation, no loops, and no user-controlled memory indexing. The `memory-safe` annotations are accurate.
