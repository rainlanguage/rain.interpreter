# Pass 1 (Security) — LibParseStackName.sol

## Evidence of Thorough Reading

**Library name:** `LibParseStackName` (line 21)

**Functions:**

| Function | Line | Visibility |
|----------|------|------------|
| `pushStackName(ParseState memory state, bytes32 word)` | 31 | `internal pure` |
| `stackNameIndex(ParseState memory state, bytes32 word)` | 62 | `internal pure` |

**Errors/Events/Structs defined:** None. The library imports `ParseState` from `LibParseState.sol` but defines no errors, events, or structs of its own.

---

## Findings

### 1. Fingerprint computed differently in `pushStackName` vs `stackNameIndex` (but consistent)

**Severity:** INFO

**Location:** Lines 40 and 69

In `pushStackName` (line 40):
```solidity
fingerprint := and(keccak256(0, 0x20), not(0xFFFFFFFF))
```
This zeroes out the low 32 bits, keeping the fingerprint in bits [255:32].

In `stackNameIndex` (line 69):
```solidity
fingerprint := shr(0x20, keccak256(0, 0x20))
```
This right-shifts by 32, placing the fingerprint in bits [223:0].

These produce different numeric values from the same hash, but the comparison at line 79 compensates correctly:
```solidity
if eq(fingerprint, shr(0x20, stackNames))
```
This shifts the stored node (which has fingerprint in bits [255:32]) right by 32, aligning it with the `stackNameIndex` fingerprint in bits [223:0]. The comparison is therefore correct.

While functionally correct, using two different representations of the same logical value across functions is error-prone for future maintainers. A comment explaining why they differ would reduce the risk of accidental breakage.

### 2. Bloom filter pollution from external `stackNameIndex` calls

**Severity:** INFO

**Location:** Line 87

`stackNameIndex` unconditionally updates the bloom filter at line 87:
```solidity
state.stackNameBloom = bloom | stackNameBloom;
```
This occurs even when the word is not found in the linked list.

`LibParse.sol` (line 228) calls `stackNameIndex` directly during RHS word resolution. When an RHS word is not a stack name and falls through to sub-parser handling, the bloom filter has already been polluted with the fingerprint of that word. This increases false positive rate on subsequent bloom checks.

This is not a correctness issue — false positives only cause unnecessary linked list traversals, which are cheap given the small n. It is a minor performance degradation.

### 3. 16-bit pointer truncation guarded post-hoc, not pre-check

**Severity:** INFO

**Location:** Lines 41-43 (allocation) and `RainterpreterParser.sol` lines 46-53

`pushStackName` stores the free memory pointer in the low 16 bits of the node (line 48). If the free memory pointer exceeds `0xFFFF`, the pointer would be silently truncated. The `ParseMemoryOverflow` check in `RainterpreterParser.sol` catches this *after* parsing completes via `checkParseMemoryOverflow` modifier.

This means during parsing, if memory crosses 0x10000, linked list pointers are temporarily corrupted. However, the entire transaction reverts, so no corrupted state is persisted. This is adequate because the parser runs in a pure context and the revert undoes all state changes.

### 4. Assembly `memory-safe` annotation with linked-list pointer reads

**Severity:** LOW

**Location:** Lines 67-86

The assembly block in `stackNameIndex` is marked `memory-safe`, but it reads from arbitrary memory addresses derived from the linked list (`mload(ptr)` at line 76). The `ptr` values come from the low 16 bits of previously stored nodes.

These pointers were allocated by `pushStackName` and are within allocated memory, so the reads are safe in practice. However, the Solidity compiler's optimizer relies on the `memory-safe` annotation to assume the assembly block only accesses scratch space (0x00-0x3F), the free memory pointer (0x40), and allocated memory beyond the free memory pointer. Reading from previously allocated memory within the managed heap is technically within the "memory-safe" contract, but the compiler has no way to verify the pointers are valid.

If a bug elsewhere corrupts a node's pointer field, this block would silently read from arbitrary memory without any bounds check. The 16-bit pointer constraint (max 0xFFFF) and the `ParseMemoryOverflow` guard limit the blast radius.

### 5. No explicit overflow guard on `stackLHSIndex`

**Severity:** INFO

**Location:** Line 47-49

```solidity
uint256 stackLHSIndex = state.topLevel1 & 0xFF;
state.stackNames = fingerprint | (stackLHSIndex << 0x10) | ptr;
index = stackLHSIndex + 1;
```

`stackLHSIndex` is masked to 8 bits (max 255). When shifted left by 0x10 (16 bits), this occupies bits [23:16] at most, which fits within the 16-bit field allocated at bits [31:16]. The `+ 1` on line 49 could make `index` = 256, but since `index` is a `uint256` return value (not packed into the node), no overflow occurs.

The entire function body is wrapped in `unchecked` (line 32), but no arithmetic here can actually overflow a `uint256`. The masking ensures `stackLHSIndex` is bounded, and the addition of 1 to at most 255 produces at most 256, well within `uint256` range.

No issue found; the `unchecked` block is safe here.

### 6. No custom error reverts in this library

**Severity:** INFO

**Location:** Entire file

This library contains no `revert` statements at all. It relies on its callers to validate inputs. This is consistent with the library's role as a low-level data structure utility. The `ParseMemoryOverflow` check is in `RainterpreterParser.sol`, not here.

No violation of the "custom errors only" convention since there are no reverts to check.

---

## Summary

No CRITICAL, HIGH, or MEDIUM findings. The library is compact and well-structured. The main observations are:

- The dual fingerprint representation (masked vs shifted) is correct but could benefit from a clarifying comment.
- Bloom filter pollution from direct `stackNameIndex` calls is a minor performance concern, not a security issue.
- The 16-bit pointer safety relies on a post-hoc guard in the caller, which is adequate given the pure/revert semantics.
- The `memory-safe` annotation is technically correct but relies on invariants maintained by the caller.
