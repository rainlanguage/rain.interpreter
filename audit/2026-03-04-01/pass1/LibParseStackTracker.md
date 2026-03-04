# Pass 1 — Security: LibParseStackTracker (A108)

**File:** `src/lib/parse/LibParseStackTracker.sol`

## Evidence

### Library
- `LibParseStackTracker` (line 15)

### Types
- `ParseStackTracker` — user-defined value type wrapping `uint256` (line 10)

### Functions
| Function | Line | Visibility |
|---|---|---|
| `pushInputs(ParseStackTracker, uint256)` | 25 | internal pure |
| `push(ParseStackTracker, uint256)` | 47 | internal pure |
| `pop(ParseStackTracker, uint256)` | 74 | internal pure |

### Errors (imported)
- `ParseStackUnderflow` (from `ErrParse.sol`)
- `ParseStackOverflow` (from `ErrParse.sol`)

### Constants / State Layout
The `ParseStackTracker` packs three fields into a single `uint256`:
- Bits [7:0]: current stack height (max 0xFF = 255)
- Bits [15:8]: input count (max 0xFF = 255)
- Bits [255:16]: high-water mark (max stack height seen)

## Assembly Review

No assembly in this file. All operations use Solidity arithmetic with `unchecked` blocks.

## Security Assessment

### `pushInputs` (line 25)
1. Calls `push(n)` first, which validates `current + n <= 0xFF`.
2. Then extracts `inputs` from bits [15:8] and adds `n`.
3. Checks `inputs > 0xFF` and reverts with `ParseStackOverflow`.
4. Repacks the tracker with `& ~uint256(0xFF00)` to clear the inputs byte, then ORs in `inputs << 8`.

**Unchecked safety:** The NatSpec states `inputs` and `n` are both `<= 0xFF`, so their sum cannot exceed `0x1FE`, which fits in `uint256`. The `> 0xFF` check catches overflow of the 8-bit field. Correct.

### `push` (line 47)
1. Extracts `current` from bits [7:0], `inputs` from bits [15:8], `max` from bits [255:16].
2. `current += n` in unchecked block.
3. Checks `current > 0xFF` and reverts with `ParseStackOverflow`.
4. Updates `max` if `current > max`.
5. Repacks: `current | (inputs << 8) | (max << 0x10)`.

**Unchecked safety:** `current` is masked to 8 bits (max 0xFF), and per the NatSpec, `n` must be `<= 0xFF`. The sum `current + n <= 0x1FE` which fits in `uint256`. The `> 0xFF` check ensures the 8-bit field doesn't overflow. Correct.

**Note on caller constraint:** The function NatSpec documents that `n` MUST be `<= 0xFF`. If a caller passes `n > 0xFF` (e.g., `n = 0x100`), then `current + n` could equal `0x1FF`, which would still be caught by the `> 0xFF` check. If `n` were astronomically large (near `type(uint256).max`), the unchecked addition would wrap, potentially producing a small `current` that passes the `> 0xFF` check. However, all callers pass either integrity-check outputs (masked to 4 bits, max 0xF) or literal small constants. This is safe by caller contract.

### `pop` (line 74)
1. Extracts `current` from bits [7:0].
2. Checks `current < n` and reverts with `ParseStackUnderflow`.
3. Subtracts `n` directly from the packed word: `ParseStackTracker.unwrap(tracker) - n`.

**Direct subtraction safety:** The NatSpec explains this shortcut. Since `n <= current <= 0xFF`, the subtraction `tracker - n` only affects bits [7:0] and cannot borrow into bits [15:8] (the inputs field). This is correct because the low byte of `tracker` is `current`, and `n <= current`, so the subtraction produces a non-negative result in the low byte with no borrow.

**Edge case:** If `n` is larger than 0xFF (which would pass the `current < n` check since `current <= 0xFF`), the revert catches it. If `n == current`, the result is zero in the low byte. All correct.

No findings.
