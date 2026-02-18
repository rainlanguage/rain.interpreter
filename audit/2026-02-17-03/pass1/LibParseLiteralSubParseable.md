# Pass 1 (Security) - LibParseLiteralSubParseable.sol

## Evidence of Thorough Reading

**Contract/Library name:** `LibParseLiteralSubParseable` (line 14)

**Functions:**
| Function | Line | Visibility |
|----------|------|------------|
| `parseSubParseable(ParseState memory, uint256, uint256)` | 30 | `internal view` |

**Errors/Events/Structs defined in this file:** None. Two errors are imported from `ErrParse.sol`:
- `UnclosedSubParseableLiteral(uint256 offset)` (used at line 70)
- `SubParseableMissingDispatch(uint256 offset)` (used at line 48)

**Using declarations (lines 15-18):**
- `using LibParse for ParseState;` (line 15) -- **unused** in this file
- `using LibParseInterstitial for ParseState;` (line 16)
- `using LibParseError for ParseState;` (line 17)
- `using LibSubParse for ParseState;` (line 18)

**Imports (lines 5-12):** `ParseState`, `LibParse`, `UnclosedSubParseableLiteral`, `SubParseableMissingDispatch`, `CMASK_WHITESPACE`, `CMASK_SUB_PARSEABLE_LITERAL_END`, `LibParseInterstitial`, `LibParseError`, `LibSubParse`, `LibParseChar`.

---

## Findings

### 1. Out-of-bounds memory read when input has no closing bracket

**Severity:** LOW

**Location:** Lines 60-71

**Description:** When `skipMask` on line 60 scans the body and reaches `end` without finding a `]` character, `cursor` equals `end`. At line 67, the assembly block reads `mload(cursor)` where `cursor == end`, which is one byte past the last valid data byte. This reads whatever happens to be in adjacent memory.

In the normal case, the byte read will not be `]` and the function correctly reverts with `UnclosedSubParseableLiteral`. However, if the memory immediately following the parse data happens to contain the byte `0x5D` (`]`) at the correct position, the check on line 69 would incorrectly pass, treating adjacent memory contents as if they were a valid closing bracket.

This is classified as LOW because:
- The parser operates on well-structured `bytes` data in memory, so `end` typically points at valid Solidity-managed memory (e.g., another allocation's length prefix or data).
- The probability of `0x5D` appearing in exactly the right byte position is low but nonzero.
- Even if the check passes, the body boundaries (`bodyStart` to `bodyEnd`) and the subsequent `subParseLiteral` call would still operate on the intended data range, so the practical impact is limited to accepting input that should have been rejected, plus advancing the cursor one byte past `end`.

**Recommendation:** Add an explicit `cursor < end` check before reading the final character, or check `cursor == end` and revert with `UnclosedSubParseableLiteral` before entering the assembly block:

```solidity
if (cursor >= end) {
    revert UnclosedSubParseableLiteral(state.parseErrorOffset(cursor));
}
```

---

### 2. Entire function body in unchecked block

**Severity:** LOW

**Description:** The entire function body (lines 35-78) is wrapped in `unchecked`. The two `++cursor` operations (lines 39 and 75) perform unchecked addition on a memory pointer. If `cursor` were `type(uint256).max`, `++cursor` would wrap to 0. In practice, `cursor` is a Solidity memory pointer (well below `type(uint256).max`), so this cannot occur under normal EVM operation.

The `unchecked` block also covers the subtraction `dispatchEnd - dispatchStart` and `bodyEnd - bodyStart` inside `subParseLiteral` (called on line 77, computed in `LibSubParse.sol` line 346-347). These subtractions are safe because `dispatchEnd >= dispatchStart` and `bodyEnd >= bodyStart` are guaranteed by the forward-only cursor movement of `skipMask`.

**Classification rationale:** LOW because the unchecked arithmetic is safe given the invariants maintained by `skipMask` and EVM memory pointer ranges, but the broad `unchecked` scope makes it harder to verify safety if the function is modified in the future.

---

### 3. Assembly block memory safety annotation

**Severity:** INFO

**Location:** Lines 65-68

**Description:** The assembly block is marked `"memory-safe"`. The block performs `mload(cursor)` which is a read-only operation and does not modify memory, so the annotation is correct. The `mload` at position `cursor` may read past the logical end of the data (as described in Finding 1), but this is a read, not a write, so it does not corrupt memory and does not violate the `memory-safe` contract.

---

### 4. No string revert messages

**Severity:** INFO

**Description:** All error paths use custom error types (`SubParseableMissingDispatch` at line 48, `UnclosedSubParseableLiteral` at line 70). No string revert messages are used. This conforms to the project convention.

---

### 5. Unused `using` declaration

**Severity:** INFO

**Location:** Line 15

**Description:** `using LibParse for ParseState;` is declared but no function from `LibParse` is called in this file. This has no security impact but adds unnecessary bytecode/compilation overhead.

---

### 6. Caller trust for opening bracket

**Severity:** INFO

**Location:** Lines 36-39

**Description:** The comment on lines 37-38 states "Caller is responsible for checking that the cursor is pointing at a sub parseable literal." The function unconditionally increments the cursor past the assumed `[` on line 39 without verifying the character. If a caller invokes `parseSubParseable` when the cursor is not at `[`, the function will silently consume an arbitrary byte and attempt to parse what follows as a sub-parseable literal.

This is by design (the caller is trusted), but it means the function's correctness depends on all call sites verifying the precondition. This is an internal function, so the trust boundary is appropriate.
