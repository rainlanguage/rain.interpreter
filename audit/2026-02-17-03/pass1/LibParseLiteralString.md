# Pass 1 (Security) -- LibParseLiteralString.sol

**File:** `src/lib/parse/literal/LibParseLiteralString.sol`

## Evidence of Thorough Reading

### Contract/Library Name

- `LibParseLiteralString` (library, line 13)

### Functions

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `boundString` | 20 | internal | pure |
| `parseString` | 77 | internal | pure |

### Errors/Events/Structs Defined

None defined in this file. The following are imported from `src/error/ErrParse.sol`:
- `UnclosedStringLiteral(uint256 offset)` -- used on line 61
- `StringTooLong(uint256 offset)` -- used on line 48

### Imports

- `ParseState` from `LibParseState.sol`
- `IntOrAString`, `LibIntOrAString` from `rain.intorastring/lib/LibIntOrAString.sol`
- `CMASK_STRING_LITERAL_END`, `CMASK_STRING_LITERAL_TAIL` from `rain.string/lib/parse/LibParseCMask.sol`
- `LibParseError` from `LibParseError.sol`

### Using-for Directives

- `LibParseError for ParseState` (line 14)
- `LibParseLiteralString for ParseState` (line 15)

---

## Security Findings

### 1. [INFO] Assembly blocks correctly marked `memory-safe`

**Lines:** 33-46, 52-54, 89-94, 96-98

All four assembly blocks are annotated `"memory-safe"`. I verified each:

- **Lines 33-46** (`boundString`): Reads from memory via `mload(innerStart)` and iterates over bytes. No writes. Reads are within the parse data buffer (caller guarantees `cursor` is within `[data, end)`). Correctly memory-safe.

- **Lines 52-54** (`boundString`): Single `mload(innerEnd)` to read the final character. `innerEnd` is bounded by `innerStart + i` where `i < 0x20` and `innerStart` is within the parse data. Even when `innerEnd == end` (reading one byte past the data), the `mload` reads a full word from a valid heap address and only the first byte is inspected. The revert at line 60-62 handles the `end == innerEnd` case. Correctly memory-safe.

- **Lines 89-94** (`parseString`): Temporarily overwrites the word at `str = stringStart - 0x20` with the string length. This modifies memory below the free memory pointer (existing data), which is allowed under Solidity's memory-safe definition. The modification is reversed in the next assembly block. Between these two blocks, `fromStringV3` only uses scratch space (addresses 0x00-0x3f) and does not allocate or modify heap memory.

- **Lines 96-98** (`parseString`): Restores the overwritten word. Pure restore of previously saved data. Correctly memory-safe.

**Risk:** None. All annotations are accurate.

---

### 2. [INFO] Unchecked arithmetic is safe in context

**Lines:** 25-68 (entire `boundString` body is in `unchecked`)

The `unchecked` block wraps all of `boundString`. Key arithmetic operations:

- **`cursor + 1`** (line 26): `cursor` is a memory pointer into a `bytes memory` allocation. Memory pointers in the EVM cannot realistically approach `type(uint256).max` due to quadratic gas costs. Overflow is physically impossible.

- **`innerStart + i`** (line 50): `i < 0x20` (32), and `innerStart` is a memory pointer. Cannot overflow.

- **`innerEnd + 1`** (line 64): `innerEnd = innerStart + i` where `i < 0x20`. Cannot overflow.

- **`sub(end, innerStart)`** in assembly (line 34): If `end < innerStart` (i.e., `cursor` is the last byte before `end`, so `innerStart = cursor + 1 = end`), this underflows to a very large value. However, `max` is clamped to `min(distanceFromEnd, 0x20)`, and when `distanceFromEnd` is huge (underflow), `max = 0x20`. But then the loop condition `lt(i, max)` would allow the loop to proceed, reading bytes from `stringData` that was loaded starting at `innerStart`. Since `stringData = mload(innerStart)` reads 32 bytes starting from `innerStart`, and those bytes may be past `end`, the loop could scan garbage data. However, any non-printable or non-string character (including the closing `"`) would terminate the loop, and if the loop reaches `i == 0x20`, it reverts with `StringTooLong`. If the loop terminates early, the `finalChar` check on line 60 would catch invalid characters or the `end == innerEnd` check would catch reading past the end. This design is safe because it relies on the closing `"` or non-printable byte to terminate scanning, and the `end == innerEnd` guard catches the edge case.

