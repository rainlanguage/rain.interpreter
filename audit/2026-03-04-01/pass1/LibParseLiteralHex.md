# A113 -- Pass 1 (Security) -- LibParseLiteralHex.sol

## Evidence of Thorough Reading

**Library name:** `LibParseLiteralHex`

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 36 | `boundHex(ParseState memory, uint256, uint256)` | function | internal | pure |
| 68 | `parseHex(ParseState memory, uint256, uint256)` | function | internal | pure |

**Errors used (imported):**
- `MalformedHexLiteral(uint256)` from `ErrParse.sol`
- `OddLengthHexLiteral(uint256)` from `ErrParse.sol`
- `ZeroLengthHexLiteral(uint256)` from `ErrParse.sol`
- `HexLiteralOverflow(uint256)` from `ErrParse.sol`

**Character masks (imported):**
- `CMASK_UPPER_ALPHA_A_F`, `CMASK_LOWER_ALPHA_A_F`, `CMASK_NUMERIC_0_9`, `CMASK_HEX` from `rain.string`

**Using-for declarations:**
- `LibParseLiteralHex for ParseState`
- `LibParseError for ParseState`

---

## Security Review

### Assembly memory safety

**`boundHex` (lines 45-50):**
- Scans forward from `innerStart` (`cursor + 2`, past the `0x` prefix) while the character matches `CMASK_HEX` and `innerEnd < end`. Uses `byte(0, mload(innerEnd))` to read one byte at a time.
- The `lt(innerEnd, end)` guard prevents reading past the source data. Tagged `memory-safe`. Correct.

**`parseHex` (lines 89-90):**
- `byte(0, mload(cursor))` reads one byte at the cursor during the backwards loop. The cursor is bounded by `hexStart` (derived from `cursor + 2` of the original input) and `hexEnd` (derived from `boundHex`). Safe within the source data.

### Bounds checks

- **Overflow**: hexLength > 0x40 (64 nybbles = 32 bytes = max bytes32) at line 76.
- **Zero length**: hexLength == 0 at line 78.
- **Odd length**: hexLength % 2 == 1 at line 80. Ensures complete bytes only.
- **Character validation**: Each character is checked against `CMASK_NUMERIC_0_9`, `CMASK_LOWER_ALPHA_A_F`, `CMASK_UPPER_ALPHA_A_F`, with a `MalformedHexLiteral` revert for anything else (line 115).

### Backwards loop analysis (lines 85-121)

The loop starts at `cursor = hexEnd - 1` and decrements until `cursor >= hexStart`. This is inside an `unchecked` block (line 69).

**Underflow concern**: When `cursor` reaches `hexStart` and the loop body decrements it, `cursor` underflows to `type(uint256).max`. The loop condition `cursor >= hexStart` then fails (since `type(uint256).max >= hexStart` is true for any reasonable `hexStart`).

Wait -- actually, `cursor >= hexStart` would be TRUE after underflow since `type(uint256).max` is enormous. But this would mean an infinite loop. Let me re-examine...

The loop is `while (cursor >= hexStart)`. After processing the character at `hexStart`, `cursor--` underflows to `type(uint256).max`. Then `type(uint256).max >= hexStart` is true, so the loop would continue reading garbage memory.

However, this is only reachable if `hexStart = 0`, which would mean `cursor + 2 = 0`, i.e., `cursor = type(uint256).max - 1`. This is impossible in practice because the source data is in Solidity-allocated memory (well above address 0). Specifically, `hexStart = cursor + 2` where `cursor` is a pointer into the source data, which is always at least `0x80` (the Solidity free memory starts at 0x80). So `hexStart >= 0x82`.

After decrementing from `hexStart` (which is >= 0x82), `cursor` becomes `hexStart - 1` (not an underflow, since hexStart >= 0x82). Then `hexStart - 1 >= hexStart` is false, so the loop terminates correctly.

This is safe because Solidity memory pointers are never near zero.

### Nybble computation

- `0-9`: `hexCharByte - uint8("0")` = `hexCharByte - 48`. For bytes 48-57, results in 0-9. Correct.
- `a-f`: `hexCharByte - uint8("a") + 10` = `hexCharByte - 97 + 10`. For bytes 97-102, results in 10-15. Correct.
- `A-F`: `hexCharByte - uint8("A") + 10` = `hexCharByte - 65 + 10`. For bytes 65-70, results in 10-15. Correct.

### Value accumulation

`value |= nybble << valueOffset` with `valueOffset += 4`. Starting from the least significant nybble (rightmost character), this correctly builds the value right-to-left. Maximum valueOffset = `(hexLength - 1) * 4`. With hexLength <= 64, max valueOffset = 252, and a 4-bit nybble shifted by 252 fits within bytes32 (256 bits). Correct.

### Custom errors

No string reverts. All error paths use custom error types.

---

## Findings

No LOW+ findings.

The hex parser is well-bounded with explicit checks for overflow, zero length, odd length, and character validity. The backwards loop is safe under the practical invariant that memory pointers are always well above zero. Assembly reads are correctly guarded by the `end` parameter.
