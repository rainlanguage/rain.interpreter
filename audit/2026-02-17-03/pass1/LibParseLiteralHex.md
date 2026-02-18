# Pass 1 (Security) — LibParseLiteralHex.sol

**File:** `src/lib/parse/literal/LibParseLiteralHex.sol`

## Evidence of Thorough Reading

### Contract/Library Name
- `LibParseLiteralHex` (library, line 20)

### Functions
| Function | Line |
|----------|------|
| `boundHex(ParseState memory, uint256 cursor, uint256 end)` | 26 |
| `parseHex(ParseState memory state, uint256 cursor, uint256 end)` | 53 |

### Errors/Events/Structs Defined
None defined in this file. The following errors are imported from `src/error/ErrParse.sol`:
- `MalformedHexLiteral(uint256 offset)`
- `OddLengthHexLiteral(uint256 offset)`
- `ZeroLengthHexLiteral(uint256 offset)`
- `HexLiteralOverflow(uint256 offset)`

### Imports
- `ParseState` from `../LibParseState.sol`
- Error types from `../../../error/ErrParse.sol`
- Character masks (`CMASK_UPPER_ALPHA_A_F`, `CMASK_LOWER_ALPHA_A_F`, `CMASK_NUMERIC_0_9`, `CMASK_HEX`) from `rain.string/lib/parse/LibParseCMask.sol`
- `LibParseError` from `../LibParseError.sol`

## Findings

### 1. INFO — `boundHex` reads one byte past `end` boundary in degenerate case

**Location:** Lines 35-40

```solidity
assembly ("memory-safe") {
    for {} and(iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), hexCharMask))), lt(innerEnd, end)) {} {
        innerEnd := add(innerEnd, 1)
    }
}
```

The `for` loop condition evaluates both sub-expressions (`and(...)` and `lt(innerEnd, end)`) on every iteration. When `innerEnd == end`, the `lt(innerEnd, end)` check is `false`, so the overall `and(...)` is `false` regardless of the other operand, and the loop exits. However, EVM evaluates all arguments before calling `and`, so `byte(0, mload(innerEnd))` is still executed when `innerEnd == end`. This reads from memory at position `end`, which is a valid memory read in the EVM (memory is infinitely extensible and initialized to zero). Since `and` short-circuits the result (not the evaluation), the byte is read but never used to affect control flow. This is safe because:
- EVM `mload` at any address is safe (just potentially expensive for very high addresses, but `end` is a normal memory pointer).
- The read result is discarded because `lt(innerEnd, end)` is false.
- No state is modified.

No action required.

### 2. INFO — Unchecked block in `parseHex` is safe

**Location:** Lines 54-111

The entire `parseHex` function body is wrapped in `unchecked`. The following arithmetic operations occur inside it:

1. **`hexEnd - hexStart` (line 60):** `hexEnd >= hexStart` is guaranteed because `boundHex` sets `innerEnd = innerStart` initially and only increments it. Safe.

2. **`hexEnd - 1` (line 70):** Only reached when `hexLength >= 2` (zero and odd-length are rejected, minimum even length is 2). Since `hexEnd = hexStart + hexLength` where `hexLength >= 2`, and `hexStart` is a memory pointer (always > 0), `hexEnd >= 2`. Safe.

3. **`cursor--` (line 105):** When `cursor == hexStart` (the last iteration), `cursor` decrements to `hexStart - 1`. Since `hexStart` is a memory pointer (always well above 0), this yields a value strictly less than `hexStart`, causing the `while (cursor >= hexStart)` condition to be false. The loop exits correctly. If `hexStart` were 0, this would wrap to `type(uint256).max` and loop infinitely, but memory pointers are never 0. Safe.

4. **`valueOffset += 4` (line 104):** Maximum `hexLength` is 0x40 (64), so maximum `valueOffset` is `64 * 4 = 256`. The shift `nybble << valueOffset` at `valueOffset == 252` (the last one for a 64-char hex) shifts by 252 bits which fits in `bytes32`. At `valueOffset == 256` (which cannot happen because the loop runs at most 64 times and increments after the shift), the shift would produce 0. Safe.

5. **`hexCharByte - uint256(uint8(bytes1("0")))` and similar (lines 86, 92, 98):** These are only reached when the character matches the corresponding CMASK, guaranteeing the subtraction doesn't underflow (e.g., `hexCharByte` is in range `0x30-0x39` for digit characters, and `uint8(bytes1("0"))` is `0x30`). Safe.

No action required.

### 3. INFO — Assembly blocks correctly marked `memory-safe`

**Location:** Lines 35, 74

Both assembly blocks only perform `mload` (read) operations and do not write to memory. They are correctly annotated as `memory-safe`.

- **Block 1 (lines 35-40):** Reads from `innerEnd` to scan hex characters. No memory writes.
- **Block 2 (lines 74-76):** Reads a single byte from `cursor`. No memory writes.

No action required.

### 4. INFO — All reverts use custom errors

**Location:** Lines 62, 64, 66, 100

All four revert paths use custom error types imported from `src/error/ErrParse.sol`:
- `HexLiteralOverflow` (line 62)
- `ZeroLengthHexLiteral` (line 64)
- `OddLengthHexLiteral` (line 66)
- `MalformedHexLiteral` (line 100)

No string revert messages are used. Compliant.

### 5. INFO — Hex value is left-aligned in `bytes32`

**Location:** Lines 86, 92, 98, 103

The parsed nybbles are shifted into `value` (a `bytes32`) starting from bit offset 0 (the least significant bits), building the value from right to left. For a hex literal like `0xAB`, `B` is placed at offset 0 and `A` at offset 4, producing `bytes32(0xAB)` which is `0x00000000000000000000000000000000000000000000000000000000000000AB`. This means the parsed value is right-aligned in the `bytes32`, which is consistent with how Solidity stores `uint256` values in `bytes32`. This is the expected behavior for numeric hex literals.

No action required.

## Summary

No CRITICAL, HIGH, MEDIUM, or LOW findings identified. The library is well-structured with proper bounds checking, correct use of custom errors, safe assembly operations, and sound arithmetic under the `unchecked` block. The `unchecked` arithmetic is justified because all subtraction and decrement operations are protected by prior bounds checks or the inherent properties of memory pointers.
