# Pass 1 (Security) — LibParseError.sol

**File:** `src/lib/parse/LibParseError.sol`
**Audit date:** 2026-02-17
**Auditor:** Claude Opus 4.6

---

## Evidence of Thorough Reading

### Contract/Library Name

- `LibParseError` (library, line 7)

### Functions

| Function | Line | Visibility | Mutability |
|---|---|---|---|
| `parseErrorOffset(ParseState memory state, uint256 cursor)` | 13 | `internal` | `pure` |
| `handleErrorSelector(ParseState memory state, uint256 cursor, bytes4 errorSelector)` | 26 | `internal` | `pure` |

### Errors / Events / Structs Defined

None defined in this file. The library imports `ParseState` from `LibParseState.sol`.

### Import Summary

- `ParseState` from `./LibParseState.sol` (line 5)

---

## Security Findings

### 1. [INFO] No bounds validation on cursor in `parseErrorOffset`

**Lines:** 13-18

```solidity
function parseErrorOffset(ParseState memory state, uint256 cursor) internal pure returns (uint256 offset) {
    bytes memory data = state.data;
    assembly ("memory-safe") {
        offset := sub(cursor, add(data, 0x20))
    }
}
```

**Analysis:** The function computes `offset = cursor - (data + 0x20)`, which is the byte offset of the cursor from the start of the data content (skipping the 32-byte length prefix). There is no check that `cursor >= data + 0x20` or that `cursor <= data + 0x20 + length(data)`. If `cursor` is less than `data + 0x20`, the subtraction will silently underflow (wrapping around to a very large uint256) because it is in an `unchecked` assembly context.

**Mitigating factors:** This function is only used for error reporting (computing an offset to include in revert data). All callers across the codebase use it in the context of `revert SomeError(state.parseErrorOffset(cursor))` or within `handleErrorSelector`. The cursor values are derived from the parsing loop which traverses `state.data`, so under normal and expected error conditions the cursor should always be within bounds. A bogus offset would not cause a security issue — it would only produce a confusing error message. The function is `internal pure`, so it cannot be called externally.

**Severity:** INFO — No exploitable impact. The lack of validation is acceptable given this is purely an error-reporting utility.

---

### 2. [INFO] Assembly block memory safety in `parseErrorOffset`

**Lines:** 15-17

```solidity
assembly ("memory-safe") {
    offset := sub(cursor, add(data, 0x20))
}
```

**Analysis:** The block is correctly marked `"memory-safe"`. It only reads from existing memory (the `data` pointer which is a Solidity `bytes memory` variable already on the stack) and writes to the return variable `offset`. It does not write to arbitrary memory, does not allocate, and does not read beyond known bounds. The `"memory-safe"` annotation is appropriate.

**Severity:** INFO — No issue found.

---

### 3. [INFO] Assembly block memory safety in `handleErrorSelector`

**Lines:** 29-33

```solidity
assembly ("memory-safe") {
    mstore(0, errorSelector)
    mstore(4, errorOffset)
    revert(0, 0x24)
}
```

**Analysis:** This block writes to the scratch space at memory offsets 0x00–0x23 (the first 36 bytes). Per Solidity conventions, memory positions 0x00–0x3F are scratch space and can be freely used. The block writes the 4-byte error selector at position 0 and the 32-byte offset at position 4, then reverts with 36 bytes of data. This matches the ABI encoding for a custom error with a single `uint256` parameter (selector + one word, where the selector is 4 bytes and the parameter starts at byte 4).

Note: `mstore(0, errorSelector)` writes the `bytes4` value left-aligned into a 32-byte word at position 0 (bytes 0-31), and then `mstore(4, errorOffset)` overwrites bytes 4-35 with the `errorOffset` value. This means bytes 0-3 contain the selector and bytes 4-35 contain the offset value, which is the correct encoding for `revert CustomError(uint256)`. The `"memory-safe"` annotation is correct since scratch space usage is permitted.

**Severity:** INFO — No issue found.

---

### 4. [INFO] Revert mechanism uses custom errors correctly

**Lines:** 26-35

**Analysis:** The `handleErrorSelector` function reverts using a raw error selector passed by the caller, not a string message. This is consistent with the project convention of using custom errors rather than string reverts. The error selector is provided by the caller (e.g., from sub-parser dispatch in `LibParseLiteralDecimal.sol` line 22), and the revert encoding matches the custom error ABI format. The zero-selector check (line 27: `if (errorSelector != 0)`) correctly treats a zero selector as "no error" and returns without reverting.

**Severity:** INFO — Compliant with project conventions.

---

## Summary

`LibParseError.sol` is a small, focused utility library with only two functions, both used exclusively for error reporting during parsing. No security vulnerabilities were identified. The assembly blocks are correctly annotated as memory-safe and use appropriate memory regions. The library is used extensively across the parser codebase (11+ calling files) for consistent error offset reporting. All usage patterns pass through `revert` with custom errors, consistent with project conventions.

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 4 |
