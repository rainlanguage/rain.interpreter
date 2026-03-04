# A114 -- Pass 1 (Security) -- LibParseLiteralString.sol

## Evidence of Thorough Reading

**Library name:** `LibParseLiteralString`

**Functions and line numbers:**

| Line | Name | Kind | Visibility | Mutability |
|------|------|------|------------|------------|
| 26 | `boundString(ParseState memory, uint256, uint256)` | function | internal | pure |
| 88 | `parseString(ParseState memory, uint256, uint256)` | function | internal | pure |

**Errors used (imported):**
- `UnclosedStringLiteral(uint256)` from `ErrParse.sol`
- `StringTooLong(uint256)` from `ErrParse.sol`

**Character masks (imported):**
- `CMASK_STRING_LITERAL_END`, `CMASK_STRING_LITERAL_TAIL` from `rain.string`

**Using-for declarations:**
- `LibParseError for ParseState`
- `LibParseLiteralString for ParseState`

---

## Security Review

### Assembly memory safety

**`boundString` (lines 39-51, 58-59):**
- Reads `mload(innerStart)` to get 32 bytes of string data (line 47).
- `distanceFromEnd := sub(end, innerStart)` computes remaining bytes. If `end < innerStart`, this underflows. However, this cannot happen because the parser cursor (`innerStart = cursor + 1`) is always less than `end` -- the caller (`tryParseLiteral`) only dispatches when a string head character is detected, which requires at least one byte at cursor.
- `max` is clamped to `min(distanceFromEnd, 0x20)` to prevent reading past `end`.
- Loop scans byte-by-byte using `byte(i, stringData)` with `i < max`. Safe.
- If `i == 0x20` (32 characters scanned without finding end), reverts `StringTooLong`. This is correct -- strings are limited to 31 bytes to fit the `IntOrAString` encoding.
- Line 58-59: reads `byte(0, mload(innerEnd))` to check the terminating character. This is within the source data since `innerEnd < end` is guaranteed by the `max` clamping.
- Line 66: checks both that the final char is a valid string end AND that `end != innerEnd` (to ensure there's room for the closing quote). Correct.

**`parseString` (lines 100-108):**
- Line 102: `str := sub(stringStart, 0x20)` -- constructs a pseudo-string pointer by pointing 32 bytes before the string content. This creates a Solidity `string memory` layout where the length prefix would be at `str` and data at `str + 0x20 = stringStart`.
- Line 103: `memSnapshot := mload(str)` -- saves whatever data is at the length position (this is part of the source data or parse state that we're temporarily overwriting).
- Line 104: `mstore(str, length)` -- writes the string length, creating a valid `string memory` for `LibIntOrAString.fromStringV3`.
- Line 107-108: After calling `fromStringV3`, restores the original data at `str`.

This is a clever in-place memory manipulation that avoids allocation. The save/restore pattern is correct -- the original data is preserved. The only risk is if `fromStringV3` stores a reference to `str` that is used later, but since it returns a value type (`IntOrAString`), this is safe.

**Potential concern -- `sub(stringStart, 0x20)` underflow**: If `stringStart < 0x20`, this would underflow. But `stringStart = cursor + 1` where `cursor` is a pointer into source data in Solidity memory (always >= 0x80). So `stringStart >= 0x81` and `sub(stringStart, 0x20) >= 0x61`. No underflow.

### Bounds checks

- String length limited to 31 bytes (checked at line 53 via `i == 0x20`).
- Closing quote must be present (checked at line 66).
- Distance clamping prevents reading past `end` (line 42).

### Custom errors

No string reverts. `UnclosedStringLiteral` and `StringTooLong` are custom errors.

---

## Findings

No LOW+ findings.

The in-place memory manipulation for string parsing is safe due to the save/restore pattern and the practical impossibility of pointer underflow. String length is properly bounded and the closing delimiter is verified.
