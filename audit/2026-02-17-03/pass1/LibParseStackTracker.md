# Pass 1 (Security) -- LibParseStackTracker.sol

## Evidence of Thorough Reading

**File:** `src/lib/parse/LibParseStackTracker.sol` (64 lines)

**Library name:** `LibParseStackTracker`

**User-defined type:** `ParseStackTracker` (line 7) -- a `uint256` used as a packed struct with the following byte layout:
- Bits 0-7 (byte 0): `current` -- current stack height
- Bits 8-15 (byte 1): `inputs` -- count of input items pushed
- Bits 16-23 (byte 2): `max` -- high watermark (maximum stack height reached)
- Bits 24-255: unused (always zero)

**Functions:**
| Function | Line | Description |
|----------|------|-------------|
| `pushInputs(ParseStackTracker, uint256)` | 17 | Pushes n items as inputs (updates both current height and inputs tally) |
| `push(ParseStackTracker, uint256)` | 34 | Pushes n items onto tracked stack, updating current height and high watermark |
| `pop(ParseStackTracker, uint256)` | 55 | Pops n items from tracked stack, reverting on underflow |

**Errors used (imported from `src/error/ErrParse.sol`):**
- `ParseStackOverflow()` (line 23, 41) -- reverted when current or inputs would exceed 0xFF
- `ParseStackUnderflow()` (line 59) -- reverted when popping more items than current height

**No events or structs defined.**

---

## Security Findings

### Finding 1: pop() subtracts from full word instead of repacking -- correct but fragile

**Severity:** LOW

**Location:** Line 61

```solidity
return ParseStackTracker.wrap(ParseStackTracker.unwrap(tracker) - n);
```

The `pop` function subtracts `n` directly from the full `uint256` word rather than extracting, modifying, and repacking the `current` byte (as `push` does). This works correctly because:

1. The underflow guard on line 58 ensures `n <= current <= 0xFF`.
2. Since `current` occupies the lowest byte and `n <= current`, the subtraction cannot borrow into the `inputs` byte (bits 8-15) or `max` byte (bits 16-23).

However, this relies on the invariant that `n` is small enough not to borrow. If a future change altered the bit layout (e.g., moving `current` to a non-zero offset), this subtraction would silently corrupt adjacent fields. The `push` function uses the safer extract-modify-repack pattern. The asymmetry between `push` (repack) and `pop` (direct subtraction) is a minor fragility.

No exploit exists in the current code because the underflow check guarantees correctness.

### Finding 2: Unchecked arithmetic is correctly bounded

**Severity:** INFO

**Location:** Lines 18-27, 35-47, 56-62

All three functions use `unchecked` blocks. In each case, the arithmetic is safe:

- **`push` (line 39):** `current += n` could overflow `uint256` in theory, but the check `current > 0xFF` on line 40 catches any result exceeding a single byte. Both operands start as values <= 0xFF (for `current`) and any `n` that causes the sum to exceed 0xFF triggers the revert. If `n` is extremely large (e.g., close to `type(uint256).max`), the unchecked addition wraps, but the result would still be checked against `0xFF` -- a wrapped value that happens to be <= 0xFF would be an incorrect stack height. See Finding 3.

- **`pushInputs` (line 21):** `inputs += n` has the same pattern, checked against `0xFF` on line 22.

- **`pop` (line 61):** Subtraction is guarded by the `current < n` check on line 58.

### Finding 3: Unchecked addition wrapping could bypass overflow check in push()

**Severity:** MEDIUM

**Location:** Lines 39-41

```solidity
current += n;
if (current > 0xFF) {
    revert ParseStackOverflow();
}
```

Within the `unchecked` block, if `n` is astronomically large (close to `type(uint256).max`), the addition `current += n` wraps around modulo `2^256`. For example, if `current = 1` and `n = type(uint256).max`, then `current + n` wraps to `0`, which passes the `> 0xFF` check. The resulting tracker would have `current = 0` instead of reverting with `ParseStackOverflow`.

**Mitigating factors:**
- In practice, `n` comes from opcode integrity declarations (inputs/outputs counts), which are small constants (typically 0-10). No realistic code path passes a value of `n` anywhere near `2^256`.
- The `push` function is `internal pure`, so it can only be called from within the parser library itself, not by external actors.
- The same issue applies to `pushInputs` at line 21 (`inputs += n`).

Despite the mitigating factors, if defense-in-depth is desired, the addition could be done in a checked context or `n` could be explicitly bounded (e.g., `require(n <= 0xFF)`).

### Finding 4: All reverts use custom errors

**Severity:** INFO

All revert paths use custom error types (`ParseStackOverflow`, `ParseStackUnderflow`) imported from `src/error/ErrParse.sol`. No string revert messages are used. This is consistent with the project conventions.

### Finding 5: No assembly blocks present

**Severity:** INFO

This file contains no inline assembly. All operations use high-level Solidity with the user-defined value type `ParseStackTracker`. No memory safety concerns from assembly.
