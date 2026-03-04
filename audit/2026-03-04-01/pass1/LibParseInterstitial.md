# Pass 1 — Security: LibParseInterstitial (A104)

**File:** `src/lib/parse/LibParseInterstitial.sol`

## Evidence

### Library
- `LibParseInterstitial` (line 17)

### Functions
| Function | Line | Visibility |
|---|---|---|
| `skipComment(ParseState memory, uint256, uint256)` | 28 | internal pure |
| `skipWhitespace(ParseState memory, uint256, uint256)` | 96 | internal pure |
| `parseInterstitial(ParseState memory, uint256, uint256)` | 111 | internal pure |

### Types / Errors / Constants
- None defined in this file
- Imports: `FSM_YANG_MASK`, `CMASK_COMMENT_HEAD`, `CMASK_WHITESPACE`, `COMMENT_END_SEQUENCE`, `COMMENT_START_SEQUENCE`, `CMASK_COMMENT_END_SEQUENCE_END`, `MalformedCommentStart`, `UnclosedComment`

## Assembly Review

### `skipComment` — start sequence read (line 45-47)
```solidity
assembly ("memory-safe") {
    startSequence := shr(0xf0, mload(cursor))
}
```
- Reads 32 bytes at `cursor`, right-shifts by 240 bits to isolate the first 2 bytes. No writes. Read is within the parse data buffer (cursor was validated `cursor + 4 <= end` at line 39, where `end <= data + 0x20 + data.length`). Correct.

### `skipComment` — end sequence check (line 67-69)
```solidity
assembly ("memory-safe") {
    endSequence := shr(0xf0, mload(sub(cursor, 1)))
}
```
- Reads 2 bytes starting one byte before `cursor`. At this point, `cursor >= original_cursor + 3` (line 55 advanced cursor by 3 before the loop). So `cursor - 1 >= original_cursor + 2`, which is within the data buffer. Correct.

### `parseInterstitial` — character read (line 114-117)
```solidity
assembly ("memory-safe") {
    char := shl(byte(0, mload(cursor)), 1)
}
```
- Standard single-byte read with bitmask conversion. Loop guard `cursor < end` at line 112 ensures cursor is in bounds. Correct.

## Security Assessment

### Bounds checking
- `skipComment` checks `cursor + 4 > end` before any reads (line 39). This prevents reading past the end of the parse data for the start sequence.
- The end-sequence read `mload(sub(cursor, 1))` at line 68 is safe because cursor has been advanced by at least 3 from the original position before the loop, so `cursor - 1` is always within the data.
- `skipWhitespace` delegates to `LibParseChar.skipMask` which receives the `end` bound.
- `parseInterstitial` checks `cursor < end` before each character read.

### Memory safety
- All assembly blocks are read-only (`mload` only, no `mstore`). The `memory-safe` annotations are accurate.
- FSM state mutation is done through Solidity assignments, not assembly.

No findings.