Actually, re-examining: when `innerStart == end`, `distanceFromEnd = sub(end, end) = 0`, so `max = 0`, the loop doesn't execute, `i = 0`, which is not `0x20`, so no `StringTooLong` revert. Then `innerEnd = innerStart = end`, `finalChar` is read from address `end` (one byte past data), and the condition `end == innerEnd` is true, so it reverts with `UnclosedStringLiteral`. This is correct behavior.

When `innerStart > end` (impossible in practice since `cursor < end` is guaranteed by the caller in `tryParseLiteral`), the underflow would be problematic, but this case cannot arise through normal parser execution.

**Risk:** None. The arithmetic is safe given the invariants maintained by callers.

---

### 3. [INFO] Temporary memory mutation in `parseString` is correctly bracketed

**Lines:** 87-98

The `parseString` function temporarily mutates memory to create a valid Solidity `string memory` by:
1. Saving the word at `str = stringStart - 0x20` to `memSnapshot` (line 92)
2. Writing the string length there (line 93)
3. Calling `fromStringV3(str)` which reads the string and returns a value type (line 95)
4. Restoring the original word (line 97)

I verified that `fromStringV3` uses only scratch space (addresses 0-0x3f) via `mstore(0, ...)` and `mcopy(sub(0x20, ...), ...)`, and does not modify memory at or near `str`'s location. The save/restore pair is correctly bracketed around the call. No reentrancy is possible (pure function). The intermediate state where memory contains a modified word is invisible to any external observer.

**Risk:** None. The pattern is sound.

---

### 4. [INFO] All reverts use custom errors

**Lines:** 48, 61

Both revert paths use custom error types:
- `StringTooLong(uint256 offset)` at line 48
- `UnclosedStringLiteral(uint256 offset)` at line 61

Both are defined in `src/error/ErrParse.sol`. No string revert messages are used anywhere in this file.

**Risk:** None. Compliant with project conventions.

---

### 5. [INFO] Operator precedence on line 60 is correct

**Line:** 60

```solidity
if (1 << finalChar & CMASK_STRING_LITERAL_END == 0 || end == innerEnd) {
```

Static analysis tools (Slither, forge-lint) flag this due to `<<` and `&` appearing in the same expression with `==`. The Slither and forge-lint suppressions are present (lines 58-59). In Solidity, `==` cannot apply to `CMASK_STRING_LITERAL_END == 0` first because that would produce a `bool`, and `uint256 & bool` is a type error. The compiler must parse this as `((1 << finalChar) & CMASK_STRING_LITERAL_END) == 0`, which is the intended behavior: checking whether `finalChar` is NOT a closing quote character.

**Risk:** None. The expression is correct. The lint suppressions are appropriate.

---

### 6. [LOW] Reading one byte past `end` in `finalChar` check

**Lines:** 52-54, 60

When the string scanning loop terminates because it encounters a non-printable character or a closing quote, `innerEnd` is set to `innerStart + i`. The assembly at line 52-54 reads `byte(0, mload(innerEnd))`. If the string data happens to end exactly at the `end` boundary without a closing quote, `innerEnd` could equal `end`, and `mload(innerEnd)` reads 32 bytes starting from `end`, which extends past the logical end of the parse data.

However, this is mitigated by:
1. The condition `end == innerEnd` on line 60 explicitly checks for this case and reverts.
2. Even though `mload` reads past `end`, it reads valid (allocated) memory -- the parse data is a `bytes memory` allocation, and Solidity allocates memory in 32-byte chunks, so there is always at least padding after the data. The read does not access unallocated memory.
3. The read value is only used to check membership in `CMASK_STRING_LITERAL_END`, and the revert happens regardless of what was read when `end == innerEnd`.

**Risk:** Minimal. The out-of-bounds read accesses allocated memory and the result is discarded via the `end == innerEnd` guard. No information leak or incorrect behavior results.

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. The library is compact (101 lines), well-structured, and handles edge cases correctly. The temporary memory mutation pattern in `parseString` is safely bracketed. All assembly is correctly annotated as memory-safe. All error paths use custom errors. The unchecked arithmetic is safe given the memory pointer invariants maintained by callers.

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 5 |
